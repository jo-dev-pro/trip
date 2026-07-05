class BackupState {
  // 🎯 UI 스낵바 및 로딩/알림 출력을 위한 필수 상태 필드만 남김
  final bool isLoading; // 백업/복원 중 뺑뺑이(로딩바)를 돌리기 위해 추가하는 것을 강력 추천합니다.
  final String? message;
  final String? errorMessage;

  BackupState({
    this.isLoading = false,
    this.message,
    this.errorMessage,
  });

  BackupState copyWith({
    bool? isLoading,
    String? message,
    String? errorMessage,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      // 💡 상태 변경 시 명시적으로 null을 주입해 메시지를 청소할 수 있도록 처리
      message: message,
      errorMessage: errorMessage,
    );
  }
}