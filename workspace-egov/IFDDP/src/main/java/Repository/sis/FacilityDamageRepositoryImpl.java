package Repository.sis;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import Dto.sis.FacilityDamageDTO;

/**
 * 시설물 손상 정보 Repository 구현체
 * - MyBatis SqlSession을 직접 사용
 */
@Repository
public class FacilityDamageRepositoryImpl implements FacilityDamageRepository {

    private static final String NAMESPACE = "mappers.FacilityDamageMapper";

    @Autowired
    private SqlSession sqlSession;

    @Override
    public Integer selectFacilityType(int facilityId) {
        return sqlSession.selectOne(NAMESPACE + ".selectFacilityType", facilityId);
    }

    @Override
    public List<FacilityDamageDTO> selectFacilityDamageInfo(int facilityId, int bcd) {
        return sqlSession.selectList(NAMESPACE + ".selectFacilityDamageInfo",
                Map.of("facilityId", facilityId, "bcd", bcd));
    }

    @Override
    public List<FacilityDamageDTO> selectAllFacilityDamageInfo() {
        return sqlSession.selectList(NAMESPACE + ".selectAllFacilityDamageInfo");
    }

    @Override
    public List<Map<String, Object>> getDamageTypeSummary(int facilityId, int bcd, String from, String to) {
        return sqlSession.selectList(NAMESPACE + ".getDamageTypeSummary",
                Map.of("facilityId", facilityId, "bcd", bcd, "from", from, "to", to));
    }

    @Override
    public List<Map<String, Object>> getWeeklyDamageCounts(int facilityId, String from, String to) {
        return sqlSession.selectList(NAMESPACE + ".getWeeklyDamageCounts",
                Map.of("facilityId", facilityId, "from", from, "to", to));
    }

    @Override
    public List<Map<String, Object>> getWeeklyTypeDistribution(int facilityId, int bcd, String from, String to) {
        return sqlSession.selectList(NAMESPACE + ".getWeeklyTypeDistribution",
                Map.of("facilityId", facilityId, "bcd", bcd, "from", from, "to", to));
    }

    @Override
    public List<Map<String, Object>> getWeeklyImpactScores(int facilityId, String from, String to) {
        return sqlSession.selectList(NAMESPACE + ".getWeeklyImpactScores",
                Map.of("facilityId", facilityId, "from", from, "to", to));
    }

    @Override
    public String getFacilityTypeName(int facilityId) {
        return sqlSession.selectOne(NAMESPACE + ".getFacilityTypeName", facilityId);
    }
    
    @Override
    public Map<String, Object> selectFacilityBasicInfo(int facilityId) {
    	System.out.println("kkk FacilityDamageRepositoryImpl selectFacilityBasicInfo facilityId->"+facilityId);
        return sqlSession.selectOne(NAMESPACE + ".selectFacilityBasicInfo", facilityId);
    }
}
