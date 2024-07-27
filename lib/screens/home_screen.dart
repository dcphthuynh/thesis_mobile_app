import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:thesis_app/screens/login_screen.dart';
import 'package:thesis_app/screens/participant_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(top: 28.0),
                child: const Text(
                  'We\'re glad to have you here. Explore and enjoy the features',
                  style: TextStyle(
                      height: 1.2,
                      color: Colors.black,
                      fontSize: 38.0,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Urbanist'),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 130.0,
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    elevation: 2.0, // Customize the elevation
                    fillColor: Colors.white, // Set the button background color
                    padding: const EdgeInsets.all(20.0), // Set padding
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.black, width: 1.0), // Border properties
                      borderRadius: BorderRadius.circular(
                          12.0), // Customize border radius
                    ),
                    child: const Text(
                      'Experimenter',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Container(
                        height: 1.5,
                        width: (MediaQuery.of(context).size.width / 2) - 38,
                        color: Colors.black,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: const Text(
                          'OR',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Urbanist'),
                        ),
                      ),
                      Container(
                        height: 1.5,
                        width: (MediaQuery.of(context).size.width / 2) - 38,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ParticipantScreen()));
                    },
                    elevation: 2.0, // Customize the elevation
                    fillColor: Colors.black, // Set the button background color
                    padding: const EdgeInsets.all(20.0), // Set padding
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.black, width: 1.0), // Border properties
                      borderRadius: BorderRadius.circular(
                          12.0), // Customize border radius
                    ),
                    child: const Text(
                      'Participant',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
