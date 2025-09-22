<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>강수량 모니터링 시스템</title>

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
  
  /* 강수량 모니터링 전용 스타일 */
  .rainfall-controls {
    background: white;
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 15px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
  }
  
  .control-buttons {
    display: flex;
    gap: 10px;
    align-items: center;
    flex-wrap: wrap;
    margin-bottom: 10px;
  }
  
  .btn-rainfall {
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    font-weight: bold;
    cursor: pointer;
    transition: all 0.3s ease;
    font-size: 0.9rem;
  }
  
  .btn-start { background: #28a745; color: white; }
  .btn-stop { background: #dc3545; color: white; }
  .btn-reset { background: #6c757d; color: white; }
  .btn-lock { background: #007bff; color: white; }
  
  .btn-rainfall:hover { transform: translateY(-1px); }
  .btn-rainfall:disabled { opacity: 0.6; cursor: not-allowed; }
  
  .status-indicator {
    margin-left: auto;
    padding: 5px 12px;
    border-radius: 15px;
    font-size: 0.8rem;
    font-weight: bold;
  }
  
  .status-ready { background: #e9ecef; color: #495057; }
  .status-running { background: #d4edda; color: #155724; }
  .status-stopped { background: #f8d7da; color: #721c24; }
  .status-locked { background: #cce5ff; color: #004085; }
  
  /* 지도 고정 상태 */
  .map-locked #map { cursor: not-allowed; }
  .map-locked::after {
    content: "지도 고정됨";
    position: absolute;
    top: 10px;
    left: 10px;
    background: rgba(0, 123, 255, 0.9);
    color: white;
    padding: 5px 10px;
    border-radius: 5px;
    font-size: 12px;
    z-index: 1000;
  }
  
  /* 범례 버튼 */
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
    background: white;
    border: 1px solid #ccc;
    border-radius: 4px;
  }
  
  /* 강수량 범례 팝업 */
  .rainfall-legend-popup {
    position: absolute;
    top: 40px;
    right: 10px;
    background: rgba(255,255,255,0.95);
    padding: 12px;
    border-radius: 8px;
    font-size: 12px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.3);
    z-index: 1000;
    display: none;
    min-width: 180px;
  }
  
  .rainfall-legend-popup h4 {
    margin: 0 0 8px 0;
    font-size: 14px;
    color: #333;
  }
  
  .rainfall-legend-popup ul {
    margin: 0;
    padding: 0;
    list-style: none;
  }
  
  .rainfall-legend-popup li {
    display: flex;
    align-items: center;
    margin-bottom: 4px;
  }
  
  .rainfall-dot {
    width: 14px;
    height: 14px;
    border-radius: 50%;
    margin-right: 8px;
    border: 2px solid white;
    box-shadow: 0 1px 3px rgba(0,0,0,0.3);
  }
  
  .rainfall-dot.red { background: #dc3545; }
  .rainfall-dot.orange { background: #fd7e14; }
  .rainfall-dot.yellow { background: #ffc107; }
  .rainfall-dot.blue { background: #007bff; }
  
  /* 데이터 테이블 */
  .rainfall-data-section {
    background: white;
    border-radius: 10px;
    padding: 15px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    min-height: 400px !important;
    display: block !important;
    visibility: visible !important;
  }
  
  .data-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid #dee2e6;
  }
  
  .data-title {
    font-size: 1.2rem;
    font-weight: bold;
    color: #495057;
  }
  
  .data-count {
    background: #007bff;
    color: white;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 0.8rem;
    font-weight: bold;
  }
  
  .table-container {
    max-height: 300px;
    min-height: 100px;
    overflow-y: auto;
    border: 1px solid #dee2e6;
    border-radius: 6px;
    display: block !important;
    visibility: visible !important;
  }
  
  #rainfall-table {
    width: 100%;
    border-collapse: collapse;
    margin: 0;
    font-size: 0.85rem;
    display: table !important;
  }
  
  #rainfall-table thead {
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: white;
    position: sticky;
    top: 0;
    z-index: 10;
  }
  
  #rainfall-table th,
  #rainfall-table td {
    padding: 8px 10px;
    text-align: left;
    border-bottom: 1px solid #dee2e6;
  }
  
  #rainfall-table th {
    font-weight: bold;
    font-size: 0.8rem;
  }
  
  #rainfall-table tbody tr:nth-child(even) {
    background-color: #f8f9fa;
  }
  
  #rainfall-table tbody tr:hover {
    background-color: #e9ecef;
  }
  
  #rainfall-table-body {
    display: table-row-group !important;
    visibility: visible !important;
  }
  
  /* 강수량별 색상 */
  .rainfall-high { color: #dc3545; font-weight: bold; }
  .rainfall-medium { color: #fd7e14; font-weight: bold; }
  .rainfall-low { color: #28a745; }
</style>
</head>

<body>
  <%@ include file="/WEB-INF/views/common/side.jsp"%>

  <header class="header">
    <h1>강수량 모니터링 시스템</h1>
  </header>

  <div class="content">
    <div class="ap5-layout">
      <!-- 왼쪽 패널 -->
      <aside class="ap5-left">
        <!-- 지역 선택 -->
        <section class="ap5-card">
          <h2 class="ap5-h2">지역 선택</h2>
          <div class="ap5-grid-2">
            <label class="ap5-field">
              <span class="ap5-label">시/도</span>
              <select class="ap5-input" disabled>
                <option>서울특별시</option>
              </select>
            </label>
            <label class="ap5-field">
              <span class="ap5-label">시/군/구</span>
              <select class="ap5-input" disabled>
                <option>마포구</option>
              </select>
            </label>
          </div>
          <p style="font-size: 0.8rem; color: #6c757d; margin: 10px 0 0 0;">
            * 강수량 모니터링은 마포구로 고정됩니다
          </p>
        </section>

        <!-- 사회기반시설 선택 -->
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

        <!-- 시뮬레이션 제어 -->
        <section class="ap5-card rainfall-controls">
          <h2 class="ap5-h2">시뮬레이션 제어</h2>
          <div class="control-buttons">
            <button id="startBtn" class="btn-rainfall btn-start">시작</button>
            <button id="stopBtn" class="btn-rainfall btn-stop" disabled>정지</button>
            <button id="resetBtn" class="btn-rainfall btn-reset">초기화</button>
            <button id="lockBtn" class="btn-rainfall btn-lock">지도고정</button>
          </div>
          <div id="statusDisplay" class="status-indicator status-ready">대기중</div>
        </section>

        <!-- 시설물 정보 -->
        <section class="ap5-card">
          <div class="ap5-kpi">
            <span>마포구 시설물 수</span> 
            <strong id="facilityCount">0</strong>
          </div>
        </section>
        
        <!-- 강수량 범례 -->
        <section class="ap5-card">
          <h2 class="ap5-h2">강수량 구역</h2>
          <ul class="ap5-legend">
            <li><span class="ap5-dot ap5-dot--danger"></span>빨간색: 80-100mm (매우강함)</li>
            <li><span class="ap5-dot ap5-dot--warn"></span>주황색: 50-79mm (강함)</li>
            <li><span class="ap5-dot ap5-dot--ok"></span>노란색: 20-49mm (보통)</li>
            <li><span class="ap5-dot ap5-dot--none"></span>파란색: 5-19mm (약함)</li>
          </ul>
        </section>
      </aside>
         
      <!-- 지도 위 범례 버튼 -->
      <div id="legendBtnContainer">
        <button id="legendToggleBtn">범례</button>
      </div>
      
      <!-- 지도 위 범례 팝업 -->
      <div id="mapLegendPopup" class="rainfall-legend-popup">
        <h4>강수량 구역</h4>
        <ul>
          <li><span class="rainfall-dot red"></span> 빨간색: 80-100mm</li>
          <li><span class="rainfall-dot orange"></span> 주황색: 50-79mm</li>
          <li><span class="rainfall-dot yellow"></span> 노란색: 20-49mm</li>
          <li><span class="rainfall-dot blue"></span> 파란색: 5-19mm</li>
        </ul>
      </div>

      <!-- 오른쪽 상단: 지도 -->
      <section class="ap5-right-top" aria-label="강수량 모니터링 지도">
        <div id="mapWrapper" style="position:relative;">
          <div id="map" class="ap5-canvas"></div>
        </div>
      </section>

      <!-- 오른쪽 하단: 데이터 테이블 -->
      <section class="ap5-right-bottom rainfall-data-section">
        <div class="data-header">
          <div class="data-title">강수량 측정 데이터</div>
          <div class="data-count">총 <span id="dataCount">0</span>건</div>
        </div>
        
        <div class="table-container">
          <table id="rainfall-table">
            <thead>
              <tr>
                <th>측정시간</th>
                <th>시설물명</th>
                <th>강수량(mm)</th>
                <th>위도</th>
                <th>경도</th>
                <th>색상구역</th>
              </tr>
            </thead>
            <tbody id="rainfall-table-body">
              <!-- 데이터가 동적으로 추가됨 -->
            </tbody>
          </table>
        </div>
      </section>
    </div>
  </div>

  <script>
    // ================= 강수량 모니터링 설정 =================
    
    // 구름 설정
    const cloudConfig = {
      size: 5000,           // 최대 반지름
      speed: 1000,         // 이동속도 (ms)
      centerLat: 37.5663,  // 시작 중심좌표
      centerLng: 126.8800
    };

    // 색상별 구역 및 강수량
    const colorZones = {
      RED: { radius: 1000, minRain: 80, maxRain: 100 },
      ORANGE: { radius: 2000, minRain: 50, maxRain: 79 },
      YELLOW: { radius: 3000, minRain: 20, maxRain: 49 },
      BLUE: { radius: 4000, minRain: 5, maxRain: 19 }
    };

    // 이동 단계 설정
    const simulationSteps = 30;
    
    // ================= 전역 변수 =================
    let map;
    let vectorLayer;
    let movingObjectLayer;
    let isMapLocked = false;
    let isSimulationRunning = false;
    let simulationInterval = null;
    let facilities = [];
    let dataCount = 0;
    let sessionId = null;
    let recordedFacilities = new Set(); // 이미 기록된 시설물 추적
    let facilityTimers = new Map(); // 시설물별 마지막 기록 시간

    // ================= 페이지 초기화 =================
    $(document).ready(function() {
      initializeMap();
      loadFacilities();
      bindEvents();
      bindFacilityTypeEvents();
      updateStatus('ready', '대기중');
    });

    // ================= 사회기반시설 버튼 이벤트 =================
    function bindFacilityTypeEvents() {
      $(".ap5-chip").on("click", function() {
        const raw = $(this).val();
        const type = (raw === undefined || raw === null || raw === "") ? null : Number(raw);

        console.log("[RAINFALL CHIP AJAX] 요청 시작");
        
        $.ajax({
          url: "${pageContext.request.contextPath}/rainfall/facilities.do",
          type: "GET",
          success: function(result) {
            console.log("[RAINFALL CHIP AJAX] 응답 받음:", result);
            
            if (result && result.markers) {
              facilities = result.markers.map(function(marker) {
                const coords = parseWKTToLatLng(marker.geom);
                return {
                  facilityId: marker.facilityId,
                  facilityName: marker.facilityName || '시설물',
                  latitude: coords ? coords.lat : null,
                  longitude: coords ? coords.lng : null,
                  address: marker.address || '',
                  severity: marker.severity || 3
                };
              }).filter(f => f.latitude && f.longitude);
              
              displayFacilities();
              $('#facilityCount').text(facilities.length);
              console.log('필터링된 시설물 데이터:', facilities.length + '개');
            } else {
              facilities = [];
              $('#facilityCount').text(0);
            }
          },
          error: function(xhr, status, error) {
            console.error("[RAINFALL CHIP AJAX] 에러:", error);
          }
        });
      });
    }

    // ================= 지도 초기화 =================
    function initializeMap() {
      try {
        map = new ol.Map({
          target: 'map',
          layers: [
            new ol.layer.Tile({ 
              source: new ol.source.OSM(), 
              zIndex: 0 
            })
          ],
          view: new ol.View({
            center: ol.proj.fromLonLat([cloudConfig.centerLng, cloudConfig.centerLat]),
            zoom: 14
          })
        });

        // 시설물 마커 레이어
        vectorLayer = new ol.layer.Vector({
          zIndex: 10,
          source: new ol.source.Vector(),
          style: new ol.style.Style({
            image: new ol.style.Circle({
              radius: 6,
              fill: new ol.style.Fill({ color: '#007bff' }),
              stroke: new ol.style.Stroke({ color: '#ffffff', width: 2 })
            })
          })
        });
        map.addLayer(vectorLayer);

        // 이동 객체 레이어
        movingObjectLayer = new ol.layer.Vector({
          zIndex: 20,
          source: new ol.source.Vector()
        });
        map.addLayer(movingObjectLayer);

        // 범례 토글 이벤트
        const legendBtn = document.getElementById('legendToggleBtn');
        const legendPopup = document.getElementById('mapLegendPopup');
        legendBtn.addEventListener('click', () => {
          legendPopup.style.display = (legendPopup.style.display === 'none' || legendPopup.style.display === '') ? 'block' : 'none';
        });

        console.log('지도 초기화 완료');
      } catch (e) {
        console.error("지도 초기화 오류:", e);
      }
    }

    // ================= 시설물 데이터 로드 =================
    function loadFacilities() {
      console.log('[RAINFALL] 전체 시설물 로드 시작');
      
      const allButton = $('.ap5-chip').first();
      if (allButton.length > 0) {
        console.log('[RAINFALL] "전체" 버튼 클릭으로 시설물 로드');
        allButton.trigger('click');
      } else {
        console.log('[RAINFALL] 직접 AJAX로 시설물 로드');
        
        $.ajax({
          url: "${pageContext.request.contextPath}/rainfall/facilities.do",
          type: "GET",
          success: function(result) {
            console.log("[RAINFALL AJAX] 응답 받음:", result);
            
            if (result && result.markers && result.markers.length > 0) {
              facilities = result.markers.map(function(marker) {
                const coords = parseWKTToLatLng(marker.geom);
                return {
                  facilityId: marker.facilityId,
                  facilityName: marker.facilityName || '시설물',
                  latitude: coords ? coords.lat : null,
                  longitude: coords ? coords.lng : null,
                  address: marker.address || '',
                  severity: marker.severity || 3
                };
              }).filter(f => f.latitude && f.longitude);
              
              displayFacilities();
              $('#facilityCount').text(facilities.length);
              console.log('DB 시설물 데이터 로드 완료:', facilities.length + '개');
            } else {
              console.warn('시설물 데이터가 없습니다.');
              facilities = [];
              $('#facilityCount').text(0);
            }
          },
          error: function(xhr, status, error) {
            console.error("[RAINFALL AJAX] 에러:", error);
            facilities = [];
            $('#facilityCount').text(0);
          }
        });
      }
    }

    // ================= WKT 좌표 파싱 유틸리티 =================
    function parseWKTToLatLng(wkt) {
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

        const looksLonLat = (a >= 124 && a <= 132) && (b >= 33 && b <= 39);
        const looksLatLon = (a >= 33 && a <= 39) && (b >= 124 && b <= 132);

        let lng, lat;
        if (looksLonLat) { lng = a; lat = b; }
        else if (looksLatLon) { lng = b; lat = a; }
        else { lng = a; lat = b; }

        return { lat: lat, lng: lng };
      } catch (e) {
        console.warn('[WKT] 파싱 예외:', e, wkt);
        return null;
      }
    }

    // ================= 시설물 마커 표시 =================
    function displayFacilities() {
      const source = vectorLayer.getSource();
      source.clear();

      facilities.forEach(function(facility) {
        if (facility.latitude && facility.longitude) {
          const coord = ol.proj.fromLonLat([facility.longitude, facility.latitude]);
          const feature = new ol.Feature({
            geometry: new ol.geom.Point(coord),
            facilityId: facility.facilityId,
            facilityName: facility.facilityName
          });
          
          feature.setStyle(new ol.style.Style({
            image: new ol.style.Circle({
              radius: 8,
              fill: new ol.style.Fill({ color: '#007bff' }),
              stroke: new ol.style.Stroke({ color: '#ffffff', width: 2 })
            }),
            text: new ol.style.Text({
              text: facility.facilityName,
              font: '12px Arial',
              fill: new ol.style.Fill({ color: '#000' }),
              stroke: new ol.style.Stroke({ color: '#fff', width: 2 }),
              offsetY: -25
            })
          }));
          
          source.addFeature(feature);
        }
      });
    }

    // ================= 이벤트 바인딩 =================
    function bindEvents() {
      $('#startBtn').click(startSimulation);
      $('#stopBtn').click(stopSimulation);
      $('#resetBtn').click(resetSimulation);
      $('#lockBtn').click(toggleMapLock);
    }

    // ================= 지도 고정/해제 =================
    function toggleMapLock() {
      isMapLocked = !isMapLocked;
      const mapWrapper = $('#mapWrapper');
      const lockBtn = $('#lockBtn');
      
      if (isMapLocked) {
        map.getInteractions().forEach(function(interaction) {
          if (interaction instanceof ol.interaction.DragPan || 
              interaction instanceof ol.interaction.MouseWheelZoom ||
              interaction instanceof ol.interaction.DoubleClickZoom) {
            interaction.setActive(false);
          }
        });
        mapWrapper.addClass('map-locked');
        lockBtn.text('고정해제').removeClass('btn-lock').addClass('btn-stop');
        updateStatus('locked', '지도고정됨');
      } else {
        map.getInteractions().forEach(function(interaction) {
          interaction.setActive(true);
        });
        mapWrapper.removeClass('map-locked');
        lockBtn.text('지도고정').removeClass('btn-stop').addClass('btn-lock');
        if (!isSimulationRunning) {
          updateStatus('ready', '대기중');
        }
      }
    }

    // ================= 시뮬레이션 시작 =================
    function startSimulation() {
      if (isSimulationRunning) return;

      sessionId = 'SIM_' + new Date().getTime();
      createMovingObject();
      
      isSimulationRunning = true;
      let step = 0;
      
      simulationInterval = setInterval(function() {
        if (step >= simulationSteps) {
          stopSimulation();
          return;
        }
        
        updateMovingObject(step, simulationSteps);
        detectAndRecordFacilities();
        step++;
      }, cloudConfig.speed);

      $('#startBtn').prop('disabled', true);
      $('#stopBtn').prop('disabled', false);
      updateStatus('running', '실행중');
      
      console.log('시뮬레이션 시작');
    }

    // ================= 시뮬레이션 정지 =================
    function stopSimulation() {
      if (!isSimulationRunning) return;

      clearInterval(simulationInterval);
      isSimulationRunning = false;

      movingObjectLayer.getSource().clear();

      $('#startBtn').prop('disabled', false);
      $('#stopBtn').prop('disabled', true);
      
      if (isMapLocked) {
        updateStatus('locked', '지도고정됨');
      } else {
        updateStatus('stopped', '정지됨');
      }
      
      console.log('시뮬레이션 정지');
    }

    // ================= 시뮬레이션 초기화 =================
    function resetSimulation() {
      stopSimulation();
      
      $('#rainfall-table-body').empty();
      dataCount = 0;
      $('#dataCount').text(dataCount);
      recordedFacilities.clear();
      
      if (isMapLocked) {
        updateStatus('locked', '지도고정됨');
      } else {
        updateStatus('ready', '대기중');
      }
      sessionId = null;
      
      console.log('시뮬레이션 초기화');
    }

    // ================= 이동 객체 생성 =================
function createMovingObject() {
  const startCoord = ol.proj.fromLonLat([cloudConfig.centerLng, cloudConfig.centerLat]);
  const source = movingObjectLayer.getSource();
  source.clear();

  Object.entries(colorZones).reverse().forEach(function([zoneName, zoneConfig]) {
    const circle = new ol.Feature({
      geometry: new ol.geom.Point(startCoord),
      zoneType: zoneName
    });
    
    let color;
    switch(zoneName) {
      case 'RED': color = '#dc3545'; break;
      case 'ORANGE': color = '#fd7e14'; break;
      case 'YELLOW': color = '#ffc107'; break;
      case 'BLUE': color = '#007bff'; break;
    }
    
    // 실제 거리에 맞는 픽셀 계산
    const view = map.getView();
    const resolution = view.getResolution();
    const pixelRadius = zoneConfig.radius / resolution;
    
    circle.setStyle(new ol.style.Style({
      image: new ol.style.Circle({
        radius: pixelRadius,
        fill: new ol.style.Fill({ 
          color: color + '30'
        }),
        stroke: new ol.style.Stroke({ 
          color: color, 
          width: 2 
        })
      })
    }));
    
    source.addFeature(circle);
  });
}

    // ================= 이동 객체 위치 업데이트 =================
   function updateMovingObject(step, totalSteps) {
  const startLng = cloudConfig.centerLng;
  const endLng = 126.9400;
  const lat = cloudConfig.centerLat;
  
  const progress = step / totalSteps;
  const currentLng = startLng + (endLng - startLng) * progress;
  const currentCoord = ol.proj.fromLonLat([currentLng, lat]);

  movingObjectLayer.getSource().getFeatures().forEach(function(feature) {
    feature.getGeometry().setCoordinates(currentCoord);
  });
}

 // ================= 시설물 감지 및 데이터 기록 (수정) =================
   function detectAndRecordFacilities() {
  const movingFeatures = movingObjectLayer.getSource().getFeatures();
  if (movingFeatures.length === 0) {
    console.log('[DEBUG] 이동 객체가 없습니다.');
    return;
  }

  const centerCoord = movingFeatures[0].getGeometry().getCoordinates();
  const centerLonLat = ol.proj.toLonLat(centerCoord);
  
  console.log('[DEBUG] 구름 위치:', centerLonLat);
  console.log('[DEBUG] 시설물 수:', facilities.length);

  facilities.forEach(function(facility) {
    if (!facility.latitude || !facility.longitude) return;

    const distanceInMeters = calculateDistanceInMeters(
      centerLonLat[1], centerLonLat[0], 
      facility.latitude, facility.longitude
    );

    console.log(`[DEBUG] ${facility.facilityName}: ${distanceInMeters.toFixed(0)}m`);

    let detectedZone = null;

    for (const [zoneName, zoneConfig] of Object.entries(colorZones)) {
      if (distanceInMeters <= zoneConfig.radius) {
        detectedZone = zoneName;
        break;
      }
    }

    if (detectedZone) {
      const now = Date.now();
      const lastRecorded = facilityTimers.get(facility.facilityId) || 0;
      
      if (now - lastRecorded >= 1000) { // 1초 경과했을 때만 기록
        console.log(`[DEBUG] ${facility.facilityName} 감지됨! 구역: ${detectedZone}`);
        recordRainfallData(facility, detectedZone, distanceInMeters);
        facilityTimers.set(facility.facilityId, now);
      }
    }
  });
}


    // ================= 정확한 거리 계산 =================
    function calculateDistanceInMeters(lat1, lon1, lat2, lon2) {
      const R = 6371000;
      const dLat = (lat2 - lat1) * Math.PI / 180;
      const dLon = (lon2 - lon1) * Math.PI / 180;
      const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                Math.sin(dLon/2) * Math.sin(dLon/2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      return R * c;
    }

    // ================= 강수량 데이터 기록 =================
    function recordRainfallData(facility, zoneName, distance) {
      try {
        console.log('[DEBUG] recordRainfallData 시작:', facility.facilityName);
        
        const zoneConfig = colorZones[zoneName];
        const rainfall = generateRandomRainfall(zoneConfig.minRain, zoneConfig.maxRain);
        
        const data = {
          facilityId: facility.facilityId,
          facilityName: facility.facilityName,
          rainfall: parseFloat(rainfall),
          latitude: facility.latitude,
          longitude: facility.longitude,
          colorZone: zoneName,
          distance: distance.toFixed(1),
          sessionId: sessionId
        };
        
        console.log('[DEBUG] 데이터 객체 생성 완료:', data);
        addDataToTable(data);
        
      } catch (error) {
        console.error('[ERROR] recordRainfallData에서 에러 발생:', error);
      }
    }

    // ================= 랜덤 강수량 생성 =================
    function generateRandomRainfall(min, max) {
      return (Math.random() * (max - min) + min).toFixed(1);
    }

    // ================= 테이블에 데이터 추가 (단순화) =================
    function addDataToTable(data) {
      console.log('[DEBUG] addDataToTable 호출됨:', data.facilityName);
      
      const now = new Date();
      const timeString = now.toLocaleTimeString('ko-KR');
      
      const zoneDisplayName = {
        'RED': '빨간색',
        'ORANGE': '주황색', 
        'YELLOW': '노란색',
        'BLUE': '파란색'
      }[data.colorZone] || data.colorZone;

      // 단순한 HTML로 변경
      const newRow = '<tr>' +
        '<td>' + timeString + '</td>' +
        '<td>' + data.facilityName + '</td>' +
        '<td>' + data.rainfall + 'mm</td>' +
        '<td>' + data.latitude.toFixed(4) + '</td>' +
        '<td>' + data.longitude.toFixed(4) + '</td>' +
        '<td>' + zoneDisplayName + '</td>' +
        '</tr>';

      console.log('[DEBUG] 생성된 HTML:', newRow);
      
      $('#rainfall-table-body').append(newRow);
      
      dataCount++;
      $('#dataCount').text(dataCount);
      
      console.log('[DEBUG] 테이블 추가 완료, 현재 행 수:', $('#rainfall-table-body tr').length);

      // 최대 50개 데이터만 유지
      const rows = $('#rainfall-table-body tr');
      if (rows.length > 50) {
        rows.first().remove();
      }
    }

    // ================= 상태 업데이트 =================
    function updateStatus(status, text) {
      const statusDisplay = $('#statusDisplay');
      statusDisplay.removeClass('status-ready status-running status-stopped status-locked');
      statusDisplay.addClass('status-' + status);
      statusDisplay.text(text);
    }
  </script>
</body>
</html>