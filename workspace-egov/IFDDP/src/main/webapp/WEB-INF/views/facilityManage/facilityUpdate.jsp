<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>시설물 관리</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/theme.css">
<!-- 커스텀 스타일 공통 변수 css -->
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/headerMain.css">
<!-- 헤더/content css -->
<!-- adg css -->
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/facilityRegistStyle.css">
</head>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script type="text/javascript">
// 컨트롤러에서 넘어온 메시지를 변수에 담기 (JSP 문법 사용)
const successMessage = "${message}";
const errorMessage = "${errorMessage}"; // ${errorMessage} 로 넘긴다.
// 메시지가 비어있지 않다면 알림창 띄우기
if (successMessage && successMessage.trim() !== "") {
    alert(successMessage);
}
if (errorMessage && errorMessage.trim() !== "") {
    alert(errorMessage);
}

//1. API에서 시설물 종류 데이터 가져오기
$(document).ready(function() {
	$.ajax({
		// 서울시의 모든 구 데이터 가져오기(25개)
		// data.seoul.go.kr 안도건 인증키 : 557152464f64676133394772706c43
		// http://openapi.seoul.go.kr:8088/557152464f64676133394772706c43/xml/SearchMeasuringSTNOfAirQualityService/1/25
        url: 'api/seoul/sigungu', // API 경로
        type: 'GET',
        dataType: 'json',
        success: function(data) {
        	// 현재 시설물의 주소
        	var region = "${facilityDto.region}";
        	
        	let options = "";
            // 데이터가 바로 배열 형태로 오는 경우
            $.each(data, function(index, district) {
                // console.log(index, district);
                // options += "<option value=" + district.code + ">" + district.name + "</option>";
                // 현재 값에 따라 select 설정
                options += "<option value='" + district.name + "' " + (region.includes(district.name) ? 'selected' : '') + ">" + district.name + "</option>";
            });
            
            // console.log(options);
            
            // select 요소에 옵션 추가
            $("#region-sigungu").html(options);
        },
        error: function(error) {
            console.error('시군구 데이터 불러오기 실패했습니다:', error);
        }
	})
	
	// 이전값 선언
	let previousFacilityTypeValue = null;
    $.ajax({
        url: 'allFacilityType', // API 경로
        type: 'GET',
        dataType: 'json',
        success: function(data) {
        	// 현재 시설물의 종류
        	var selectedFacilityType = "${facilityDto.facilityType}";
        	
            // 2. select 옵션 생성하기
            let options = '';
            
            // 3. 데이터 순회하면서 옵션 추가
            $.each(data, function(index, facilityType) {
            	// console.log(facilityType.contents);
            	options += "<option value=" + facilityType.mcd + " " + (selectedFacilityType == facilityType.mcd ? 'selected' : '') + ">" + facilityType.contents + "</option>";
            });
            
            // 4. select 요소에 옵션 추가
            $('#facilityType').html(options);
        	// 이전값 설정
            // previousFacilityTypeValue = $('#facilityType').val(); // 초기값
            // 변경 트리거 발동
            $('#facilityType').trigger('change');
        },
        error: function(error) {
            console.error('시설물 종류 데이터를 불러오는 데 실패했습니다:', error);
        }
    });
    
    let damageCount = 0; // 손상 정보 입력란의 고유 번호를 관리할 변수
	// facilityType select 변경 이벤트 감지
    $('#facilityType').on('change', function() {
        // 최초 선택 시 이전값이 null이면 현재값으로 설정
        if (previousFacilityTypeValue === null) {
            previousFacilityTypeValue = $(this).val();
            
            // 최초 선택 후 DB 시설물의 손상 정보가 있는지 확인
        	var facilityDamageList = "${facilityDto.damageList}";
        	
        	if(facilityDamageList.)
        	
        	console.log(facilityDamageList);
        }
    	// 손상 정보가 있는지 확인
    	const hasDamageRows = $('#damageTableBody tr').length > 0;

    	// 손상 정보가 있을 경우에만 확인 메시지 표시
    	if (hasDamageRows) {
    		// 정말 진행하는지 확인
        	if (confirm('시설물 유형을 변경하면 작성 중인 손상 정보가 모두 삭제됩니다. 계속하시겠습니까?')) {
            	// 기존에 작성된 손상 정보 삭제
                $('#damageTableBody').empty();
        	}
        	else{
        		// 이전값 다시 선택...
            	$(this).val(previousFacilityTypeValue); 
        		return;
        	}
    	}
    	// 이전값을 현재값으로 설정
        previousFacilityTypeValue = $(this).val(); 
    	
        // 선택된 값 가져오기
        var selectedValue = $(this).val();
        var param = 300 + (selectedValue * 10);
        // console.log(param);
        
        // AJAX 호출
        $.ajax({
            url: 'allDamageTypeOfFacility/' + param, // 300 + (시설물Type * 10)
            type: 'GET',
            dataType: 'json',
            success: function(data) {
            	// 손상 정보 템플릿에 손상 유형 추가
	            let options = '';

	            // 3. 데이터 순회하면서 옵션 추가
	            $.each(data, function(index, damageType) {
	            	// console.log(facilityType.contents);
	                options += "<option value=" + damageType.mcd + ">" + damageType.contents + "</option>";
	            });

	            // 4. select 요소에 옵션 추가
	            $('select[name="damageList[INDEX_PLACEHOLDER].damageType"]').html(options);
            },
            error: function(xhr, status, error) {
                console.error('데이터 로드 실패:', error);
            }
        });
    });
	
    // 위에서도 사용하기 떄문에 위로 이동
    // let damageCount = 0; // 손상 정보 입력란의 고유 번호를 관리할 변수
    $('#addDamageBtn').on('click', function() {
    	// 템플릿 HTML 가져오기
        const templateHtml = $('#damageTemplate').html();
        
        // INDEX_PLACEHOLDER를 현재 인덱스로 교체
        const newRowHtml = templateHtml.replace(/INDEX_PLACEHOLDER/g, damageCount);
        
        // 새 행 추가
        $('#damageTableBody').append(newRowHtml);
        
        // console.log(newRowHtml);
        
        // 현재 날짜로 기본 설정
	    var today = new Date();
	    // YYYY-MM-DD 형식으로 변환 (input date 형식)
	    var year = today.getFullYear();
	    var month = String(today.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작해서 +1 해줘야 함
	    var day = String(today.getDate()).padStart(2, '0');
	    var formattedDate = year + '-' + month + '-' + day;
	    
	    // console.log(formattedDate);
	    // console.log(damageCount);
	    
	    // Date 찾기
    	$('input[name="damageList[' + damageCount + '].reportedDate"]').val(formattedDate);

        // 카운터 증가
        damageCount++;
        
        // 삭제 후 번호 재정렬 함수 호출
        updateDamageIndices();
    });
	// 동적으로 생성된 요소에 대한 이벤트 처리는 이벤트 위임 방식으로 해야 한다고 합니다.
    $(document).on('click', '.remove-damage-btn', function() {
        // 현재 클릭한 버튼의 가장 가까운 tr 요소를 찾아서 삭제
        $(this).closest('tr').remove();
        
        // 삭제 후 번호 재정렬 함수 호출
        updateDamageIndices();
    });
 	// 폼 제출 전에 템플릿 요소를 제외시키기
    $('#registFacility').on('submit', function(e) {
        // 템플릿 요소 제거 또는 비활성화
        $('#damageTemplate').prop('disabled', true);
        // 또는
        $('#damageTemplate').remove();
    });
});

//인덱스 재정렬 함수
function updateDamageIndices() {
    // 모든 손상 행 가져오기
    const rows = $('#damageTableBody tr');
    
    // 각 행에 대해 인덱스 업데이트
    rows.each(function(index) {
        const newIndex = index;
        
        // 행의 data-index 속성 업데이트
        $(this).attr('data-index', newIndex);
        
        // 행 번호 표시 업데이트
        $(this).find('.damage-index').text(newIndex + 1); // 표시용+1
        
        // 모든 input, select 요소의 name 속성 업데이트
        $(this).find('input, select, textarea').each(function() {
            const oldName = $(this).attr('name');
            if (oldName) {
                const newName = oldName.replace(/damageList\[\d+\]/, 'damageList[' + newIndex + ']');
                $(this).attr('name', newName);
            }
        });
    });
    
    // damageCount 변수 업데이트 (총 행 개수 + 1)
    damageCount = rows.length + 1;
}
</script>
<body>
	<%-- 사이드바 include: 반드시 BODY 안에 --%>
	<%@ include file="/WEB-INF/views/common/side.jsp"%>

	<!-- 상단 헤더 -->
	<header class="header">
		<h1>시설물 관리</h1>
	</header>

	<!-- 본문 시작(여기부터 입력) -->
	<div class="content">
		<div class="main-title">시설물 수정</div>
		<hr class="main-title-line">
		
		<!-- 시설물 등록 정보 입력 -->
		<form id="registFacility" action="${pageContext.request.contextPath}/facilityUpdate" method="post" enctype="multipart/form-data">
			<div class="form-groups">
				<div>
					<h3>시설물 정보</h3>
					<hr>
				</div>
				<div class="form-row-group">
					<div class="form-group">
		                <label for="facilityName">시설물 명</label>
		                <p/>
		                <input type="text" name="facilityName" class="form-control" value="${facilityDto.facilityName }" required="required" readonly="readonly">
		            </div>
				</div>
				<div class="form-row-group">
					<div class="form-group half-width">
		                <label for="facilityRegion">시설물 주소</label>
		                <p/>
		                <div style="display: flex; gap: 10px;">
			                <select id="region-sido" name="regionSido" style="width: 50%">
			                	<option value="서울특별시">서울특별시</option>
			                </select>
			                <select id="region-sigungu" name="regionSigungu" style="width: 50%">
			                </select>
		                </div>
		            </div>
					<div class="form-group half-width">
		                <label for="facilityAddress">시설물 상세 주소</label>
		                <p/>
		                <input type="text" id="facilityAddress" name="address" class="form-control" placeholder="시설물 상세 주소" value="${facilityDto.address }">
		            </div>
				</div>
				<div class="form-row-group">
					<div class="form-group half-width">
		                <label for="facilityType">시설물 종류</label>
		                <p/>
		                <select id="facilityType" name="facilityType"></select>
		            </div>
					<div class="form-group half-width">
		                <label for="facilityScale">시설물 규모</label>
		                <p/>
		                <select name="facilityScale">
						    <option value="1" ${facilityDto.facilityScale == '1' ? 'selected' : ''}>1종</option>
						    <option value="2" ${facilityDto.facilityScale == '2' ? 'selected' : ''}>2종</option>
						    <option value="3" ${facilityDto.facilityScale == '3' ? 'selected' : ''}>3종</option>
		                </select>
		            </div>
				</div>
				<div class="form-row-group">
					<div class="form-group">
		                <label for="facilityGeom">시설물 위치좌표</label>
		                <p/>
		                <div style="display: flex; gap: 10px;">
			                <label style="display: flex; align-items: center; height: 30px; margin: auto;">위도(Lat):</label>
			                <input type="number" id="facilityGeomX" name="facilityGeomX" class="form-control" placeholder="시설물 위도(Lat)" required="required"
			                step="0.000001" min="33" max="39" value="${facilityDto.facilityGeomX }">
			                <label style="display: flex; align-items: center; height: 30px; margin: auto;">경도(Lon):</label>
			                <input type="number" id="facilityGeomY" name="facilityGeomY" class="form-control" placeholder="시설물 경도(Lon)" required="required"
			                step="0.000001" min="125" max="131" value="${facilityDto.facilityGeomY }">
		                </div>
		            </div>
				</div>
				<div class="form-row-group">
					<div class="form-group">
		                <label for="facilityYearBuilt">준공년도</label>
		                <p/>
		                <fmt:formatDate value="${facilityDto.yearBuilt}" pattern="yyyy-MM-dd" var="formattedYearBuilt" />
		                <input type="date" id="facilityYearBuilt" name="yearBuilt" class="form-control" value="${formattedYearBuilt}">
		            </div>
				</div>
				
				<div>
					<h3>시설물 손상 정보</h3>
					<hr>
				</div>
				<!-- 손상 정보 -->
		    	<table class="board-table">
		            <thead>
		                <tr>
		                    <th>번호</th>
		                    <th>손상 유형</th>
		                    <th>손상 위험도</th>
		                    <th>손상 수</th>
		                    <th>손상 설명</th>
		                    <th>검사관</th>
		                    <th>발생일자</th>
		                    <th>이미지</th>
		                    <th>삭제</th>
		                </tr>
		            </thead>
        			<tbody id="damageTableBody">
	                <!-- 손상 정보가 여기에 추가될 거야 -->
		            </tbody>
		    	</table>
			    <!-- 손상 정보 추가 -->
				<div style="text-align: center;">
					<button type="button" id="addDamageBtn" class="btn btn-outline-secondary mt-3">
				        ➕ 손상 정보 추가
				    </button>
				    <!-- 손상 정보 템플릿 -->
					<table style="display: none;">
					    <tbody id="damageTemplate">
						    <tr data-index="INDEX_PLACEHOLDER">
						        <td class="damage-index">INDEX_PLACEHOLDER</td>
						        <td>
						            <select class="form-select" name="damageList[INDEX_PLACEHOLDER].damageType">
						            <!-- ajax 추가 -->
						            </select>
						        </td>
						        <td>
						            <select class="form-select" name="damageList[INDEX_PLACEHOLDER].severity">
						                <option value="0">선택하세요</option>
						                <option value="1">A</option>
						                <option value="2">B</option>
						                <option value="3">C</option>
						                <option value="4">D</option>
						                <option value="5">E</option>
						            </select>
						        </td>
						        <td>
						            <input type="number" class="form-control" name="damageList[INDEX_PLACEHOLDER].damageCnt" value="0">
						        </td>
						        <td>
						            <input type="text" class="form-control" name="damageList[INDEX_PLACEHOLDER].description" placeholder="손상 설명 입력">
						        </td>
						        <td>
						            <input type="text" class="form-control" name="damageList[INDEX_PLACEHOLDER].inspectorId" placeholder="검사관">
						        </td>
						        <td>
						            <input type="date" class="form-control" name="damageList[INDEX_PLACEHOLDER].reportedDate">
						        </td>
						        <td>
						            <input type="file" class="form-control file-input" name="damageList[INDEX_PLACEHOLDER].damageFiles" multiple>
						        </td>
						        <td>
						            <button type="button" class="delete-btn remove-damage-btn">삭제</button>
						        </td>
						    </tr>
					    </tbody>
					</table>
				</div>
			    
				<div style="display: flex; justify-content: flex-end; gap: 10px;">
					<button type="submit" class="regist-btn">수정</button>
					<button type="button" class="cancel-btn" onclick="location.href='${pageContext.request.contextPath}/facilityList.do'">취소</button>
				</div>
				
			</div>
		</form>
	</div>
	<!-- 본문 끝(여기까지 입력)-->

	<!-- 접힘/펼침 및 드롭다운-접힘 이동 로직 -->
	<script>
	document.addEventListener('DOMContentLoaded', () => {
		const sb  = document.getElementById('sidebar');
		const btn = document.getElementById('sbToggle');
		if (!sb || !btn) return;
		
		btn.addEventListener('click', () => {
			sb.classList.toggle('collapsed');               // 사이드바 폭 토글
			document.body.classList.toggle('is-collapsed'); // 헤더/본문 위치 동기화
			
			btn.innerHTML = sb.classList.contains('collapsed')
			  ? '<i class="bi bi-chevron-double-right"></i>'
			  : '<i class="bi bi-chevron-double-left"></i>';
		});
		
		// 접힘 상태에서 드롭다운 summary 클릭 → 기본 URL로 이동
		document.querySelectorAll('details.menu > summary').forEach(sum => {
			sum.addEventListener('click', (e) => {
				if (document.body.classList.contains('is-collapsed')) {
					e.preventDefault();
					e.stopPropagation();
					const url = sum.parentElement.dataset.href || sum.dataset.href;
					if (url) location.href = url;
				}
			});
		});
	});
	</script>
</body>
</html>