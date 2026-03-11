import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medicatime/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'providers/auth_provider.dart';
import 'providers/medication_provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/medication_list_screen.dart';
import 'screens/add_edit_medication_screen.dart';
import 'screens/history_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
  settings: initializationSettings,
  onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  onDidReceiveBackgroundNotificationResponse:
      onDidReceiveBackgroundNotificationResponse,
);

  // Request notification permission (Android 13+)
  await requestNotificationPermission();

  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;

  if (status.isDenied || status.isRestricted) {
    await Permission.notification.request();
  }
}

void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;

  if (payload != null) {
    final parts = payload.split('|');
    final medicationId = parts[0];
    final time = parts.length > 1 ? parts[1] : '';
    final action = notificationResponse.actionId;

    final provider = MedicationProvider();

    if (action == 'taken') {
      await provider.markAsTaken(medicationId, time);
    } else if (action == 'skip') {
      await provider.markAsSkipped(medicationId, time);
    }
  }
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse) {
  onDidReceiveNotificationResponse(notificationResponse);
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<MedicationProvider>(
          create: (_) => MedicationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'MedicaTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF2E7D32),
            secondary: Color(0xFF81C784),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Color(0xFFF4FBF6),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
          cardColor: Color(0xFFF4FBF6),
        ),
        darkTheme: ThemeData(
          fontFamily: 'Roboto',
          colorScheme: ColorScheme(
            primary: Color(0xFF81C784),
            onPrimary: Colors.black,
            secondary: Color(0xFF81C784),
            onSecondary: Colors.black,
            surface: Color(0xFF1E1E1E),
            onSurface: Color(0xFFFFFFFF),
            error: Colors.red,
            onError: Colors.white,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Color(0xFF121212),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            foregroundColor: Color(0xFFFFFFFF),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF81C784),
              foregroundColor: Colors.black,
            ),
          ),
          cardColor: Color(0xFF1E1E1E),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
          '/medications': (context) => MedicationListScreen(),
          '/add_medication': (context) => AddEditMedicationScreen(),
          '/history': (context) => HistoryScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}