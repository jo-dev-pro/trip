class BackupState {
  final List<String> showDbNameList;
  final List<String> checkedDbNameList;
  final List<bool> checkedDbList;
  final int selectedCount;
  
  // 🎯 [추가] UI 스낵바 출력을 위한 메시지 상태 필드
  final String? message;
  final String? errorMessage;

  BackupState({
    required this.showDbNameList,
    required this.checkedDbNameList,
    required this.checkedDbList,
    required this.selectedCount,
    this.message,
    this.errorMessage,
  });

  BackupState copyWith({
    List<String>? showDbNameList,
    List<String>? checkedDbNameList,
    List<bool>? checkedDbList,
    int? selectedCount,
    String? message,
    String? errorMessage,
  }) {
    return BackupState(
      showDbNameList: showDbNameList ?? this.showDbNameList,
      checkedDbNameList: checkedDbNameList ?? this.checkedDbNameList,
      checkedDbList: checkedDbList ?? this.checkedDbList,
      selectedCount: selectedCount ?? this.selectedCount,
      // 💡 메시지는 소비되고 나면 초기화될 수 있도록 기본적으로 명시적 null 처리가 가능하게 하거나 덮어씁니다.
      message: message,
      errorMessage: errorMessage,
    );
  }
}