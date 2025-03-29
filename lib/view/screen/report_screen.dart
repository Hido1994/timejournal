import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:faktura/service/report_service.dart';
import 'package:faktura/service/trip_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreen();
}

class _ReportScreen extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  ReportService reportService = ReportService.instance;
  TripService tripService = TripService.instance;

  List<int> years = [];
  List<String> types = [];

  int? selectedYear;
  String? selectedType;

  void _init() async {
    List<int> years = await tripService.getYears();
    List<String> types = await tripService.getTypes();

    setState(() {
      this.years = years;
      this.types = types;
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              if (years.isNotEmpty)
                DropdownButton(
                    hint: const Text('Jahr'),
                    isExpanded: true,
                    value: selectedYear,
                    items: years.map<DropdownMenuItem<int>>((int item) {
                      return DropdownMenuItem<int>(
                        value: item,
                        child: Text(item.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                      });
                    }),
              if (types.isNotEmpty)
                DropdownButton(
                    hint: const Text('Art'),
                    isExpanded: true,
                    value: selectedType,
                    items: types.map<DropdownMenuItem<String>>((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    })
            ]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

          Excel excel =
              await reportService.generateExcel(selectedYear, selectedType);
          ShareResult result = await Share.shareXFiles([
            XFile.fromData(Uint8List.fromList(excel.encode()!),
                mimeType: 'xlsx')
          ]);
          if (ShareResultStatus.success == result.status) {
            messenger.showSnackBar(const SnackBar(
              content: Text('Report erstellt!'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        tooltip: 'Export',
        child: const Icon(Icons.download_rounded),
      ),
    );
  }
}
