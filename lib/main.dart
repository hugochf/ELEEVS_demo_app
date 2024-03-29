import 'package:flutter/material.dart';
import 'package:myapp/Screens/startButton.dart';
// import 'package:myapp/Screens/testButton.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asuka EV control Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black26),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: 'Asuka EV Charger control Demo'),
      home: const Scaffold(
        body: Center(child: LoadingButton()),
      ),
    );
  }
}
