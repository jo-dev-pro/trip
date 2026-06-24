class BackupRestoreState {
  final List<String> showDbNameList;
  final List<String> checkedDbNameList;
  final List<bool> checkedDbList;
  final int selectedCount;

  BackupRestoreState({
    required this.showDbNameList,
    required this.checkedDbNameList,
    required this.checkedDbList,
    required this.selectedCount,
  });

  BackupRestoreState copyWith({
    List<String>? showDbNameList,
    List<String>? checkedDbNameList,
    List<bool>? checkedDbList,
    int? selectedCount,
  }) {
    return BackupRestoreState(
      showDbNameList: showDbNameList ?? this.showDbNameList,
      checkedDbNameList: checkedDbNameList ?? this.checkedDbNameList,
      checkedDbList: checkedDbList ?? this.checkedDbList,
      selectedCount: selectedCount ?? this.selectedCount,
    );
  }
}