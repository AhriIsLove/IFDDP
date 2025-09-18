package Controller.sis;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

//import Service.sis.FacilityDamageService;
//import Dto.sis.FacilityDamageDTO;

/**
 * 시설물 손상 정보 컨트롤러 (뷰 + API)
 * - 뷰(미리보기/단독진입용): facilityDamage.jsp / facility/facilityDamagegraph.jsp
 * - API: /api/damage/statistics  (서비스가 항상 '객체형 dailyData'를 반환한다고 가정)
 *
 * ※ 실제 화면에선 두 JSP는 include 전용 조각으로 사용됩니다.
 */
@Controller
@RequestMapping
public class FacilityDamageController {
//
//    @Autowired
//    private FacilityDamageService facilityDamageService;
//
//    /** ----------------------------- 뷰 (JSP, 선택적) -----------------------------
//     * include 전용 조각이지만, 단독 미리보기/디자인 확인을 위해 남겨둔 엔드포인트입니다.
//     * ViewResolver(prefix=/WEB-INF/views/, suffix=.jsp) 기준의 뷰 이름을 반환합니다.
//     */
//
//    /** 말풍선 팝업 조각 미리보기 */
//    @RequestMapping(value = "/facilityDamage.do")
//    public String getFacilityInfo(
//            @RequestParam(value="facilityId", defaultValue="1") int facilityId,
//            Model model) {
//        try {
//            List<FacilityDamageDTO> list = facilityDamageService.getFacilityDamageInfo(facilityId);
//            if (!list.isEmpty()) {
//                FacilityDamageDTO first = list.get(0);
//                model.addAttribute("facilityName", first.getFacilityName());
//                model.addAttribute("facilityAddress", first.getAddress());
//            } else {
//                model.addAttribute("facilityName", "시설물 정보 없음");
//                model.addAttribute("facilityAddress", "데이터가 없습니다. facilityId=" + facilityId);
//            }
//            model.addAttribute("damageList", list);
//        } catch (Exception e) {
//            e.printStackTrace();
//            model.addAttribute("facilityName", "에러 발생");
//            model.addAttribute("facilityAddress", "에러: " + e.getMessage());
//            model.addAttribute("damageList", new ArrayList<>());
//        }
//        // 파일 경로: /WEB-INF/views/facilityDamage.jsp
//        return "facilityDamage";
//    }
//
//    /** 하단 그래프 시트 조각 미리보기 */
//    @RequestMapping("/tablegraph.do")
//    public String tablegraph(@RequestParam(value="facilityId", defaultValue="3") int facilityId,
//                             Model model) {
//        // 페이지 진입만 담당 (데이터는 AJAX로 로드)
//        model.addAttribute("facilityId", facilityId);
//        // 파일 경로: /WEB-INF/views/facility/facilityDamagegraph.jsp
//        return "facilityDamagegraph";
//    }
//
//    /** ----------------------------- API (AJAX) ----------------------------- */
//
//    /**
//     * 반환 스키마:
//     * {
//     *   facilityId, facilityName, facilityType?: {group,code,name},
//     *   summaryData: [ { damageType:{group,code,name}, damageImpact, totalCount } ],
//     *   dailyData: {
//     *     counts:       [ { dateLabel, total } ],
//     *     typeDist:     [ { dateLabel, damageType:{group,code,name}, count } ],
//     *     impactScores: [ { dateLabel, score } ]
//     *   }
//     * }
//     */
//    @GetMapping("/api/damage/statistics")
//    @ResponseBody
//    public ResponseEntity<Map<String, Object>> getDamageStatistics(
//            @RequestParam(value="facilityId") int facilityId,
//            @RequestParam(value="from", required = false) String from,
//            @RequestParam(value="to",   required = false) String to
//    ) {
//        try {
//            // 기본값 설정 (7월-8월)
//            String fromDate = (from != null && !from.isEmpty()) ? from : "2024-07-01";
//            String toDate   = (to   != null && !to.isEmpty())   ? to   : "2024-08-31";
//
//            // 서비스 호출 (날짜 범위 파라미터 포함)
//            Map<String, Object> raw = facilityDamageService.getFacilityDamageStatistics(facilityId, fromDate, toDate);
//            if (raw == null) raw = new HashMap<>();
//
//            // 최상위 메타
//            Map<String, Object> body = new LinkedHashMap<>();
//            body.put("facilityId", facilityId);
//            body.put("facilityName", safeStr(raw.get("facilityName")));
//
//            @SuppressWarnings("unchecked")
//            Map<String, Object> facilityType = (Map<String, Object>) raw.get("facilityType");
//            if (facilityType != null) {
//                body.put("facilityType", Map.of(
//                        "group", facilityType.getOrDefault("group", 200),
//                        "code",  facilityType.getOrDefault("code",  0),
//                        "name",  safeStr(facilityType.get("name"))
//                ));
//            }
//
//            // summaryData
//            @SuppressWarnings("unchecked")
//            Map<String, Integer> damageTypeCount =
//                    (Map<String, Integer>) raw.get("damageTypeCount");
//            @SuppressWarnings("unchecked")
//            Map<String, String> damageImpact =
//                    (Map<String, String>) raw.getOrDefault("damageImpact", Collections.emptyMap());
//            @SuppressWarnings("unchecked")
//            Map<String, Map<String, Object>> damageTypeCode =
//                    (Map<String, Map<String, Object>>) raw.get("damageTypeCode");
//
//            List<Map<String, Object>> summaryData = new ArrayList<>();
//            if (damageTypeCount != null && !damageTypeCount.isEmpty()) {
//                List<String> types = new ArrayList<>(damageTypeCount.keySet());
//                Collections.sort(types);
//                for (String typeName : types) {
//                    Map<String, Object> row = new LinkedHashMap<>();
//                    if (damageTypeCode != null && damageTypeCode.containsKey(typeName)) {
//                        Map<String, Object> meta = damageTypeCode.get(typeName);
//                        row.put("damageType", Map.of(
//                                "group", meta.getOrDefault("group", 300),
//                                "code",  meta.getOrDefault("code",  0),
//                                "name",  typeName
//                        ));
//                    } else {
//                        row.put("damageType", Map.of("name", typeName));
//                    }
//                    String grade = safeStr(damageImpact.get(typeName));
//                    if (grade != null && !grade.isBlank()) {
//                        row.put("damageImpact", grade);  // facilityDamagegraph.jsp용
//                        row.put("severity", grade);      // facilityDamage.jsp용 (동일 값)
//                    }
//                    row.put("totalCount", damageTypeCount.getOrDefault(typeName, 0));
//                    summaryData.add(row);
//                }
//            }
//            body.put("summaryData", summaryData);
//
//            // dailyData (서비스가 '객체형'을 준다는 가정)
//            Map<String, Object> dailyObj = buildDailyObject(raw);
//            body.put("dailyData", dailyObj);
//
//            // 빈 구조 보정
//            ensureEmptyStructures(body);
//
//            return ResponseEntity.ok(body);
//        } catch (Exception e) {
//            e.printStackTrace();
//            Map<String, Object> err = new HashMap<>();
//            err.put("error", e.getMessage() == null ? "unknown error" : e.getMessage());
//            return ResponseEntity.status(500).body(err);
//        }
//    }
//
//    /* ------------------------- 내부 헬퍼 (스키마 어댑터) ------------------------- */
//
//    /**
//     * dailyData를 '객체형(Map)'으로만 처리.
//     * 서비스가 항상 객체형을 반환하므로 List 분기/하드코딩 변환은 제거.
//     */
//    @SuppressWarnings("unchecked")
//    private Map<String, Object> buildDailyObject(Map<String, Object> raw) {
//        Object daily = raw.get("dailyData");
//        if (daily instanceof Map) {
//            Map<String, Object> obj = (Map<String, Object>) daily;
//            Map<String, Object> normalized = new LinkedHashMap<>();
//            List<Map<String, Object>> counts =
//                    sortByDateLabel((List<Map<String, Object>>) obj.getOrDefault("counts", Collections.emptyList()));
//            List<Map<String, Object>> typeDist =
//                    sortByDateLabel((List<Map<String, Object>>) obj.getOrDefault("typeDist", Collections.emptyList()));
//            List<Map<String, Object>> impactScores =
//                    sortByDateLabel((List<Map<String, Object>>) obj.getOrDefault("impactScores", Collections.emptyList()));
//            normalized.put("counts", counts);
//            normalized.put("typeDist", normalizeTypeDist(typeDist));
//            normalized.put("impactScores", impactScores);
//            return normalized;
//        }
//        // 없으면 빈 구조 반환
//        Map<String, Object> empty = new LinkedHashMap<>();
//        empty.put("counts", Collections.emptyList());
//        empty.put("typeDist", Collections.emptyList());
//        empty.put("impactScores", Collections.emptyList());
//        return empty;
//    }
//
//    /** typeDist에 들어온 항목을 정규화(중복 dateLabel+type.name 합산) - damageType은 이미 객체 형태 */
//    @SuppressWarnings("unchecked")
//    private List<Map<String, Object>> normalizeTypeDist(List<Map<String, Object>> typeDist) {
//        Map<String, Map<String, Object>> dedup = new LinkedHashMap<>();
//        for (Map<String, Object> item : typeDist) {
//            String date = safeStr(item.get("dateLabel"));
//            Map<String, Object> damageTypeObj = (Map<String, Object>) item.get("damageType");
//
//            String name = safeStr(damageTypeObj.get("name"));
//            if (name == null) name = "기타";
//
//            String key = date + "|" + name;
//            Map<String, Object> existing = dedup.get(key);
//            if (existing == null) {
//                Map<String, Object> newItem = new LinkedHashMap<>();
//                newItem.put("dateLabel", date);
//                newItem.put("damageType", damageTypeObj);
//                newItem.put("count", 0);
//                dedup.put(key, newItem);
//                existing = newItem;
//            }
//            Integer cnt = ((Number) item.getOrDefault("count", 0)).intValue();
//            Integer prev = ((Number) existing.getOrDefault("count", 0)).intValue();
//            existing.put("count", prev + cnt);
//        }
//        return new ArrayList<>(dedup.values());
//    }
//
//    private List<Map<String, Object>> sortByDateLabel(List<Map<String, Object>> list) {
//        if (list == null) return Collections.emptyList();
//        return list.stream()
//                .sorted(Comparator.comparing(m -> safeStr(m.get("dateLabel")),
//                        Comparator.nullsLast(String::compareTo)))
//                .collect(Collectors.toList());
//    }
//
//    private void ensureEmptyStructures(Map<String, Object> body) {
//        if (!body.containsKey("summaryData") || body.get("summaryData") == null)
//            body.put("summaryData", Collections.emptyList());
//
//        Object wk = body.get("dailyData");
//        if (!(wk instanceof Map)) {
//            body.put("dailyData", Map.of(
//                    "counts", Collections.emptyList(),
//                    "typeDist", Collections.emptyList(),
//                    "impactScores", Collections.emptyList()
//            ));
//            return;
//        }
//        @SuppressWarnings("unchecked")
//        Map<String, Object> w = (Map<String, Object>) wk;
//        if (!w.containsKey("counts") || w.get("counts") == null) w.put("counts", Collections.emptyList());
//        if (!w.containsKey("typeDist") || w.get("typeDist") == null) w.put("typeDist", Collections.emptyList());
//        if (!w.containsKey("impactScores") || w.get("impactScores") == null) w.put("impactScores", Collections.emptyList());
//    }
//
//    private String safeStr(Object o) {
//        return (o == null) ? null : String.valueOf(o);
//    }
//
//    private int safeInt(Object o) {
//        try {
//            if (o == null) return 0;
//            if (o instanceof Number) return ((Number) o).intValue();
//            return Integer.parseInt(String.valueOf(o));
//        } catch (Exception e) {
//            return 0;
//        }
//    }
//
//    private double safeDouble(Object o) {
//        try {
//            if (o == null) return 0.0;
//            if (o instanceof Number) return ((Number) o).doubleValue();
//            return Double.parseDouble(String.valueOf(o));
//        } catch (Exception e) {
//            return 0.0;
//        }
//    }
}
