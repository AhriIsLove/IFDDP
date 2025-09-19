<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>노후화 패턴</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/theme.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/headerMain.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/agingPattern.css">

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@7.5.2/ol.css">
<script src="https://cdn.jsdelivr.net/npm/ol@7.5.2/dist/ol.js"></script>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
  /* 지도/팝업/시트 z-index 정리 */
  #mapWrapper, #map { position: relative; z-index: 1; }
  #map.ap5-canvas { min-height: 520px; }
  #facilityPopup { z-index: 1000; }
  /* 카드 임베드 시트: 초기에 숨김, 카드 레이아웃 안에서만 표시 */
  .tg-embed #tablegraphSheet { position: static !important; z-index: 0 !important; display: none; }
  
  /* 버튼 위치 */
#legendBtnContainer {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 1000;
}
#legendToggleBtn {
  padding: 5px 10px;
  font-size: 12px;
  cursor: pointer;
}

/* 범례 팝업 */
.map-legend-popup {
  position: absolute;
  top: 40px; /* 버튼 아래 */
  right: 10px;
  background: rgba(255,255,255,0.95);
  padding: 10px;
  border-radius: 5px;
  font-size: 12px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.3);
  z-index: 1000;
  display: none; /* 처음엔 숨김 */
}
.map-legend-popup h4 {
  margin: 0 0 5px 0;
  font-size: 14px;
}
.map-legend-popup ul {
  margin: 0;
  padding: 0;
  list-style: none;
}
.map-legend-popup li {
  display: flex;
  align-items: center;
  margin-bottom: 3px;
}
.map-legend-popup .dot {
  display: inline-block;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 5px;
}
.dot.danger { background: #FF4136; }
.dot.warn   { background: #FF851B; }
.dot.ok     { background: #2ECC40; }
.dot.none   { background: #7F7F7F; }
</style>

<script>
$(function() {
  // chip 클릭 → 서버 요청 후 마커 표시
  $(".ap5-chip").on("click", function() {
    const raw = $(this).val();
    const type = (raw === undefined || raw === null || raw === "") ? null : Number(raw);

    $.ajax({
      url: "${pageContext.request.contextPath}/map/facility.do",
      type: "POST",
      contentType: "application/json",
      data: JSON.stringify({ facilityType: type }),
      success: function(result) {
        console.log("[AJAX] 응답:", result);
        $("#ap5Total").text(result?.totalCount ?? 0);
        (window.addMarkersToMap || function(){ console.warn("addMarkersToMap 없음"); })(result?.markers || []);
      },
      error: function(xhr, status, error) {
        console.error("[AJAX] 에러:", error, xhr?.responseText);
        alert("에러 발생: " + error);
      }
    });
  });
});
</script>
</head>

<body>
  <%@ include file="/WEB-INF/views/common/side.jsp"%>

  <header class="header">
    <h1>노후화 패턴 분석</h1>
  </header>

  <div class="content">
    <div class="ap5-layout">
      <!-- 왼쪽 패널 -->
      <aside class="ap5-left">
        <section class="ap5-card">
          <h2 class="ap5-h2">지역 선택</h2>
          <div class="ap5-grid-2">
            <label class="ap5-field">
              <span class="ap5-label">시/도</span>
              <select class="ap5-input"><option>서울특별시</option></select>
            </label>
            <label class="ap5-field">
              <span class="ap5-label">시/군/구</span>
              <select class="ap5-input"><option>마포구</option></select>
            </label>
          </div>
        </section>

        <section class="ap5-card">
          <h2 class="ap5-h2">사회기반시설</h2>
          <div class="ap5-chips" role="group" aria-label="시설 종류">
            <button type="button" class="ap5-chip ap5-chip--active">전체</button>
            <button type="button" class="ap5-chip" value="1">건축물</button>
            <button type="button" class="ap5-chip" value="2">도로</button>
            <button type="button" class="ap5-chip" value="3">도보</button>
            <button type="button" class="ap5-chip" value="4">교량</button>
            <button type="button" class="ap5-chip" value="5">터널</button>
            <button type="button" class="ap5-chip" value="6">옹벽</button>
            <button type="button" class="ap5-chip" value="7">하천</button>
            <button type="button" class="ap5-chip" value="8">상하수도</button>
            <button type="button" class="ap5-chip" value="9">절토사면</button>
          </div>
        </section>

        <section class="ap5-card">
          <div class="ap5-kpi"><span>총 개체 수</span> <strong id="ap5Total">0</strong></div>
        </section>
        
        <!-- 범례 -->
        <section class="ap5-card">
           <h2 class="ap5-h2">손상위험도평가</h2>
           <ul class="ap5-legend">
              <li><span class="ap5-dot ap5-dot--danger"></span>위험</li>
              <li><span class="ap5-dot ap5-dot--warn"></span>경고</li>
              <li><span class="ap5-dot ap5-dot--ok"></span>보통</li>
              <li><span class="ap5-dot ap5-dot--none"></span>데이터없음</li>
           </ul>
        </section>
     </aside>
         
      <!-- 지도 위 범례 0916-->
      <!-- 범례 토글 버튼 -->
      <div id="legendBtnContainer">
           <button id="legendToggleBtn">범례</button>
      </div>
      
      <!-- 범례 팝업 -->
      <div id="mapLegendPopup" class="map-legend-popup">
        <h4>손상 위험도</h4>
        <ul>
          <li><span class="dot danger"></span> 위험</li>
          <li><span class="dot warn"></span> 경고</li>
          <li><span class="dot ok"></span> 보통</li>
          <li><span class="dot none"></span> 데이터없음</li>
        </ul>
      </div>

      <!-- 오른쪽: 지도 + 말풍선 -->
      <section class="ap5-right-top" aria-label="결과 영역">
        <div id="mapWrapper" style="position:relative;">
          <div id="map" class="ap5-canvas"></div>
          <%@ include file="/WEB-INF/views/facilityDamage.jsp" %>
        </div>
      </section>

      <!-- 하단: 카드 임베드 모드의 그래프 시트 (초기 숨김) -->
      <section class="ap5-right-bottom ap5-card tg-embed">
        <%@ include file="/WEB-INF/views/facilityDamagegraph.jsp" %>
      </section>
    </div>
  </div>

  <script>
  // ================= 지도 초기화 =================
  let map;
  let vectorLayer;

  $(document).ready(function() {
    try {
      map = new ol.Map({
        target: 'map',
        layers: [
          new ol.layer.Tile({ source: new ol.source.OSM(), zIndex: 0 })
        ],
        view: new ol.View({
          center: ol.proj.fromLonLat([126.9084, 37.5638]), // 마포구 근방
          zoom: 14
        })
      });
      
      // 범례 토글
      const legendBtn = document.getElementById('legendToggleBtn');
      const legendPopup = document.getElementById('mapLegendPopup');

      legendBtn.addEventListener('click', () => {
        if(legendPopup.style.display === 'none' || legendPopup.style.display === '') {
          legendPopup.style.display = 'block';
        } else {
          legendPopup.style.display = 'none';
        }
      });
      

      // 벡터 레이어: 항상 타일 위로
      vectorLayer = new ol.layer.Vector({
        zIndex: 20,
        source: new ol.source.Vector(),
        style: function(feature) {
          const severity = feature.get('severity');
          let color = '#7F7F7F';                 // 기본(데이터 없음)
          if (severity === 0) color = '#2ECC40'; // 보통
          else if (severity === 1) color = '#FF851B'; // 경고
          else if (severity === 2) color = '#FF4136'; // 위험
          else if (severity === 3) color = '#7F7F7F'; // 데이터 없음

          return new ol.style.Style({
            image: new ol.style.Circle({
              radius: 7,
              fill: new ol.style.Fill({ color }),
              stroke: new ol.style.Stroke({ color: '#FFFFFF', width: 2 })
            })
          });
        }
      });
      map.addLayer(vectorLayer);

      // ====== ★ 마커 클릭 → 말풍선 + 하단 시트 오픈 ======
      map.on('singleclick', function(evt) {
        const feature = map.forEachFeatureAtPixel(evt.pixel, f => f);
        if (!feature) return;

        const coord = feature.getGeometry()?.getCoordinates();
        const px = coord ? map.getPixelFromCoordinate(coord) : evt.pixel;

        const facilityId   = feature.get('facilityId');
        const facilityName = feature.get('facilityName') || '시설 정보';
        const address      = feature.get('address') || '';

        if (typeof window.loadFacilityPopup === 'function') {
          window.loadFacilityPopup(facilityId, facilityName, address);
          if (typeof window.positionPopup === 'function') window.positionPopup(px);
        }
        if (typeof window.openTableGraph === 'function') {
          window.openTableGraph(facilityId, facilityName, address);
        }
      });

    } catch (e) {
      console.error("지도 초기화 오류:", e);
    }
  });

  // ================ 좌표 유틸 (WKT 견고 파서) ================
  function parsePointWktToMapCoord(wkt) {
    if (!wkt) return null;
    try {
      const text = String(wkt).trim();
      const m = /^POINT\s*\(\s*([+-]?\d+(\.\d+)?)\s+([+-]?\d+(\.\d+)?)\s*\)$/i.exec(text);
      if (!m) {
        console.warn('[WKT] POINT 파싱 실패:', wkt);
        return null;
      }
      let a = parseFloat(m[1]);
      let b = parseFloat(m[3]);

      const absA = Math.abs(a), absB = Math.abs(b);
      const isLikelyWebMerc = (absA > 180 || absB > 180);
      if (isLikelyWebMerc) return [a, b]; // EPSG:3857

      // 한국 경위도 범위로 순서 추정
      const looksLonLat = (a >= 124 && a <= 132) && (b >= 33 && b <= 39);
      const looksLatLon = (a >= 33 && a <= 39) && (b >= 124 && b <= 132);

      let lon, lat;
      if (looksLonLat) { lon = a; lat = b; }
      else if (looksLatLon) { lon = b; lat = a; }
      else { if (absA <= 90 && absB <= 180) { lon = b; lat = a; } else { lon = a; lat = b; } }

      return ol.proj.fromLonLat([lon, lat]);
    } catch (e) {
      console.warn('[WKT] 파싱 예외:', e, wkt);
      return null;
    }
  }

  // ================= 마커 렌더러 =================
  function addMarkersToMap(markers) {
    try {
      if (!map || !vectorLayer) {
        console.warn('map/vectorLayer 미초기화');
        return;
      }
      const src = vectorLayer.getSource();
      src.clear();

      if (!Array.isArray(markers) || markers.length === 0) {
        console.log('마커 데이터 없음');
        map.renderSync();
        return;
      }

      const coordsAdded = [];
      markers.forEach((marker, idx) => {
        const coord = parsePointWktToMapCoord(marker?.geom);
        if (!coord) {
          console.warn(`마커[${idx}] 좌표 파싱 실패`, marker?.geom);
          return;
        }
        const f = new ol.Feature({
          geometry: new ol.geom.Point(coord),
          severity: (marker?.severity != null ? Number(marker.severity) : 3),
          facilityId: marker?.facilityId,
          facilityType: marker?.facilityType,
          facilityName: marker?.facilityName || null,  // ★ 클릭 시 말풍선/시트 타이틀용
          address: marker?.address || null             // ★ 클릭 시 말풍선 주소용
        });
        src.addFeature(f);
        coordsAdded.push(coord);
      });

      if (coordsAdded.length > 0) {
        const extent = src.getExtent();
        map.getView().fit(extent, { padding: [50, 50, 50, 50], maxZoom: 18, duration: 250 });
      }
      map.renderSync();

      console.log(`[Marker] 추가 완료: ${coordsAdded.length}개`);
    } catch (e) {
      console.error('마커 추가 중 오류:', e);
    }
  }
  // 전역 노출
  window.addMarkersToMap = addMarkersToMap;
  </script>
</body>
</html>
