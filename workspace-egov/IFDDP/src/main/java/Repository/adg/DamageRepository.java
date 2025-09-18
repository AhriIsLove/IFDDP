package Repository.adg;

import java.util.List;

import Dto.adg.DamageDto;

public interface DamageRepository {
	// 시설물 등록
	List<Integer> registDamage(int facilityId, List<DamageDto> damageDtos);
	
	// 손상 종류(String -> int)
	int getDamageType(String typeKorean);
}
