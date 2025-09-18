package Service.adg;

import java.io.IOException;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import Dto.adg.BunryuDto;
import Dto.adg.FacilityDto;

public interface FacilityService {
	// 모든 시설물 조회
	List<FacilityDto> getAllFacilityAllInfo();
	
	// 범위 시설물 조회
	List<FacilityDto> getAllFacility(int page, int size);
	int getAllFacilityCnt();

	// 범위 시설물 검색 조회
	List<FacilityDto> getSearchFacility(FacilityDto facilityDto, int page, int size);
	int getSearchFacilityCnt(FacilityDto facilityDto);
	
	// 모든 시설물 종류
	List<BunryuDto> getAllFacilityType();
	
	// 시설물의 모든 손상 종류
	List<BunryuDto> getDamageTypeOfFacility(int facilityType);
	
	// 시설물 등록
	int registFacility(FacilityDto facilityDto);
	int registFacilitys(MultipartFile file) throws IOException;
	
	// 시설물 조회
	FacilityDto getFacilityById(FacilityDto facilityDto);
	
	// 시설물 손상 이미지
	List<String> getDamageImgOfDamageId(int damageId);
}
