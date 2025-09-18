package Service.nkm;

import java.util.List;

import Dto.adg.FacilityDto;

public interface MarkerService {

	List<FacilityDto> getFacilityMarkers(FacilityDto facilityType);

}
