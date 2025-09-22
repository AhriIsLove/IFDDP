package Service.sis;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import Dto.nkm.MarkerDTO;
import Repository.sis.RainfallRepository;
import lombok.RequiredArgsConstructor;

@Service("rainfallService")
@Transactional
@RequiredArgsConstructor
public class RainfallServiceImpl implements RainfallService {
    
    @Resource(name = "rainfallRepository")
    private RainfallRepository rainfallRepository;

    @Override
    public List<MarkerDTO> getMapoFacilities() {
        System.out.println("RainfallServiceImpl getMapoFacilities Start");
        
        try {
            List<MarkerDTO> facilities = rainfallRepository.getMapoFacilities();
            System.out.println("마포구 시설물 조회 완료: " + facilities.size() + "개");
            return facilities;
            
        } catch (Exception e) {
            System.err.println("마포구 시설물 조회 실패: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    @Override
    public List<MarkerDTO> getFacilitiesByRegion(String region) {
        System.out.println("RainfallServiceImpl getFacilitiesByRegion Start - Region: " + region);
        
        try {
            List<MarkerDTO> facilities = rainfallRepository.getFacilitiesByRegion(region);
            System.out.println(region + " 시설물 조회 완료: " + facilities.size() + "개");
            return facilities;
            
        } catch (Exception e) {
            System.err.println(region + " 시설물 조회 실패: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
}
