package vn.edu.fpt.cinemamanagement.controller.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.edu.fpt.cinemamanagement.dto.request.CustomerBookingRequestDTO;
import vn.edu.fpt.cinemamanagement.repositories.CustomerRepository;
import vn.edu.fpt.cinemamanagement.services.CustomerBookingService;

import java.security.Principal;
import java.util.Map;

@RestController
@RequestMapping("/api/customer/bookings")
public class CustomerBookingRestController {
    private final CustomerBookingService bookingService;
    private final CustomerRepository customerRepository;

    public CustomerBookingRestController(CustomerBookingService bookingService, CustomerRepository customerRepository) {
        this.bookingService = bookingService;
        this.customerRepository = customerRepository;
    }

    @PostMapping("/preview")
    public ResponseEntity<?> preview(Principal principal, @RequestBody CustomerBookingRequestDTO request) {
        if (customerId(principal) == null) return unauthorized();
        try {
            return ResponseEntity.ok(bookingService.preview(request));
        } catch (IllegalArgumentException exception) {
            return ResponseEntity.badRequest().body(Map.of("message", exception.getMessage()));
        }
    }

    private String customerId(Principal principal) {
        if (principal == null) return null;
        return customerRepository.findByUsername(principal.getName()).map(customer -> customer.getUser_id()).orElse(null);
    }

    private ResponseEntity<Map<String, String>> unauthorized() {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "Tài khoản khách hàng không hợp lệ."));
    }

}
