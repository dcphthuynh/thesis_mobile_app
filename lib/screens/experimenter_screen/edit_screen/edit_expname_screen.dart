import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/styles.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/experiment_content.dart';
import 'package:thesis_app/objects/multiple_choice.dart';
import 'package:thesis_app/objects/slider_data.dart';
import 'package:thesis_app/screens/experimenter_screen/create_screen/create_question_screen.dart';
import 'package:thesis_app/screens/experimenter_screen/edit_screen/edit_question_screen.dart';

class EditExperimentNameScreen extends StatefulWidget {
  final String experimentName;
  final String userId;
  const EditExperimentNameScreen(
      {super.key, required this.experimentName, required this.userId});

  @override
  State<EditExperimentNameScreen> createState() =>
      _EditExperimentNameScreenState();
}

class _EditExperimentNameScreenState extends State<EditExperimentNameScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isDuplicated = false;
  final experimentNameInput = TextEditingController();
  late List<ExperimentContent>? experimentContents;
  late List<SliderData>? verticalSliderData;
  late List<SliderData>? horizontalSliderData;
  late List<MultipleChoice>? mCQsData;

  @override
  void initState() {
    experimentNameInput.text = widget.experimentName;
    super.initState();
  }

  void updateExperimentName(
      String newExperimentName, String oldExperimentName, String userId) async {
    await LocalDatabase()
        .updateExperimentName(newExperimentName, oldExperimentName, userId);
  }

  void confirmation(String title, Widget content, VoidCallback onPressedYes,
      VoidCallback onPressedNo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: content,
            actions: [
              CupertinoDialogAction(
                onPressed: onPressedYes,
                child: const Text(
                  'Yes',
                  style: TextStyles.dialogTextStyle,
                ),
              ),
              CupertinoDialogAction(
                onPressed: onPressedNo,
                child: const Text(
                  'No',
                  style: TextStyles.dialogTextStyle,
                ),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: Text(title),
            content: content,
            actions: [
              DialogButton(
                onPressed: onPressedNo,
                child: const Text('No'),
              ),
              DialogButton(
                onPressed: onPressedYes,
                child: const Text('Yes'),
              ),
            ],
          );
        }
      },
    );
  }

  moveToEditQuestionScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(
          experimentName: experimentNameInput.text,
        ),
      ),
    );
  }

  moveToCreateQuestionScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuestionScreen(
          experimentName: experimentNameInput.text,
        ),
      ),
    );
  }

  void moveToNextScreen(String expName) async {
    experimentContents = await LocalDatabase().getQuestions(expName);
    if (experimentContents != null) {
      moveToEditQuestionScreen();
    } else {
      moveToCreateQuestionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Edit Experiment\'s Name',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Do you want to change your experiment name?',
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          textFieldLabel: 'Experiment name',
                          textEditingController: experimentNameInput,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        isDuplicated &&
                                experimentNameInput.text !=
                                    widget.experimentName
                            ? const Text(
                                "Your experiment's name is unavailable",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w800),
                              )
                            : const SizedBox(),
                      ],
                    ),
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
                            .getSpecificExperiment(experimentNameInput.text);
                        setState(() {
                          isDuplicated = res;
                        });
                        if (!isDuplicated) {
                          confirmation(
                              'Save Changes',
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Change experiment name to ',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 17.0),
                                    ),
                                    TextSpan(
                                      text: experimentNameInput.text,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                    const TextSpan(
                                      text: ' ?',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 17.0),
                                    ),
                                  ],
                                ),
                              ), () {
                            Navigator.pop(context);
                            updateExperimentName(experimentNameInput.text,
                                widget.experimentName, widget.userId);
                            moveToNextScreen(experimentNameInput.text);
                          }, () {
                            Navigator.pop(context);
                          });
                        } else if (isDuplicated &&
                            widget.experimentName == experimentNameInput.text) {
                          confirmation(
                              'Keep Changes',
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Keep experiment name ',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 17.0),
                                    ),
                                    TextSpan(
                                      text: experimentNameInput.text,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                    const TextSpan(
                                      text: ' ?',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 17.0),
                                    ),
                                  ],
                                ),
                              ), () {
                            Navigator.pop(context);
                            moveToNextScreen(experimentNameInput.text);
                          }, () {
                            Navigator.pop(context);
                          });
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
    );
  }
}
