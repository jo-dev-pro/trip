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

  // ──────────── 날짜 선택 ────────────
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

  // ──────────── 이미지 bottom sheet ────────────
  void _showImageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false, // 외부 터치로 닫히지 않게
      enableDrag: false, // 드래그로 닫히지 않게
      builder: (_) => const ImagePickerSheet(),
    );
  }

  // ──────────── 저장 ────────────
  Future<void> _onSave(List<dynamic> currentImages) async {
    FocusScope.of(context).unfocus();

    // 1. 기본 Form 검증 (제목, 여행지, 일자별 필수값)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formState = ref.read(tripFormProvider);
    final formValue = formState.value;
    final model = formValue?.trip;

    // 2. 날짜 선택 검증
    if (model == null || model.startDate == null || model.endDate == null) {
      _showWarningSnackBar('여행 기간을 선택해주세요.');
      return;
    }

    // 3. 이미지 필수 선택 검증 (기획 상 이미지 필수 '*' 표시 대응)
    if (currentImages.isEmpty) {
      _showWarningSnackBar('최소 한 장 이상의 이미지를 등록해주세요.');
      return;
    }

    // 4. 저장 로직 실행
    await ref
        .read(tripFormProvider.notifier)
        .save(
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

    // ✨ UI 확인 포인트: 멤버 변수 접근 대신 가급적 상태(State)에서 연동하도록 리팩토링 권장
    // 아래는 우선 기존 비즈니스 로직을 유지하며 연동한 모습입니다.
    final currentImages = notifier.currentImages;

    final formValue = formState.value;
    final model = formValue?.trip;
    final List<DailyNoteModel> dailyNotes = formValue?.dailyNotes ?? [];
    final isSaving = formState.isLoading;

    // 리스너 설정
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
                  // ── 제목 ──
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

                  // ── 여행지 ──
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

                  // ── 날짜 ──
                  SectionCard(
                    children: [
                      const FieldLabel(text: '여행 기간 *'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // ── 시작일 버튼 ──
                          Expanded(
                            child: DateButton(
                              label: '시작일',
                              date: model.startDate,
                              // ✨ 화살표(=>) 대신 중괄호({}) 블록으로 감싸 void Function()으로 컴파일러에게 전달합니다.
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
                          // ── 종료일 버튼 ──
                          Expanded(
                            child: DateButton(
                              label: '종료일',
                              date: model.endDate,
                              // ✨ 종료일 역시 동일하게 중괄호 블록 처리를 하고, 파라미터는 false로 넘겨줍니다.
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

                  // ── 일자별 주제 입력 ──
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

                  // ── 메모 ──
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

                  // ── 이미지 섹션 ──
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

                  // ── 등록 버튼 ──
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
// 💡 포커스 유실 및 데이터 업데이트 매핑 오류를 방지한 서브 위젯
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

  // ✨ 추가된 포인트: 위젯의 상태가 상위 노드에 의해 리빌드될 때 값 동기화 보장
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
            width: 55,
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
              decoration: InputDecoration(
                hintText: '${widget.currentDay}일차 핵심 테마 또는 주요 장소',
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
