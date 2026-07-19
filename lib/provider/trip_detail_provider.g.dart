// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripDetail)
final tripDetailProvider = TripDetailFamily._();

final class TripDetailProvider
    extends $AsyncNotifierProvider<TripDetail, TripDetailState> {
  TripDetailProvider._({
    required TripDetailFamily super.from,
    required String super.argument,
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

String _$tripDetailHash() => r'abd43014687e8060e4aaac99c14f5072b8c99857';

final class TripDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          TripDetail,
          AsyncValue<TripDetailState>,
          TripDetailState,
          FutureOr<TripDetailState>,
          String
        > {
  TripDetailFamily._()
    : super(
        retry: null,
        name: r'tripDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripDetailProvider call(String tripId) =>
      TripDetailProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripDetailProvider';
}

abstract class _$TripDetail extends $AsyncNotifier<TripDetailState> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<TripDetailState> build(String tripId);
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
    required String super.argument,
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
    final argument = this.argument as String;
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

String _$tripFirstImageHash() => r'd8207a04bfaed98f89dcebbab27d59c467527213';

final class TripFirstImageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  TripFirstImageFamily._()
    : super(
        retry: null,
        name: r'tripFirstImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripFirstImageProvider call(String tripId) =>
      TripFirstImageProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripFirstImageProvider';
}
