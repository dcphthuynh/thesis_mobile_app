import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/screens/experimenter_screen/experimenter_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userIDInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();
  bool isWrong = false;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    userIDInput.clear;
    passwordInput.clear;
    keepLoggedIn();
  }

  Future<void> keepLoggedIn() async {
    var userID = await getSavedUserId();
    var password = await getSavedPassword();
    var isKeepLoggedIn = await getLoggedInStatus();

    if (isKeepLoggedIn != null &&
        isKeepLoggedIn &&
        userID != null &&
        password != null) {
      var res = await LocalDatabase().login(userID, password);
      if (res == true) {
        moveToNextScreen(userID);
      }
    }
  }

  void moveToNextScreen(String userID) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ExperimenterScreen(
                  userID: userID,
                )));
  }

  void saveLoginData(
      String userId, String password, bool isKeepLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', userId);
    prefs.setString('password', password);

    prefs.setBool('isKeepLoggedIn', isKeepLoggedIn);
  }

  Future<String?> getSavedUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('user_id');
    return userID;
  }

  Future<String?> getSavedPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var password = prefs.getString('password');
    return password;
  }

  Future<bool?> getLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isKeepLoggedIn = prefs.getBool('isKeepLoggedIn');
    return isKeepLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(top: 28.0),
                      child: const Text(
                        'Welcome back! Glad to see you, Again!',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 38.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Urbanist'),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30.0,
                        ),
                        CustomTextField(
                          textFieldLabel: 'UserID',
                          textEditingController: userIDInput,
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          textFieldLabel: 'Password',
                          textEditingController: passwordInput,
                          isPassword: true,
                        ),
                        isWrong
                            ? Container(
                                margin: const EdgeInsets.only(top: 10.0),
                                child: const Text(
                                  "Username or passowrd is incorrect",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Urbanist'),
                                ),
                              )
                            : const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Remember',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Urbanist'),
                            ),
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        var res = await LocalDatabase()
                            .login(userIDInput.text, passwordInput.text);
                        if (res == true) {
                          moveToNextScreen(userIDInput.text);
                          if (isChecked) {
                            saveLoginData(userIDInput.text, passwordInput.text,
                                isChecked);
                          }
                          userIDInput.clear();
                          passwordInput.clear();
                          isChecked = false;
                        } else {
                          setState(() {
                            isWrong = true;
                          });
                        }
                      }
                    },
                    elevation: 2.0, // Customize the elevation
                    fillColor: Colors.black, // Set the button background color
                    padding: const EdgeInsets.all(17.5), // Set padding
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.black, width: 1.0), // Border properties
                      borderRadius: BorderRadius.circular(
                          12.0), // Customize border radius
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
