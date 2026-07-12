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

import '../../common/util/loaders/loaders.dart';

/// ── 💾 [클라우드 저장 대응형] 여행 신규 등록 화면 ──
class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _placeCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // 달력 모달 표시 및 날짜 선택 동기화
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.indigo.shade700),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    final notifier = ref.read(tripFormProvider.notifier);

    if (isStart) {
      notifier.updateStartDate(picked);
    } else {
      notifier.updateEndDate(picked);
    }
  }

  // 갤러리 멀티 픽커 시트 호출
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

  // 저장 처리 핸들러 (파이어베이스 연동 규격 검증)
  Future<void> _onSave(List<dynamic> currentImages) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formState = ref.read(tripFormProvider);
    final formValue = formState.value;
    final model = formValue?.trip;

    if (model == null || model.startDate == null || model.endDate == null) {
      _showWarningSnackBar('여행 기간을 선택해주세요.');
      return;
    }

    if (currentImages.isEmpty) {
      _showWarningSnackBar('최소 한 장 이상의 이미지를 등록해주세요.');
      return;
    }

    // tripFormProvider 내부에서 고용량 원본 파일 압축 후 파이어베이스 전송 수행
    await ref.read(tripFormProvider.notifier).save(
          title: _titleCtrl.text.trim(),
          place: _placeCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
        );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripFormProvider);
    final notifier = ref.read(tripFormProvider.notifier);

    final currentImages = notifier.currentImages;
    final formValue = formState.value;
    final model = formValue?.trip;
    final List<DailyNoteModel> dailyNotes = formValue?.dailyNotes ?? [];
    final isSaving = formState.isLoading;

    // 비동기 처리 성공 및 실패 스낵바 알림 리스너
    ref.listen<AsyncValue<TripFormState>>(tripFormProvider, (prev, next) {
      if (prev is AsyncLoading && next is AsyncData) {
        JLoaders.successSnackBar(
          context,
          title: '알림',
          message: '여행 일정이 성공적으로 등록되었습니다!',
        );
        Navigator.of(context).pop();
      }
      if (next is AsyncError) {
        JLoaders.errorSnackBar(
          context,
          title: '오류',
          message: next.error.toString(),
        );
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          title: const Text(
            '여행 일정 등록',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: formState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('에러 발생: $err')),
          data: (state) {
            if (model == null) {
              return const Center(child: Text('데이터를 불러오지 못했습니다.'));
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 제목
                  SectionCard(
                    children: [
                      const FieldLabel(text: '제목 *'),
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

                  // 여행지
                  SectionCard(
                    children: [
                      const FieldLabel(text: '여행지 *'),
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

                  // 날짜
                  SectionCard(
                    children: [
                      const FieldLabel(text: '여행 기간 *'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DateButton(
                              label: '시작일',
                              date: model.startDate,
                              onTap: isSaving
                                  ? null
                                  : () {
                                      _pickDate(isStart: true);
                                    },
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
                              onTap: isSaving
                                  ? null
                                  : () {
                                      _pickDate(isStart: false);
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 일자별 테마/주제 입력부
                  if (model.startDate != null && model.endDate != null) ...[
                    SectionCard(
                      children: [
                        const FieldLabel(text: '일자별 여행 주제 입력 *'),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dailyNotes.length,
                          itemBuilder: (context, index) {
                            final noteItem = dailyNotes[index];
                            final currentDay = noteItem.dayCount ?? (index + 1);

                            return _DailyNoteInputRow(
                              key: ValueKey(
                                'day_${currentDay}_${dailyNotes.length}',
                              ),
                              currentDay: currentDay,
                              initialValue: noteItem.comment,
                              onChanged: (value) {
                                notifier.updateDailyNoteComment(
                                  currentDay,
                                  value,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 메모
                  SectionCard(
                    children: [
                      const FieldLabel(text: '메모'),
                      const SizedBox(height: 8),
                      StyledTextField(
                        controller: _noteCtrl,
                        hint: '여행에 대한 메모를 입력하세요',
                        maxLines: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 이미지 첨부 그리드 섹션
                  SectionCard(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const FieldLabel(text: '이미지 *'),
                          TextButton.icon(
                            onPressed: isSaving ? null : _showImageBottomSheet,
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
                        const SizedBox(height: 12),
                        ImageGrid(
                          images: currentImages,
                          onRemove: notifier.removeImage,
                          onCommentChanged: notifier.updateImageComment,
                          coverImagePath: notifier.coverImagePath,
                          onCoverImageChanged: notifier.setCoverImage,
                        ),
                      ] else
                        const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 최종 등록 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () => _onSave(currentImages),
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
                              '등록',
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
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 포커스 소실 및 타이핑 리렌더링 버그 방지용 자체 컨트롤러 보유 서브 인풋 위젯
// ─────────────────────────────────────────────────────────────────────────────
class _DailyNoteInputRow extends StatefulWidget {
  final int currentDay;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _DailyNoteInputRow({
    super.key,
    required this.currentDay,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_DailyNoteInputRow> createState() => _DailyNoteInputRowState();
}

class _DailyNoteInputRowState extends State<_DailyNoteInputRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _DailyNoteInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text &&
        widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 63,
            alignment: Alignment.centerLeft,
            child: Text(
              '${widget.currentDay}일차 :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _controller,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: '${widget.currentDay}일차 핵심 테마 또는 주요 장소',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF4F6FA),
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
              onChanged: widget.onChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '${widget.currentDay}일차 주제를 입력하세요.';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}