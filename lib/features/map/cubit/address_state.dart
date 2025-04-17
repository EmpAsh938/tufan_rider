import 'package:equatable/equatable.dart';

class RideLocation {
  final double lat;
  final double lng;
  final String? name;

  RideLocation({required this.lat, required this.lng, this.name});
}

class AddressState extends Equatable {
  final RideLocation? source;
  final RideLocation? destination;

  const AddressState({
    this.source,
    this.destination,
  });

  AddressState copyWith({
    RideLocation? source,
    RideLocation? destination,
  }) {
    return AddressState(
      source: source ?? this.source,
      destination: destination ?? this.destination,
    );
  }

  @override
  List<Object?> get props => [source, destination];
}
