<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- 시설 말풍선 팝업 (JSP) : 마지막 날짜 기준 -->
<div class="facility-info-container" id="facilityPopup" style="display:none;">
  <div class="facility-header">
    <h3 class="facility-title" id="popupTitle"><c:out value="${facilityName}" /></h3>
    <button class="close-btn" id="popupCloseBtn" type="button">×</button>
  </div>

  <div class="facility-location">
    <span class="location-icon">📍</span>
    <span class="location-text" id="popupAddress"><c:out value="${facilityAddress}" /></span>
  </div>

  <!-- 마지막 점검일 표시 추가 -->
  <div class="facility-date">
    <span class="date-icon">📅</span>
    <span class="date-text" id="popupLastDate">마지막 점검일: -</span>
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
      <!-- JS로만 처리 -->
      <tr><td colspan="3" style="text-align:center;">데이터를 불러오는 중...</td></tr>
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
  .facility-date{padding:8px 15px;border-bottom:1px solid #eee;font-size:12px;color:#777;font-style:italic}
  .location-icon, .date-icon{margin-right:6px}
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
    const dateEl  = document.getElementById('popupLastDate');
    const tbodyEl = document.getElementById('damageInfoTable');

    titleEl.textContent = facilityName || '시설 요약';
    addrEl.textContent  = facilityAddress || '';
    dateEl.textContent  = '마지막 점검일: -';
    popupEl.style.display = 'block';
    tbodyEl.innerHTML = '<tr><td colspan="3" style="text-align:center;">데이터를 불러오는 중...</td></tr>';

    try {
      const resp = await fetch('<%=request.getContextPath()%>/api/damage/statistics?facilityId=' + encodeURIComponent(facilityId));
      if (!resp.ok) throw new Error('통계 API 오류');
      const json = await resp.json();

      // ★ 마지막 날짜 데이터 추출
      const dailyData = json.dailyData || {};
      const typeDist = dailyData.typeDist || [];
      
      // 가장 마지막 날짜 찾기
      const lastDate = getLastDateFromTypeDist(typeDist);
      if (lastDate) {
        dateEl.textContent = '마지막 점검일: ' + lastDate;
      }

     
		      // 개별 손상 데이터를 사용하여 마지막 날짜의 모든 항목 표시
		const dailyImpacts = json.dailyImpacts || [];
		const lastDateItems = dailyImpacts.filter(item => {
		  const itemDate = item.dateLabel || item.datelabel;
		  return itemDate === lastDate;
		});
		
		const rows = lastDateItems.map(item => {
		  const typeName = item.damage_type_name || '기타';
		  const severity = item.damage_impact || '-';
		  const count = item.damage_count || 1;  // ★ 실제 건수 사용
		  
		  return '<tr>' +
		    '<td>' + escapeHtml(typeName) + '</td>' +
		    '<td>' + escapeHtml(severity) + '</td>' +
		    '<td>' + count + '</td>' +  // ★ 실제 건수 표시
		    '</tr>';
		}).join('');
      if (rows) {
        tbodyEl.innerHTML = rows;
      } else {
        tbodyEl.innerHTML = '<tr><td colspan="3" style="text-align:center;">해당 날짜 데이터가 없습니다.</td></tr>';
      }
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

  // ★ 마지막 날짜 추출 함수 추가
  function getLastDateFromTypeDist(typeDist) {
    if (!typeDist || !typeDist.length) return null;
    
    const dates = typeDist.map(item => item.dateLabel).filter(Boolean);
    if (!dates.length) return null;
    
 // 날짜 객체로 변환해서 정렬 후 다시 문자열로
    dates.sort((a, b) => new Date(a) - new Date(b));
    return dates[dates.length - 1];
  }

  // 외부에서 호출 가능하도록 노출
  window.loadFacilityPopup = loadFacilityPopup;
  window.positionPopup = positionPopup;
  window.closeFacilityPopup = () => {
    document.getElementById('facilityPopup').style.display='none';
  };
</script>