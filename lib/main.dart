import 'package:flutter/material.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';

import 'dismissKeyboard.dart';
import 'login.dart';
import 'navigationService.dart';
import 'report.dart';
import 'config.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  //static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
        child: MaterialApp(
          title: 'KinderCastle Nanny',
          theme: ThemeData(
            primarySwatch: Colors.blue
          ),
          home: const MyHomePage(),
          // navigatorObservers: [
          //   FirebaseAnalyticsObserver(analytics: analytics)
          // ],
          navigatorKey: NavigationService.instance.navigationKey,
          routes: {
            "login":(BuildContext context) => const Login(),
            "home":(BuildContext context) => const Report(),
          }
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future? _token;

  @override
  void initState() {
    _token = Config().getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _token,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data == null ? const Login() : const Report();
        }
        return const Scaffold(
            body: Center(
              child: CircularProgressIndicator()
            )
        );
      },
    );
  }
}
