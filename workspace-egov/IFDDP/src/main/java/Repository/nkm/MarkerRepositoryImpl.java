package Repository.nkm;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import Dto.adg.FacilityDto;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class MarkerRepositoryImpl implements MarkerRepository {
	private final SqlSession session;

	@Override
	public List<FacilityDto> getFacilityMarkers(FacilityDto facilityType) {
		System.out.println("MarkerRepositoryImpl getFacilityMarkers Start");
		
		List<FacilityDto> markers = null;
		try {
			// 시설물 좌표 가져오기
			// markers = session.selectList("getFacilityMarkers");
			if(facilityType.getFacilityType() == 0) {
				// 전체
				markers = session.selectList("getFacilityMarkersAll");
			} else
				// 사회기반시설물
				markers = session.selectList("getFacilityMarkers" , facilityType);
			
			System.out.println("markers->"+markers);
		} catch (Exception e) {
			System.out.println("MarkerRepositoryImpl getFacilityMarkers Exception->" + e.getMessage());
		}
		
		return markers;
	}

}
