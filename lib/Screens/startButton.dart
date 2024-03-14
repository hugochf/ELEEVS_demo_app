import 'package:flutter/material.dart';
import '../aes.dart' as aes;
import '../commands.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/Screens/stopButton.dart';
import "../MQTTServices.dart";

class LoadingButton extends StatefulWidget {
  const LoadingButton({super.key});
  @override
  State<LoadingButton> createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton>
    with TickerProviderStateMixin {
  late AnimationController controller;
  final player = AudioPlayer();

  // Add a controller for logo fade and move animations
  late AnimationController sharedController;
  late Animation<double> logoFadeAnimation;
  late Animation<Offset> logoSlideAnimation;
  late Animation<double> pictureFadeAnimation;
  late Animation<Offset> pictureSlideAnimation;

  @override
  void initState() {
    mqttClientManager.disconnect();
    setupMqttClient();
    setupUpdatesListener();
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Trigger your next function here
          mqttClientManager.publishMessage(
              pubTopic, aes.msgEnc(stringToHex(Commands.evOn)));
          // Play the sound effect
          playSoundEffect();
          Future.delayed(const Duration(seconds: 3), () {
            navigateToStopScreen();
          });
        }
      });

    // Shared Animation Controller
    sharedController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Logo Animations
    logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: sharedController,
        curve: Curves.easeInOut,
      ),
    );

    logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Move from the top
      end: const Offset(0, 0), // Final position
    ).animate(
      CurvedAnimation(
        parent: sharedController,
        curve: Curves.easeInOut,
      ),
    );

    // Additional Picture Animations
    pictureFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: sharedController,
        curve: Curves.easeInOut,
      ),
    );

    pictureSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Move from the bottom
      end: const Offset(0, 0), // Final position
    ).animate(
      CurvedAnimation(
        parent: sharedController,
        curve: Curves.easeInOut,
      ),
    );

    // Start Shared Animations
    sharedController.forward();
  }

  Future<void> playSoundEffect() async {
    await player.play(AssetSource('ding.mp3'));
  }

  void navigateToStopScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    player.dispose();
    sharedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isIconAmber = controller.value == 1.0;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fade in and move company logo from the top
              SlideTransition(
                position: logoSlideAnimation,
                child: FadeTransition(
                  opacity: logoFadeAnimation,
                  child: SizedBox(
                    width: 150, // Adjust the width as needed
                    height: 150, // Adjust the height as needed
                    child: Image.asset(
                      'assets/Images/logo.png',
                    ),
                  ),
                ),
              ),
              // Center the content horizontally
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 50, right: 50),
                      child: Text(
                        '長押して充電を開始する',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (_) => controller.forward(),
                      onTapUp: (_) {
                        if (controller.status == AnimationStatus.forward) {
                          controller.reverse();
                        }
                      },
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Transform.scale(
                              scale: 5,
                              child: const CircularProgressIndicator(
                                value: 1.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black12),
                                strokeWidth: 4,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Transform.scale(
                              scale: 5,
                              child: CircularProgressIndicator(
                                value: controller.value,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.lightGreen),
                                strokeWidth: 4,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            isIconAmber
                                ? const Icon(
                                    Icons.check,
                                    size: 100,
                                    color: Colors.amber,
                                  )
                                : Transform.scale(
                                    scale: controller.value * 0.8 + 1.1,
                                    child: (controller.value == 0.0)
                                        ? const Icon(
                                            Icons.power_settings_new,
                                            size: 80,
                                            color: Colors.black45,
                                          )
                                        : const Icon(
                                            Icons.bolt,
                                            size: 100,
                                            color: Colors.redAccent,
                                          ),
                                  )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SlideTransition(
                  position: pictureSlideAnimation,
                  child: FadeTransition(
                    opacity: pictureFadeAnimation,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.85, // Adjust the width as needed
                      child: Image.asset(
                        'assets/Images/appMeter.png',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
