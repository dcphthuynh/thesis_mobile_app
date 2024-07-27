import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/styles.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/experiment.dart';
import 'package:thesis_app/screens/experimenter_screen/create_screen/create_question_screen.dart';

class CreateExperimentNameScreen extends StatefulWidget {
  const CreateExperimentNameScreen({super.key, required this.userID});
  final String userID;

  @override
  State<CreateExperimentNameScreen> createState() =>
      _CreateExperimentNameScreenState();
}

class _CreateExperimentNameScreenState
    extends State<CreateExperimentNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final experimentNameInput = TextEditingController();
  late Experiment savedExperiment;

  List<String> userIDs = [];
  List<String?> selectedUserIDs = [];
  bool isDuplicated = false;

  @override
  void initState() {
    super.initState();
  }

  void moveToNextScreen(String experimentName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuestionScreen(
          experimentName: experimentName,
        ),
      ),
    );
  }

  confirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: const Text('Save Changes'),
            content: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Your experiment name will be ',
                    style: TextStyle(color: Colors.black, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: experimentNameInput.text,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const TextSpan(
                    text: ' ?',
                    style: TextStyle(color: Colors.black, fontSize: 17.0),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  moveToNextScreen(experimentNameInput.text);
                },
                child: const Text(
                  'Yes',
                  style: TextStyles.dialogTextStyle,
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'No',
                  style: TextStyles.dialogTextStyle,
                ),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Save Changes'),
            content: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Your experiment name will be ',
                    style: TextStyle(color: Colors.black, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: experimentNameInput.text,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const TextSpan(
                    text: ' ?',
                    style: TextStyle(color: Colors.black, fontSize: 17.0),
                  ),
                ],
              ),
            ),
            actions: [
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              ),
              DialogButton(
                onPressed: () {
                  Navigator.pop(context);
                  moveToNextScreen(experimentNameInput.text);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        }
      },
    );
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
        body: Center(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'First things first, please name your experiment',
                        style: TextStyle(
                            height: 1.2,
                            color: Colors.black,
                            fontSize: 38.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Urbanist'),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextField(
                            textFieldLabel: 'Experiment name',
                            textEditingController: experimentNameInput,
                            // label: 'the experiment\'s name',
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          isDuplicated
                              ? const Text(
                                  "Your experiment's name is unavailable",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 18.0,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w700),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: RoundedButton(
                        isBlack: true,
                        buttonLabel: 'Continue',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool res = await LocalDatabase()
                                .getSpecificExperiment(
                                    experimentNameInput.text);
                            setState(() {
                              isDuplicated = res;
                            });
                            if (!isDuplicated) {
                              await LocalDatabase().addExperimentName(
                                  experimentNameInput.text, widget.userID);
                              confirmation();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
