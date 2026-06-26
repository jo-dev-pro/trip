import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip/provider/trip_provider.dart'; // 💡 수정된 통합 프로바이더 경로로 변경

class ImagePickerSheet extends ConsumerStatefulWidget {
  const ImagePickerSheet({super.key});

  @override
  ConsumerState<ImagePickerSheet> createState() => _ImagePickerSheetState();
}

class _ImagePickerSheetState extends ConsumerState<ImagePickerSheet> {
  List<XFile> _galleryImages = [];
  final Set<int> _selectedIndexes = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    setState(() => _loading = true);
    // photo_manager 미사용 시, 진입하자마자 갤러리를 자동으로 열어주는 흐름도 좋습니다.
    setState(() => _loading = false);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() {
        _galleryImages = picked;
        _selectedIndexes.clear();
      });
    }
  }

  Future<void> _confirmSelection() async {
    final selected = _selectedIndexes.map((i) => _galleryImages[i]).toList();
    if (selected.isEmpty) {
      Navigator.pop(context);
      return;
    }

    // 💡 변경: 기존 createNotifier 대신 새롭게 설계한 tripFormNotifier를 트리거합니다.
    await ref
        .read(tripFormProvider.notifier)
        .addImagesFromGallery(selected);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 헤더 영역
            Padding(
              padding: const EdgeInsets.only(top:4, bottom: 4, left: 16, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '사진 선택',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _pickFromGallery,
                        child: Text(
                          '갤러리열기 ',
                          style: TextStyle(color: Colors.indigo.shade600),
                        ),
                      ),
                      if (_selectedIndexes.isNotEmpty) ...[
                        ElevatedButton(
                          onPressed: _confirmSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('선택 완료 (${_selectedIndexes.length})'),
                        ),
                      ],
                      // 💡 닫기 버튼 (실수로 닫히지 않도록 명시적 버튼으로만 닫기)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade600),
                        onPressed: () => Navigator.pop(context),
                        tooltip: '닫기',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 이미지 그리드 목록 영역
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _galleryImages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '"갤러리 열기"를 눌러 사진을 불러오세요',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                      itemCount: _galleryImages.length,
                      itemBuilder: (_, i) {
                        final isSelected = _selectedIndexes.contains(i);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedIndexes.remove(i);
                              } else {
                                _selectedIndexes.add(i);
                              }
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_galleryImages[i].path),
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,   // 💡 썸네일 크기로 디코딩 → 메모리/속도 개선
                                  cacheHeight: 300,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.indigo.shade600,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
