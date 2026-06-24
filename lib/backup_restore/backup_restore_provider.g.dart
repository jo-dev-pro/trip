// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_restore_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BackupRestore)
final backupRestoreProvider = BackupRestoreProvider._();

final class BackupRestoreProvider
    extends $NotifierProvider<BackupRestore, BackupRestoreState> {
  BackupRestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRestoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRestoreHash();

  @$internal
  @override
  BackupRestore create() => BackupRestore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupRestoreState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupRestoreState>(value),
    );
  }
}

String _$backupRestoreHash() => r'851e3c2a8b2178c58dc70e746658d7cc2b16f0b0';

abstract class _$BackupRestore extends $Notifier<BackupRestoreState> {
  BackupRestoreState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackupRestoreState, BackupRestoreState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackupRestoreState, BackupRestoreState>,
              BackupRestoreState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
