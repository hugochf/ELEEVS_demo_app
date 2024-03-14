import 'package:flutter/material.dart';
import 'dart:async';
import 'package:page_transition/page_transition.dart';
import 'package:myapp/Screens/finished.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isFinished = false;
  Duration timerDuration = Duration(seconds: 0);
  late Timer timer;
  double timerTextSize = 18.0;

  @override
  void initState() {
    super.initState();
    // Start the timer when the page is loaded
    startTimer();
  }

  @override
  void dispose() {
    // Stop the timer when the page is disposed
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    // Update the timer every second
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        timerDuration = timerDuration + const Duration(seconds: 1);
      });
    });
  }

  double calculateTimerTextSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.20; // Adjust the multiplier as needed
  }

  Widget build(BuildContext context) {
    timerTextSize = calculateTimerTextSize(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '充電しています',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              const SizedBox(height: 100),
              Text(
                '充電時間：',
                style: TextStyle(
                    fontSize: timerTextSize * 0.4, color: Colors.black54),
              ),
              Text(
                '${timerDuration.inHours}:${(timerDuration.inMinutes % 60).toString().padLeft(2, '0')}:${(timerDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                style:
                    TextStyle(fontSize: timerTextSize, color: Colors.black54),
              ),
              const SizedBox(height: 100),
              SwipeableButtonView(
                buttonText: '　スライドで充電停止',
                buttontextstyle:
                    const TextStyle(fontSize: 28, color: Colors.white),
                buttonWidget: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey),
                activeColor: const Color(0xFF009C41),
                onWaitingProcess: () {
                  timer.cancel();
                  Future.delayed(const Duration(seconds: 1),
                      () => setState(() => isFinished = true));
                },
                isFinished: isFinished,
                onFinish: () async {
                  await Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: const ConfirmationPage(),
                    ),
                  );
                  setState(() {
                    isFinished = false;
                    timerDuration = Duration(seconds: 0);
                  });
                  startTimer();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
