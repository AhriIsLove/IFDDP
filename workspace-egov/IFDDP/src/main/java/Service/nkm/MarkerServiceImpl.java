package Service.nkm;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import Dto.adg.FacilityDto;
import Repository.nkm.MarkerRepository;
import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class MarkerServiceImpl implements MarkerService {
	private final MarkerRepository markerRepository;

	@Override
	public List<FacilityDto> getFacilityMarkers(FacilityDto facilityType) {
		System.out.println("MarkerServiceImpl getFacilityMarkers Start");
		/* List<FacilityDto> markers = markerRepository(facilityType); */
		return markerRepository.getFacilityMarkers(facilityType);
	}
	
	

}
