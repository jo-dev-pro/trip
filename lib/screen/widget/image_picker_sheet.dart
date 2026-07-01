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

  bool _loading = false; // 로딩 상태 관리
  final int _maxImageLimit = 30; // 최대 선택 제한

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickFromGallery() async {
    // 💡 누르자마자 즉시 로딩 서클 시작
    setState(() {
      _loading = true;
    });

    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 85);

      if (picked.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      // 💡 [확실한 개수 제한] 30개 초과 시 즉시 강제 커트
      List<XFile> finalImages = picked;
      if (picked.length > _maxImageLimit) {
        finalImages = picked.sublist(0, _maxImageLimit);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('사진은 최대 $_maxImageLimit장까지만 선택 가능합니다. (초과분 제외)'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // 💡 이 단계를 거쳐야 UI가 로딩바를 인지하고 스위칭할 시간을 법니다.
      await Future.delayed(const Duration(milliseconds: 150));

      if (mounted) {
        setState(() {
          _galleryImages = finalImages;
          _selectedIndexes.clear();
          _loading = false; // 데이터 할당 후 로딩 해제
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

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

  bool get _isAllSelected =>
      _galleryImages.isNotEmpty &&
      _selectedIndexes.length == _galleryImages.length;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      snap: true, // 💡 시트가 중간에 어정쩡하게 걸리지 않고 딱딱 붙게 만듦
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // 드래그 핸들 (시트 자체를 내릴 수 있는 영역)
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
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                  TextButton(
                    onPressed: _loading ? null : _pickFromGallery,
                    child: Text(
                      '  갤러리  ',
                      style: TextStyle(color: Colors.indigo.shade600),
                    ),
                  ),
                  if (_galleryImages.isNotEmpty && !_isAllSelected && !_loading)
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
                  if (_selectedIndexes.isNotEmpty && !_loading)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: _confirmSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            // 본문 영역
            Expanded(
              child: _loading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.indigo.shade400),
                          const SizedBox(height: 16),
                          const Text('사진을 불러오는 중...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : _galleryImages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                '"갤러리"를 눌러 사진을 불러오세요\n(최대 $_maxImageLimit장)',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          // 💡 매우 중요: 시트의 스크롤 컨트롤러를 바인딩하여 
                          // 리스트 스크롤 시 시트가 닫히는 충돌 현상을 방지합니다.
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