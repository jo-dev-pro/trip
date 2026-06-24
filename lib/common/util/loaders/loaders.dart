import 'package:flutter/material.dart';

import 'widgets/pulseicon.dart';

class JLoaders {

  // snackbar
  static void successSnackBar(
    BuildContext context, {
    required String title,
    String message = '',
    int duration = 2,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                const Icon(Icons.check, color: Colors.white), // icon 대응
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // title
                      Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ), // message
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating, // margin을 주려면 floating 필수
        backgroundColor: Colors.deepPurple, // backgroundColor 대응
        duration: Duration(seconds: duration), // duration 대응
        margin: const EdgeInsets.all(10), // margin 대응
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // GetX 기본 스타일 대응
      ),
    );
  }

  // snackbar
  static void warningSnackBar(
    BuildContext context, {
    required String title,
    String message = '',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                PulseIcon(icon: Icons.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // title
                      Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ), // message
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating, // margin을 주려면 floating 필수
        // 하단 스낵바라면 보통 수평(horizontal)이나 아래(down)로 밀어서 끕니다.
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: Colors.orange, // backgroundColor 대응
        duration: Duration(seconds: 2), // duration 대응
        margin: const EdgeInsets.only(
          bottom: 20,
          left: 10,
          right: 10,
        ), // margin 대응
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // GetX 기본 스타일 대응
      ),
    );
  }

  // snackbar
  static void errorSnackBar(
    BuildContext context, {
    required String title,
    String message = '',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                PulseIcon(icon: Icons.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // title
                      Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ), // message
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating, // margin을 주려면 floating 필수
        // 하단 스낵바라면 보통 수평(horizontal)이나 아래(down)로 밀어서 끕니다.
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: Colors.red.shade600, // backgroundColor 대응
        duration: Duration(seconds: 2), // duration 대응
        margin: const EdgeInsets.only(
          bottom: 20,
          left: 10,
          right: 10,
        ), // margin 대응
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // GetX 기본 스타일 대응
      ),
    );
  }
}
