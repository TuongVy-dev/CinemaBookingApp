package vn.edu.fpt.cinemamanagement.services;

import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import vn.edu.fpt.cinemamanagement.dto.request.CustomerBookingRequestDTO;
import vn.edu.fpt.cinemamanagement.dto.response.CustomerBookingQuoteResponseDTO;
import vn.edu.fpt.cinemamanagement.entities.Concession;
import vn.edu.fpt.cinemamanagement.entities.ShowtimeSeat;
import vn.edu.fpt.cinemamanagement.entities.Voucher;
import vn.edu.fpt.cinemamanagement.enums.SeatStatus;
import vn.edu.fpt.cinemamanagement.repositories.ConcessionRepository;
import vn.edu.fpt.cinemamanagement.repositories.ShowtimeRepository;
import vn.edu.fpt.cinemamanagement.repositories.ShowtimeSeatRepository;
import vn.edu.fpt.cinemamanagement.repositories.VoucherRepository;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/** Prices every customer selection on the server before persisting a booking. */
@Service
public class CustomerBookingService {
    private final ShowtimeRepository showtimeRepository;
    private final ShowtimeSeatRepository showtimeSeatRepository;
    private final ConcessionRepository concessionRepository;
    private final VoucherRepository voucherRepository;
    private final ISeatPricingService seatPricingService;

    public CustomerBookingService(
            ShowtimeRepository showtimeRepository,
            ShowtimeSeatRepository showtimeSeatRepository,
            ConcessionRepository concessionRepository,
            VoucherRepository voucherRepository,
            ISeatPricingService seatPricingService
    ) {
        this.showtimeRepository = showtimeRepository;
        this.showtimeSeatRepository = showtimeSeatRepository;
        this.concessionRepository = concessionRepository;
        this.voucherRepository = voucherRepository;
        this.seatPricingService = seatPricingService;
    }

    @Transactional
    public CustomerBookingQuoteResponseDTO preview(CustomerBookingRequestDTO request) {
        PricedSelection selection = price(request);
        return selection.toQuote();
    }

    private PricedSelection price(CustomerBookingRequestDTO request) {
        validateRequest(request);
        if (showtimeRepository.findByShowtimeId(request.getShowtimeId()) == null) {
            throw new IllegalArgumentException("Không tìm thấy suất chiếu.");
        }
        List<String> seatIds = uniqueSeatIds(request.getShowtimeSeatIds());
        List<ShowtimeSeat> seats = showtimeSeatRepository.findByShowtimeIdAndIdsForUpdate(
                request.getShowtimeId(), seatIds);
        if (seats.size() != seatIds.size()) throw new IllegalArgumentException("Một số ghế không thuộc suất chiếu này.");
        for (ShowtimeSeat seat : seats) {
            if (seat.getStatus() != SeatStatus.AVAILABLE) {
                throw new IllegalArgumentException("Ghế không còn trống: " + seatCode(seat));
            }
        }

        List<CustomerBookingQuoteResponseDTO.Item> ticketItems = new ArrayList<>();
        BigDecimal ticketSubtotal = BigDecimal.ZERO;
        for (ShowtimeSeat seat : seats) {
            BigDecimal unitPrice = seatPricingService.calculatePrice(seat.getTemplateSeat().getSeatType());
            ticketSubtotal = ticketSubtotal.add(unitPrice);
            ticketItems.add(new CustomerBookingQuoteResponseDTO.Item(
                    "SEAT", seat.getShowtimeSeatID(), seatCode(seat), 1, unitPrice, unitPrice));
        }

        List<ConcessionLine> concessions = new ArrayList<>();
        List<CustomerBookingQuoteResponseDTO.Item> concessionItems = new ArrayList<>();
        BigDecimal concessionSubtotal = BigDecimal.ZERO;
        List<CustomerBookingRequestDTO.ConcessionItemDTO> requestedConcessions =
                request.getConcessions() == null ? List.of() : request.getConcessions();
        for (CustomerBookingRequestDTO.ConcessionItemDTO requested : requestedConcessions) {
            if (requested == null || requested.getConcessionId() == null || requested.getConcessionId().isBlank() || requested.getQuantity() <= 0) {
                throw new IllegalArgumentException("Món ăn/nước uống không hợp lệ.");
            }
            Concession concession = concessionRepository.findById(requested.getConcessionId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy món đã chọn."));
            BigDecimal lineTotal = concession.getPrice().multiply(BigDecimal.valueOf(requested.getQuantity()));
            concessionSubtotal = concessionSubtotal.add(lineTotal);
            concessions.add(new ConcessionLine(concession, requested.getQuantity()));
            concessionItems.add(new CustomerBookingQuoteResponseDTO.Item(
                    "CONCESSION", concession.getConcessionId(), concession.getName(), requested.getQuantity(), concession.getPrice(), lineTotal));
        }

        BigDecimal subtotal = ticketSubtotal.add(concessionSubtotal);
        Voucher voucher = findApplicableVoucher(request.getVoucherCode());
        BigDecimal total = voucher == null ? subtotal : discountedTotal(voucher, subtotal);
        return new PricedSelection(seats, concessions, ticketItems, concessionItems, ticketSubtotal, concessionSubtotal, subtotal, voucher, total);
    }

    private Voucher findApplicableVoucher(String voucherCode) {
        if (voucherCode == null || voucherCode.isBlank()) return null;
        Voucher voucher = voucherRepository.findByVoucherCode(voucherCode.trim().toUpperCase());
        if (voucher == null || !voucher.isStatus() || voucher.getUsedCount() >= voucher.getUsageLimit()) {
            throw new IllegalArgumentException("Voucher không hợp lệ hoặc đã hết lượt sử dụng.");
        }
        return voucher;
    }

    private BigDecimal discountedTotal(Voucher voucher, BigDecimal subtotal) {
        BigDecimal discount = "Percentage".equalsIgnoreCase(voucher.getDiscountType())
                ? subtotal.multiply(BigDecimal.valueOf(voucher.getDiscountValue())).divide(BigDecimal.valueOf(100))
                : BigDecimal.valueOf(voucher.getDiscountValue());
        return subtotal.subtract(discount).max(BigDecimal.ZERO);
    }

    private void validateRequest(CustomerBookingRequestDTO request) {
        if (request == null || request.getShowtimeId() == null || request.getShowtimeId().isBlank()) {
            throw new IllegalArgumentException("Suất chiếu là bắt buộc.");
        }
        if (request.getShowtimeSeatIds() == null || request.getShowtimeSeatIds().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất một ghế.");
        }
    }

    private List<String> uniqueSeatIds(List<String> seatIds) {
        List<String> clean = seatIds.stream().filter(Objects::nonNull).map(String::trim).filter(id -> !id.isBlank()).distinct().toList();
        if (clean.size() != seatIds.size()) throw new IllegalArgumentException("Danh sách ghế không hợp lệ.");
        return clean;
    }

    private String seatCode(ShowtimeSeat seat) { return seat.getTemplateSeat().getRowLabel() + seat.getTemplateSeat().getSeatNumber(); }

    private record ConcessionLine(Concession concession, int quantity) {}
    private record PricedSelection(
            List<ShowtimeSeat> seats, List<ConcessionLine> concessions,
            List<CustomerBookingQuoteResponseDTO.Item> ticketItems,
            List<CustomerBookingQuoteResponseDTO.Item> concessionItems,
            BigDecimal ticketSubtotal, BigDecimal concessionSubtotal, BigDecimal subtotal,
            Voucher voucher, BigDecimal total
    ) {
        CustomerBookingQuoteResponseDTO toQuote() {
            BigDecimal discount = subtotal.subtract(total);
            CustomerBookingQuoteResponseDTO.Voucher voucherData = voucher == null ? null
                    : new CustomerBookingQuoteResponseDTO.Voucher(voucher.getVoucherId(), voucher.getCode(), voucher.getDiscountType(), voucher.getDiscountValue());
            return new CustomerBookingQuoteResponseDTO(ticketItems, concessionItems, ticketSubtotal, concessionSubtotal, subtotal, voucherData, discount, total);
        }
    }
}
