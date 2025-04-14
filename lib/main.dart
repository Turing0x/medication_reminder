import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/medication_list_screen.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize reminder service
  await ReminderService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Athiti',
        colorScheme: ColorScheme.light(
          primary: Color(0xFF5A4AA4),
          onPrimary: Colors.white,
          secondary: Color(0xFF7B50C5),
          onSecondary: Colors.white,
          tertiary: Color(0xFF71599B),
          surface: Colors.white,
          error: Color(0xFFDC3545),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 244, 244, 245),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 244, 244, 245),
          indicatorColor: Colors.white,
          labelTextStyle:
              WidgetStateProperty.all(TextStyle(color: Color(0xFF5A4AA4))),
          iconTheme:
              WidgetStateProperty.all(IconThemeData(color: Color(0xFF5A4AA4))),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF333227),
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF333227),
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF333227),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF5A4AA4),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF5E5370)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF5E5370)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF5A4AA4)),
          ),
        ),
      ),
      home: const MedicationListScreen(),
    );
  }
}
