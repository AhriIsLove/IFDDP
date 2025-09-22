package Dto.sis;

import java.util.Date;

public class FacilityDamageDTO {
    
    /** 시설물 ID */
    private int facilityId;
    
    /** 시설물명 */
    private String facilityName;
    
    /** 시설물 주소 */
    private String address;
    
    /** 손상 ID */
    private int damageId;
    
    /** 손상 유형 코드 */
    private int damageType;
    
    /** 손상 유형명 */
    private String damageTypeName;
    
    /** 손상 위험도 */
    private String damageImpact;
    
    /** 심각도 */
    private String severity;
    
    /** 손상 건수 */
    private int damageCnt;
    
    /** 설명 */
    private String description;
    
    /** 점검자 ID */
    private String inspectorId;
    
    /** 신고일자 */
    private Date reportedDate;
    
    // 기본 생성자
    public FacilityDamageDTO() {}
    
    // Getter, Setter
    public int getFacilityId() {
        return facilityId;
    }
    
    public void setFacilityId(int facilityId) {
        this.facilityId = facilityId;
    }
    
    public String getFacilityName() {
        return facilityName;
    }
    
    public void setFacilityName(String facilityName) {
        this.facilityName = facilityName;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public int getDamageId() {
        return damageId;
    }
    
    public void setDamageId(int damageId) {
        this.damageId = damageId;
    }
    
    public int getDamageType() {
        return damageType;
    }
    
    public void setDamageType(int damageType) {
        this.damageType = damageType;
    }
    
    public String getDamageTypeName() {
        return damageTypeName;
    }
    
    public void setDamageTypeName(String damageTypeName) {
        this.damageTypeName = damageTypeName;
    }
    
    public String getDamageImpact() {
        return damageImpact;
    }
    
    public void setDamageImpact(String damageImpact) {
        this.damageImpact = damageImpact;
    }
    
    public String getSeverity() {
        return severity;
    }
    
    public void setSeverity(String severity) {
        this.severity = severity;
    }
    
    public int getDamageCnt() {
        return damageCnt;
    }
    
    public void setDamageCnt(int damageCnt) {
        this.damageCnt = damageCnt;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getInspectorId() {
        return inspectorId;
    }
    
    public void setInspectorId(String inspectorId) {
        this.inspectorId = inspectorId;
    }
    
    public Date getReportedDate() {
        return reportedDate;
    }
    
    public void setReportedDate(Date reportedDate) {
        this.reportedDate = reportedDate;
    }
    
    @Override
    public String toString() {
        return "FacilityDamageDTO{" +
                "facilityId=" + facilityId +
                ", facilityName='" + facilityName + '\'' +
                ", address='" + address + '\'' +
                ", damageId=" + damageId +
                ", damageType=" + damageType +
                ", damageTypeName='" + damageTypeName + '\'' +
                ", damageImpact='" + damageImpact + '\'' +
                ", severity='" + severity + '\'' +
                ", damageCnt=" + damageCnt +
                ", description='" + description + '\'' +
                ", inspectorId=" + inspectorId +
                ", reportedDate=" + reportedDate +
                '}';
    }
}    

