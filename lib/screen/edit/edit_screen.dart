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

  // 일자별 테마 수정을 위한 컨트롤러 리스트
  final List<TextEditingController> _themeCtrls = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
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
    if (!mounted) return;

    final trip = widget.tripState.trip;
    final comments = widget.tripState.comments;
    final dailyNotes = widget.tripState.dailyNotes;

    // 💡 [수정]: 2번 대안 아키텍처 명세에 맞게 dailyNotes까지 포함해 3가지 데이터 팩을 전송합니다.
    ref.read(tripFormProvider.notifier).setTravel(trip, comments, dailyNotes);

    // 기본 입력 필드 데이터 동기화
    _titleCtrl.text = trip.title;
    _placeCtrl.text = trip.place;
    _noteCtrl.text = trip.note ?? '';

    // DailyNoteModel 기반 일자별 핵심 테마 매핑
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

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pickDate({required bool isStart}) async {
    // 💡 [수정]: formState의 value값은 이제 TripFormState 객체이므로 알맹이를 한 단계 벗겨냅니다.
    final formValue = ref.read(tripFormProvider).value;
    if (formValue == null) return;

    final tripModel = formValue.trip;
    if (tripModel.startDate == null || tripModel.endDate == null) return;

    // 기존의 총 일수 계산
    final originalDays =
        tripModel.endDate!.difference(tripModel.startDate!).inDays + 1;

    // 1. 달력 띄우기
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? tripModel.startDate! : tripModel.endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    // 2. 가상의 새로운 일수 계산해보기
    final newStart = isStart ? picked : tripModel.startDate!;
    final newEnd = isStart ? tripModel.endDate! : picked;
    final newDays = newEnd.difference(newStart).inDays + 1;

    // 역전 현상 방지
    if (newDays <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('시작일은 종료일보다 앞서야 합니다.')));
      }
      return;
    }

    // 3. 만약 기간이 줄어들었다면 경고 팝업 노출
    if (newDays < originalDays) {
      // 💡 빌드 컨텍스트 사용 전 안전하게 mounted 체크를 넣어주는 것이 좋습니다.
      if (!mounted) return;
      
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              child: const Text(
                '변경',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    // 4. 검증을 통과했거나 기간이 줄어들지 않았다면 프로바이더 상태 업데이트
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

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onUpdate() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(tripFormProvider.notifier);

    // 💡 [수정]: 이제는 프로바이더 내부의 dailyNotes 상태창에 이미 실시간 동기화가 이루어지므로,
    // 불필요했던 외부 매개변수 'themes: updatedThemes' 부분을 걷어내고 순수 저장 정보만 쏘아 올립니다.
    await notifier.save(
      title: _titleCtrl.text.trim(),
      place: _placeCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
    );

    if (mounted) {
      final tripId = widget.tripState.trip.id;
      if (tripId != null) {
        // 💡 디테일 화면 프로바이더(tripDetailProvider)의 캐시를 무효화하여 
        // 이전 화면으로 돌아갔을 때 새롭게 수정된 DB 데이터를 다시 긁어오도록 트리거를 당깁니다.
        ref.invalidate(tripDetailProvider(tripId));
      }
      
      Navigator.of(context).pop();
    }
  }

  void _showImageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ImagePickerSheet(),
    );
  }

  Future<void> _onDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '여행 일정 삭제',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('정말로 이 여행 일정을 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripFormProvider);
    final notifier = ref.read(tripFormProvider.notifier);

    // 💡 [수정]: data 수급 단에서 TripFormState 매핑 가공 처리 진행
    return formState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('에러 발생: $err'))),
      data: (formValue) {
        final isSaving = formState.isLoading;
        final currentImages = notifier.currentImages;
        final model = formValue.trip; // 👈 순수 데이터 모델만 디커플링 추출

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.indigo.shade700,
            foregroundColor: Colors.white,
            title: const Text(
              '여행 일정 수정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: '일정 삭제',
                onPressed: isSaving ? null : _onDelete,
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
                            '~', // 💡 요렇게 따옴표로 감싸서 문자열(String)로 만들어 줍니다!
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
                                    controller: _themeCtrls[index],
                                    decoration: InputDecoration(
                                      hintText: '$currentDay일차 핵심 테마 또는 주요 장소',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.indigo.shade700,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    // 💡 [수정 포인트]: 텍스트 입력 칸의 글자가 바뀔 때마다
                                    // Notifier의 내부 상태창에 실시간으로 매핑 싱크를 시켜 버그를 원천 차단합니다.
                                    onChanged: (value) {
                                      notifier.updateDailyNoteComment(
                                        currentDay,
                                        value.trim(),
                                      );
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
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
                    onPressed: isSaving ? null : _onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: isSaving
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
