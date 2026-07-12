import 'package:flutter/material.dart';

class BuildEmptyState extends StatelessWidget {
  const BuildEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.luggage_outlined, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '등록된 여행 일정이 없습니다.',
            style: TextStyle(
              fontSize: 16,
              // color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '아래 버튼을 눌러 첫 여행을 계획해보세요!',
            style: TextStyle(fontSize: 13,
            //  color: Colors.grey.shade400,
             ),
          ),
        ],
      ),
    );
  }
}
