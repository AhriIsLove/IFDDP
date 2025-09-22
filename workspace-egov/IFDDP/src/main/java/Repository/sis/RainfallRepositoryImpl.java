package Repository.sis;

import java.util.List;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;
import Dto.nkm.MarkerDTO;
import lombok.RequiredArgsConstructor;

@Repository("rainfallRepository")
@RequiredArgsConstructor
public class RainfallRepositoryImpl implements RainfallRepository {
    
    private final SqlSession sqlSession;
    
    @Override
    public List<MarkerDTO> getMapoFacilities() {
        List<MarkerDTO> markers = null;
        
        try {
            // SELECT : 마포구 시설물 데이터 (좌표 포함)
            markers = sqlSession.selectList("Rainfall.getMapoFacilities");
            System.out.println("마포구 시설물 조회 성공: " + markers.size() + "개");
            
        } catch (Exception e) {
            System.err.println("마포구 시설물 조회 실패");
            System.err.println(e.getMessage());
            e.printStackTrace();
        }
        
        return markers;
    }
    
    @Override
    public List<MarkerDTO> getFacilitiesByRegion(String region) {
        List<MarkerDTO> markers = null;
        
        try {
            // SELECT : 특정 지역 시설물 데이터
            markers = sqlSession.selectList("Rainfall.getFacilitiesByRegion", region);
            System.out.println(region + " 시설물 조회 성공: " + markers.size() + "개");
            
        } catch (Exception e) {
            System.err.println(region + " 시설물 조회 실패");
            System.err.println(e.getMessage());
            e.printStackTrace();
        }
        
        return markers;
    }
    
    @Override
    public List<MarkerDTO> getFacilitiesWithCoordinates() {
        List<MarkerDTO> markers = null;
        
        try {
            // SELECT : 좌표 정보가 있는 시설물만
            markers = sqlSession.selectList("Rainfall.getFacilitiesWithCoordinates");
            System.out.println("좌표 포함 시설물 조회 성공: " + markers.size() + "개");
            
        } catch (Exception e) {
            System.err.println("좌표 포함 시설물 조회 실패");
            System.err.println(e.getMessage());
            e.printStackTrace();
        }
        
        return markers;
    }
}