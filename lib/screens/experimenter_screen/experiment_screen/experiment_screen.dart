import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/answer.dart';
import 'package:thesis_app/objects/multiple_choice.dart';
import 'package:thesis_app/objects/experiment_content.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:thesis_app/objects/slider_data.dart';
import 'package:thesis_app/screens/experimenter_screen/experimenter_screen.dart';

class ExperimentScreen extends StatefulWidget {
  final String experimentName;
  final String userId;
  final bool isParticipant;
  const ExperimentScreen(
      {super.key,
      required this.experimentName,
      required this.userId,
      required this.isParticipant});

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  TextEditingController answerInput = TextEditingController();
  double _valueForVerticalSlider = 0.0;
  double _valueForHorizontalSlider = 0.0;
  int currentNumber = 0;
  late List<ExperimentContent> contentList;
  late ExperimentContent content;
  String selectedValueForMCQs = '';
  final ScrollController _scrollControllerForHorizontal = ScrollController();
  final ScrollController _scrollControllerForCommonUI = ScrollController();
  final ScrollController _scrollControllerForNotice = ScrollController();
  bool _isButtonDisabled = true;
  Future<void>? future;
  late List<MultipleChoice>? multipleChoiceList;
  List<Answer> listOfAnswer = [];
  late List<SliderData>? listOfVerticalSlider;
  late List<SliderData>? listOfHorizontalSlider;
  late String answer;
  late Stopwatch stopwatch;
  DateTime? startAt;
  DateTime? endAt;
  final audioPlayer = AudioPlayer();
  bool isPlayedSound = false;
  Uint8List? imageBytesInMemory;

  @override
  void initState() {
    stopwatch = Stopwatch()..start();
    startAt = DateTime.now();
    super.initState();
    future = _initializeData();
  }

  Future<void> _initializeData() async {
    var resOfGettingAllQuestionsWithoutRating = await LocalDatabase()
        .getExperimentContentWithoutRating(widget.experimentName);
    var resOfGettingAllQuestionsWithRating = await LocalDatabase()
        .getExperimentContentWithRating(widget.experimentName);
    var resOfGettingMultipleChoices =
        await LocalDatabase().getMultipleChoice(widget.experimentName);
    var resOfGettingVerticalSlider =
        await LocalDatabase().getSliderData(widget.experimentName, true);

    var resOfGettingHorizontalSlider =
        await LocalDatabase().getSliderData(widget.experimentName, false);
    if (resOfGettingAllQuestionsWithRating != null &&
        resOfGettingAllQuestionsWithoutRating != null) {
      List<ExperimentContent> combinedList = [
        ...resOfGettingAllQuestionsWithoutRating,
        ...resOfGettingAllQuestionsWithRating
      ];
      combinedList.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
      contentList = combinedList;
    }
    if (resOfGettingAllQuestionsWithRating == null) {
      contentList = resOfGettingAllQuestionsWithoutRating;
    }
    if (resOfGettingAllQuestionsWithoutRating == null) {
      contentList = resOfGettingAllQuestionsWithRating;
    }
    content = contentList[currentNumber];
    inspect(contentList);

    if (resOfGettingMultipleChoices != null) {
      multipleChoiceList = resOfGettingMultipleChoices;
    }
    if (resOfGettingVerticalSlider != null) {
      listOfVerticalSlider = resOfGettingVerticalSlider;
    }
    if (resOfGettingHorizontalSlider != null) {
      listOfHorizontalSlider = resOfGettingHorizontalSlider;
    }
    if (content.answerType == 'Horizontal Slider') {
      for (int i = 0; i < listOfHorizontalSlider!.length; i++) {
        if (listOfHorizontalSlider![i].questionId == content.id &&
            listOfHorizontalSlider![i].tickNumber == 2) {
          _valueForHorizontalSlider =
              listOfHorizontalSlider![i].atValue.toDouble();
        }
      }
    }
    if (content.answerType == 'Vertical Slider') {
      for (int i = 0; i < listOfVerticalSlider!.length; i++) {
        if (listOfVerticalSlider![i].questionId == content.id) {
          if (listOfVerticalSlider![i].tickNumber == 2) {
            _valueForVerticalSlider =
                listOfVerticalSlider![i].atValue.toDouble();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    commonPortrait();
    super.dispose();
  }

  void resetUI() {
    setState(() {
      if (content.answerType == 'Horizontal Slider') {
        for (int i = 0; i < listOfHorizontalSlider!.length; i++) {
          if (listOfHorizontalSlider![i].questionId == content.id &&
              listOfHorizontalSlider![i].tickNumber == 2) {
            _valueForHorizontalSlider =
                listOfHorizontalSlider![i].atValue.toDouble();
          }
        }
      }
      if (content.answerType == 'Vertical Slider') {
        for (int i = 0; i < listOfVerticalSlider!.length; i++) {
          if (listOfVerticalSlider![i].questionId == content.id) {
            if (listOfVerticalSlider![i].tickNumber == 2) {
              _valueForVerticalSlider =
                  listOfVerticalSlider![i].atValue.toDouble();
            }
          }
        }
      }
      selectedValueForMCQs = '';
      answerInput.clear();
      isPlayedSound = false;
    });
  }

  void showEndOfExperimentAlert() async {
    stopwatch.stop();
    endAt = DateTime.now();
    if (widget.isParticipant) {
      await LocalDatabase().addParticipantInfo(
          widget.userId,
          widget.experimentName,
          startAt.toString(),
          endAt.toString(),
          stopwatch.elapsed.toString());
      for (Answer answer in listOfAnswer) {
        await LocalDatabase().insertAnswer(answer, startAt.toString());
      }
      Alert(
        context: context,
        type: AlertType.warning,
        title: "WARNING",
        desc: "This is the end of the experiment.",
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            width: 120,
            child: const Text(
              "OK",
              style: TextStyle(
                  fontFamily: 'Urbanist', color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    } else {
      Alert(
        context: context,
        type: AlertType.warning,
        title: "WARNING",
        desc: "This is the end of the experiment.",
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExperimenterScreen(
                            userID: widget.userId,
                          )));
            },
            width: 120,
            child: const Text(
              "OK",
              style: TextStyle(
                  fontFamily: 'Urbanist', color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    }
    // ignore: use_build_context_synchronously
  }

  void enableButton() {
    setState(() {
      _isButtonDisabled = true;
    });
    listOfAnswer.add(Answer(
        experimentName: widget.experimentName,
        questionAnswerType: content.answerType!,
        answer: answer,
        questionId: content.id));
    moveToNextQuestion();
    // _scrollController.animateTo(
    //   0.0,
    //   duration: const Duration(milliseconds: 500),
    //   curve: Curves.easeInOut,
    // );
  }

  void moveToNextQuestion() {
    setState(() {
      if (currentNumber < contentList.length - 1) {
        currentNumber++;
        content = contentList[currentNumber];
        inspect(content.image);
        resetUI();
      } else {
        showEndOfExperimentAlert();
      }
    });
  }

  AppBar? appBar() {
    return widget.isParticipant
        ? null
        : AppBar(
            leading: IconButton(
                onPressed: () {
                  commonPortrait();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
          );
  }

  Widget verticalRotate() {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  flex: 3,
                  child: Center(
                      child:
                          Lottie.asset('assets/images/vertical_rotate.json'))),
              const Expanded(
                child: Center(
                  child: Text(
                    'Please rotate your device into portrait to continue!!!',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
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

  void commonPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  playAlertSound() async {
    await audioPlayer.play(AssetSource("audio/alert.mp3"));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, display a loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Scaffold(
              body: Container(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset('assets/images/error.png'),
                    Text(
                      'Oops!!',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 40.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[600]),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      widget.isParticipant
                          ? 'Something went wrong. Please contact the experimenter.'
                          : 'Something went wrong. Please check the experiment again!!',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[600]),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Background color
                        elevation: 5, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30.0), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 13), // Padding
                      ),
                      child: const Text(
                        'Go back',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            if (content.alertSound == 1 && !isPlayedSound) {
              playAlertSound();
              isPlayedSound = true;
            }
            return Scaffold(body: buildSpecificUI());
          }
        });
  }

  Widget buildSpecificUI() {
    return contentList[currentNumber].type == 'Notice'
        ? buildUIForNotice()
        : contentList[currentNumber].type == 'Timer'
            ? buildUIForTimer()
            : contentList[currentNumber].answerType == 'Horizontal Slider'
                ? buildHorizontalSliderUI()
                : contentList[currentNumber].answerType == 'Vertical Slider'
                    ? buildVerticalSliderUI()
                    : contentList[currentNumber].answerType == 'Input Answer'
                        ? buildInputAnswerUI()
                        : buildMCQsUI();
  }

  Widget buildVerticalSliderUI() {
    return buildCommonUI(
        buildUIForVerticalSlider(), buildCommonButton(true), true);
  }

  Widget buildHorizontalSliderUI() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return Scaffold(
        appBar: appBar(),
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollControllerForHorizontal,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 12.0,
                        ),
                        Center(
                          child: Text(
                            'Question. ${contentList[currentNumber].title}',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        content.image != null
                            ? const SizedBox(
                                height: 12.0,
                              )
                            : const SizedBox(
                                height: 122.0,
                              ),
                        content.image != null
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                width: MediaQuery.of(context).size.width / 3,
                                child: Image.memory(content.image!))
                            : const SizedBox(),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 12.0),
                            child: buildUIForHorizontalSlider()),
                        const SizedBox(
                          height: 18.0,
                        ),
                        content.helpText != null
                            ? Center(
                                child: Text(
                                  'Help text: ${content.helpText!}',
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                buildCommonButton(false),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar(),
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    flex: 3,
                    child:
                        Lottie.asset('assets/images/horizontal_rotate.json')),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Please rotate your device into landscape to do this question!!!',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
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

  Widget buildInputAnswerUI() {
    return buildCommonUI(
        buildUIForInputAnswer(), buildCommonButton(true), false);
  }

  Widget buildMCQsUI() {
    return buildCommonUI(buildUIForMCQs(), buildCommonButton(true), false);
  }

  Widget buildCommonButton(bool isVertical) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RawMaterialButton(
          onPressed: content.type == 'Notice'
              ? moveToNextQuestion
              : _isButtonDisabled
                  ? null
                  : enableButton,
          elevation: 6.0, // Customize the elevation
          fillColor: content.type == 'Notice'
              ? Colors.black
              : _isButtonDisabled
                  ? Colors.grey[200]
                  : Colors.black, // Set the button background color
          padding: isVertical
              ? const EdgeInsets.symmetric(horizontal: 34.0, vertical: 16.0)
              : const EdgeInsets.symmetric(
                  horizontal: 34.0, vertical: 16.0), // Set padding
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            // Border properties
            borderRadius:
                BorderRadius.circular(38.0), // Customize border radius
          ),
          child: Text(
            content.textButton == null ? 'Continue' : content.textButton!,
            style: TextStyle(
              fontFamily: 'Urbanist',
              color: content.type == 'Notice'
                  ? Colors.white
                  : _isButtonDisabled
                      ? Colors.grey
                      : Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ElevatedButton(
  //         style: ButtonStyle(
  //           padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
  //             EdgeInsets.symmetric(
  //                 horizontal: isVertical ? 40.0 : 120.0, vertical: 18.0),
  //           ),
  //           backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
  //         ),

  //       ),

  Widget buildUIForVerticalSlider() {
    return SfSlider.vertical(
      inactiveColor: Colors.grey[300],
      activeColor: Colors.black,
      interval: 1,
      key: const Key('vertical_key'),
      min: listOfVerticalSlider!
          .firstWhere((element) =>
              element.questionId == content.id && element.tickNumber == 2)
          .atValue,
      max: listOfVerticalSlider!
          .firstWhere((element) =>
              element.questionId == content.id && element.tickNumber == 1)
          .atValue,
      value: _valueForVerticalSlider,
      labelFormatterCallback: (dynamic actualValue, String formattedText) {
        for (int i = 0; i < listOfVerticalSlider!.length; i++) {
          if (listOfVerticalSlider![i].questionId ==
              contentList[currentNumber].id) {
            if (actualValue == listOfVerticalSlider![i].atValue) {
              return listOfVerticalSlider![i].tickContent;
            }
          }
        }
        return '';
      },
      showTicks: false,
      showLabels: true,
      enableTooltip: false,
      onChanged: (dynamic value) {
        setState(() {
          _valueForVerticalSlider = value;
          answer = _valueForVerticalSlider.toString();
          _isButtonDisabled = false;
        });
      },
    );
  }

  Widget buildUIForHorizontalSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: SfSlider(
        inactiveColor: Colors.grey[300],
        activeColor: Colors.black,
        key: const Key('horizontal_key'),
        interval: 1,
        min: listOfHorizontalSlider!
            .firstWhere((element) =>
                element.questionId == content.id && element.tickNumber == 2)
            .atValue,
        max: listOfHorizontalSlider!
            .firstWhere((element) =>
                element.questionId == content.id && element.tickNumber == 1)
            .atValue,
        value: _valueForHorizontalSlider,
        labelFormatterCallback: (dynamic actualValue, String formattedText) {
          for (int i = 0; i < listOfHorizontalSlider!.length; i++) {
            if (listOfHorizontalSlider![i].questionId == content.id) {
              if (actualValue == listOfHorizontalSlider![i].atValue) {
                return listOfHorizontalSlider![i].tickContent;
              }
            }
          }
          return '';
        },
        showTicks: false,
        showLabels: true,
        enableTooltip: false,
        // minorTicksPerInterval: 1,
        onChanged: (dynamic value) {
          setState(() {
            _valueForHorizontalSlider = value;
            answer = _valueForHorizontalSlider.toString();
            _isButtonDisabled = false;
          });
        },
      ),
    );
  }

  Widget buildUIForInputAnswer() {
    return CustomTextField(
      textFieldLabel: 'Your answer',
      textEditingController: answerInput,
      isLong: true,
      onChanged: true,
      onChangedFunction: (String value) {
        setState(() {
          if (value != '') {
            _isButtonDisabled = false;
            answer = value;
          } else {
            _isButtonDisabled = true;
          }
        });
      },
    );
  }

  Widget buildUIForMCQs() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < multipleChoiceList!.length; i++)
          if (multipleChoiceList![i].questionId == content.id)
            RadioListTile<String>(
              title: Text(multipleChoiceList![i].choiceContent),
              value: multipleChoiceList![i].choiceContent,
              groupValue: selectedValueForMCQs,
              onChanged: (String? value) {
                setState(() {
                  selectedValueForMCQs = value!;
                  answer = value;
                  _isButtonDisabled = false;
                });
              },
            ),
      ],
    );
  }

  Widget buildCommonUI(Widget content, Widget button, isVerticalSlider) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Scaffold(
        appBar: appBar(),
        body: Container(
          margin: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollControllerForCommonUI,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 12.0,
                        ),
                        Center(
                          child: Text(
                            'Question. ${contentList[currentNumber].title}',
                            style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                height: 1.3),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        this.content.image != null
                            ? Image.memory(this.content.image!)
                            : const SizedBox(),
                        isVerticalSlider
                            ? SizedBox(
                                height: 600,
                                width: 150,
                                child: content,
                              )
                            : content,
                        const SizedBox(
                          height: 20.0,
                        ),
                        this.content.helpText != null
                            ? Center(
                                child: Text(
                                  'Help text: ${this.content.helpText!}',
                                  style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3),
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                ),
                button,
              ],
            ),
          ),
        ),
      );
    } else {
      return verticalRotate();
    }
  }

  Widget buildUIForNotice() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Scaffold(
        appBar: appBar(),
        body: Container(
          margin: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollControllerForNotice,
                    child: Column(
                      children: [
                        Text(content.title,
                            style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 26.0,
                                fontWeight: FontWeight.w600,
                                height: 1.3)),
                        content.image != null
                            ? Image.memory(content.image!)
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                buildCommonButton(true)
              ],
            ),
          ),
        ),
      );
    } else {
      return verticalRotate();
    }
  }

  Widget buildUIForTimer() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      Future.delayed(Duration(seconds: content.timer!), () {
        moveToNextQuestion();
      });
      return Scaffold(
        appBar: appBar(),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      content.title,
                      style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 26.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return verticalRotate();
    }
  }
}
