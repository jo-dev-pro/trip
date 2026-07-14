import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 💡 캐싱 패키지 적용

import '../../model/trip_comment_model.dart';

/// ── 💡 [클라우드 대응형] 선택 이미지 목록 그리드 위젯 ──
class ImageGrid extends StatelessWidget {
  const ImageGrid({
    super.key,
    required this.images,
    required this.onRemove,
    required this.onCommentChanged,
    this.coverImagePath,         // 현재 대표 이미지 경로 (로컬 또는 웹 URL)
    this.onCoverImageChanged,    // 대표 이미지 변경 콜백
  });

  final List<TripCommentModel> images;
  final void Function(int) onRemove;
  final void Function(int, String) onCommentChanged;
  final String? coverImagePath;
  final void Function(String? path)? onCoverImageChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = images[i];
        
        // 💡 주소가 파이어베이스 원격 스토리지 경로(HTTP)인지 로컬 샌드박스 경로인지 판별
        final isNetwork = item.path.startsWith('http') || item.path.startsWith('https');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 썸네일 표시 및 대표 이미지 오버레이 핸들러
              GestureDetector(
                onTap: () {
                  if (onCoverImageChanged != null) {
                    final isCover = coverImagePath == item.path;
                    onCoverImageChanged!(isCover ? null : item.path);
                  }
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: isNetwork
                            ? CachedNetworkImage(
                                imageUrl: item.path,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 1.5),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                                ),
                              )
                            : Image.file(
                                File(item.path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                                ),
                              ),
                      ),
                    ),
                    // 대표 이미지 표식 (노란색 별)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(
                        coverImagePath == item.path ? Icons.star : Icons.star_border,
                        color: coverImagePath == item.path ? Colors.amber : Colors.white,
                        size: 20,
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 이미지별 설명 텍스트 입력부
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    key: ValueKey(item.path),
                    initialValue: item.comment,
                    decoration: InputDecoration(
                      hintText: '이미지 설명 (선택)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400, 
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => onCommentChanged(i, v),
                  ),
                ),
              ),
              // 이미지 개별 삭제 버튼
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Colors.red.shade400, size: 20),
                onPressed: () => onRemove(i),
              ),
            ],
          ),
        );
      },
    );
  }
}