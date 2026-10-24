package vn.edu.fpt.cinemamanagement.exception;

import org.springframework.http.HttpStatus;

/** Lỗi nghiệp vụ khi giữ/nhả ghế. {@code code} ổn định để client phân nhánh. */
public class SeatHoldException extends RuntimeException {
    private final HttpStatus status;
    private final String code;

    public SeatHoldException(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getCode() {
        return code;
    }
}
