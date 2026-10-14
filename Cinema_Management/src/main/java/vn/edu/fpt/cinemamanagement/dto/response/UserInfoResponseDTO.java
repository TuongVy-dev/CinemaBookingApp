package vn.edu.fpt.cinemamanagement.dto.response;

public class UserInfoResponseDTO {
    private String userId;
    private String username;
    private String role;
    private String email;
    private String phone;
    private String dob;
    private Boolean sex;

    public UserInfoResponseDTO() {}

    public UserInfoResponseDTO(String userId, String username, String role) {
        this.userId = userId;
        this.username = username;
        this.role = role;
    }

    public UserInfoResponseDTO(String userId, String username, String role, String email, String phone, String dob, Boolean sex) {
        this.userId = userId;
        this.username = username;
        this.role = role;
        this.email = email;
        this.phone = phone;
        this.dob = dob;
        this.sex = sex;
    }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getDob() { return dob; }
    public void setDob(String dob) { this.dob = dob; }
    public Boolean getSex() { return sex; }
    public void setSex(Boolean sex) { this.sex = sex; }
}

