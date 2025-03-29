import 'package:faktura/persistence/model/trip.dart';
import 'package:faktura/service/trip_service.dart';
import 'package:faktura/view/widget/autocomplete_text_form_field.dart';
import 'package:faktura/view/widget/datetime_picker_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/trip_provider_state.dart';

class FormScreen extends StatefulWidget {
  final int? entryId;
  final int? parentId;
  final bool finalize;

  const FormScreen(
      {super.key, this.entryId, this.parentId, this.finalize = false});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  TripService tripService = TripService.instance;

  Trip trip = Trip();

  List<String> vehicles = [];
  List<String> reasons = [];
  List<String> locations = [];
  List<String> types = [];

  Future<void> _initTrip() async {
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    now = now.subtract(Duration(seconds: now.second));

    List<String> vehicles = await tripService.getVehicles();
    List<String> reasons = await tripService.getReasons();
    List<String> locations = await tripService.getLocations();
    List<String> types = await tripService.getTypes();

    Trip trip = Trip();
    trip.parent = widget.parentId;

    if (widget.entryId == null) {
      trip.startDate = now;

      if (reasons.isNotEmpty) {
        trip.reason = reasons[0];
      }
      if (vehicles.isNotEmpty) {
        trip.vehicle = vehicles[0];
      }
      if (types.isNotEmpty) {
        trip.type = types[0];
      }

      trip.startMileage = await tripService.getLastEndMileage(trip.vehicle);
      trip.startLocation = await tripService.getLastEndLocation();
    } else {
      trip = await tripService.getById(widget.entryId!);
    }

    if (this.trip.endDate == null && widget.finalize) {
      trip.endDate = now;
      if (trip.endLocation == null && trip.parent != null) {
        Trip parent = await tripService.getById(trip.parent!);
        trip.endLocation = parent.startLocation;

        if (trip.endLocation != null &&
            trip.startLocation != null &&
            trip.startMileage != null &&
            trip.endMileage == null) {
          tripService
              .getLastTripDistance(
              trip.startLocation, trip.endLocation)
              .then((value) => setState(() {
            trip.endMileage =
            (trip.startMileage! + value!);
          }));
        }

      }
    }

    setState(() {
      this.trip = trip;
      this.vehicles = vehicles;
      this.reasons = reasons;
      this.locations = locations;
      this.types = types;
    });
  }

  @override
  void initState() {
    super.initState();

    _initTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.entryId == null ? "Neu" : "Bearbeiten")),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DateTimePickerTextFormField(
                  key: UniqueKey(),
                  title: 'Abfahrt',
                  initialValue: trip.startDate,
                  onChanged: (date) {
                    date = DateTime(date.year, date.month, date.day, date.hour, date.minute);
                    trip.startDate = date;
                  },
                ),
                DateTimePickerTextFormField(
                  key: UniqueKey(),
                  title: 'Ankunft',
                  initialValue: trip.endDate,
                  onChanged: (date) {
                    date = DateTime(date.year, date.month, date.day, date.hour, date.minute);
                    trip.endDate = date;
                  },
                  validator: (value) {
                    if (trip.endDate != null &&
                        trip.startDate != null &&
                        trip.endDate!.isBefore(trip.startDate!)) {
                      return 'Abfahrt muss vor Ankunft liegen!';
                    }
                    return null;
                  },
                ),
                AutocompleteTextFormField(
                    key: UniqueKey(),
                    title: 'Art',
                    options: types,
                    initialValue: trip.type,
                    onChanged: (value) {
                      trip.type = value;
                    }),
                AutocompleteTextFormField(
                    key: UniqueKey(),
                    title: 'Zweck',
                    options: reasons,
                    initialValue: trip.reason,
                    onChanged: (value) {
                      trip.reason = value;
                    }),
                AutocompleteTextFormField(
                    key: UniqueKey(),
                    title: 'Fahrzeug',
                    options: vehicles,
                    initialValue: trip.vehicle,
                    onChanged: (value) {
                      trip.vehicle = value;
                    },
                    onSelected: (value) {
                      trip.vehicle = value;

                      tripService
                          .getLastEndMileage(value)
                          .then((value) => setState(() {
                                trip.startMileage = value;
                                trip.endMileage = null;
                              }));
                    }),
                AutocompleteTextFormField(
                    key: UniqueKey(),
                    title: 'Abfahrtsort',
                    options: locations,
                    initialValue: trip.startLocation,
                    onChanged: (value) {
                      trip.startLocation = value;
                    }),
                AutocompleteTextFormField(
                    key: UniqueKey(),
                    title: 'Ankunftsort',
                    options: locations,
                    initialValue: trip.endLocation,
                    onChanged: (value) {
                      trip.endLocation = value;
                      if (trip.endLocation != null &&
                          trip.startLocation != null &&
                          trip.startMileage != null &&
                          trip.endMileage == null) {
                        tripService
                            .getLastTripDistance(
                                trip.startLocation, trip.endLocation)
                            .then((value) => setState(() {
                                  trip.endMileage =
                                      (trip.startMileage! + value!);
                                }));
                      }
                    }),
                AutocompleteTextFormField(
                    key: UniqueKey(),
                    title: 'KM-Abfahrt',
                    options: const [],
                    initialValue: trip.startMileage?.toString(),
                    textInputType: TextInputType.number,
                    onChanged: (value) {
                      trip.startMileage = int.tryParse(value);
                    }),
                AutocompleteTextFormField(
                  key: UniqueKey(),
                  title: 'KM-Ankunft',
                  options: const [],
                  initialValue: trip.endMileage?.toString(),
                  textInputType: TextInputType.number,
                  onChanged: (value) {
                    trip.endMileage = int.tryParse(value);
                  },
                  validator: (value) {
                    if (trip.endMileage != null &&
                        trip.startMileage != null &&
                        trip.endMileage! <= trip.startMileage!) {
                      return 'KM-Abfahrt muss kleiner als KM-Ankunft sein!';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            tripService.save(trip).then((value) {
              Provider.of<TripProviderState>(context, listen: false).refresh();

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Fahrt aktualisiert!'),
                behavior: SnackBarBehavior.floating,
              ));
              Navigator.pop(context);
            });
          }
        },
        tooltip: 'Speichern',
        child: const Icon(Icons.check),
      ),
    );
  }
}
