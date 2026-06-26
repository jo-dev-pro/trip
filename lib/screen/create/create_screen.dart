import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trip/model/daily_note_model.dart';
import 'package:trip/provider/trip_detail_state.dart';
import 'package:trip/provider/trip_provider.dart';
import 'package:trip/screen/widget/date_button.dart';
import 'package:trip/screen/widget/field_label.dart';
import 'package:trip/screen/widget/image_grid.dart';
import 'package:trip/screen/widget/image_picker_sheet.dart';
import 'package:trip/screen/widget/section_card.dart';
import 'package:trip/screen/widget/styled_text_field.dart';

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
      isDismissible: false,   // 💡 외부 터치로 닫히지 않게
      enableDrag: false,      // 💡 드래그로 닫히지 않게
      builder: (_) => const ImagePickerSheet(),
    );
  }

  // ──────────── 저장 ────────────
  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(tripFormProvider.notifier);
    final formState = ref.read(tripFormProvider);
    final formValue = formState.value;
    final model = formValue?.trip;

    if (model == null || model.startDate == null || model.endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 기간을 선택해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await notifier.save(
      title: _titleCtrl.text,
      place: _placeCtrl.text,
      note: _noteCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripFormProvider);
    final notifier = ref.read(tripFormProvider.notifier);
    
    // ✨ 1. 뼈대가 되는 가상 데이터 확인 (notifier 내부 변수 보다는 상태 기반 수급 권장)
    // 만약 상태(formState.value) 안에 이미지 리스트가 있다면 formState.value?.images 등으로 바꾸는 것이 가장 좋습니다.
    final currentImages = notifier.currentImages; 

    final formValue = formState.value;
    final model = formValue?.trip;
    final List<DailyNoteModel> dailyNotes = formValue?.dailyNotes ?? [];
    final isSaving = formState.isLoading;

    // 리스너 설정
    ref.listen<AsyncValue<TripFormState>>(tripFormProvider, (prev, next) {
      if (prev is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('여행 일정이 성공적으로 등록되었습니다!'),
            backgroundColor: Colors.indigo,
          ),
        );
        Navigator.of(context).pop();
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    // 💡 변경 포인트: 최상단에서 전면 차단하는 대신 기본 Scaffold 레이아웃을 유지합니다.
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
        // 💡 model이 없거나 초기 로딩 중일 때 전체 화면을 날리는 대신 body 안에서만 인디케이터 처리
        body: formState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('에러 발생: $err')),
          data: (state) {
            // 초기 데이터가 아예 안 만들어진 경우 안전장치
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
                              key: ValueKey('day_${currentDay}_${dailyNotes.length}'), // 키값 보강
                              currentDay: currentDay,
                              initialValue: noteItem.comment,
                              onChanged: (value) {
                                notifier.updateDailyNoteComment(currentDay, value);
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
                      const FieldLabel(text: '메모 *'),
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
                      // 💡 UI 확인 포인트: 수급된 이미지 배열이 비어있지 않다면 리스트 정상 렌더링
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
                      onPressed: isSaving ? null : _onSave,
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

// _DailyNoteInputRow 부분은 기존 코드 유지 (생략)

// ─────────────────────────────────────────────────────────────────────────────
// 💡 포커스 유실 현상 방지를 위해 분리한 동적 폼 필드 로컬 위젯 (StatefulWidget)
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
