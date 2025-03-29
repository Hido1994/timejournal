import 'package:faktura/persistence/model/trip.dart';
import 'package:faktura/persistence/repository/trip_repository.dart';

class TripService {
  static final TripService instance = TripService._privateConstructor();

  TripService._privateConstructor();

  final TripRepository _tripRepository = TripRepository.instance;

  Future<int> delete(int id) async {
    return await _tripRepository.delete(id);
  }

  Future<List<Trip>> getAll(
      {String? where, String orderBy = 'startDate DESC'}) async {
    return await _tripRepository.getAll(where: where, orderBy: orderBy);
  }

  Future<Trip> save(Trip entry) async {
    return await _tripRepository.save(entry);
  }

  Future<Trip> getById(int id) async {
    return await _tripRepository.getById(id);
  }

  Future<List<String>> getReasons() async {
    return (await _tripRepository.getDistinctValues('reason'))
        .map((e) => e as String)
        .toList();
  }

  Future<List<String>> getVehicles() async {
    return (await _tripRepository.getDistinctValues('vehicle'))
        .map((e) => e as String)
        .toList();
  }

  Future<List<String>> getTypes() async {
    return (await _tripRepository.getDistinctValues('type'))
        .map((e) => e as String)
        .toList();
  }

  Future<int?> getLastEndMileage(String? vehicle) async {
    if (vehicle != null) {
      List<Trip> result =
          await _tripRepository.getAll(where: 'vehicle = "$vehicle"');
      return result.isNotEmpty ? result.first.endMileage : null;
    }

    return null;
  }

  Future<int?> getLastTripDistance(
      String? startLocation, String? endLocation) async {
    if (startLocation != null && endLocation != null) {
      List<Trip> result = await _tripRepository.getAll(
          where:
              '(startLocation = "$startLocation" and endLocation = "$endLocation") or (startLocation = "$endLocation" and endLocation = "$startLocation")');
      return result.isNotEmpty
          ? result.first.endMileage! - result.first.startMileage!
          : null;
    }
    return null;
  }

  Future<String?> getLastEndLocation() async {
    List<Trip> result =
        await _tripRepository.getAll(where: 'endLocation is not null');
    return result.isNotEmpty ? result.first.endLocation : null;
  }

  Future<List<String>> getLocations() async {
    List startLocations =
        await _tripRepository.getDistinctValues('startLocation');
    List endLocations = await _tripRepository.getDistinctValues('endLocation');
    return {...startLocations, ...endLocations}
        .map((e) => e as String)
        .toList();
  }

  Future<List<int>> getYears() async {
    List years = await _tripRepository.getDistinctValues('startDate');
    return years
        .map((e) => DateTime.fromMillisecondsSinceEpoch(e).year)
        .toSet()
        .toList();
  }
}
