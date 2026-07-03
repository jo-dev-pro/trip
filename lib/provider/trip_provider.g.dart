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

String _$tripListHash() => r'7e252b559a54aae6620da52b557cb9acd45ed4de';

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

String _$tripFormNotifierHash() => r'8dd57c93b80b31dc495620131741daec98cef343';

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

String _$tripDetailHash() => r'e6abc930a86178f2b5e6df07448314d426076fd1';

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

/// 특정 여행 ID(tripId)에 등록된 대표 이미지 경로를 반환하는 함수형 프로바이더
/// ✨ coverImagePath → 없으면 첫 번째 comment.path 순으로 폴백

@ProviderFor(tripFirstImage)
final tripFirstImageProvider = TripFirstImageFamily._();

/// 특정 여행 ID(tripId)에 등록된 대표 이미지 경로를 반환하는 함수형 프로바이더
/// ✨ coverImagePath → 없으면 첫 번째 comment.path 순으로 폴백

final class TripFirstImageProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 특정 여행 ID(tripId)에 등록된 대표 이미지 경로를 반환하는 함수형 프로바이더
  /// ✨ coverImagePath → 없으면 첫 번째 comment.path 순으로 폴백
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

String _$tripFirstImageHash() => r'1aab43a5e0c8976ddb70833d6cd5d72ba0334d3d';

/// 특정 여행 ID(tripId)에 등록된 대표 이미지 경로를 반환하는 함수형 프로바이더
/// ✨ coverImagePath → 없으면 첫 번째 comment.path 순으로 폴백

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

  /// 특정 여행 ID(tripId)에 등록된 대표 이미지 경로를 반환하는 함수형 프로바이더
  /// ✨ coverImagePath → 없으면 첫 번째 comment.path 순으로 폴백

  TripFirstImageProvider call(int tripId) =>
      TripFirstImageProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripFirstImageProvider';
}
