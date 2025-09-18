package Repository.nkm;

import java.util.List;

import Dto.adg.FacilityDto;

public interface MarkerRepository {

	List<FacilityDto> getFacilityMarkers(FacilityDto facilityType);

}
