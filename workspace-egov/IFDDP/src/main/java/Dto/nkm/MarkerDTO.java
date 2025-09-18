package Dto.nkm;

import java.util.Date;

import lombok.Data;

@Data
public class MarkerDTO {
	private int 	facilityId; 	// 시설물 식별자
	private String 	facilityName; 	// 시설물 이름
	private int 	facilityType; 	// 시설물 종류
	private int 	facilityScale; 	// 시설물 규모
	private String 	geom; 			// 시설물 위치 좌표
	private String 	region; 		// 시설물 지역
	private String 	address; 		// 시설물 상세 주소
	private Date 	yearBuilt; 		// 준공년도
	private int 	severity;		// 손상 위험도    , JOIN
}
