package vn.edu.fpt.cinemamanagement.services;

import jakarta.transaction.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import vn.edu.fpt.cinemamanagement.dto.request.SeatHoldRequestDTO;
import vn.edu.fpt.cinemamanagement.dto.response.SeatHoldResponseDTO;
import vn.edu.fpt.cinemamanagement.entities.ShowtimeSeat;
import vn.edu.fpt.cinemamanagement.enums.BookingStatus;
import vn.edu.fpt.cinemamanagement.enums.SeatStatus;
import vn.edu.fpt.cinemamanagement.exception.SeatHoldException;
import vn.edu.fpt.cinemamanagement.repositories.ShowtimeRepository;
import vn.edu.fpt.cinemamanagement.repositories.ShowtimeSeatRepository;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Giữ ghế tạm thời cho khách trước khi tạo booking (UC-16).
 *
 * <p>Trạng thái ghế PENDING được ghi xuống DB trong transaction có khóa hàng
 * ({@link ShowtimeSeatRepository#findByShowtimeIdAndIdsForUpdate}) nên hai khách
 * không thể giữ trùng ghế. DB hiện chưa có bảng hold, vì vậy thông tin hold
 * (chủ sở hữu, hạn giữ) nằm trong bộ nhớ, giống cache idempotency của
 * {@code CustomerBookingRestController}; ghế mồ côi sau khi khởi động lại được
 * dọn bởi {@link #releaseOrphanPendingSeats()}.</p>
 */
@Service
public class CustomerSeatHoldService {
    public static final Duration HOLD_DURATION = Duration.ofMinutes(5);
    public static final int MAX_SEATS_PER_HOLD = 8;

    private final ShowtimeRepository showtimeRepository;
    private final ShowtimeSeatRepository showtimeSeatRepository;
    private final Map<String, SeatHold> holds = new ConcurrentHashMap<>();

    public CustomerSeatHoldService(
            ShowtimeRepository showtimeRepository,
            ShowtimeSeatRepository showtimeSeatRepository
    ) {
        this.showtimeRepository = showtimeRepository;
        this.showtimeSeatRepository = showtimeSeatRepository;
    }

    @Transactional
    public synchronized SeatHoldResponseDTO hold(String customerId, SeatHoldRequestDTO request) {
        validateRequest(request);
        String showtimeId = request.showtimeId().trim();
        List<String> seatIds = uniqueSeatIds(request.showtimeSeatIds());
        if (showtimeRepository.findByShowtimeId(showtimeId) == null) {
            throw new SeatHoldException(HttpStatus.NOT_FOUND, "SHOWTIME_NOT_FOUND", "Không tìm thấy suất chiếu.");
        }

        // Mỗi khách chỉ giữ một nhóm ghế cho một suất chiếu: giữ lại thì thay hold cũ.
        holds.values().stream()
                .filter(hold -> hold.customerId().equals(customerId) && hold.showtimeId().equals(showtimeId))
                .toList()
                .forEach(this::releaseSeats);

        List<ShowtimeSeat> seats = showtimeSeatRepository.findByShowtimeIdAndIdsForUpdate(showtimeId, seatIds);
        if (seats.size() != seatIds.size()) {
            throw new SeatHoldException(HttpStatus.BAD_REQUEST, "INVALID_SEATS", "Một số ghế không thuộc suất chiếu này.");
        }
        List<ShowtimeSeat> unavailable = seats.stream()
                .filter(seat -> seat.getStatus() != SeatStatus.AVAILABLE)
                .toList();
        if (!unavailable.isEmpty()) {
            throw new SeatHoldException(
                    HttpStatus.CONFLICT,
                    "SEAT_UNAVAILABLE",
                    "Ghế không còn trống: " + String.join(", ", unavailable.stream().map(this::seatCode).toList())
            );
        }

        seats.forEach(seat -> seat.setStatus(SeatStatus.PENDING));
        showtimeSeatRepository.saveAll(seats);

        OffsetDateTime now = OffsetDateTime.now();
        SeatHold hold = new SeatHold(
                UUID.randomUUID().toString(),
                customerId,
                showtimeId,
                seatIds,
                now.plus(HOLD_DURATION)
        );
        addHold(hold);
        return hold.toResponse(now);
    }

    @Transactional
    public synchronized void release(String customerId, String holdId) {
        releaseSeats(ownedHold(customerId, holdId));
    }

    @Transactional
    public synchronized int releaseExpiredHolds() {
        OffsetDateTime now = OffsetDateTime.now();
        List<SeatHold> expired = holds.values().stream()
                .filter(hold -> !hold.expiresAt().isAfter(now))
                .toList();
        expired.forEach(this::releaseSeats);
        return expired.size();
    }

    /** Chỉ gọi khi khởi động: lúc đó bộ nhớ chưa có hold nào hợp lệ. */
    @Transactional
    public synchronized int releaseOrphanPendingSeats() {
        return showtimeSeatRepository.releaseOrphanPendingSeats(
                SeatStatus.PENDING, SeatStatus.AVAILABLE, BookingStatus.CANCELLED);
    }

    private SeatHold ownedHold(String customerId, String holdId) {
        SeatHold hold = holdId == null ? null : holds.get(holdId);
        // Không phân biệt "không tồn tại" và "của người khác" để không lộ holdId.
        if (hold == null || !hold.customerId().equals(customerId)) {
            throw new SeatHoldException(HttpStatus.NOT_FOUND, "HOLD_NOT_FOUND", "Không tìm thấy lượt giữ ghế.");
        }
        return hold;
    }

    private void releaseSeats(SeatHold hold) {
        removeHold(hold);
        List<ShowtimeSeat> seats = showtimeSeatRepository.findByShowtimeIdAndIdsForUpdate(
                hold.showtimeId(), hold.seatIds());
        // Chỉ trả ghế còn PENDING; ghế đã được luồng khác chuyển trạng thái thì giữ nguyên.
        List<ShowtimeSeat> released = seats.stream()
                .filter(seat -> seat.getStatus() == SeatStatus.PENDING)
                .toList();
        released.forEach(seat -> seat.setStatus(SeatStatus.AVAILABLE));
        showtimeSeatRepository.saveAll(released);
    }

    // Bộ nhớ không tham gia transaction DB: nếu transaction rollback thì hoàn tác thay đổi.
    private void addHold(SeatHold hold) {
        holds.put(hold.holdId(), hold);
        onRollback(() -> holds.remove(hold.holdId()));
    }

    private void removeHold(SeatHold hold) {
        holds.remove(hold.holdId());
        onRollback(() -> holds.put(hold.holdId(), hold));
    }

    private void onRollback(Runnable action) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) return;
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCompletion(int status) {
                if (status != STATUS_COMMITTED) action.run();
            }
        });
    }

    private void validateRequest(SeatHoldRequestDTO request) {
        if (request == null || request.showtimeId() == null || request.showtimeId().isBlank()) {
            throw new SeatHoldException(HttpStatus.BAD_REQUEST, "INVALID_REQUEST", "Suất chiếu là bắt buộc.");
        }
        if (request.showtimeSeatIds() == null || request.showtimeSeatIds().isEmpty()) {
            throw new SeatHoldException(HttpStatus.BAD_REQUEST, "INVALID_REQUEST", "Vui lòng chọn ít nhất một ghế.");
        }
        if (request.showtimeSeatIds().size() > MAX_SEATS_PER_HOLD) {
            throw new SeatHoldException(HttpStatus.BAD_REQUEST, "INVALID_REQUEST",
                    "Chỉ được giữ tối đa " + MAX_SEATS_PER_HOLD + " ghế.");
        }
    }

    private List<String> uniqueSeatIds(List<String> seatIds) {
        List<String> clean = seatIds.stream()
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(id -> !id.isBlank())
                .distinct()
                .toList();
        if (clean.size() != seatIds.size()) {
            throw new SeatHoldException(HttpStatus.BAD_REQUEST, "INVALID_REQUEST", "Danh sách ghế không hợp lệ.");
        }
        return clean;
    }

    private String seatCode(ShowtimeSeat seat) {
        return seat.getTemplateSeat().getRowLabel() + seat.getTemplateSeat().getSeatNumber();
    }

    private record SeatHold(
            String holdId,
            String customerId,
            String showtimeId,
            List<String> seatIds,
            OffsetDateTime expiresAt
    ) {
        SeatHoldResponseDTO toResponse(OffsetDateTime serverTime) {
            return new SeatHoldResponseDTO(holdId, showtimeId, seatIds, expiresAt, serverTime);
        }
    }
}
