package Service.adg;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.geotools.geometry.DirectPosition2D;
import org.geotools.referencing.CRS;
import org.opengis.referencing.FactoryException;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.opengis.referencing.operation.MathTransform;
import org.opengis.referencing.operation.TransformException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import Dto.adg.BunryuDto;
import Dto.adg.DamageDto;
import Dto.adg.FacilityDto;
import Repository.adg.DamageRepository;
import Repository.adg.FacilityRepository;
import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class FacilityServiceImpl implements FacilityService {
	private final FacilityRepository facilityRepository;
	private final DamageRepository damageRepository;

	@Override
	public List<FacilityDto> getAllFacilityAllInfo() {
		//시설물의 모든 정보를 가져온다.
		return facilityRepository.getAllFacilityAllInfo();
	}
	
	@Override
	public List<FacilityDto> getAllFacility(int page, int size) {
		
		return facilityRepository.getAllFacility(page, size);
	}
	@Override
	public int getAllFacilityCnt() {
		
		return facilityRepository.getAllFacilityCnt();
	}

	@Override
	public List<FacilityDto> getSearchFacility(FacilityDto facilityDto, int page, int size) {
		
		return facilityRepository.getSearchFacility(facilityDto, page, size);
	}
	@Override
	public int getSearchFacilityCnt(FacilityDto facilityDto) {
		
		return facilityRepository.getSearchFacilityCnt(facilityDto);
	}

	@Override
	public List<BunryuDto> getAllFacilityType() {
		
		return facilityRepository.getAllFacilityType();
	}

	@Override
	public List<BunryuDto> getDamageTypeOfFacility(int facilityType) {
		
		return facilityRepository.getDamageTypeOfFacility(facilityType);
	}
	
	@Override
	public int registFacility(FacilityDto facilityDto) {
		// 정상적인 데이터인지 확인
		
		// LatLon -> geom(EPSG:5186) 가공
        try {
            // WGS84 좌표계 (EPSG:4326)
            CoordinateReferenceSystem sourceCRS = CRS.decode("EPSG:4326");
            // 목표 좌표계 (EPSG:5186, 중부원점)
            CoordinateReferenceSystem targetCRS = CRS.decode("EPSG:5186");
            
            // 변환기 생성
            MathTransform transform = CRS.findMathTransform(sourceCRS, targetCRS);
            
            // 위경도 좌표 (경도, 위도 순서)
            double lat = facilityDto.getFacilityGeomX();
            double lon = facilityDto.getFacilityGeomY();
            
            // 변환 실행
            DirectPosition2D srcPoint = new DirectPosition2D(lon, lat);
            DirectPosition2D dstPoint = new DirectPosition2D();
            transform.transform(srcPoint, dstPoint);
            
            // 변환된 좌표 출력
//            System.out.println("변환 결과: X=" + dstPoint.x + ", Y=" + dstPoint.y);
//            System.out.println(dstPoint);//DirectPosition2D[6367142.568326866, 4377658.4916852]

            // INSERT 형태 : ST_SetSRID(ST_MakePoint(126.9002, 37.5779), 5186), 
            facilityDto.setGeom("ST_SetSRID(ST_MakePoint("+ lon + ", " + lat + "), 5186)"); 
        } catch (FactoryException | TransformException e) {
            e.printStackTrace();
        }
        
		// region 가공
        facilityDto.setRegion(facilityDto.getRegionSido() + " " + facilityDto.getRegionSigungu());

		// 시설물 데이터 넣기
		int resultFacility = facilityRepository.registFacility(facilityDto);

		// 손상 데이터 넣기
		List<Integer> resultDamage = damageRepository.registDamage(resultFacility, facilityDto.getDamageList());
		
		// 손상 이미지 넣기
		
		return resultFacility;
	}

	@Override
	public int registFacilitys(MultipartFile file) throws IOException {
        // 등록용 시설물Dto 목록
        List<FacilityDto> facilityDtos = new ArrayList<FacilityDto>();

        // 워크북 생성
        Workbook workbook;
        if (file.getOriginalFilename().endsWith(".xlsx")) {
            workbook = new XSSFWorkbook(file.getInputStream()); // XLSX 파일
        } else {
            workbook = new HSSFWorkbook(file.getInputStream()); // XLS 파일
        }

        // 첫 번째 시트 가져오기
        Sheet sheet = workbook.getSheetAt(0);
        
        // 헤더 건너뛰기
        int startRow = 1;
        int lastFacilityId = 0;

        // 각 행 처리
        for (int i = startRow; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;
            
            try {
            	// 시설물 명도 손상 정보도 없으면 패스
            	if(row.getCell(1) == null && row.getCell(9) == null) {
            		continue;
            	}
            	
            	// 시설물 명이 있으면 시설물 추가
            	if(row.getCell(1) != null) {
                    FacilityDto dto = new FacilityDto();
                    
                    // 각 셀 데이터 추출
                    // 필수:시설물 식별자(int)
                    // dto.setFacilityId((int)row.getCell(0).getNumericCellValue());
                    // 필수:시설물 명(String)
                    dto.setFacilityName(getCellValueAsString(row.getCell(1)));
                    // 시설물 종류(String:건축물,도로,도보, ...)
                    if (row.getCell(2) != null) dto.setFacilityType(facilityRepository.getFacilityType(getCellValueAsString(row.getCell(2))));
                    // 시설물 규모(String:1종,2종,3종)
                    if (row.getCell(3) != null) dto.setFacilityScale(getCellValueAsString(row.getCell(3)).charAt(0)-48);
                    // 시설물 위치(double/double:Lat/Lon)
                    if (row.getCell(4) != null && row.getCell(5) != null) {
                        dto.setFacilityGeomX(row.getCell(4).getNumericCellValue());
                        dto.setFacilityGeomY(row.getCell(5).getNumericCellValue());
                    }
                    // Lat,Lon으로 주소 가져오기
                    // https://api.vworld.kr/req/address?service=address&request=getAddress&version=2.0&crs=epsg:4326&point=126.9188,37.5570&format=json&type=both&key=469BE1D2-99C1-3245-8BDD-6AA1B4658915
                    // 시설물 지역(String:Region)
                    if (row.getCell(6) != null) dto.setRegion(getCellValueAsString(row.getCell(6)));
                    // 시설물 상세 주소(String:Address)
                    if (row.getCell(7) != null) dto.setAddress(getCellValueAsString(row.getCell(7)));
                    // 시설물 준공년도(Date)
                    if (row.getCell(8) != null) dto.setYearBuilt(row.getCell(8).getDateCellValue());

            		// 시설물 데이터 넣기
            		lastFacilityId = facilityRepository.registFacility(dto);
            		
            		System.out.println(lastFacilityId);
            	}
            	// 손상 정보 추가(마지막 시설물 데이터가 있는경우)
            	if(row.getCell(9) != null && lastFacilityId != 0) {
            		List<DamageDto> damageDtos = new ArrayList<DamageDto>();
            		DamageDto damageDto = new DamageDto();
            		
            		// 손상 정보의 시설물 식별자
            		damageDto.setFacilityId(lastFacilityId);
            		// 손상 유형
            		damageDto.setDamageType(damageRepository.getDamageType(getCellValueAsString(row.getCell(9))));
            		// 손상 위험도
            		damageDto.setSeverity(row.getCell(10).getStringCellValue().charAt(0)-64);
            		// 손상 수
            		damageDto.setDamageCnt((int)row.getCell(11).getNumericCellValue());
            		// 손상 점검자
            		damageDto.setInspectorId(getCellValueAsString(row.getCell(12)));
            		// 손상 설명
            		damageDto.setDescription(getCellValueAsString(row.getCell(13)));
            		// 손상 발생일
            		damageDto.setReportedDate(row.getCell(14).getDateCellValue());
            		
            		System.out.println(damageDto);
            		
            		damageDtos.add(damageDto);
            		
            		// 손상 이미지도 있으면 추가
            		
            		// 손상 데이터 넣기
            		List<Integer> resultDamage = damageRepository.registDamage(lastFacilityId, damageDtos);
            	}
            }
            catch (Exception e) {
            	System.out.println(i + "번 등록 실패");
            	System.out.println(e);
            	// 등록 될 수 없는 데이터의 순번을 반환한다.
            	return i;
			}
        }
        
//        System.out.println(facilityDtos);

        // 워크북 닫기
        workbook.close();
		
        // 모두 정상 등록 완료
		return 0;
	}

	// 셀값을 무조건 String으로 변환
	private String getCellValueAsString(Cell cell) {
	    if (cell == null) return "";
	    
	    switch (cell.getCellType()) {
	        case STRING:
	            return cell.getStringCellValue();
	        case NUMERIC:
	            if (DateUtil.isCellDateFormatted(cell)) {
	                return new SimpleDateFormat("yyyy-MM-dd").format(cell.getDateCellValue());
	            } else {
	                // 숫자를 문자열로 변환 (소수점 처리 주의)
	                double numericValue = cell.getNumericCellValue();
	                // 정수인 경우 소수점 제거
	                if (numericValue == Math.floor(numericValue)) {
	                    return String.valueOf((long)numericValue);
	                } else {
	                    return String.valueOf(numericValue);
	                }
	            }
	        case BOOLEAN:
	            return String.valueOf(cell.getBooleanCellValue());
	        case FORMULA:
	            try {
	                return String.valueOf(cell.getStringCellValue());
	            } catch (Exception e) {
	                try {
	                    return String.valueOf(cell.getNumericCellValue());
	                } catch (Exception ex) {
	                    return String.valueOf(cell.getBooleanCellValue());
	                }
	            }
	        case BLANK:
	            return "";
	        default:
	            return "";
	    }
	}
}
