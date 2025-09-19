package Controller.sis;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import Service.sis.FacilityDamageService;
import lombok.RequiredArgsConstructor;
import Dto.sis.FacilityDamageDTO;

@Controller
@RequiredArgsConstructor
//@RequestMapping
public class FacilityDamageController {

    @Autowired
    private FacilityDamageService facilityDamageService;

    @RequestMapping(value = "/facilityDamage.do")
    public String getFacilityInfo(
            @RequestParam(value="facilityId", defaultValue="1") int facilityId,
            Model model) {
        try {
            List<FacilityDamageDTO> list = facilityDamageService.getFacilityDamageInfo(facilityId);
            if (!list.isEmpty()) {
                FacilityDamageDTO first = list.get(0);
                System.out.println("FacilityDamageController getFacilityInfo first->"+first);
                model.addAttribute("facilityName", first.getFacilityName());
                model.addAttribute("facilityAddress", first.getAddress());
            } else {
                model.addAttribute("facilityName", "시설물 정보 없음");
                model.addAttribute("facilityAddress", "데이터가 없습니다. facilityId=" + facilityId);
            }
            model.addAttribute("damageList", list);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("facilityName", "에러 발생");
            model.addAttribute("facilityAddress", "에러: " + e.getMessage());
            model.addAttribute("damageList", new ArrayList<>());
        }
        return "facilityDamage";
    }

    @RequestMapping("/tablegraph.do")
    public String tablegraph(@RequestParam(value="facilityId", defaultValue="3") int facilityId,
                             Model model) {
        model.addAttribute("facilityId", facilityId);
        return "facilityDamagegraph";
    }

    @RequestMapping(value = "/damage/statistics")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getDamageStatistics(
            @RequestParam(value="facilityId") int facilityId,
            @RequestParam(value="from", required = false) String from,
            @RequestParam(value="to",   required = false) String to
    ) {
    	System.out.println("API 호출됨 - facilityId: " + facilityId); // 이 줄 추가
        try {
            String fromDate = (from != null && !from.isEmpty()) ? from : "2024-07-01";
            String toDate   = (to   != null && !to.isEmpty())   ? to   : "2025-09-30";

            // [CTRL-LOG1] API 진입 파라미터 확인
            System.out.println("[CTRL] /api/damage/statistics in: facilityId=" + facilityId
                    + ", from=" + fromDate + ", to=" + toDate);

            Map<String, Object> raw = facilityDamageService.getFacilityDamageStatistics(facilityId, fromDate, toDate);
            if (raw == null) raw = new HashMap<>();

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("facilityId", facilityId);
            body.put("facilityName", safeStr(raw.get("facilityName")));

            System.out.println("kkk FacilityDamageController getDamageStatistics body1->"+body);
            
            @SuppressWarnings("unchecked")
            Map<String, Object> facilityType = (Map<String, Object>) raw.get("facilityType");
            if (facilityType != null) {
                body.put("facilityType", Map.of(
                        "group", facilityType.getOrDefault("group", 200),
                        "code",  facilityType.getOrDefault("code",  0),
                        "name",  safeStr(facilityType.get("name"))
                ));
            }
            System.out.println("kkk FacilityDamageController getDamageStatistics body2->"+body);

            @SuppressWarnings("unchecked")
            Map<String, Integer> damageTypeCount =
                    (Map<String, Integer>) raw.get("damageTypeCount");
            @SuppressWarnings("unchecked")
            Map<String, String> damageImpact =
                    (Map<String, String>) raw.getOrDefault("damageImpact", Collections.emptyMap());
            @SuppressWarnings("unchecked")
            Map<String, Map<String, Object>> damageTypeCode =
                    (Map<String, Map<String, Object>>) raw.get("damageTypeCode");

            List<Map<String, Object>> summaryData = new ArrayList<>();
            if (damageTypeCount != null && !damageTypeCount.isEmpty()) {
                List<String> types = new ArrayList<>(damageTypeCount.keySet());
                Collections.sort(types);
                for (String typeName : types) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    if (damageTypeCode != null && damageTypeCode.containsKey(typeName)) {
                        Map<String, Object> meta = damageTypeCode.get(typeName);
                        row.put("damageType", Map.of(
                                "group", meta.getOrDefault("group", 300),
                                "code",  meta.getOrDefault("code",  0),
                                "name",  typeName
                        ));
                    } else {
                        row.put("damageType", Map.of("name", typeName));
                    }
                    String grade = safeStr(damageImpact.get(typeName));
                    if (grade != null && !grade.isBlank()) {
                        row.put("damageImpact", grade);
                        row.put("severity", grade);
                    }
                    row.put("totalCount", damageTypeCount.getOrDefault(typeName, 0));
                    summaryData.add(row);
                }
            }
            body.put("summaryData", summaryData);

            Map<String, Object> dailyObj = buildDailyObject(raw);
            body.put("dailyData", dailyObj);
            ensureEmptyStructures(body);

            // [CTRL-LOG2] 서비스 결과 요약(사이즈) 확인
            int cntCounts = 0, cntType = 0, cntImpact = 0;
            if (dailyObj instanceof Map) {
                Object c = ((Map<?,?>) dailyObj).get("counts");
                Object t = ((Map<?,?>) dailyObj).get("typeDist");
                Object i = ((Map<?,?>) dailyObj).get("impactScores");
                cntCounts = (c instanceof List) ? ((List<?>) c).size() : 0;
                cntType   = (t instanceof List) ? ((List<?>) t).size() : 0;
                cntImpact = (i instanceof List) ? ((List<?>) i).size() : 0;
            }
            System.out.println("--kkk-->[CTRL] service ok: summary=" + summaryData.size()
                    + ", counts=" + cntCounts + ", typeDist=" + cntType + ", impact=" + cntImpact);

            return ResponseEntity.ok(body);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> err = new HashMap<>();
            err.put("error", e.getMessage() == null ? "unknown error" : e.getMessage());
            return ResponseEntity.status(500).body(err);
        }
    }

    // ====== 이하 기존 헬퍼 메서드들 그대로 ======
    @SuppressWarnings("unchecked")
    private Map<String, Object> buildDailyObject(Map<String, Object> raw) { /* 생략 없이 기존 그대로 */ 
        Object daily = raw.get("dailyData");
        if (daily instanceof Map) {
            Map<String, Object> obj = (Map<String, Object>) daily;
            Map<String, Object> normalized = new LinkedHashMap<>();
            List<Map<String, Object>> counts =
                    sortByDateLabel((List<Map<String, Object>>) obj.getOrDefault("counts", Collections.emptyList()));
            List<Map<String, Object>> typeDist =
                    sortByDateLabel((List<Map<String, Object>>) obj.getOrDefault("typeDist", Collections.emptyList()));
            List<Map<String, Object>> impactScores =
                    sortByDateLabel((List<Map<String, Object>>) obj.getOrDefault("impactScores", Collections.emptyList()));
            normalized.put("counts", counts);
            normalized.put("typeDist", normalizeTypeDist(typeDist));
            normalized.put("impactScores", impactScores);
            return normalized;
        }
        Map<String, Object> empty = new LinkedHashMap<>();
        empty.put("counts", Collections.emptyList());
        empty.put("typeDist", Collections.emptyList());
        empty.put("impactScores", Collections.emptyList());
        return empty;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> normalizeTypeDist(List<Map<String, Object>> typeDist) { /* 기존 그대로 */ 
        Map<String, Map<String, Object>> dedup = new LinkedHashMap<>();
        for (Map<String, Object> item : typeDist) {
            String date = safeStr(item.get("dateLabel"));
            Map<String, Object> damageTypeObj = (Map<String, Object>) item.get("damageType");
            String name = safeStr(damageTypeObj.get("name"));
            if (name == null) name = "기타";
            String key = date + "|" + name;
            Map<String, Object> existing = dedup.get(key);
            if (existing == null) {
                Map<String, Object> newItem = new LinkedHashMap<>();
                newItem.put("dateLabel", date);
                newItem.put("damageType", damageTypeObj);
                newItem.put("count", 0);
                dedup.put(key, newItem);
                existing = newItem;
            }
            Integer cnt = ((Number) item.getOrDefault("count", 0)).intValue();
            Integer prev = ((Number) existing.getOrDefault("count", 0)).intValue();
            existing.put("count", prev + cnt);
        }
        return new ArrayList<>(dedup.values());
    }

    private List<Map<String, Object>> sortByDateLabel(List<Map<String, Object>> list) {
        if (list == null) return Collections.emptyList();
        return list.stream()
                .sorted(Comparator.comparing(m -> safeStr(m.get("dateLabel")),
                        Comparator.nullsLast(String::compareTo)))
                .collect(Collectors.toList());
    }

    private void ensureEmptyStructures(Map<String, Object> body) {
        if (!body.containsKey("summaryData") || body.get("summaryData") == null)
            body.put("summaryData", Collections.emptyList());
        Object wk = body.get("dailyData");
        if (!(wk instanceof Map)) {
            body.put("dailyData", Map.of(
                    "counts", Collections.emptyList(),
                    "typeDist", Collections.emptyList(),
                    "impactScores", Collections.emptyList()
            ));
            return;
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> w = (Map<String, Object>) wk;
        if (!w.containsKey("counts") || w.get("counts") == null) w.put("counts", Collections.emptyList());
        if (!w.containsKey("typeDist") || w.get("typeDist") == null) w.put("typeDist", Collections.emptyList());
        if (!w.containsKey("impactScores") || w.get("impactScores") == null) w.put("impactScores", Collections.emptyList());
    }

    private String safeStr(Object o) { return (o == null) ? null : String.valueOf(o); }
}
