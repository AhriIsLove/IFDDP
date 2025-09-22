package Repository.nkm;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import Dto.adg.FacilityDto;
import Dto.nkm.MarkerDTO;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class MarkerRepositoryImpl implements MarkerRepository {
	private final SqlSession session;

	@Override
	public List<MarkerDTO> getFacilityMarkers(FacilityDto facilityType) {
		System.out.println("MarkerRepositoryImpl getFacilityMarkers Start");
		
		List<MarkerDTO> markers = null;
		try {
			// 시설물 좌표 가져오기
			// markers = session.selectList("getFacilityMarkers");
			if(facilityType.getFacilityType() == 0) {
				// 전체
				System.out.println("MarkerRepositoryImpl getFacilityMarkers 전체 Start");
				markers = session.selectList("K3_getFacilityMarkersAll");
			} else {
				// 사회기반시설물
				System.out.println("MarkerRepositoryImpl getFacilityMarkers 사회기반시설물 Start");
			System.out.println("MarkerRepositoryImpl getFacilityMarkers facilityType->"+facilityType.getFacilityType());
			// markers = session.selectList("getFacilityMarkers" , facilityType.getFacilityType());
			markers = session.selectList("K3_getFacilityMarkers" , facilityType.getFacilityType());
			}
			System.out.println("markers->"+markers);
		} catch (Exception e) {
			System.out.println("MarkerRepositoryImpl getFacilityMarkers Exception->" + e.getMessage());
		}
		
		return markers;
	}

}
