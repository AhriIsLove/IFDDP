<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!-- ===================== facilityDamagegraph.jsp (FRAGMENT) ===================== -->
<!-- 오버레이(기본) + 카드 임베드(.tg-embed 래퍼 사용 시) 두 모드 지원 -->

<style>
  /* ===== 기본: 오버레이 모드 (마커 클릭 시 떠서 보임) ===== */
  #tablegraphSheet{
    position: fixed; left: 16px; right: 16px; bottom: 16px;
    min-height: 30vh; background: #fff; border-radius: 14px;
    box-shadow: 0 8px 32px rgba(0,0,0,.22);
    transform: translateY(24px);
    transition: transform .28s ease, opacity .2s ease;
    z-index: 900; /* 말풍선(예: 1000)보다 낮게 */
    display: none; opacity: 0; /* 초기 숨김 */
  }
  #tablegraphSheet.open { opacity: 1; transform: translateY(0); }

  #tablegraphSheet .tg-handle { width: 40px; height: 4px; background: #e5e7eb; border-radius: 9999px; margin: 10px auto 6px; }
  #tablegraphSheet .tg-header { display:flex; align-items:center; justify-content:space-between; padding: 10px 14px; border-bottom: 1px solid #eee; }
  #tablegraphSheet .tg-title  { font-weight: 800; font-size: 14px; color:#1f2937; }
  #tablegraphSheet .tg-sub    { font-size:12px; color:#6b7280; margin-top:2px; }
  #tablegraphSheet .tg-btn    { border:1px solid #e5e7eb; background:#f9fafb; padding:6px 10px; border-radius:8px; cursor:pointer; font-size:12px; }

  #tablegraphSheet .tg-body   { display:flex; gap:22px; padding: 12px 14px; height: calc(30vh - 74px); overflow:auto; }
  #tablegraphSheet .tg-summary { min-width: 280px; flex: 0 0 320px; }

  #tablegraphSheet table { border-collapse: collapse; width:100%; background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,.06) }
  #tablegraphSheet th { background:#2c5aa0; color:#fff; padding:10px; text-align:center; font-weight:700; font-size:12px; }
  #tablegraphSheet td { padding:8px 10px; text-align:center; border-bottom:1px solid #eee; font-size:12px; }
  #tablegraphSheet tr:nth-child(even){ background:#f8f9fa; }
  #tablegraphSheet .tg-no { padding:24px; color:#666; font-style:italic; text-align:center; }
  #tablegraphSheet .tg-count { font-weight:700; color:#1976d2; }

  #tablegraphSheet .tg-chartwrap { flex: 1; min-width: 420px; }
  #tablegraphSheet #tgLegend { display:flex; gap:10px; flex-wrap:wrap; justify-content:flex-start; margin:6px 0 10px; }
  #tablegraphSheet .tg-legend-chip { display: inline-flex; align-items: center; gap: 4px; padding: 4px 8px; border-radius:3px; box-shadow: inset 0 0 0 1px rgba(0,0,0,.15); font-size: 11px; color: white; font-weight: 500; }

  /* ===== 임베드 모드: include 래퍼 섹션에 .tg-embed 클래스가 있을 때 적용 =====
     예) <section class="ap5-right-bottom ap5-card tg-embed"> ... include ... </section> */
  .tg-embed #tablegraphSheet{
    position: static; left:auto; right:auto; bottom:auto;
    width:100%; min-height: 180px; height: 180px; max-height: 180px;
    margin: 0; box-shadow: none; z-index: auto;
    display: block; opacity: 1; transform: none; /* 항상 보임 */
  }
  .tg-embed #tablegraphSheet .tg-body{ height: 140px !important; }
  .tg-embed #tablegraphSheet .tg-handle{ display:none; } /* 카드 안에선 핸들 숨김(선택) */
</style>

<div id="tablegraphSheet" aria-hidden="true">
  <div class="tg-handle"></div>
  <div class="tg-header">
    <div>
      <div class="tg-title" id="tgTitle">시설 일간 통계</div>
      <div class="tg-sub"   id="tgSub"></div>
    </div>
    
  

  <div class="tg-body">
    <!-- 좌측: 요약 테이블 -->
    <div class="tg-summary">
      <table>
        <thead>
          <tr>
            <th style="width:45%;">손상유형</th>
            <th style="width:25%;">영향도</th>
            <th style="width:30%;">발생건수</th>
          </tr>
        </thead>
        <tbody id="tgSummaryBody">
          <!-- 스켈레톤 행은 JS가 채웁니다 -->
        </tbody>
      </table>
    </div>

    <!-- 우측: 복합 그래프 -->
    <div class="tg-chartwrap">
      <!-- 동적으로 생성되는 범례 -->
      <div id="tgLegend"></div>
      <canvas id="tgDamageChart" height="120" aria-label="damage chart"></canvas>
    </div>
  </div>
</div>

<script>
  // ====== Consts ======
  const TG_TYPES   = ['균열','누전','누수','변형','구조이상'];
  const SEVERITY_COLORS = {
    'A': '#dc2626', // 빨강
    'B': '#ea580c', // 주황
    'C': '#eab308', // 노랑
    'D': '#84cc16', // 연두색
    'E': '#16a34a'  // 초록색
  };
  const BASE = '${pageContext.request.contextPath}';

  // 임베드 여부 감지: include를 감싸는 섹션에 .tg-embed 클래스가 있으면 true
  const TG_EMBED = !!document.querySelector('.tg-embed #tablegraphSheet');

  // ====== Public API (map.jsp에서 호출) ======
  window.openTableGraph = async function(facilityId, facilityName, facilityAddress, from=null, to=null){
    const sheet = document.getElementById('tablegraphSheet');

    // 표시 제어: 오버레이만 열고/닫음, 임베드는 항상 보임
    if (!TG_EMBED) {
      sheet.style.display = 'block';
      requestAnimationFrame(()=>sheet.classList.add('open'));
    }

    document.getElementById('tgTitle').textContent = facilityName ? (facilityName + ' · 일간 통계') : '시설 일간 통계';
    document.getElementById('tgSub').textContent   = facilityAddress || '';

    // 1) 스켈레톤 요약표/차트 즉시 렌더 (DB와 무관하게 틀 먼저)
    renderSummarySkeleton();
    const skeletonLabels = buildSkeletonLabels(from, to);
    ensureChartJs(() => initChartSkeleton(skeletonLabels));

    // 2) 데이터 로드 후 갱신
    const params = new URLSearchParams({ facilityId: String(facilityId) });
    if (from) params.set('from', from);
    if (to)   params.set('to',   to);

    try{
      const resp = await fetch(BASE + '/api/damage/statistics?' + params.toString());
      if(!resp.ok) throw new Error('통계 API 오류');
      const data = await resp.json();

      updateSummaryTable(data?.summaryData || []);
      const dd = data?.dailyData || { counts:[], typeDist:[], impactScores:[] };
      updateChartWithData(dd, data?.summaryData || []);
    }catch(err){
      console.error(err); /* 실패 시 스켈레톤 그대로 유지 */
    }
  };

  window.toggleTableGraph = function(){
    if (TG_EMBED) return; // 임베드 모드에선 토글 무의미
    const sheet = document.getElementById('tablegraphSheet');
    sheet.classList.toggle('open');
  };

  window.closeTableGraph = function(){
    if (TG_EMBED) return; // 임베드 모드에선 닫기 무의미
    const sheet = document.getElementById('tablegraphSheet');
    sheet.classList.remove('open');
    setTimeout(()=>{ if(!sheet.classList.contains('open')) sheet.style.display='none'; }, 280);
  };

  // ====== Internal State ======
  let tgChart = null;

  // ====== Skeleton helpers ======
  function renderSummarySkeleton(){
    const tb = document.getElementById('tgSummaryBody');
    tb.innerHTML = TG_TYPES.map(t =>
      '<tr>' +
        '<td>' + escapeHtml(t) + '</td>' +
        '<td>-</td>' +
        '<td><span class="tg-count">0</span></td>' +
      '</tr>'
    ).join('');
  }

  function buildSkeletonLabels(from, to){
    const lbls = [];
    if (from && to) {
      const d1 = parseDateLoose(from), d2 = parseDateLoose(to);
      if (d1 && d2) {
        let cur = new Date(d1); cur.setHours(0,0,0,0);
        const end = new Date(d2); end.setHours(0,0,0,0);
        let cnt=0, cap=90;
        while (cur <= end && cnt < cap) {
          lbls.push(fmtMonthDay(cur));
          cur.setDate(cur.getDate()+1); cnt++;
        }
      }
    }
    if (!lbls.length) {
      const today = new Date(); today.setHours(0,0,0,0);
      for (let i=13; i>=0; i--) {
        const d = new Date(today); d.setDate(today.getDate()-i);
        lbls.push(fmtMonthDay(d));
      }
    }
    return lbls;
  }

  function parseDateLoose(s){
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s||'');
    if (!m) return null;
    return new Date(Number(m[1]), Number(m[2])-1, Number(m[3]));
  }
  function fmtMonthDay(d){
    const m = d.getMonth()+1, day = d.getDate();
    return m + '월 ' + (day<10?('0'+day):day) + '일';
  }

  // ====== Chart (skeleton first) ======
  function ensureChartJs(cb){
    if (typeof Chart !== 'undefined') { cb(); return; }
    const id = 'chartjs-cdn-loader';
    if (document.getElementById(id)) {
      document.getElementById(id).addEventListener('load', cb, { once:true });
      return;
    }
    const s = document.createElement('script');
    s.id = id; s.src = 'https://cdn.jsdelivr.net/npm/chart.js';
    s.onload = cb; s.onerror = () => console.warn('Chart.js 로드 실패');
    document.head.appendChild(s);
  }

  function initChartSkeleton(labels){
    const ctx = document.getElementById('tgDamageChart').getContext('2d');

    // 스켈레톤 범례
    updateLegendDynamic([]);

    // 축을 항상 보이게 하기 위한 더미 데이터셋 (hidden)
    const hiddenBarDummy  = { type:'bar',  label:'_', data: labels.map(()=>0), hidden:true, yAxisID:'y'  };
    const hiddenLineDummy = { type:'line', label:'_', data: labels.map(()=>0), hidden:true, yAxisID:'y1', tension:0.25 };

    if (tgChart) tgChart.destroy();

    tgChart = new Chart(ctx, {
      data: { labels, datasets: [hiddenBarDummy, hiddenLineDummy] },
      options: {
        responsive:true, maintainAspectRatio:false,
        interaction:{ mode:'index', intersect:false },
        plugins:{ legend:{ display:false }, tooltip:{ enabled:true } },
        scales:{
          x:{
            stacked:true,
            grid:{ display:true, drawBorder:true },
            ticks:{ autoSkip:true, maxRotation:0, minRotation:0 }
          },
          y:{
            stacked:true, beginAtZero:true,
            title:{ display:true, text:'건수' },
            grid:{ display:true, drawBorder:true },
            ticks:{ stepSize:5 },
            suggestedMin:0, suggestedMax:20
          },
          y1:{
            position:'right', beginAtZero:true,
            title:{ display:true, text:'영향도' },
            grid:{ drawOnChartArea:false, display:true },
            ticks:{ stepSize:10 },
            suggestedMin:0, suggestedMax:100
          }
        }
      }
    });
  }

  function updateChartWithData(dailyData, summaryData){
    if (!tgChart) return;

    const labels = uniqueDatesFromCounts(dailyData?.counts);
    if (labels.length) tgChart.data.labels = labels;

    const typeDist = dailyData?.typeDist || [];
    const typesInData = Array.from(new Set(typeDist.map(d => (d?.damageType && d.damageType.name) || '기타')));
    const types = typesInData.length ? typesInData : TG_TYPES;

    // 동적 범례 업데이트 (손상 유형과 해당 손상 등급의 색상으로)
    updateLegendDynamic(summaryData);

    const barSets = types.map((t,i)=>{
      // summaryData에서 해당 손상 유형의 severity 찾기
      const summary = summaryData.find(s => 
        (s?.damageType && s.damageType.name === t) || s?.damageTypeName === t
      );
      const severity = summary?.severity || summary?.damageImpact || 'E';
      const color = SEVERITY_COLORS[severity] || SEVERITY_COLORS['E'];

      return {
        type:'bar',
        label:t,
        data: (tgChart.data.labels || []).map(lbl=>{
          const f = typeDist.find(d => d?.dateLabel===lbl && ((d?.damageType && d.damageType.name) === t));
          return f ? Number(f.count) : 0;
        }),
        backgroundColor: color
      };
    });

    const impactData = (tgChart.data.labels || []).map(lbl=>{
      const f = (dailyData?.impactScores || []).find(d => d?.dateLabel === lbl);
      return f ? Number(f.score) : 0;
    });
    const lineSet = { type:'line', label:'영향도', data: impactData, yAxisID:'y1', tension:0.25, spanGaps:true };

    const dummies = (tgChart.data.datasets || []).filter(ds => ds.hidden === true);
    tgChart.data.datasets = [...dummies, ...barSets, lineSet];

    tgChart.update();
  }

  function uniqueDatesFromCounts(counts){
    const seen = new Set(); const out = [];
    (counts||[]).forEach(it=>{ const k=it?.dateLabel; if(k && !seen.has(k)){ seen.add(k); out.push(k); }});
    return out;
  }

  function updateLegendDynamic(summaryData){
    const el = document.getElementById('tgLegend');
    if (!summaryData || !summaryData.length) {
      el.innerHTML = ''; // 데이터 없으면 범례 숨김
      return;
    }

    el.innerHTML = summaryData.map(item => {
      const typeName = (item?.damageType && item.damageType.name) || item?.damageTypeName || '기타';
      const severity = item?.severity || item?.damageImpact || 'E';
      const color = SEVERITY_COLORS[severity] || SEVERITY_COLORS['E'];
      
      return '<span class="tg-legend-chip" style="background-color:' + color + '">' + 
             escapeHtml(typeName) + ' (' + severity + ')' +
             '</span>';
    }).join('');
  }

  // ====== Summary table (data) ======
  function updateSummaryTable(rows){
    const tb = document.getElementById('tgSummaryBody');
    if(!rows || !rows.length){ return; } // 스켈레톤 유지
    tb.innerHTML = rows.map(r=>{
      const typeName = (r?.damageType && typeof r.damageType==='object') ? (r.damageType.name || '') : (r.damageTypeName || r.damageType || '');
      const sev      = r?.severity || r?.damageImpact || '';
      const cnt      = Number(r?.totalCount || r?.damageCnt || 0);
      return '<tr>' +
        '<td>' + escapeHtml(typeName) + '</td>' +
        '<td>' + escapeHtml(sev) + '</td>' +
        '<td><span class="tg-count">' + cnt + '</span></td>' +
        '</tr>';
    }).join('');
  }

  // ====== Helpers ======
  function escapeHtml(s){
    if (s == null) return '';
    return String(s)
      .replaceAll('&','&amp;')
      .replaceAll('<','&lt;')
      .replaceAll('>','&gt;')
      .replaceAll('"','&quot;')
      .replaceAll("'","&#39;");
  }
</script>