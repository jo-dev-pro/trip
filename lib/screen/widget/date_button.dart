import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateButton extends StatelessWidget {
  const DateButton({super.key, required this.label, this.date, required this.onTap});

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yy.MM.dd');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null
                ? Colors.indigo.shade300
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 16,
                color: date != null
                    ? Colors.indigo.shade600
                    : Colors.grey.shade400),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                date != null ? fmt.format(date!) : label,
                style: TextStyle(
                  fontSize: 13,
                  color: date != null
                      ? Colors.indigo.shade800
                      : Colors.grey.shade400,
                  fontWeight: date != null
                      ? FontWeight.w600
                      : FontWeight.normal,
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
