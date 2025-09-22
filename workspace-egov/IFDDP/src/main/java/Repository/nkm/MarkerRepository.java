package Repository.nkm;

import java.util.List;

import Dto.adg.FacilityDto;
import Dto.nkm.MarkerDTO;

public interface MarkerRepository {

	List<MarkerDTO> getFacilityMarkers(FacilityDto facilityType);

}
