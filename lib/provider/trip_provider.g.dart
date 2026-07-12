// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripList)
final tripListProvider = TripListProvider._();

final class TripListProvider
    extends $AsyncNotifierProvider<TripList, List<TripModel>> {
  TripListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripListHash();

  @$internal
  @override
  TripList create() => TripList();
}

String _$tripListHash() => r'e6715d864c17ac796cfc52cc6b5761767fa0baa4';

abstract class _$TripList extends $AsyncNotifier<List<TripModel>> {
  FutureOr<List<TripModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TripModel>>, List<TripModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TripModel>>, List<TripModel>>,
              AsyncValue<List<TripModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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

String _$tripFormNotifierHash() => r'59c23ff327ba17e4a5821b8494002c289576fa73';

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

@ProviderFor(TripDetail)
final tripDetailProvider = TripDetailFamily._();

final class TripDetailProvider
    extends $AsyncNotifierProvider<TripDetail, TripDetailState> {
  TripDetailProvider._({
    required TripDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tripDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripDetailHash();

  @override
  String toString() {
    return r'tripDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripDetail create() => TripDetail();

  @override
  bool operator ==(Object other) {
    return other is TripDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripDetailHash() => r'9b67925293cf9857d50b4821178ff082554bed66';

final class TripDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          TripDetail,
          AsyncValue<TripDetailState>,
          TripDetailState,
          FutureOr<TripDetailState>,
          int
        > {
  TripDetailFamily._()
    : super(
        retry: null,
        name: r'tripDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripDetailProvider call(int tripId) =>
      TripDetailProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripDetailProvider';
}

abstract class _$TripDetail extends $AsyncNotifier<TripDetailState> {
  late final _$args = ref.$arg as int;
  int get tripId => _$args;

  FutureOr<TripDetailState> build(int tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TripDetailState>, TripDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TripDetailState>, TripDetailState>,
              AsyncValue<TripDetailState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(tripFirstImage)
final tripFirstImageProvider = TripFirstImageFamily._();

final class TripFirstImageProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  TripFirstImageProvider._({
    required TripFirstImageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tripFirstImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripFirstImageHash();

  @override
  String toString() {
    return r'tripFirstImageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as int;
    return tripFirstImage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripFirstImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripFirstImageHash() => r'7ade3626367af3eac2630a7345670a38581e3d28';

final class TripFirstImageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, int> {
  TripFirstImageFamily._()
    : super(
        retry: null,
        name: r'tripFirstImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripFirstImageProvider call(int tripId) =>
      TripFirstImageProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripFirstImageProvider';
}
