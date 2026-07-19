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
    extends $StreamNotifierProvider<TripList, List<TripModel>> {
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

String _$tripListHash() => r'd5db6252e03a97b39c8c4ab685a732dd5b535d03';

abstract class _$TripList extends $StreamNotifier<List<TripModel>> {
  Stream<List<TripModel>> build();
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
