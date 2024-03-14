import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/main.dart';
import '../aes.dart' as aes;
import '../commands.dart';
import "../MQTTServices.dart";

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({Key? key}) : super(key: key);

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool isAnimationFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isAnimationFinished = true;
        });
      }
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    _controller.dispose();
    super.dispose();
  }

  void navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    mqttClientManager.publishMessage(
        pubTopic, aes.msgEnc(stringToHex(Commands.evOff)));
    return Scaffold(
      backgroundColor: const Color(0x00962e),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(),
            Container(
              child: Column(
                children: [
                  const Text(
                    'ご来場いただきありがとうございました',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height:
                          200, // Set a fixed height for the Lottie animation
                      child: Lottie.asset(
                        "assets/Images/check.json",
                        controller: _controller,
                        onLoaded: (composition) {
                          _controller
                            ..duration = composition.duration
                            ..forward();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: navigateToNextPage,
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(16.0),
                child: isAnimationFinished
                    ? const Icon(
                        Icons.arrow_circle_left_outlined,
                        color: Colors.white,
                        size: 60.0,
                      )
                    : const Icon(
                        Icons.arrow_back,
                        color: Color(0x00962e),
                        size: 60.0,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
