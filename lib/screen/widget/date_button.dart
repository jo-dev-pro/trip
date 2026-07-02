import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateButton extends StatelessWidget {
  const DateButton({
    super.key, 
    required this.label, 
    this.date, 
    this.onTap, // ✨ 1. required 제거
  });

  final String label;
  final DateTime? date;
  final VoidCallback? onTap; // ✨ 2. VoidCallback? (널러블)로 변경

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yy.MM.dd');
    
    // ✨ 3. onTap이 null이면 버튼이 비활성화(disabled)된 것처럼 연출하기 위해 색상 정의
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap, // ✨ null이 들어오면 자연스럽게 터치가 먹히지 않습니다.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          // ✨ 4. 비활성화 상태일 때 배경색을 살짝 어둡게 하거나 투명도를 주면 UX에 좋습니다.
          color: isEnabled ? const Color(0xFFF4F6FA) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null
                ? Colors.indigo.shade300
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: !isEnabled
                  ? Colors.grey.shade300 // 비활성화 상태 색상
                  : (date != null ? Colors.indigo.shade600 : Colors.grey.shade400),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                date != null ? fmt.format(date!) : label,
                style: TextStyle(
                  fontSize: 13,
                  color: !isEnabled
                      ? Colors.grey.shade400 // 비활성화 상태 색상
                      : (date != null ? Colors.indigo.shade800 : Colors.grey.shade400),
                  fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}