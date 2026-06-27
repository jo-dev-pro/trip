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
  bool _loading = false; // 갤러리 picker 대기 중
  bool _rendering = false; // 💡 이미지 그리드 렌더링 중

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    // 💡 갤러리에서 선택 완료 → 렌더링 시작 전 로딩 표시
    setState(() {
      _loading = true;
      _rendering = true;
    });

    // 다음 프레임에 이미지 목록 세팅 → UI가 로딩 인디케이터를 먼저 그린 뒤 이미지 로드
    await Future.microtask(() {
      if (mounted) {
        setState(() {
          _galleryImages = picked;
          _selectedIndexes.clear();
          _loading = false; // 목록은 세팅됐지만 렌더링은 아직
        });
      }
    });

    // 💡 이미지가 실제로 화면에 그려진 뒤 렌더링 완료 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _rendering = false);
    });
  }

  // 💡 전체 선택
  void _selectAll() {
    setState(() {
      _selectedIndexes.addAll(List.generate(_galleryImages.length, (i) => i));
    });
  }

  Future<void> _confirmSelection() async {
    final selected = _selectedIndexes.map((i) => _galleryImages[i]).toList();
    if (selected.isEmpty) {
      Navigator.pop(context);
      return;
    }
    await ref.read(tripFormProvider.notifier).addImagesFromGallery(selected);
    if (mounted) Navigator.pop(context);
  }

  // 전체선택 여부
  bool get _isAllSelected =>
      _galleryImages.isNotEmpty &&
      _selectedIndexes.length == _galleryImages.length;

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
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  // 닫기
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context),
                    tooltip: '닫기',
                  ),
                  // 제목
                  Expanded(
                    child: Text(
                      '사진 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 갤러리 열기
                  TextButton(
                    onPressed: (_loading || _rendering)
                        ? null
                        : _pickFromGallery,
                    child: Text(
                      '갤러리',
                      style: TextStyle(color: Colors.indigo.shade600),
                    ),
                  ),
                  // 💡 전체선택: 이미지 있고 전체 미선택 상태일 때만 표시
                  if (_galleryImages.isNotEmpty &&
                      !_isAllSelected &&
                      !_rendering)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: TextButton(
                        onPressed: _selectAll,
                        child: Text(
                          '전체선택',
                          style: TextStyle(color: Colors.indigo.shade400),
                        ),
                      ),
                    ),
                  // 선택완료
                  if (_selectedIndexes.isNotEmpty && !_rendering)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: _confirmSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('완료 (${_selectedIndexes.length})'),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 본문
            Expanded(
              child: _loading || _rendering
                  // 💡 갤러리 선택 후 이미지 로딩 중 → 인디케이터 + 안내 문구
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.indigo.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '사진을 불러오는 중...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
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
                                  cacheWidth: 300,
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
