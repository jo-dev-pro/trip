// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Backup)
final backupProvider = BackupProvider._();

final class BackupProvider extends $NotifierProvider<Backup, BackupState> {
  BackupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupHash();

  @$internal
  @override
  Backup create() => Backup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupState>(value),
    );
  }
}

String _$backupHash() => r'd37c8363f1128b8a41e1a293c0ef484ce36a33f0';

abstract class _$Backup extends $Notifier<BackupState> {
  BackupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackupState, BackupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackupState, BackupState>,
              BackupState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
