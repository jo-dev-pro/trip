// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_provider.dart';

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

String _$tripDetailHash() => r'820a2517fd855e482865badf47573e246a4488f9';

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
