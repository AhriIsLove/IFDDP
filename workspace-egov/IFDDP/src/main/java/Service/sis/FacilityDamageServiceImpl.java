package Service.sis;

import java.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import Dto.sis.FacilityDamageDTO;
import Repository.sis.FacilityDamageRepository;

@Service("facilityDamageService")
public class FacilityDamageServiceImpl implements FacilityDamageService {

    @Autowired
    private FacilityDamageRepository facilityDamageRepository;

    private int mapFacilityTypeToBcd(Integer facilityType) {
        if (facilityType == null) return 300;
        switch (facilityType) {
            case 1: return 310; case 2: return 320; case 3: return 330;
            case 4: return 340; case 5: return 350; case 6: return 360;
            case 7: return 370; case 8: return 380; case 9: return 390;
            default: return 300;
        }
    }

    @Override
    public List<FacilityDamageDTO> getFacilityDamageInfo(int facilityId) throws Exception {
        Integer facilityType = facilityDamageRepository.selectFacilityType(facilityId);
        int bcd = mapFacilityTypeToBcd(facilityType);
        List<FacilityDamageDTO> list = facilityDamageRepository.selectFacilityDamageInfo(facilityId, bcd);
        return (list != null) ? list : Collections.<FacilityDamageDTO>emptyList();
    }

    @Override
    public List<FacilityDamageDTO> getAllFacilityDamageInfo() throws Exception {
        List<FacilityDamageDTO> list = facilityDamageRepository.selectAllFacilityDamageInfo();
        return (list != null) ? list : Collections.<FacilityDamageDTO>emptyList();
    }

    @Override
    public Map<String, Object> getFacilityDamageStatistics(int facilityId, String from, String to) throws Exception {
        Map<String, Object> result = new HashMap<>();
        
     // 시설물 기본 정보 먼저 조회
        Map<String, Object> facilityBasicInfo = facilityDamageRepository.selectFacilityBasicInfo(facilityId);
        String facilityName = facilityBasicInfo != null ? (String) facilityBasicInfo.get("facilityName") : "";
        System.out.println("kkk getFacilityDamageStatistics facilityBasicInfo->"+facilityBasicInfo); 
        Integer facilityType = facilityDamageRepository.selectFacilityType(facilityId);
        int bcd = mapFacilityTypeToBcd(facilityType);

        // [SVC-LOG1] 리포지토리 호출 직전 파라미터/BCD 확인
        System.out.println("[SVC] fetch stats: facilityId=" + facilityId
                + ", bcd=" + bcd + ", from=" + from + ", to=" + to);

        List<FacilityDamageDTO> damageList =
                nvlList(facilityDamageRepository.selectFacilityDamageInfo(facilityId, bcd));
       // String facilityName = damageList.isEmpty() ? "" : damageList.get(0).getFacilityName();

        List<Map<String, Object>> damageTypeSummary =
                nvlList(facilityDamageRepository.getDamageTypeSummary(facilityId, bcd, from, to));
        List<Map<String, Object>> weeklyCounts =
                nvlList(facilityDamageRepository.getWeeklyDamageCounts(facilityId, from, to));
        System.out.println("[DEBUG] Raw weeklyCounts: " + weeklyCounts);
        List<Map<String, Object>> weeklyTypeDistribution =
                nvlList(facilityDamageRepository.getWeeklyTypeDistribution(facilityId, bcd, from, to));
        System.out.println("[DEBUG] Raw weeklyTypeDistribution: " + weeklyTypeDistribution);
        List<Map<String, Object>> weeklyImpactScores =
                nvlList(facilityDamageRepository.getWeeklyImpactScores(facilityId, from, to));
        System.out.println("[DEBUG] weeklyImpactScores data: " + weeklyImpactScores);
        
       

        // [SVC-LOG2] 리포지토리 결과 사이즈 요약
        System.out.println("[SVC] repo sizes: summary=" + damageTypeSummary.size()
                + ", counts=" + weeklyCounts.size()
                + ", typeDist=" + weeklyTypeDistribution.size()
                + ", impact=" + weeklyImpactScores.size());

        Map<String, Integer> damageTypeCount = new HashMap<>();
        Map<String, String>  impactGradeMap  = new HashMap<>();
        for (Map<String, Object> summary : damageTypeSummary) {
            String typeName = (String) summary.get("damage_type_name");
            String impact   = (String) summary.get("DAMAGE_IMPACT");
            Integer count   = toInt(summary.get("total_count"));
            if (typeName != null) {
                damageTypeCount.put(typeName, damageTypeCount.getOrDefault(typeName, 0) + count);
                
                // 가장 심각한 등급 선택 (A > B > C > D > E)
                String currentGrade = impactGradeMap.get(typeName);
                if (currentGrade == null || impact.compareTo(currentGrade) < 0) {
                    impactGradeMap.put(typeName, impact);
                }
            }
        }

        Map<String, Object> dailyDataObj = new HashMap<>();

        List<Map<String, Object>> counts = new ArrayList<>();
        for (Map<String, Object> w : weeklyCounts) {
        	Object dateObj = w.get("datelabel");
        	String dateLabel = (dateObj != null) ? dateObj.toString() : null;
            Integer totalCount = toInt(w.get("total"));
            if (dateLabel != null) {
                Map<String, Object> cRow = new HashMap<>();
                cRow.put("dateLabel", dateLabel);
                cRow.put("total", totalCount);
                counts.add(cRow);
            }
        }
        dailyDataObj.put("counts", counts);

        List<Map<String, Object>> typeDistList = new ArrayList<>();
        for (Map<String, Object> t : weeklyTypeDistribution) {
        	Object dateObj = t.get("datelabel");
        	String dateLabel = (dateObj != null) ? dateObj.toString() : null;
            String damageTypeName = (String) t.get("damage_type_name");
            Integer damageTypeCode = toInt(t.get("DAMAGE_TYPE"));
            Integer groupCode = toInt(t.get("BCD"));
            Integer cnt = toInt(t.get("count"));
            if (dateLabel != null && damageTypeName != null) {
                Map<String, Object> damageTypeObj = new HashMap<>();
                damageTypeObj.put("group", groupCode);
                damageTypeObj.put("code",  damageTypeCode);
                damageTypeObj.put("name",  damageTypeName);
                Map<String, Object> item = new HashMap<>();
                item.put("dateLabel",  dateLabel);
                item.put("damageType", damageTypeObj);
                item.put("count",      cnt);
                typeDistList.add(item);
            }
        }
        dailyDataObj.put("typeDist", typeDistList);

        List<Map<String, Object>> impactScores = new ArrayList<>();
        for (Map<String, Object> is : weeklyImpactScores) {
        	Object dateObj = is.get("datelabel");
        	String dateLabel = (dateObj != null) ? dateObj.toString() : null;
            Double score = toDouble(is.get("score"));
            if (dateLabel != null) {
                Map<String, Object> iRow = new HashMap<>();
                iRow.put("dateLabel", dateLabel);
                iRow.put("score", score);
                impactScores.add(iRow);
            }
        }
        dailyDataObj.put("impactScores", impactScores);

        Map<String, Double> scoreByDate = new HashMap<>();
        for (Map<String, Object> is : weeklyImpactScores) {
            String dl = (String) is.get("dateLabel");
            if (dl != null) scoreByDate.put(dl, toDouble(is.get("score")));
        }
        double weightedSum = 0.0; int countSum = 0;
        for (Map<String, Object> wk : weeklyCounts) {
            String dl = (String) wk.get("dateLabel");
            int c = toInt(wk.get("total"));
            double s = (dl != null) ? scoreByDate.getOrDefault(dl, 0.0) : 0.0;
            weightedSum += s * c; countSum += c;
        }
        double totalAvgScore = countSum == 0 ? 0.0 : (weightedSum / countSum);

        result.put("facilityName", facilityName);
        result.put("facilityId", facilityId);
        result.put("damageTypeCount", damageTypeCount);
        result.put("damageImpact", impactGradeMap);
        result.put("avgImpactScore", String.format("%.1f", totalAvgScore));
        result.put("damageList", damageList);
        int sumDamageCnt = 0; for (FacilityDamageDTO d : damageList) sumDamageCnt += d.getDamageCnt();
        result.put("totalDamageCount", sumDamageCnt);
        result.put("dailyData", dailyDataObj);

        String facilityTypeName = facilityDamageRepository.getFacilityTypeName(facilityId);
        Map<String, Object> facilityTypeMeta = new HashMap<>();
        facilityTypeMeta.put("group", 200);
        facilityTypeMeta.put("code",  facilityType);
        facilityTypeMeta.put("name",  facilityTypeName != null ? facilityTypeName : "기타");
        result.put("facilityType", facilityTypeMeta);

        Map<String, Map<String, Object>> damageTypeCode = new HashMap<>();
        for (Map<String, Object> s : damageTypeSummary) {
            String typeName = (String) s.get("damage_type_name");
            Integer typeCode = toInt(s.get("DAMAGE_TYPE"));
            Integer groupCode = toInt(s.get("BCD"));
            if (typeName != null) {
                Map<String, Object> meta = new HashMap<>();
                meta.put("group", groupCode);
                meta.put("code",  typeCode);
                meta.put("name",  typeName);
                damageTypeCode.put(typeName, meta);
            }
        }
        result.put("damageTypeCode", damageTypeCode);

        return result;
    }

    /* ==== 유틸 ==== */
    private <T> List<T> nvlList(List<T> in){ return (in != null) ? in : Collections.<T>emptyList(); }
    private int toInt(Object o){
        if (o == null) return 0; if (o instanceof Number) return ((Number)o).intValue();
        try { return Integer.parseInt(String.valueOf(o)); } catch(Exception e){ return 0; }
    }
    private double toDouble(Object o){
        if (o == null) return 0.0; if (o instanceof Number) return ((Number)o).doubleValue();
        try { return Double.parseDouble(String.valueOf(o)); } catch(Exception e){ return 0.0; }
    }
}
