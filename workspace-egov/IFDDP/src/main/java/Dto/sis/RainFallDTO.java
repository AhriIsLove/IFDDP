package Dto.sis;

/**
 * 강우량 정보 DTO
 */
public class RainFallDTO {
    
    private int rainFallId;          // 강우량 ID
    private String stationName;      // 관측소명
    private String stationCode;      // 관측소 코드
    private String measureDate;      // 측정 날짜
    private String measureTime;      // 측정 시간
    private Double rainfall;         // 강우량 (mm)
    private Double temperature;      // 온도 (℃)
    private Double humidity;         // 습도 (%)
    private String weatherCondition; // 날씨 상태
    private String address;          // 관측소 주소
    private Double latitude;         // 위도
    private Double longitude;        // 경도
    private String createdDate;      // 생성일
    private String updatedDate;      // 수정일
    
    // 기본 생성자
    public RainFallDTO() {}
    
    // 생성자
    public RainFallDTO(int rainFallId, String stationName, String stationCode, 
                       String measureDate, String measureTime, Double rainfall) {
        this.rainFallId = rainFallId;
        this.stationName = stationName;
        this.stationCode = stationCode;
        this.measureDate = measureDate;
        this.measureTime = measureTime;
        this.rainfall = rainfall;
    }
    
    // Getter and Setter methods
    public int getRainFallId() {
        return rainFallId;
    }
    
    public void setRainFallId(int rainFallId) {
        this.rainFallId = rainFallId;
    }
    
    public String getStationName() {
        return stationName;
    }
    
    public void setStationName(String stationName) {
        this.stationName = stationName;
    }
    
    public String getStationCode() {
        return stationCode;
    }
    
    public void setStationCode(String stationCode) {
        this.stationCode = stationCode;
    }
    
    public String getMeasureDate() {
        return measureDate;
    }
    
    public void setMeasureDate(String measureDate) {
        this.measureDate = measureDate;
    }
    
    public String getMeasureTime() {
        return measureTime;
    }
    
    public void setMeasureTime(String measureTime) {
        this.measureTime = measureTime;
    }
    
    public Double getRainfall() {
        return rainfall;
    }
    
    public void setRainfall(Double rainfall) {
        this.rainfall = rainfall;
    }
    
    public Double getTemperature() {
        return temperature;
    }
    
    public void setTemperature(Double temperature) {
        this.temperature = temperature;
    }
    
    public Double getHumidity() {
        return humidity;
    }
    
    public void setHumidity(Double humidity) {
        this.humidity = humidity;
    }
    
    public String getWeatherCondition() {
        return weatherCondition;
    }
    
    public void setWeatherCondition(String weatherCondition) {
        this.weatherCondition = weatherCondition;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public Double getLatitude() {
        return latitude;
    }
    
    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }
    
    public Double getLongitude() {
        return longitude;
    }
    
    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }
    
    public String getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }
    
    public String getUpdatedDate() {
        return updatedDate;
    }
    
    public void setUpdatedDate(String updatedDate) {
        this.updatedDate = updatedDate;
    }
    
    @Override
    public String toString() {
        return "RainFallDTO{" +
                "rainFallId=" + rainFallId +
                ", stationName='" + stationName + '\'' +
                ", stationCode='" + stationCode + '\'' +
                ", measureDate='" + measureDate + '\'' +
                ", measureTime='" + measureTime + '\'' +
                ", rainfall=" + rainfall +
                ", temperature=" + temperature +
                ", humidity=" + humidity +
                ", weatherCondition='" + weatherCondition + '\'' +
                ", address='" + address + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", createdDate='" + createdDate + '\'' +
                ", updatedDate='" + updatedDate + '\'' +
                '}';
    }
}
