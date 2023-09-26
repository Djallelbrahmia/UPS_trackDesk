import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ups_trackdesk/provider/data_provider.dart';
import 'package:ups_trackdesk/views/auth/login.dart';
import 'package:ups_trackdesk/views/code_barre.dart';
import 'package:ups_trackdesk/views/form_step1.dart';
import 'package:ups_trackdesk/views/form_step2.dart';
import 'package:ups_trackdesk/views/form_step3.dart';
import 'package:ups_trackdesk/views/histroy.dart';
import 'package:ups_trackdesk/views/home_page.dart';
import 'package:ups_trackdesk/views/last_step.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class NewApp extends StatefulWidget {
  const NewApp({super.key});

  @override
  State<NewApp> createState() => _NewAppState();
}

class _NewAppState extends State<NewApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            background: Colors.white,
            primary: const Color.fromARGB(255, 223, 197, 111),
            secondary: const Color(0xff002263),
          ),
          useMaterial3: true,
        ),
        home: LoginScreen());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DataProvider dataProvider = DataProvider();
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 223, 197, 111),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: Text(snapshot.error.toString())),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<DataProvider>.value(value: dataProvider),
            ],
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                return MaterialApp(
                  title: 'UPS TrackDesk',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSwatch().copyWith(
                      background: Colors.white,
                      primary: const Color.fromARGB(255, 223, 197, 111),
                      secondary: const Color(0xff002263),
                    ),
                    useMaterial3: true,
                  ),
                  routes: {
                    FirstStep.routeName: (context) {
                      return const FirstStep(
                        isHome: true,
                      );
                    },
                    SecondStep.routeName: (context) {
                      return const SecondStep();
                    },
                    ThirdStep.routeName: (context) {
                      return const ThirdStep();
                    },
                    Barcode.routeName: (context) {
                      return Barcode();
                    },
                    LastStep.routeName: (context) {
                      return const LastStep();
                    },
                    MyHomePage.routeName: (context) {
                      return const MyHomePage();
                    },
                    HistoryView.routeName: (context) {
                      return const HistoryView();
                    },
                  },
                  home: (FirebaseAuth.instance.currentUser == null)
                      ? const LoginScreen()
                      : const MyHomePage(),
                );
              },
            ),
          );
        });
  }
}
