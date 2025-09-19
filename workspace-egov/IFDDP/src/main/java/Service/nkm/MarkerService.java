package Service.nkm;

import java.util.List;

import Dto.adg.FacilityDto;
import Dto.nkm.MarkerDTO;

public interface MarkerService {

	List<MarkerDTO> getFacilityMarkers(FacilityDto facilityType);

}
