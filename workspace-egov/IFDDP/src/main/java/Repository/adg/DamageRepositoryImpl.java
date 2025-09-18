package Repository.adg;

import java.util.ArrayList;
import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;
import org.springframework.web.multipart.MultipartFile;

import Dto.adg.DamageDto;
import Dto.adg.DamageImgDto;
import Dto.adg.FacilityDto;
import Util.CustomFileUtil;
import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class DamageRepositoryImpl implements DamageRepository {
	private final SqlSession sqlSession;
	private final CustomFileUtil customFileUtil;

	@Override
	public List<Integer> registDamage(int facilityId, List<DamageDto> damageDtos) {
		List<Integer> resultList = new ArrayList<Integer>();//실패 기본 설정
		
//		System.out.println(facilityId);
//		System.out.println(damageDtos);

		try {
			for(DamageDto damageDto : damageDtos) {
				// 시설물 ID 설정
				damageDto.setFacilityId(facilityId);
				
				// INSERT : 손상
				int result = sqlSession.insert("Damage.insertDamage", damageDto);
				
				// 손상 이미지가 없으면 패스
				if(damageDto.getDamageFiles() == null) continue;
				
				// 손상 이미지 추가
				for(int ord = 0; ord < damageDto.getDamageFiles().size(); ord++) {
					MultipartFile file = damageDto.getDamageFiles().get(ord);

//					System.out.println(file);
					
					// 파일 복사
					String fileName = customFileUtil.saveFile(file);
					
					System.out.println(fileName);
					
					// 손상 이미지 삽입용 DTO 생성
					DamageImgDto damageImgDto = DamageImgDto.builder()
							.damageId(result)
							.ord(ord)
							.fileName(fileName)
							.build();
					
					// INSERT : 손상 이미지
					sqlSession.insert("Damage.insertDamageImg", damageImgDto);
				}
				
				resultList.add(damageDto.getDamageId());
			}
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("TT");
			System.out.println(e);
			return resultList;//실패
		}
		
		return resultList;
	}

	@Override
	public int getDamageType(String typeKorean) {
		int type = 0;
		try {
			// SELECT : 시설물 데이터
			type = sqlSession.selectOne("Damage.getDamageType", typeKorean);
			
			// System.out.println(facilityDtos);
		}
		catch (Exception e) {
			// TODO: handle exception
			System.out.println("손상 종류 가져오기 실패");
			System.out.println(e);
		}
		
		return type;
	}
}
