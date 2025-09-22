package Service.sis;

import java.util.List;

import Dto.nkm.MarkerDTO;

public interface RainfallService {
    /**
     * 마포구 시설물 조회
     * @return 마포구에 위치한 시설물 목록 (좌표 포함)
     */
    List<MarkerDTO> getMapoFacilities();
    
    /**
     * 특정 지역의 시설물 조회
     * @param region 지역명
     * @return 해당 지역의 시설물 목록
     */
    List<MarkerDTO> getFacilitiesByRegion(String region);
}