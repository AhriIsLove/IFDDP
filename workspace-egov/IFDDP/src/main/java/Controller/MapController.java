package Controller;
	
	
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StreamUtils;
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
@RequiredArgsConstructor
@RequestMapping("/map")
public class MapController {
	
	    @Autowired
		private final MarkerService markerService;
	                  
		// 테스트
	    @GetMapping("/view.do")
	    public String mapView(Model model) {
	    	
			/*
			 * // SHP → GeoServer에서 GeoJSON으로 접근 가능하다고 가정 String geoJsonUrl =
			 * "http://localhost:8081/geoserver/mapo/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=mapo:n3a_a0070000&outputFormat=application/json&srsName=EPSG:4326";
			 * 
			 * model.addAttribute("geoJsonUrl", geoJsonUrl);
			 */
	    	
	    	// webapp/resources/data/mapoDong.geojson를 읽을 수 있는 URL
			/*
			 * String geoJsonUrl = "/data/mapoDong.geojson"; // ResourceHandler 설정 필요
			 * model.addAttribute("geoJsonUrl", geoJsonUrl);
			 */
	    	System.out.println("--- view.do   End  ----");
	    	
	        return "map"; // map.jsp
	    }
	    
	    // 사회기반시설물 선택 후 마커 가져오기
	    @PostMapping("/facility.do")
	    @ResponseBody
	    public Map<String, Object> facility(@RequestBody FacilityDto facilityType) {
	    	System.out.println("MapController facility facilityType->"+facilityType);
	    	// 사회기반시설물 종류에 따른 좌표 리스트 가져오기
	    	List<MarkerDTO> markers = markerService.getFacilityMarkers(facilityType);
	    	System.out.println("MapController facility markers->"+markers);
	    	
	    	Map<String, Object> result = new HashMap<String, Object>();
	    	result.put("totalCount", markers.size());
	    	result.put("markers", markers);
	    	
	    	return result;
	    }


	}
