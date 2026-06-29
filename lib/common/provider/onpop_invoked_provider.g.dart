// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onpop_invoked_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JOnPopInvoked)
final jOnPopInvokedProvider = JOnPopInvokedProvider._();

final class JOnPopInvokedProvider
    extends $NotifierProvider<JOnPopInvoked, bool> {
  JOnPopInvokedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jOnPopInvokedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jOnPopInvokedHash();

  @$internal
  @override
  JOnPopInvoked create() => JOnPopInvoked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$jOnPopInvokedHash() => r'e6e686ab8dd9e6b0c0a32535d2fd40c8c3db2a8e';

abstract class _$JOnPopInvoked extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
