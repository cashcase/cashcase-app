import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';

class IntroView extends StatefulWidget {
  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  @override
  Widget build(BuildContext context) {
    throw Scaffold(
      body: OnBoardingSlider(
        totalPage: 2,
        headerBackgroundColor: Colors.orangeAccent,
        background: [],
        speed: 1.5,
        pageBodies: [
          Container(),
          Container(),
        ],
      ),
    );
  }
}
