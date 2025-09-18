package Dto.adg;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Data;

@Data
public class FacilityDto {
	// Entity
	private int 	facilityId; // 시설물 식별자
	private String 	facilityName; // 시설물 이름
	private int 	facilityType; // 시설물 종류
	private int 	facilityScale; // 시설물 규모
	private String 	geom; // 시설물 위치 좌표
	private String 	region; // 시설물 지역
	private String 	address; // 시설물 상세 주소
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date 	yearBuilt; // 준공년도
	
//	등록용 DTO
	private String regionSido;
	private String regionSigungu;
	private double facilityGeomX;
	private double facilityGeomY;
	
	// 표시용 한글 전환
	private String facilityTypeKorean;
	private String facilityScaleKorean;
	// 조인용 손상 정보
	private String damageTypeKorean;
	private int severity;
	private int damageCnt;
	private String inspectorId;
	private String description;
	private String reportedDate;
	
	// 검색용 DTO
	private String 	searchType; // 검색조건
	private String 	searchValue; // 검색어
	
	// 손상정보
	private List<DamageDto> damageList = new ArrayList<>();
}
