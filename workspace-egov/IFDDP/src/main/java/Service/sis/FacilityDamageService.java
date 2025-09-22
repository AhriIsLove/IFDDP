package Service.sis;

import java.util.List;
import java.util.Map;

import Dto.sis.FacilityDamageDTO;

/**
 * 시설물 손상 정보 서비스 인터페이스
 */
public interface FacilityDamageService {

    /** 특정 시설물의 손상 정보 조회 */
    List<FacilityDamageDTO> getFacilityDamageInfo(int facilityId) throws Exception;

    /** 모든 시설물의 손상 정보 조회 */
    List<FacilityDamageDTO> getAllFacilityDamageInfo() throws Exception;

    /** 특정 시설물의 손상 통계 정보 조회 */
    Map<String, Object> getFacilityDamageStatistics(int facilityId, String from, String to) throws Exception;
}
