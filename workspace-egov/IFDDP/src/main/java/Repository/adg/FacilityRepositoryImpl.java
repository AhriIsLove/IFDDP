package Repository.adg;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import Dto.adg.BunryuDto;
import Dto.adg.FacilityDto;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class FacilityRepositoryImpl implements FacilityRepository {
	private final SqlSession sqlSession;

	@Override
	public List<FacilityDto> getAllFacilityAllInfo() {
		List<FacilityDto> facilityDtos = null;
		
		try {
			// SELECT : 시설물 데이터
			facilityDtos = sqlSession.selectList("Facility.getAllFacilityAllInfo");
			
			System.out.println(facilityDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("모든 시설물 모든 정보 가져오기 실패");
		}
		
		return facilityDtos;
	}

	@Override
	public List<FacilityDto> getAllFacility(int page, int size) {
		// 리턴용 데이터 설정
		List<FacilityDto> facilityDtos = null;
		
		// 파라미터 설정
		Map<String, Object> params = new HashMap<>();
		params.put("page", page);
		params.put("size", size);
		
		try {
			// SELECT : 시설물 데이터
			facilityDtos = sqlSession.selectList("Facility.getAllFacility", params);
			
			// System.out.println(facilityDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 가져오기 실패");
		}

		return facilityDtos;
	}
	@Override
	public int getAllFacilityCnt() {
		int cnt = 0;
		try {
			// SELECT : 시설물 데이터
			cnt = sqlSession.selectOne("Facility.getAllFacilityCnt");
			
			// System.out.println(facilityDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 개수 가져오기 실패");
		}
		
		return cnt;
	}

	@Override
	public List<FacilityDto> getSearchFacility(FacilityDto facilityDto, int page, int size) {
		// 리턴용 데이터 설정
		List<FacilityDto> facilityDtos = null;
		
		// 파라미터 설정
		Map<String, Object> params = new HashMap<>();
		params.put("facilityDto", facilityDto);
		params.put("page", page);
		params.put("size", size);
		
		try {
			// SELECT : 시설물 데이터
			facilityDtos = sqlSession.selectList("Facility.getSearchFacility", params);
			
			// System.out.println(facilityDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 검색 가져오기 실패");
			System.out.println(e);
		}

		return facilityDtos;
	}
	@Override
	public int getSearchFacilityCnt(FacilityDto facilityDto) {
		int cnt = 0;
		try {
			// SELECT : 시설물 데이터
			cnt = sqlSession.selectOne("Facility.getSearchFacilityCnt", facilityDto);
			
			// System.out.println(facilityDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 검색 개수 가져오기 실패");
			System.out.println(e);
		}
		
		return cnt;
	}

	@Override
	public List<BunryuDto> getAllFacilityType() {
		// 리턴용 데이터 설정
		List<BunryuDto> bunryuDtos = null;
		
		try {
			// SELECT : 시설물의 모든 종류
			bunryuDtos = sqlSession.selectList("Facility.getAllFacilityType");
			
			// System.out.println(bunryuDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 모든 종류 가져오기 실패");
		}

		return bunryuDtos;
	}
	@Override
	public int getFacilityType(String typeKorean) {
		int type = 0;
		try {
			// SELECT : 시설물 데이터
			type = sqlSession.selectOne("Facility.getFacilityType", typeKorean);
			
			// System.out.println(facilityDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 종류 가져오기 실패");
			System.out.println(e);
		}
		
		return type;
	}

	@Override
	public List<BunryuDto> getDamageTypeOfFacility(int facilityType) {
		// 리턴용 데이터 설정
		List<BunryuDto> bunryuDtos = null;
		
		try {
			// SELECT : 시설물 종류의 모든 손상 종류
			bunryuDtos = sqlSession.selectList("Facility.getDamageTypeOfFacility", facilityType);
			
			// System.out.println(bunryuDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 종류의 모든 손상 종류 가져오기 실패");
		}

		return bunryuDtos;
	}

	@Override
	public int registFacility(FacilityDto facilityDto) {
		int result = 0;//실패 기본 설정
		
		try {
			System.out.println(facilityDto);
			// INSERT : 시설물
			sqlSession.insert("Facility.insertFacility", facilityDto);
			
			// 삽입한 시설물 ID
			result = facilityDto.getFacilityId();
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("TT");
			System.out.println(e);
			return result;//실패
		}
		
		return result;
	}

	@Override
	public FacilityDto getFacilityById(FacilityDto p_FacilityDto) {
		FacilityDto facilityDto = null;
		try {
			// SELECT : 시설물 데이터
			facilityDto = sqlSession.selectOne("Facility.getFacilityById", p_FacilityDto);
			
			System.out.println(facilityDto);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("시설물 조회 실패");
			System.out.println(e);
		}
		
		return facilityDto;
	}
}
