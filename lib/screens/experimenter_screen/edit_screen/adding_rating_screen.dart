import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/slider_value_text_field.dart';
import 'package:thesis_app/components/styles.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';

class AddingRatingScreen extends StatefulWidget {
  const AddingRatingScreen(
      {super.key,
      required this.experimentName,
      required this.orderNumber,
      required this.ratingId});

  final String experimentName;
  final int orderNumber;
  final int ratingId;

  @override
  State<AddingRatingScreen> createState() => _AddingRatingScreenState();
}

class _AddingRatingScreenState extends State<AddingRatingScreen> {
  final questionTitleInput = TextEditingController();
  final highAnchorText = TextEditingController();
  final lowAnchorText = TextEditingController();
  final highAnchorValue = TextEditingController();
  final lowAnchorValue = TextEditingController();
  final _formKeyForQuestionStage = GlobalKey<FormState>();
  final _formKeyForHelpText = GlobalKey<FormState>();
  final _formKeyForTextButton = GlobalKey<FormState>();
  final _formKeyForModifyTicks = GlobalKey<FormState>();
  final _formKeyForSlider = GlobalKey<FormState>();
  final _formKeyForAdditionalSlider = GlobalKey<FormState>();
  final helpTextInput = TextEditingController();
  final textButtonInput = TextEditingController();
  bool isCheckedSwapPoles = false;
  List listAnswerType = [
    'Vertical Slider',
    'Horizontal Slider',
  ];
  List listNumberOfModifiedTitleInVerticalSlider = [];
  String? valueChoosed;
  late List savedQuestion = [];
  bool isNoticeStage = false;
  bool isQuestionStage = false;
  bool isVerticalSlider = false;
  bool isHorizontalSlider = false;
  bool isChecked = false;
  String? numberSelectedForMCQs;
  String? numberSelectedForAdditionalSlider;
  List<TextEditingController> tickSliderControllers = [];
  List<TextEditingController> valueSliderControllers = [];
  bool isCheckedAlertSound = false;
  bool isVisible = false;
  bool isCheckedHelpText = false;
  bool isCheckedTextButton = false;
  late int currentRatingId;
  bool isShowDialogModifyTick = false;
  bool isShowDialogModifyTickEqually = false;
  bool isShowDialogAboutHighAndLow = false;
  File? _image;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    currentRatingId = widget.ratingId;
    for (int i = 1; i <= 8; i++) {
      listNumberOfModifiedTitleInVerticalSlider.add(i.toString());
    }
  }

  void initializeControllersForVertical(int count) {
    tickSliderControllers =
        List.generate(count, (index) => TextEditingController());
    valueSliderControllers =
        List.generate(count, (index) => TextEditingController());
  }

  backToPreviousScreen() {
    Navigator.pop(context, true);
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

  addingFunction() async {
    _image == null
        ? imageBytes = null
        : imageBytes = await _image!.readAsBytes();
    if (_formKeyForQuestionStage.currentState!.validate()) {
      if (isHorizontalSlider || isVerticalSlider) {
        if (_formKeyForSlider.currentState!.validate()) {
          if (int.parse(highAnchorValue.text) <=
              int.parse(lowAnchorValue.text)) {
            showDialogAboutLowAndHighValue();
          } else {
            if (isChecked) {
              if (_formKeyForAdditionalSlider.currentState!.validate() &&
                  _formKeyForModifyTicks.currentState!.validate()) {
                outerLoop:
                for (int i = 0; i < tickSliderControllers.length; i++) {
                  if (int.parse(valueSliderControllers[i].text) >=
                          int.parse(highAnchorValue.text) ||
                      int.parse(valueSliderControllers[i].text) <=
                          int.parse(lowAnchorValue.text)) {
                    isShowDialogModifyTick = true;
                    isShowDialogModifyTickEqually = false;
                    break;
                  } else {
                    isShowDialogModifyTick = false;
                    isShowDialogModifyTickEqually = false;
                    for (int j = 0; j < i; j++) {
                      if (int.parse(valueSliderControllers[i].text) ==
                          int.parse(valueSliderControllers[j].text)) {
                        isShowDialogModifyTickEqually = true;
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
                  Navigator.pop(context);
                  backToPreviousScreen();
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
              DialogButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  backToPreviousScreen();
                },
              ),
              DialogButton(
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

  validationFunction() async {
    if (!isCheckedTextButton && isCheckedHelpText) {
      if (_formKeyForHelpText.currentState!.validate()) {
        await LocalDatabase().addRatingContainer(
            widget.experimentName,
            questionTitleInput.text,
            widget.orderNumber,
            currentRatingId,
            valueChoosed!,
            helpTextInput.text,
            null,
            isCheckedAlertSound,
            imageBytes);
      }
    }
    if (isCheckedTextButton && !isCheckedHelpText) {
      if (_formKeyForTextButton.currentState!.validate()) {
        await LocalDatabase().addRatingContainer(
            widget.experimentName,
            questionTitleInput.text,
            widget.orderNumber,
            currentRatingId,
            valueChoosed!,
            null,
            textButtonInput.text,
            isCheckedAlertSound,
            imageBytes);
      }
    }
    if (isCheckedHelpText && isCheckedTextButton) {
      if (_formKeyForTextButton.currentState!.validate() &&
          _formKeyForHelpText.currentState!.validate()) {
        await LocalDatabase().addRatingContainer(
            widget.experimentName,
            questionTitleInput.text,
            widget.orderNumber,
            currentRatingId,
            valueChoosed!,
            helpTextInput.text,
            textButtonInput.text,
            isCheckedAlertSound,
            imageBytes);
      }
    }
    if (!isCheckedHelpText && !isCheckedTextButton) {
      await LocalDatabase().addRatingContainer(
          widget.experimentName,
          questionTitleInput.text,
          widget.orderNumber,
          currentRatingId,
          valueChoosed!,
          null,
          null,
          isCheckedAlertSound,
          imageBytes);
    }
    if (isVerticalSlider) {
      if (!isCheckedSwapPoles) {
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
            1,
            highAnchorValue.text,
            highAnchorText.text,
            true);
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
            2,
            lowAnchorValue.text,
            lowAnchorText.text,
            true);
      } else {
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
            1,
            highAnchorValue.text,
            lowAnchorText.text,
            true);
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
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
      if (!isCheckedSwapPoles) {
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
            1,
            highAnchorValue.text,
            highAnchorText.text,
            false);
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
            2,
            lowAnchorValue.text,
            lowAnchorText.text,
            false);
      } else {
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
            1,
            highAnchorValue.text,
            lowAnchorText.text,
            false);
        await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
            questionTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
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
    }
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

  nextFunction() {
    setState(() {
      questionTitleInput.clear();
      valueChoosed = null;
      lowAnchorText.clear();
      lowAnchorValue.clear();
      highAnchorText.clear();
      highAnchorValue.clear();
      isChecked = false;
      helpTextInput.clear();
      textButtonInput.clear();
      isCheckedSwapPoles = false;
      isCheckedAlertSound = false;
      isCheckedHelpText = false;
      isCheckedTextButton = false;
      _image = null;
    });
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
                          key: _formKeyForQuestionStage,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomTextField(
                                textEditingController: questionTitleInput,
                                textFieldLabel: 'Question',
                                isLong: true,
                                onChanged: true,
                                onChangedFunction: (value) {
                                  setState(() {
                                    questionTitleInput.text = value;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: _pickImage,
                                    child: Text('Pick Image'),
                                  ),
                                  _image != null
                                      ? TextButton(
                                          onPressed: _deleteImage,
                                          child: Text('Delete Chosen Image'),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              _image == null
                                  ? const SizedBox()
                                  : Image.file(_image!),
                              const Text(
                                "Answer type",
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField(
                                      isExpanded: true,
                                      hint: const Text('Select an option'),
                                      value: valueChoosed,
                                      onChanged: (newValue) {
                                        setState(() {
                                          valueChoosed = newValue.toString();
                                          isVisible = true;
                                          if (newValue.toString() ==
                                              'Vertical Slider') {
                                            isVerticalSlider = true;
                                            isHorizontalSlider = false;
                                          } else if (newValue.toString() ==
                                              'Horizontal Slider') {
                                            isHorizontalSlider = true;
                                            isVerticalSlider = false;
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
                                ],
                              ),
                              isHorizontalSlider ||
                                      isVerticalSlider && valueChoosed != null
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
                                                child: SliderValueTextField(
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
                                                textAlign: TextAlign.center,
                                              )),
                                              Expanded(
                                                flex: 4,
                                                child: SliderValueTextField(
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
                                                child: SliderValueTextField(
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
                                                textAlign: TextAlign.center,
                                              )),
                                              Expanded(
                                                flex: 4,
                                                child: SliderValueTextField(
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
                              (isVerticalSlider || isHorizontalSlider) &&
                                      valueChoosed != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Swap poles?',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400),
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
                              (isVerticalSlider || isHorizontalSlider) &&
                                      valueChoosed != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Modify the tick?',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400),
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
                                                child: Form(
                                                  key: _formKeyForModifyTicks,
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
                                                              FontWeight.w600),
                                                    ),
                                                    value:
                                                        numberSelectedForAdditionalSlider,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        numberSelectedForAdditionalSlider =
                                                            newValue.toString();
                                                        initializeControllersForVertical(
                                                            int.parse(
                                                                numberSelectedForAdditionalSlider!));
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value == '') {
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
                                                                      child: Text(
                                                                          e)),
                                                                ))
                                                            .toList(),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox()
                                      ],
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
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
                                            const EdgeInsets.only(top: 12.0),
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
                        isVisible
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
                        isVisible && isCheckedHelpText
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
                        isVisible
                            ? Row(
                                children: [
                                  const Text(
                                    'Adjust text button? (Default is "Continue")',
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
                        isVisible && isCheckedTextButton
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
                        valueChoosed != null
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
                        addingFunction();
                      },
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    RoundedButton(
                      isBlack: false,
                      buttonLabel: (questionTitleInput.text.isNotEmpty ||
                              valueChoosed != null)
                          ? 'Done'
                          : 'Go Back',
                      onPressed: () {
                        if (questionTitleInput.text.isNotEmpty ||
                            valueChoosed != null) {
                          showAddingDialog();
                        } else {
                          backToPreviousScreen();
                        }
                      },
                    ),
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
