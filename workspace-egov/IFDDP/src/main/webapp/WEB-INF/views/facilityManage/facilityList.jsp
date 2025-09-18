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
	href="${pageContext.request.contextPath}/resources/css/facilityListStyle.css">
</head>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script><!-- jquery 사용 -->
<script src="https://cdn.jsdelivr.net/npm/xlsx/dist/xlsx.full.min.js"></script><!-- xlsx파일 사용 -->
<script>
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
	
    // 전역 변수 설정
    let currentPage = 0;
    const itemsPerPage = 10;
    let loading = false;
    let allItemsLoaded = false;
    
    // 페이지 로드 시 초기 데이터 세팅
    $(document).ready(function() {
        // 초기 데이터는 이미 서버에서 렌더링됨
        setupInfiniteScroll();
    });
    
    // 무한 스크롤 설정
    function setupInfiniteScroll() {
        // Intersection Observer 생성
        const options = {
            root: null,
            rootMargin: '0px',
            threshold: 0.1
        };
        
        const observer = new IntersectionObserver(handleIntersect, options);
        
        // 테이블 마지막 행을 관찰 대상으로 설정
        const target = document.querySelector('.board-table tbody tr:last-child');
        if (target) {
            observer.observe(target);
        }
    }
    
    // 관찰 대상이 화면에 보일 때 실행되는 함수
    function handleIntersect(entries, observer) {
        entries.forEach(entry => {
            if (entry.isIntersecting && !loading && !allItemsLoaded) {
                loadMoreItems();
            }
        });
    }
    
    // 추가 데이터 로드 함수
    function loadMoreItems() {
        loading = true;
        
        // 로딩 표시 추가
        $('.board-table tbody').append('<tr class="loading-row"><td colspan="5" style="text-align:center;">로딩 중...</td></tr>');

        $.ajax({
            url: '${pageContext.request.contextPath}/facility?searchType=${facilityDto.searchType}&searchValue=${facilityDto.searchValue}',
            type: 'GET',
            data: {
                page: currentPage,
                size: itemsPerPage
            },
            success: function(response) {
                // 로딩 표시 제거
                $('.loading-row').remove();
                
                // 데이터가 없으면 모든 항목 로드 완료
                if (response.length === 0) {
                    allItemsLoaded = true;
                    $('.board-table tbody').append('<tr class="end-row"><td colspan="6" style="text-align:center;">모든 시설물을 불러왔어요! 🎉</td></tr>');
                    return;
                }
                
                // 받은 데이터를 테이블에 추가
                let html = '';
                response.forEach((facility, index) => {
                	// 타임스탬프를 날짜 형식으로 변환
                    let yearBuiltFormatted = facility.yearBuilt;
                    // 숫자인 경우(타임스탬프)에만 변환 처리
                    if (!isNaN(facility.yearBuilt)) {
                        const date = new Date(parseInt(facility.yearBuilt));
                        yearBuiltFormatted = date.getFullYear() + '-' + 
                                            (date.getMonth() + 1).toString().padStart(2, '0') + '-' + 
                                            date.getDate().toString().padStart(2, '0');
                    }

                    const count = (currentPage * 10) + index + 1;
                    
                	html += '<tr>' +
                    '<td style="text-align: center;">' + count + '</td>' +  // 여기에 count 추가
                    '<td style="text-align: center;">' + (facility.facilityId || '') + '</td>' +
                    '<td>' + (facility.facilityName || '') + '</td>' +
                    '<td>' + (facility.region || '') + '</td>' +
                    '<td>' + (facility.address || '') + '</td>' +
                    '<td style="text-align: center;">' + yearBuiltFormatted + '</td>' +
                    '</tr>';
                    // console.log(facility.facilityName);
                });

                
                // console.log(html);
                
                // 새 데이터를 테이블에 추가
                $('.board-table tbody').append(html);
                
                // 새로 추가된 마지막 행에 observer 다시 설정
                setupInfiniteScroll();
                
                loading = false;
            },
            error: function(error) {
                $('.loading-row').remove();
                $('.board-table tbody').append('<tr class="error-row"><td colspan="5" style="text-align:center;">데이터를 불러오는 중 오류가 발생했어요 😥</td></tr>');
                console.error('데이터 로드 실패:', error);
                loading = false;
            },
            // finally
            complete: function() {
            	currentPage++;
            }
        });
    }
    
	function facilityDownload(){
		// JSP 변수를 JavaScript 변수로 저장
		const contextPath = "${pageContext.request.contextPath}";
	
		/* 검색조건에 맞는 데이터 모두 가져온다(AJAX) */
		fetch(contextPath + "/facilityDownload")
			.then(response => response.json())
			.then(data => {
				
				// 워크북 생성
				const workbook = XLSX.utils.book_new();
	
				// JSON을 워크시트로 변환
				const worksheet = XLSX.utils.json_to_sheet(data);
	
				// 워크시트를 워크북에 추가
				XLSX.utils.book_append_sheet(workbook, worksheet, "시설물 목록");
	
				// 현재 시간 포맷팅하기
				const now = new Date();
				const year = now.getFullYear();
				const month = String(now.getMonth() + 1).padStart(2, '0');
				const day = String(now.getDate()).padStart(2, '0');
	
				// 시간 문자열 만들기
				const timeString = year + month + day;
	
				// 파일로 저장
				// 브라우저에서는 다운로드 형태로 저장됨
				XLSX.writeFile(workbook, "시설물 목록" + timeString + ".xlsx");
			})
			.catch(error => console.error("다운로드 오류:", error));
	}
	
	$(function() {
	    $('#excelFileUpload').on('change', function() {
	        const selectedFile = this.files[0];
	        if(selectedFile) {
	        	// 파일 전달을 위해 FormData 객체 생성
	            const formData = new FormData();
	            formData.append('file', selectedFile);
	            
	         	// Ajax로 컨트롤러 호출
	            $.ajax({
	                url: '${pageContext.request.contextPath}/facilityUpload', // 컨트롤러 URL
	                type: 'POST',
	                data: formData,
	                processData: false,  // 필수: FormData 처리 방지
	                contentType: false,  // 필수: 컨텐트 타입 자동 설정
	                success: function(response) {
	                    console.log('업로드 성공:', response);
	                    alert('Excel 파일 업로드 성공!');
	                    // 성공 후 처리 (예: 페이지 새로고침)
	                    // location.reload();
	                },
	                error: function(error) {
	                    console.error('업로드 실패:', error);
	                    alert('Excel 파일 업로드 실패!');
	                },
	                // finally
	                complete: function() {
	                	// 새로고침
	                	location.reload();
	                }
	            });
	        }
	    });
	});
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
		<div class="main-title">시설물 목록</div>
		<hr class="main-title-line">
		
		<div class="control-div">
			<!-- 등록 -->
			<button class="regist-btn" onclick="location.href='facilityRegist.do'">등록</button>
			<button class="regist-btn" onclick="facilityDownload()">Excel 다운로드</button>
			<input type="file" id="excelFileUpload" style="display: none;">
			<button class="regist-btn" onclick="document.getElementById('excelFileUpload').click()">Excel 업로드</button>
			<!-- 검색 -->
			<div style="margin: auto 0 auto auto;">
				<form action="${pageContext.request.contextPath}/facilityList.do">
					<label class="search-label">검색조건</label>
					<select class="search-select" name="searchType">
						<option value="FACILITY_ID" ${facilityDto.searchType == 'FACILITY_ID' ? 'selected' : ''}>ID</option>
						<option value="FACILITY_NAME" ${facilityDto.searchType == 'FACILITY_NAME' ? 'selected' : ''}>시설물 이름</option>
						<option value="ADDRESS" ${facilityDto.searchType == 'ADDRESS' ? 'selected' : ''}>주소</option>
						<option value="YEAR_BULIT" ${facilityDto.searchType == 'YEAR_BULIT' ? 'selected' : ''}>준공년도</option>
					</select>
					<input class="search-text" type="text" name="searchValue">
					<input class="search-button" type="submit" value="검색">
				</form>
			</div>
		</div>
		<div style="text-align: right; margin-top: 5px;">
			<span>검색결과 : ${facilityListCount}건</span>
		</div>
		
		<table class="board-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>ID</th>
                    <th>시설물 이름</th>
                    <th>지역</th>
                    <th>주소</th>
                    <th>준공년도</th>
                </tr>
            </thead>
            <tbody>
	            <tr>
	            </tr>
            	<%-- 
                <c:choose>
                    <c:when test="${not empty facilityList}">
                        <c:forEach var="facility" items="${facilityList}" varStatus="status">
                            <tr>
                                <td style="text-align: center;">${status.count}</td>
                                <td style="text-align: center;">${facility.facilityId}</td>
                                <td>${facility.facilityName}</td>
                                <td>${facility.region}</td>
                                <td>${facility.address}</td>
                                <td style="text-align: center;"><fmt:formatDate value="${facility.yearBuilt}" pattern="yyyy-MM-dd"/></td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise> <!-- facilityList가 비어있다면 -->
                        <tr>
                            <td colspan="5" class="no-data">🥲 표시할 시설물 정보가 없어요.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                 --%>
            </tbody>
        </table>
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