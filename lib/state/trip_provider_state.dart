import 'package:timejournal/persistence/model/trip.dart';
import 'package:timejournal/service/trip_service.dart';
import 'package:flutter/material.dart';

class TripProviderState extends ChangeNotifier {
  TripService tripService = TripService.instance;

  List<Trip> trips = [];

  void refresh() {
    tripService.getAll().then((value) {
      trips = value;
      notifyListeners();
    });
  }
}
