import 'package:faktura/state/trip_provider_state.dart';
import 'package:faktura/view/screen/calendar_screen.dart';
import 'package:faktura/view/screen/report_screen.dart';
import 'package:faktura/view/screen/settings_screen.dart';
import 'package:faktura/view/screen/trips_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faktura',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // darkTheme: ThemeData.from(
      //         colorScheme: ColorScheme.fromSwatch(
      //             brightness: Brightness.dark,
      //             backgroundColor: Colors.black,
      //             accentColor: Colors.white,
      //             cardColor: Colors.black))
      //     .copyWith(
      //         // textTheme: const TextTheme(
      //         //     titleMedium:
      //         //         TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      //         //     bodyMedium: TextStyle()),
      //         canvasColor: Colors.grey.shade900.withOpacity(0.9),
      //         appBarTheme: const AppBarTheme(
      //             elevation: 0,
      //             titleTextStyle:
      //                 TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      //         snackBarTheme: const SnackBarThemeData(
      //           backgroundColor: Colors.black54,
      //           contentTextStyle: TextStyle(color: Colors.white),
      //         )),
      themeMode: ThemeMode.light,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex = 0;
  final _navigatorKey = GlobalKey<NavigatorState>();

  Map<String, dynamic> routes = {
    '/': const TripsScreen(),
    '/report': const ReportScreen(),
    '/settings': const SettingsScreen(),
    '/calendar': const CalendarScreen(),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Einträge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Bericht',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalendar',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _navigatorKey.currentState
              ?.popAndPushNamed(routes.keys.toList()[index]);
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: ChangeNotifierProvider(
          create: (context) => TripProviderState(),
          child: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(builder: (_) => routes[settings.name]);
            },
          )),
    );
  }
}
