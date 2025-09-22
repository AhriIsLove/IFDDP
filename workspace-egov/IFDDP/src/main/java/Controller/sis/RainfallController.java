package Controller.sis;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import Dto.adg.FacilityDto;
import Dto.nkm.MarkerDTO;
import Service.nkm.MarkerService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/rainfall")
@RequiredArgsConstructor
public class RainfallController {
    
    @Resource
    private MarkerService markerService;
    
    /**
     * 강수량 모니터링 메인 페이지
     */
    @GetMapping("/agingfattern.do")
    public String showRainfallMain(Model model) {
        System.out.println("RainfallController agingfattern Start");
        
        try {
            // MarkerService를 통한 시설물 데이터 가져오기
            FacilityDto facilityType = new FacilityDto();
            facilityType.setFacilityType(0); // 전체 조회
            List<MarkerDTO> facilities = markerService.getFacilityMarkers(facilityType);
            
            model.addAttribute("facilities", facilities);
            model.addAttribute("facilityCount", facilities.size());
            
            System.out.println("시설물 개수: " + facilities.size());
            
        } catch (Exception e) {
            System.err.println("강수량 모니터링 페이지 로드 실패: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("errorMessage", "데이터 로드 중 오류가 발생했습니다.");
        }
        
        return "rainfall/main";
    }
    
    /**
     * 손상진단 시뮬레이션 페이지 (rainFall.jsp)
     */
    @GetMapping("/simulation.do")
    public String showRainfallSimulation(Model model) {
        System.out.println("RainfallController simulation Start");
        
        return "rainFall";
    }
    
    /**
     * 시설물 데이터 조회 API
     * POST와 GET 모두 지원
     */
    @PostMapping(value = "/facilities.do", produces = "application/json")
    @ResponseBody
    public Map<String, Object> getFacilitiesPost(@RequestBody FacilityDto facilityType) {
        return getFacilitiesInternal(facilityType);
    }
    
    /**
     * GET 방식 시설물 데이터 조회 (전체 조회용)
     */
    @GetMapping(value = "/facilities.do", produces = "application/json")
    @ResponseBody
    public Map<String, Object> getFacilitiesGet() {
        // 전체 조회를 위한 기본 FacilityDto 생성
        FacilityDto facilityType = new FacilityDto();
        facilityType.setFacilityType(0); // 전체 조회 (0 = 전체)
        return getFacilitiesInternal(facilityType);
    }
    
    /**
     * 실제 시설물 조회 로직
     */
    private Map<String, Object> getFacilitiesInternal(FacilityDto facilityType) {
        System.out.println("=== RainfallController getFacilitiesInternal 시작 ===");
        System.out.println("RainfallController facility facilityType->"+facilityType);
        
        try {
            // facilityType이 null인 경우 기본값 설정
            if (facilityType == null) {
                facilityType = new FacilityDto();
                facilityType.setFacilityType(0); // 전체 조회 (0 = 전체)
                System.out.println("facilityType이 null이어서 기본값으로 설정: 0");
            }
            
            System.out.println("현재 facilityType: " + facilityType.getFacilityType());
            
            // MarkerService를 통한 시설물 데이터 조회
            List<MarkerDTO> markers = markerService.getFacilityMarkers(facilityType);
            System.out.println("RainfallController facility markers 개수: " + (markers != null ? markers.size() : 0));
            
            if (markers != null && !markers.isEmpty()) {
                System.out.println("첫 번째 마커: " + markers.get(0));
            }
            
            Map<String, Object> result = new HashMap<String, Object>();
            result.put("totalCount", markers != null ? markers.size() : 0);
            result.put("markers", markers);
            
            System.out.println("=== RainfallController getFacilitiesInternal 완료 ===");
            return result;
            
        } catch (Exception e) {
            System.err.println("RainfallController 시설물 데이터 조회 실패: " + e.getMessage());
            e.printStackTrace();
            
            Map<String, Object> errorResult = new HashMap<String, Object>();
            errorResult.put("totalCount", 0);
            errorResult.put("markers", new java.util.ArrayList<>());
            return errorResult;
        }
    }
}