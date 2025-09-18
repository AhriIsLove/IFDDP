package Dto.adg;

import java.util.Date;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.multipart.MultipartFile;

import lombok.Builder;
import lombok.Data;

@Data
public class DamageDto {
	private int damageId; // 손상 식별자
	private int facilityId; // 시설물 식별자
	private int damageType; // 손상 종류
	private int severity; // 손상 위험도
	private int damageCnt; // 손상 객체 수
	private String description; // 손상 상세 설명
	private String inspectorId; // 검사관 ID
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date reportedDate; // 평가 실시일

	private String damageTypeKorean;
	
	//손상 이미지 파일
    private List<MultipartFile> damageFiles;
}
