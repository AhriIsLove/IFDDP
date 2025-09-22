<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- 시설 말풍선 팝업 (JSP) : severity 기준 -->
<div class="facility-info-container" id="facilityPopup" style="display:none;">
  <div class="facility-header">
    <h3 class="facility-title" id="popupTitle"><c:out value="${facilityName}" /></h3>
    <button class="close-btn" id="popupCloseBtn" type="button">×</button>
  </div>

  <div class="facility-location">
    <span class="location-icon">📍</span>
    <span class="location-text" id="popupAddress"><c:out value="${facilityAddress}" /></span>
  </div>

  <div class="damage-info-section">
    <table class="damage-table">
      <thead>
      <tr>
        <th>손상유형</th>
        <th>손상 영향도</th>
        <th>발생건수</th>
      </tr>
      </thead>
      <tbody id="damageInfoTable">
      <!-- (옵션) 서버 사이드 초기 렌더 -->
      <c:choose>
        <c:when test="${not empty damageList}">
          <c:forEach var="d" items="${damageList}">
            <tr>
              <td><c:out value="${d.damageTypeName != null ? d.damageTypeName : d.damageType}" /></td>
              <td><c:out value="${d.severity}" /></td>
              <td>
                <c:choose>
                  <c:when test="${not empty d.damageCnt}"><c:out value="${d.damageCnt}" /></c:when>
                  <c:when test="${not empty d.totalCount}"><c:out value="${d.totalCount}" /></c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <tr><td colspan="3" style="text-align:center;">손상 정보가 없습니다.</td></tr>
        </c:otherwise>
      </c:choose>
      </tbody>
    </table>
  </div>
</div>

<style>
  .facility-info-container{background:#fff;border:2px solid #333;border-radius:10px;box-shadow:0 4px 20px rgba(0,0,0,.3);min-width:300px;max-width:360px;position:absolute;z-index:1000}
  .facility-header{background:#4a90e2;color:#fff;padding:12px 15px;border-radius:8px 8px 0 0;display:flex;justify-content:space-between;align-items:center}
  .facility-title{margin:0;font-size:16px;font-weight:bold}
  .close-btn{background:rgba(255,255,255,.2);color:#fff;border:none;border-radius:50%;width:24px;height:24px;cursor:pointer;font-size:14px;font-weight:bold}
  .close-btn:hover{background:rgba(255,255,255,.3)}
  .facility-location{padding:12px 15px;border-bottom:1px solid #eee;font-size:14px;color:#555}
  .location-icon{margin-right:6px}
  .damage-info-section{padding:15px}
  .damage-table{width:100%;border-collapse:collapse}
  .damage-table th{background:#f8f9fa;border:1px solid #ddd;padding:8px 10px;text-align:center;font-size:13px;font-weight:bold}
  .damage-table td{border:1px solid #ddd;padding:8px 10px;text-align:center;font-size:13px}
</style>

<script>
  // === 팝업 열기(지도 마커 클릭 시 호출) ===
  async function loadFacilityPopup(facilityId, facilityName, facilityAddress) {
    const popupEl = document.getElementById('facilityPopup');
    const titleEl = document.getElementById('popupTitle');
    const addrEl  = document.getElementById('popupAddress');
    const tbodyEl = document.getElementById('damageInfoTable');

    titleEl.textContent = facilityName || '시설 요약';
    addrEl.textContent  = facilityAddress || '';
    popupEl.style.display = 'block';
    tbodyEl.innerHTML = '<tr><td colspan="3" style="text-align:center;">데이터를 불러오는 중...</td></tr>';

    try {
      const resp = await fetch('<%=request.getContextPath()%>/api/damage/statistics?facilityId=' + encodeURIComponent(facilityId));
      if (!resp.ok) throw new Error('통계 API 오류');
      const json = await resp.json();

      // 기대 응답 형태 예시:
      // { summaryData: [{ damageType, damageTypeName, severity, damageCnt|totalCount }, ...] }
      const rows = (json.summaryData || []).map(item => {
        const typeName =
          (item.damageType && typeof item.damageType === 'object')
            ? (item.damageType.name || '-')
            : (item.damageTypeName || item.damageType || '-');
        const sev = pick(item, ['severity']); // 평균 아님! 그대로 출력
        const cnt = pick(item, ['damageCnt','totalCount']);
        return '<tr>' +
          '<td>' + escapeHtml(typeName) + '</td>' +
          '<td>' + (sev || '-') + '</td>' +
          '<td>' + (cnt || '-') + '</td>' +
          '</tr>';
      }).join('');

      tbodyEl.innerHTML = rows || '<tr><td colspan="3" style="text-align:center;">표시할 데이터가 없습니다.</td></tr>';
    } catch (e) {
      tbodyEl.innerHTML = '<tr><td colspan="3" style="text-align:center;color:#d00;">불러오기 실패: ' + escapeHtml(e.message) + '</td></tr>';
      console.error(e);
    }
  }

  // === 팝업 닫기 ===
  document.getElementById('popupCloseBtn').addEventListener('click', () => {
    document.getElementById('facilityPopup').style.display = 'none';
  });

  // === 지도 좌표 → 픽셀로 위치 지정(OpenLayers용) ===
  function positionPopup(px){
    const el = document.getElementById('facilityPopup');
    el.style.left = (px[0]) + 'px';
    el.style.top  = (px[1]) + 'px';
  }

  // === 유틸 ===
  function escapeHtml(s){
    if (s == null) return '';
    return String(s)
      .replaceAll('&','&amp;')
      .replaceAll('<','&lt;')
      .replaceAll('>','&gt;')
      .replaceAll('"','&quot;')
      .replaceAll("'","&#39;");
  }
  function pick(obj, keys){
    if (!obj) return undefined;
    for (const k of keys){ if (obj[k] != null) return obj[k]; }
    return undefined;
  }

  // 외부에서 호출 가능하도록 노출
  window.loadFacilityPopup = loadFacilityPopup;
  window.positionPopup = positionPopup;
  window.closeFacilityPopup = () => {
    document.getElementById('facilityPopup').style.display='none';
  };
</script>
