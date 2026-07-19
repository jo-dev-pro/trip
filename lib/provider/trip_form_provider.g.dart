// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripFormNotifier)
final tripFormProvider = TripFormNotifierProvider._();

final class TripFormNotifierProvider
    extends $NotifierProvider<TripFormNotifier, AsyncValue<TripFormState>> {
  TripFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripFormNotifierHash();

  @$internal
  @override
  TripFormNotifier create() => TripFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TripFormState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TripFormState>>(value),
    );
  }
}

String _$tripFormNotifierHash() => r'751ee218b40041f17c6dc1dc261bd901309fce37';

abstract class _$TripFormNotifier extends $Notifier<AsyncValue<TripFormState>> {
  AsyncValue<TripFormState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TripFormState>, AsyncValue<TripFormState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TripFormState>, AsyncValue<TripFormState>>,
              AsyncValue<TripFormState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
