import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/daily_note_model.dart';
import '../../provider/trip_detail_state.dart';
import '../../provider/trip_provider.dart';
import '../../screen/widget/date_button.dart';
import '../../screen/widget/field_label.dart';
import '../../screen/widget/image_grid.dart';
import '../../screen/widget/image_picker_sheet.dart';
import '../../screen/widget/section_card.dart';
import '../../screen/widget/styled_text_field.dart';

class EditScreen extends ConsumerStatefulWidget {
  final TripDetailState tripState;

  const EditScreen({super.key, required this.tripState});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final List<TextEditingController> _themeCtrls = [];
  
  // 저장 중 상태를 명확하게 제어하기 위한 로컬 변수
  bool _isSavingLocal = false;

  @override
  void initState() {
    super.initState();
    // 데이터 소스가 위젯 생성 시점에 확실하므로 포스트 프레임 콜백 없이 즉시 초기화하여 
    // 깜빡임 및 초기 렌더링 지연을 방지합니다.
    _initializeControllers();
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    for (var ctrl in _themeCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    final trip = widget.tripState.trip;
    final comments = widget.tripState.comments;
    final dailyNotes = widget.tripState.dailyNotes;

    // Riverpod Provider 상태 초기화 (창이 열릴 때 최초 1회)
    ref.read(tripFormProvider.notifier).setTravel(trip, comments, dailyNotes);

    _titleCtrl.text = trip.title;
    _placeCtrl.text = trip.place;
    _noteCtrl.text = trip.note ?? '';

    _themeCtrls.clear();

    if (trip.startDate != null && trip.endDate != null) {
      final days = trip.endDate!.difference(trip.startDate!).inDays + 1;
      for (int i = 0; i < days; i++) {
        final currentDay = i + 1;
        final matchedNote = dailyNotes.firstWhere(
          (note) => note.dayCount == currentDay,
          orElse: () => DailyNoteModel(comment: ''),
        );
        _themeCtrls.add(TextEditingController(text: matchedNote.comment));
      }
    }
  }

  void _pickDate({required bool isStart}) async {
    final formValue = ref.read(tripFormProvider).value;
    if (formValue == null) return;

    final tripModel = formValue.trip;
    if (tripModel.startDate == null || tripModel.endDate == null) return;

    final originalDays =
        tripModel.endDate!.difference(tripModel.startDate!).inDays + 1;

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? tripModel.startDate! : tripModel.endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    final newStart = isStart ? picked : tripModel.startDate!;
    final newEnd = isStart ? tripModel.endDate! : picked;
    final newDays = newEnd.difference(newStart).inDays + 1;

    if (newDays <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시작일은 종료일보다 앞서야 합니다.')),
        );
      }
      return;
    }

    if (newDays < originalDays) {
      if (!mounted) return;
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            '여행 기간 축소 안내',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '여행 기간을 줄이면, 제외되는 날짜에 작성된 일별 주제 및 노트가 \'영구 삭제\'됩니다.\n정말 변경하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('변경', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final notifier = ref.read(tripFormProvider.notifier);
    if (isStart) {
      notifier.updateStartDate(picked);
    } else {
      notifier.updateEndDate(picked);
    }

    _rebalanceThemeControllers(newDays);
  }

  void _rebalanceThemeControllers(int targetDays) {
    if (targetDays <= 0) return;

    if (_themeCtrls.length < targetDays) {
      while (_themeCtrls.length < targetDays) {
        _themeCtrls.add(TextEditingController(text: ''));
      }
    } else if (_themeCtrls.length > targetDays) {
      while (_themeCtrls.length > targetDays) {
        _themeCtrls.last.dispose();
        _themeCtrls.removeLast();
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _onUpdate() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSavingLocal = true;
    });

    try {
      final notifier = ref.read(tripFormProvider.notifier);
      
      // 💡 [중요] 저장 직전, 컨트롤러에 남아있는 최종 텍스트 값을 상태에 최종 반영합니다.
      for (int i = 0; i < _themeCtrls.length; i++) {
        notifier.updateDailyNoteComment(i + 1, _themeCtrls[i].text.trim());
      }

      await notifier.save(
        title: _titleCtrl.text.trim(),
        place: _placeCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
      );

      if (mounted) {
        final tripId = widget.tripState.trip.id;
        if (tripId != null) {
          ref.invalidate(tripDetailProvider(tripId));
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingLocal = false;
        });
      }
    }
  }

  void _showImageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const ImagePickerSheet(),
    );
  }

  Future<void> _onDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('여행 일정 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말로 이 여행 일정을 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final tripId = widget.tripState.trip.id;
    if (tripId == null) return;

    try {
      await ref.read(tripListProvider.notifier).deleteTrip(tripId);
      if (!mounted) return;
      ref.read(tripListProvider.notifier).refresh();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripFormProvider);
    final notifier = ref.read(tripFormProvider.notifier);

    return formState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('에러 발생: $err'))),
      data: (formValue) {
        final currentImages = notifier.currentImages;
        final model = formValue.trip;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.indigo.shade700,
            foregroundColor: Colors.white,
            title: const Text('여행 일정 수정', style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: '일정 삭제',
                onPressed: _isSavingLocal ? null : _onDelete,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── 제목 ──
                SectionCard(
                  children: [
                    FieldLabel(text: '제목 *'),
                    const SizedBox(height: 8),
                    StyledTextField(
                      controller: _titleCtrl,
                      hint: '여행 제목을 입력하세요',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '제목을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── 여행지 ──
                SectionCard(
                  children: [
                    FieldLabel(text: '여행지 *'),
                    const SizedBox(height: 8),
                    StyledTextField(
                      controller: _placeCtrl,
                      hint: '예) 제주도, 도쿄, 파리',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '여행지를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── 날짜 ──
                SectionCard(
                  children: [
                    FieldLabel(text: '여행 기간 *'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DateButton(
                            label: '시작일',
                            date: model.startDate,
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '~',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: DateButton(
                            label: '종료일',
                            date: model.endDate,
                            onTap: () => _pickDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── 일자별 주제 입력 ──
                if (model.startDate != null && model.endDate != null) ...[
                  SectionCard(
                    children: [
                      FieldLabel(text: '일자별 여행 주제 입력 *'),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _themeCtrls.length,
                        itemBuilder: (context, index) {
                          final currentDay = index + 1;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 55,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '$currentDay일차 :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    // Key를 부여하여 Rebalance(원소 가감) 시 상태가 꼬이지 않도록 명시합니다.
                                    key: ValueKey('day_${currentDay}_ctrl'),
                                    controller: _themeCtrls[index],
                                    decoration: InputDecoration(
                                      hintText: '$currentDay일차 핵심 테마 또는 주요 장소',
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.indigo.shade700,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    // 💡 매 타이핑마다 State를 무겁게 변경하는 대신, 컨트롤러 자체에 위임하고 
                                    // validation 시점 혹은 최종 save 시점에 일괄 동기화하는 구조가 안전합니다.
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return '$currentDay일차 주제를 입력하세요.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // ── 메모 ──
                SectionCard(
                  children: [
                    FieldLabel(text: '메모'),
                    const SizedBox(height: 8),
                    StyledTextField(
                      controller: _noteCtrl,
                      hint: '여행에 대한 메모를 입력하세요',
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── 이미지 섹션 ──
                SectionCard(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FieldLabel(text: '이미지'),
                        TextButton.icon(
                          onPressed: _showImageBottomSheet,
                          icon: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.indigo.shade700,
                            size: 20,
                          ),
                          label: Text(
                            '이미지 등록',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentImages.isNotEmpty) ...[
                      ImageGrid(
                        images: currentImages,
                        onRemove: notifier.removeImage,
                        onCommentChanged: notifier.updateImageComment,
                        coverImagePath: notifier.coverImagePath,
                        onCoverImageChanged: notifier.setCoverImage,
                      ),
                    ] else
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '이미지 등록 버튼을 눌러 사진을 추가하세요',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── 수정 완료 버튼 ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSavingLocal ? null : _onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: _isSavingLocal
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            '수정 완료',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}