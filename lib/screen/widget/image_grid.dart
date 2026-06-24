import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trip/model/trip_comment_model.dart';

// 이미지 그리드 (선택된 이미지 목록)
class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key, required this.images, required this.onRemove, required this.onCommentChanged});

  final List<TripCommentModel> images;
  final void Function(int) onRemove;
  final void Function(int, String) onCommentChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = images[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 썸네일
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
                // child:
                //         Image.network(
                //             item.imagePath,
                //             fit: BoxFit.cover,
                //

                child: Image.file(
                  File(item.path),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image,
                        color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 코멘트 입력
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    // [핵심 1] 하이브 데이터가 변경(로드 완료)되면 TextFormField를 새로 그리도록 고유 키 부여
                    key: ValueKey(item.path),
                    
                    // [핵심 2] 하이브에서 가져온 코멘트 값을 초기값으로 세팅
                    initialValue: item.comment,
                    decoration: InputDecoration(
                      hintText: '이미지 설명 (선택)',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => onCommentChanged(i, v),
                  ),
                ),
              ),
              // 삭제 버튼
              IconButton(
                icon: Icon(Icons.close_rounded,
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
