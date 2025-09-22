package Repository.sis;

import java.util.List;
import java.util.Map;
import Dto.sis.FacilityDamageDTO;

/**
 * 시설물 손상 정보 Repository 인터페이스
 */
public interface FacilityDamageRepository {
	
	Map<String, Object> selectFacilityBasicInfo(int facilityId);
    
    /** 시설물 타입 조회 */
    Integer selectFacilityType(int facilityId);

    /** 특정 시설물의 손상 정보 조회 */
    List<FacilityDamageDTO> selectFacilityDamageInfo(int facilityId, int bcd);

    /** 모든 시설물의 손상 정보 조회 */
    List<FacilityDamageDTO> selectAllFacilityDamageInfo();

    /** 손상 유형별 요약 정보 */
    List<Map<String, Object>> getDamageTypeSummary(int facilityId, int bcd, String from, String to);

    /** 주차별 손상 건수 */
    List<Map<String, Object>> getWeeklyDamageCounts(int facilityId, String from, String to);

    /** 주차별 손상 유형 분포 */
    List<Map<String, Object>> getWeeklyTypeDistribution(int facilityId, int bcd, String from, String to);

    /** 주차별 평균 영향도 점수 */
    List<Map<String, Object>> getWeeklyImpactScores(int facilityId, String from, String to);

    /** 시설물 타입명 조회 */
    String getFacilityTypeName(int facilityId);
}
