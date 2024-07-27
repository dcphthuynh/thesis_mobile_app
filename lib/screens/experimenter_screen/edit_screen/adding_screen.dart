import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/slider_value_text_field.dart';
import 'package:thesis_app/components/styles.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';

class AddingQuestionScreen extends StatefulWidget {
  const AddingQuestionScreen(
      {super.key, required this.experimentName, required this.orderNumber});

  final String experimentName;
  final int orderNumber;

  @override
  State<AddingQuestionScreen> createState() => _AddingQuestionScreenState();
}

class _AddingQuestionScreenState extends State<AddingQuestionScreen> {
  final questionTitleInput = TextEditingController();
  final noticeInput = TextEditingController();
  final highAnchorText = TextEditingController();
  final lowAnchorText = TextEditingController();
  final highAnchorValue = TextEditingController();
  final lowAnchorValue = TextEditingController();
  final _formKeyForNoticeStage = GlobalKey<FormState>();
  final _formKeyForQuestionStage = GlobalKey<FormState>();
  final _formKeyForMCQs = GlobalKey<FormState>();
  final _formKeyForSlider = GlobalKey<FormState>();
  final _formKeyForAdditionalSlider = GlobalKey<FormState>();
  final helpTextInput = TextEditingController();
  final textButtonInput = TextEditingController();
  final timerTitleInput = TextEditingController();
  final timerValueInput = TextEditingController();
  final _formKeyForTimerStage = GlobalKey<FormState>();
  final _formKeyForHelpText = GlobalKey<FormState>();
  final _formKeyForTextButton = GlobalKey<FormState>();
  final _formKeyForQuestionType = GlobalKey<FormState>();
  bool isTimerStage = false;

  List listAnswerType = [
    'Vertical Slider',
    'Horizontal Slider',
    'Multiple Choices',
    'Input Answer',
  ];
  List listNumberOfChoices = [];
  List listNumberOfModifiedTitleInVerticalSlider = [];
  String? valueChoosed;
  String? selectedValue;
  List listOptions = ['Notice Stage', 'Question Stage', 'Timer Stage'];
  late List savedQuestion = [];
  bool isVisibleForMCQs = false;
  bool isNoticeStage = false;
  bool isQuestionStage = false;
  bool isVerticalSlider = false;
  bool isHorizontalSlider = false;
  bool isChecked = false;
  bool isVisible = false;
  String? numberSelectedForMCQs;
  String? numberSelectedForVerticalSlider;
  List<TextEditingController> mCQsControllers = [];
  List<TextEditingController> tickSliderControllers = [];
  List<TextEditingController> valueSliderControllers = [];
  bool isCheckedSwapPoles = false;
  bool isCheckedAlertSound = false;
  bool isCheckedHelpText = false;
  bool isCheckedTextButton = false;
  bool isShowDialogModifyTick = false;
  bool isShowDialogModifyTickEqually = false;
  bool isShowDialogAboutHighAndLow = false;
  int orderNumber = 0;
  File? _image;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    orderNumber = widget.orderNumber;
    for (int i = 2; i <= 5; i++) {
      listNumberOfChoices.add(i.toString());
    }
    for (int i = 1; i <= 8; i++) {
      listNumberOfModifiedTitleInVerticalSlider.add(i.toString());
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _deleteImage() {
    setState(() {
      _image = null;
    });
  }

  nextFunction() {
    setState(() {
      if (isQuestionStage || isNoticeStage) {
        numberSelectedForMCQs = null;
        isNoticeStage = false;
        isQuestionStage = false;
        isVisibleForMCQs = false;
        isVerticalSlider = false;
        isHorizontalSlider = false;
        noticeInput.clear();
        questionTitleInput.clear();
        highAnchorText.clear();
        lowAnchorText.clear();
        tickSliderControllers.clear();
        valueSliderControllers.clear();
        valueChoosed = null;
        mCQsControllers.clear();
        helpTextInput.clear();
        textButtonInput.clear();
        selectedValue = null;
        numberSelectedForVerticalSlider = null;
        isChecked = false;
        isVisible = false;
        orderNumber++;
        lowAnchorValue.clear();
        highAnchorValue.clear();
        isCheckedSwapPoles = false;
        isCheckedAlertSound = false;
        isCheckedHelpText = false;
        isCheckedTextButton = false;
        _image = null;
      }
      if (isTimerStage) {
        isTimerStage = false;
        timerTitleInput.clear();
        timerValueInput.clear();
        orderNumber++;
        isCheckedAlertSound = false;
        selectedValue = null;
      }
    });
  }

  showDialogAboutModifyTick() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: const Text('WRONG FORMAT INPUT!!!'),
            content: const Text(
                'Modify Tick Value must be less than High Anchor Value and higher than Low Anchor Value.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('WRONG FORMAT INPUT!!!'),
            content: const Text(
                'Modify Tick Value must be less than High Anchor Value and higher than Low Anchor Value.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
      },
    );
  }

  showDialogAboutModifyTickEqually() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: const Text('WRONG FORMAT INPUT!!!'),
            content: const Text(
                'Modify Tick Value must be different from each other.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('WRONG FORMAT INPUT!!!'),
            content: const Text(
                'Modify Tick Value must be different from each other.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
      },
    );
  }

  showDialogAboutLowAndHighValue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: const Text('WRONG FORMAT INPUT!!!'),
            content: const Text(
                'Low Anchor Value must be less than High Anchor Value.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('WRONG FORMAT INPUT!!!'),
            content: const Text(
                'Low Anchor Value must be less than High Anchor Value.'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
      },
    );
  }

  validationFunction() {
    if (isCheckedTextButton && isCheckedHelpText) {
      if (_formKeyForHelpText.currentState!.validate() &&
          _formKeyForTextButton.currentState!.validate()) {
        addingFunction();
        // showAddingDialog();
      }
    }
    if (isCheckedTextButton && !isCheckedHelpText) {
      if (_formKeyForTextButton.currentState!.validate()) {
        addingFunction();
        // showAddingDialog();
      }
    }
    if (!isCheckedTextButton && isCheckedHelpText) {
      if (_formKeyForHelpText.currentState!.validate()) {
        addingFunction();
        // showAddingDialog();
      }
    }
    if (!isCheckedTextButton && !isCheckedHelpText) {
      addingFunction();
      // showAddingDialog();
    }
  }

  void initializeControllersForMCQs(int count) {
    mCQsControllers = List.generate(count, (index) => TextEditingController());
  }

  void initializeControllersForVertical(int count) {
    tickSliderControllers =
        List.generate(count, (index) => TextEditingController());
    valueSliderControllers =
        List.generate(count, (index) => TextEditingController());
  }

  showAddingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: const Text('Save Changes'),
            content: const Text(
                'Are you sure want to go back? All changes will not be saved.'),
            actions: [
              CupertinoDialogAction(
                child: const Text(
                  'Yes',
                  style: TextStyles.dialogTextStyle,
                ),
                onPressed: () {
                  pressingYesButton();
                },
              ),
              CupertinoDialogAction(
                child: const Text(
                  'No',
                  style: TextStyles.dialogTextStyle,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Save Changes'),
            content: const Text(
                'Are you sure want to go back? All changes will not be saved.'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  pressingYesButton();
                },
              ),
            ],
          );
        }
      },
    );
  }

  pressingYesButton() {
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  validationForHelpTextAndTextButton() async {
    if (isCheckedHelpText) {
      await LocalDatabase().addQuestion(
          widget.experimentName,
          questionTitleInput.text,
          orderNumber,
          valueChoosed!,
          helpTextInput.text,
          null,
          isCheckedAlertSound,
          imageBytes);
    }
    if (isCheckedTextButton) {
      await LocalDatabase().addQuestion(
          widget.experimentName,
          questionTitleInput.text,
          orderNumber,
          valueChoosed!,
          null,
          textButtonInput.text,
          isCheckedAlertSound,
          imageBytes);
    }
    if (isCheckedHelpText && isCheckedTextButton) {
      await LocalDatabase().addQuestion(
          widget.experimentName,
          questionTitleInput.text,
          orderNumber,
          valueChoosed!,
          helpTextInput.text,
          textButtonInput.text,
          isCheckedAlertSound,
          imageBytes);
    }
    if (!isCheckedHelpText && !isCheckedTextButton) {
      await LocalDatabase().addQuestion(
          widget.experimentName,
          questionTitleInput.text,
          orderNumber,
          valueChoosed!,
          null,
          null,
          isCheckedAlertSound,
          imageBytes);
    }
  }

  addingFunction() async {
    _image == null
        ? imageBytes = null
        : imageBytes = await _image!.readAsBytes();
    if (isQuestionStage) {
      if (isVisibleForMCQs) {
        validationForHelpTextAndTextButton();
        for (int i = 0; i < mCQsControllers.length; i++) {
          await LocalDatabase().addMultipleChoice(
              widget.experimentName,
              questionTitleInput.text,
              i + 1,
              mCQsControllers[i].text,
              orderNumber);
        }

        nextFunction();
      } else if (isVerticalSlider) {
        validationForHelpTextAndTextButton();
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              true);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              true);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              true);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              true);
        }
        if (isChecked) {
          for (int i = 0; i < tickSliderControllers.length; i++) {
            await LocalDatabase().addSliderOptions(
                widget.experimentName,
                questionTitleInput.text,
                i + 3,
                int.parse(valueSliderControllers[i].text),
                tickSliderControllers[i].text,
                true);
          }
        }
        nextFunction();
      } else if (isHorizontalSlider) {
        validationForHelpTextAndTextButton();
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              false);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              false);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              false);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              orderNumber,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              false);
        }
        if (isChecked) {
          for (int i = 0; i < tickSliderControllers.length; i++) {
            await LocalDatabase().addSliderOptions(
                widget.experimentName,
                questionTitleInput.text,
                i + 3,
                int.parse(valueSliderControllers[i].text),
                tickSliderControllers[i].text,
                false);
          }
        }
        nextFunction();
      } else {
        validationForHelpTextAndTextButton();
        nextFunction();
      }
    }
    if (isNoticeStage) {
      if (isCheckedHelpText && !isCheckedTextButton) {
        await LocalDatabase().addNoticeStage(
            orderNumber,
            widget.experimentName,
            noticeInput.text,
            helpTextInput.text,
            null,
            isCheckedAlertSound,
            imageBytes);
      }
      if (isCheckedTextButton && !isCheckedHelpText) {
        await LocalDatabase().addNoticeStage(
            orderNumber,
            widget.experimentName,
            noticeInput.text,
            null,
            textButtonInput.text,
            isCheckedAlertSound,
            imageBytes);
      }
      if (isCheckedHelpText && isCheckedTextButton) {
        await LocalDatabase().addNoticeStage(
            orderNumber,
            widget.experimentName,
            noticeInput.text,
            helpTextInput.text,
            textButtonInput.text,
            isCheckedAlertSound,
            imageBytes);
      }
      if (!isCheckedHelpText && !isCheckedTextButton) {
        await LocalDatabase().addNoticeStage(orderNumber, widget.experimentName,
            noticeInput.text, null, null, isCheckedAlertSound, imageBytes);
      }
      nextFunction();
    }
    if (isTimerStage) {
      await LocalDatabase().addTimerStage(
          widget.experimentName,
          timerTitleInput.text,
          orderNumber,
          int.parse(timerValueInput.text),
          isCheckedAlertSound);
      nextFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return buildUI(context);
  }

  Widget buildUI(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                          key: _formKeyForQuestionType,
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            value: selectedValue,
                            hint: const Text('Select an option'),
                            onChanged: (newValue) {
                              setState(() {
                                selectedValue = newValue.toString();
                                if (newValue.toString() == 'Notice Stage') {
                                  isNoticeStage = true;
                                  isQuestionStage = false;
                                  isTimerStage = false;
                                  isVisible = true;
                                } else if (newValue.toString() ==
                                    'Timer Stage') {
                                  isQuestionStage = false;
                                  isNoticeStage = false;
                                  isVisible = false;
                                  isTimerStage = true;
                                } else {
                                  isQuestionStage = true;
                                  isNoticeStage = false;
                                  isVisible = true;
                                  isTimerStage = false;
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an option';
                              }
                              return null; // Validation passed
                            },
                            items: listOptions
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        isTimerStage
                            ? Form(
                                key: _formKeyForTimerStage,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      textEditingController: timerTitleInput,
                                      textFieldLabel:
                                          'Instruction to show whilst waiting',
                                      isLong: true,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    CustomTextField(
                                      textEditingController: timerValueInput,
                                      textFieldLabel: 'Time to wait in minute',
                                      isLong: false,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        isNoticeStage
                            ? Column(
                                children: [
                                  Form(
                                    key: _formKeyForNoticeStage,
                                    child: CustomTextField(
                                      textEditingController: noticeInput,
                                      textFieldLabel: 'Instruction',
                                      isLong: true,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: _pickImage,
                                            child: const Text('Pick Image'),
                                          ),
                                          _image != null
                                              ? TextButton(
                                                  onPressed: _deleteImage,
                                                  child: const Text(
                                                      'Delete Chosen Image'),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      _image == null
                                          ? const SizedBox()
                                          : Image.file(_image!),
                                    ],
                                  )
                                ],
                              )
                            : const SizedBox(),
                        isQuestionStage
                            ? Form(
                                key: _formKeyForQuestionStage,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomTextField(
                                      textEditingController: questionTitleInput,
                                      textFieldLabel: 'Question',
                                      isLong: true,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: _pickImage,
                                              child: Text('Pick Image'),
                                            ),
                                            _image != null
                                                ? TextButton(
                                                    onPressed: _deleteImage,
                                                    child: Text(
                                                        'Delete Chosen Image'),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                        _image == null
                                            ? const SizedBox()
                                            : Image.file(_image!),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: isVisibleForMCQs
                                          ? MainAxisAlignment.spaceAround
                                          : MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: isVisibleForMCQs ? 2 : 1,
                                            child: const Text(
                                              "Answer type",
                                              textAlign: TextAlign.center,
                                            )),
                                        isVisibleForMCQs
                                            ? const Expanded(
                                                child: Text('Number of choice'))
                                            : const SizedBox()
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: isVisibleForMCQs ? 2 : 1,
                                          child: DropdownButtonFormField(
                                            isExpanded: true,
                                            hint:
                                                const Text('Select an option'),
                                            value: valueChoosed,
                                            onChanged: (newValue) {
                                              setState(() {
                                                valueChoosed =
                                                    newValue.toString();
                                                if (newValue.toString() ==
                                                    'Multiple Choices') {
                                                  isVisibleForMCQs = true;
                                                  isVerticalSlider = false;
                                                  isHorizontalSlider = false;
                                                } else if (newValue
                                                        .toString() ==
                                                    'Vertical Slider') {
                                                  isVerticalSlider = true;
                                                  isVisibleForMCQs = false;
                                                  isHorizontalSlider = false;
                                                } else if (newValue
                                                        .toString() ==
                                                    'Horizontal Slider') {
                                                  isHorizontalSlider = true;
                                                  isVerticalSlider = false;
                                                  isVisibleForMCQs = false;
                                                } else {
                                                  isVisibleForMCQs = false;
                                                  isVerticalSlider = false;
                                                  isHorizontalSlider = false;
                                                }
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Please select an option';
                                              }
                                              return null; // Validation passed
                                            },
                                            items: listAnswerType
                                                .map((e) => DropdownMenuItem(
                                                      value: e,
                                                      child: Text(
                                                        e,
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                        isVisibleForMCQs
                                            ? const SizedBox(
                                                width: 20.0,
                                              )
                                            : const SizedBox(),
                                        isVisibleForMCQs
                                            ? Expanded(
                                                child: DropdownButtonFormField(
                                                  isExpanded: true,
                                                  hint: const Text('Choices'),
                                                  value: numberSelectedForMCQs,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      numberSelectedForMCQs =
                                                          newValue.toString();
                                                      initializeControllersForMCQs(
                                                          int.parse(
                                                              numberSelectedForMCQs!));
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (value == null) {
                                                      return 'Please select an option';
                                                    }
                                                    return null; // Validation passed
                                                  },
                                                  items: listNumberOfChoices
                                                      .map((e) =>
                                                          DropdownMenuItem(
                                                            value: e,
                                                            child: Center(
                                                                child: Text(e)),
                                                          ))
                                                      .toList(),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    isHorizontalSlider || isVerticalSlider
                                        ? Form(
                                            key: _formKeyForSlider,
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 12.0),
                                                  child: Row(children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child:
                                                          SliderValueTextField(
                                                        isValue: false,
                                                        textFieldLabel:
                                                            'Low Anchor Text',
                                                        textEditingController:
                                                            lowAnchorText,
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        child: Text(
                                                      'At',
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                    Expanded(
                                                      flex: 4,
                                                      child:
                                                          SliderValueTextField(
                                                        isValue: true,
                                                        textFieldLabel:
                                                            'Low Anchor Value',
                                                        textEditingController:
                                                            lowAnchorValue,
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 12.0),
                                                  child: Row(children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child:
                                                          SliderValueTextField(
                                                        isValue: false,
                                                        textFieldLabel:
                                                            'High Anchor Text',
                                                        textEditingController:
                                                            highAnchorText,
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        child: Text(
                                                      'At',
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                    Expanded(
                                                      flex: 4,
                                                      child:
                                                          SliderValueTextField(
                                                        isValue: true,
                                                        textFieldLabel:
                                                            'High Anchor Value',
                                                        textEditingController:
                                                            highAnchorValue,
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                    isVerticalSlider || isHorizontalSlider
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Swap poles?',
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Checkbox(
                                                value: isCheckedSwapPoles,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isCheckedSwapPoles = value!;
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                    isVerticalSlider || isHorizontalSlider
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Modify the tick?',
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Checkbox(
                                                value: isChecked,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isChecked = value!;
                                                  });
                                                },
                                              ),
                                              isChecked
                                                  ? Expanded(
                                                      child:
                                                          DropdownButtonFormField(
                                                        isExpanded: true,
                                                        hint: const Text(
                                                          'Number of ticks',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        value:
                                                            numberSelectedForVerticalSlider,
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            numberSelectedForVerticalSlider =
                                                                newValue
                                                                    .toString();
                                                            initializeControllersForVertical(
                                                                int.parse(
                                                                    numberSelectedForVerticalSlider!));
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value == null) {
                                                            return 'Please select an option';
                                                          }
                                                          return null; // Validation passed
                                                        },
                                                        items:
                                                            listNumberOfModifiedTitleInVerticalSlider
                                                                .map((e) =>
                                                                    DropdownMenuItem(
                                                                      value: e,
                                                                      child: Center(
                                                                          child:
                                                                              Text(e)),
                                                                    ))
                                                                .toList(),
                                                      ),
                                                    )
                                                  : const SizedBox()
                                            ],
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        (isVerticalSlider || isHorizontalSlider) && isChecked
                            ? Form(
                                key: _formKeyForAdditionalSlider,
                                child: Column(
                                  children: [
                                    for (int i = 0;
                                        i < tickSliderControllers.length;
                                        i++)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Row(children: [
                                          Expanded(
                                            flex: 4,
                                            child: SliderValueTextField(
                                              isValue: false,
                                              textFieldLabel:
                                                  'Anchor ${i + 1} Text',
                                              textEditingController:
                                                  tickSliderControllers[i],
                                            ),
                                          ),
                                          const Expanded(
                                              child: Text(
                                            'At',
                                            textAlign: TextAlign.center,
                                          )),
                                          Expanded(
                                            flex: 4,
                                            child: SliderValueTextField(
                                              isValue: true,
                                              textFieldLabel:
                                                  'Anchor ${i + 1} Value',
                                              textEditingController:
                                                  valueSliderControllers[i],
                                            ),
                                          ),
                                        ]),
                                      )
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        isVisibleForMCQs && isQuestionStage
                            ? Form(
                                key: _formKeyForMCQs,
                                child: Column(
                                  children: [
                                    for (int i = 0;
                                        i < mCQsControllers.length;
                                        i++)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 12.0),
                                        child: CustomTextField(
                                            textFieldLabel: 'Choice ${i + 1}',
                                            textEditingController:
                                                mCQsControllers[i]),
                                      )
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        selectedValue != null && isVisible
                            ? Row(
                                children: [
                                  const Text(
                                    'Help text',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Checkbox(
                                      value: isCheckedHelpText,
                                      onChanged: (value) {
                                        setState(() {
                                          isCheckedHelpText = value!;
                                        });
                                      }),
                                ],
                              )
                            : const SizedBox(),
                        selectedValue != null && isVisible && isCheckedHelpText
                            ? Form(
                                key: _formKeyForHelpText,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      textEditingController: helpTextInput,
                                      textFieldLabel: 'Help text',
                                      isLong: true,
                                    ),
                                    const SizedBox(),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        selectedValue != null && isVisible
                            ? Row(
                                children: [
                                  const Text(
                                    'Adjust text button? (Default is \'Continue\')',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Checkbox(
                                      value: isCheckedTextButton,
                                      onChanged: (value) {
                                        setState(() {
                                          isCheckedTextButton = value!;
                                        });
                                      }),
                                ],
                              )
                            : const SizedBox(),
                        selectedValue != null &&
                                isVisible &&
                                isCheckedTextButton
                            ? Form(
                                key: _formKeyForTextButton,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      textEditingController: textButtonInput,
                                      textFieldLabel: 'Text button',
                                      isLong: false,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        selectedValue != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Play alert sound on screen play?',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Checkbox(
                                    value: isCheckedAlertSound,
                                    onChanged: (value) {
                                      setState(() {
                                        isCheckedAlertSound = value!;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedButton(
                      isBlack: true,
                      buttonLabel: 'Add new',
                      onPressed: () {
                        if (_formKeyForQuestionType.currentState!.validate()) {
                          if (isQuestionStage) {
                            if (_formKeyForQuestionStage.currentState!
                                .validate()) {
                              if (isVisibleForMCQs) {
                                if (_formKeyForMCQs.currentState!.validate()) {
                                  validationFunction();
                                }
                              } else if (isHorizontalSlider ||
                                  isVerticalSlider) {
                                if (_formKeyForSlider.currentState!
                                    .validate()) {
                                  if (int.parse(highAnchorValue.text) <=
                                      int.parse(lowAnchorValue.text)) {
                                    showDialogAboutLowAndHighValue();
                                  } else {
                                    if (isChecked) {
                                      if (_formKeyForAdditionalSlider
                                          .currentState!
                                          .validate()) {
                                        outerLoop:
                                        for (int i = 0;
                                            i < tickSliderControllers.length;
                                            i++) {
                                          if (int.parse(
                                                      valueSliderControllers[i]
                                                          .text) >=
                                                  int.parse(
                                                      highAnchorValue.text) ||
                                              int.parse(
                                                      valueSliderControllers[i]
                                                          .text) <=
                                                  int.parse(
                                                      lowAnchorValue.text)) {
                                            isShowDialogModifyTick = true;
                                            isShowDialogModifyTickEqually =
                                                false;
                                            break;
                                          } else {
                                            isShowDialogModifyTick = false;
                                            isShowDialogModifyTickEqually =
                                                false;
                                            for (int j = 0; j < i; j++) {
                                              if (int.parse(
                                                      valueSliderControllers[i]
                                                          .text) ==
                                                  int.parse(
                                                      valueSliderControllers[j]
                                                          .text)) {
                                                isShowDialogModifyTickEqually =
                                                    true;
                                                break outerLoop;
                                              }
                                            }
                                          }
                                        }
                                        if (isShowDialogModifyTick) {
                                          showDialogAboutModifyTick();
                                        } else if (isShowDialogModifyTickEqually) {
                                          showDialogAboutModifyTickEqually();
                                        } else {
                                          validationFunction();
                                        }
                                      }
                                    } else {
                                      validationFunction();
                                    }
                                  }
                                }
                              } else {
                                validationFunction();
                              }
                            }
                          } else if (isTimerStage) {
                            if (_formKeyForTimerStage.currentState!
                                .validate()) {
                              validationFunction();
                            }
                          } else {
                            if (_formKeyForNoticeStage.currentState!
                                .validate()) {
                              validationFunction();
                            }
                          }
                          // updateFunction();
                        }
                      },
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    RoundedButton(
                        isBlack: false,
                        buttonLabel: selectedValue != null ? 'Done' : 'Go Back',
                        onPressed: () {
                          if (selectedValue != null) {
                            showAddingDialog();
                          } else {
                            Navigator.pop(context, true);
                          }
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
