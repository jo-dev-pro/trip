import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trip/model/trip_comment_model.dart';

// ─── 💡 [풀스크린 버전] 사진 전체 화면 및 하단 코멘트 오버레이 뷰어 ───
class ImageCommentViewer extends StatefulWidget {
  final List<TripCommentModel> imageComments;
  final int initialIndex;

  const ImageCommentViewer({
    super.key,
    required this.imageComments,
    required this.initialIndex,
  });

  @override
  State<ImageCommentViewer> createState() => _ImageCommentViewerState();
}

class _ImageCommentViewerState extends State<ImageCommentViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // 💡 사용자가 선택한 사진 위치에서 스크롤이 시작되도록 설정
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 보고 있는 페이지의 데이터 모델 확보
    final currentItem = widget.imageComments[_currentIndex];
    final totalCount = widget.imageComments.length;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // 💡 [핵심] 상단 중앙에 현재 이미지 순서 표시 (예: 3 / 15)
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentIndex + 1} / $totalCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 🔴 [핵심] 좌우 슬라이드가 가능한 PageView 배치
          PageView.builder(
            controller: _pageController,
            itemCount: totalCount,
            physics: const BouncingScrollPhysics(), // 부드러운 스크롤 바운스 효과
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index; // 페이지가 바뀔 때마다 인덱스 및 코멘트 갱신
              });
            },
            itemBuilder: (context, index) {
              final item = widget.imageComments[index];
              return InteractiveViewer(
                maxScale: 4.0,
                child: Center(
                  child: Image.file(
                    File(item.path),
                    fit: BoxFit.contain, // 💡 슬라이드 감상 시 사진 전체 비율이 깨지지 않도록 수리
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),

          // 2. 하단 코멘트 가독성을 위한 암전 블러 패널
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: IgnorePointer( // 패널 뒤의 사진 줌인/멀티터치를 방해하지 않음
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. 🔴 현재 인덱스 항목의 코멘트 실시간 바인딩 노출
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MEMO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // 데이터가 비어있을 때의 기본 플레이스홀더 처리 포함
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.18,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          currentItem.comment.isEmpty 
                              ? '등록된 메모가 없습니다.' 
                              : currentItem.comment,
                          style: TextStyle(
                            color: currentItem.comment.isEmpty ? Colors.grey : Colors.white,
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            shadows: const [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}