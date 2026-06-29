import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../provider/trip_provider.dart';

class ImagePickerSheet extends ConsumerStatefulWidget {
  const ImagePickerSheet({super.key});

  @override
  ConsumerState<ImagePickerSheet> createState() => _ImagePickerSheetState();
}

class _ImagePickerSheetState extends ConsumerState<ImagePickerSheet> {
  List<XFile> _galleryImages = [];
  final Set<int> _selectedIndexes = {};
  bool _loading = false;
  
  // 💡 최대 선택 가능 개수 설정
  final int _maxImageLimit = 30; 

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    // 초기 로드 로직 (필요 시 유지)
  }

  Future<void> _pickFromGallery() async {
    // 💡 1. 갤러리를 열기 전 로딩 상태 활성화
    setState(() => _loading = true);

    try {
      final picker = ImagePicker();
      // 💡 limit 파라미터로 갤러리 자체에서 개수를 제한 (지원하는 OS 버전에서 작동)
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
        limit: _maxImageLimit, 
      );

      if (picked.isNotEmpty) {
        // 💡 2. 만약 사용자가 제한 개수를 초과해서 선택하려고 했거나, 많이 선택한 경우 안내
        if (picked.length > _maxImageLimit) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('사진은 최대 $_maxImageLimit장까지만 선택 가능합니다.')),
            );
          }
          // 제한된 개수만큼만 잘라서 할당
          setState(() {
            _galleryImages = picked.sublist(0, _maxImageLimit);
            _selectedIndexes.clear();
          });
        } else {
          setState(() {
            _galleryImages = picked;
            _selectedIndexes.clear();
          });
        }
      }
    } catch (e) {
      // 에러 처리
    } finally {
      // 💡 3. 이미지 처리가 끝나면 로딩 상태 해제
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmSelection() async {
    final selected = _selectedIndexes.map((i) => _galleryImages[i]).toList();
    if (selected.isEmpty) {
      Navigator.pop(context);
      return;
    }

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
              padding: const EdgeInsets.only(top: 4, bottom: 4, left: 16, right: 10),
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
                        onPressed: _loading ? null : _pickFromGallery, // 로딩 중 클릭 방지
                        child: Text(
                          '갤러리열기 ',
                          style: TextStyle(color: Colors.indigo.shade600),
                        ),
                      ),
                      if (_selectedIndexes.isNotEmpty && !_loading) ...[
                        ElevatedButton(
                          onPressed: _confirmSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('선택 완료 (${_selectedIndexes.length})'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 이미지 그리드 목록 영역
            Expanded(
              // 💡 로딩 바가 돌 때 스피너를 보여줌으로써 앱이 멈추지 않았음을 인지시킴
              child: _loading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('이미지를 불러오는 중입니다...'),
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
                                '"갤러리 열기"를 눌러 사진을 불러오세요\n(최대 $_maxImageLimit장)',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                      cacheWidth: 300, // 💡 메모리 최적화를 위해 캐시 사이즈 제한
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