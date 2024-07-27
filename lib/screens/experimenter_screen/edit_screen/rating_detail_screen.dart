import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/slider_value_text_field.dart';
import 'package:thesis_app/components/styles.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/experiment_content.dart';
import 'package:thesis_app/objects/slider_data.dart';

class RatingDetailScreen extends StatefulWidget {
  // In the constructor, require a Todo.
  const RatingDetailScreen(
      {super.key,
      required this.experimentContent,
      this.verticalSliderData,
      this.horizontalSliderData,
      required this.experimentName,
      required this.ratingItems});

  // Declare a field that holds the Todo.
  final String experimentName;
  final ExperimentContent experimentContent;
  final List<SliderData>? verticalSliderData;
  final List<SliderData>? horizontalSliderData;
  final int ratingItems;

  @override
  State<RatingDetailScreen> createState() => _RatingDetailScreenState();
}

class _RatingDetailScreenState extends State<RatingDetailScreen> {
  late ExperimentContent initialState;
  late List<SliderData> initialStateOfVerticalSlider;
  final questionTitleInput = TextEditingController();
  final _formKeyForQuestionStage = GlobalKey<FormState>();
  String? valueChoosed;
  bool isVerticalSlider = false;
  bool isHorizontalSlider = false;
  List listAnswerType = [
    'Vertical Slider',
    'Horizontal Slider',
  ];
  String? numberSelectedForAdditionalSlider;
  List listNumberOfModifiedTitleInVerticalSlider = [];
  bool isChecked = false;
  final _formKeyForSlider = GlobalKey<FormState>();
  final _formKeyForAdditionalSlider = GlobalKey<FormState>();
  final _formKeyForHelpText = GlobalKey<FormState>();
  final _formKeyForTextButton = GlobalKey<FormState>();
  List<TextEditingController> tickSliderControllers = [];
  List<TextEditingController> valueSliderControllers = [];
  final highAnchorText = TextEditingController();
  final lowAnchorText = TextEditingController();
  final highAnchorValue = TextEditingController();
  final lowAnchorValue = TextEditingController();
  final helpTextInput = TextEditingController();
  final textButtonInput = TextEditingController();
  bool isCheckedSwapPoles = false;
  bool isCheckedAlertSound = false;
  bool isChangedForAlertSound = false;
  bool isCheckedHelpText = false;
  bool isCheckedTextButton = false;
  bool isChangedForHelpText = false;
  bool isChangedForTextButton = false;
  bool isShowDialogModifyTick = false;
  bool isShowDialogModifyTickEqually = false;
  bool isShowDialogAboutHighAndLow = false;
  File? _image;
  Uint8List? imageBytesInMemory;
  Uint8List? imageBytesNew;
  bool isImageChanged = false;

  void initializeControllersForVertical(int count) {
    tickSliderControllers =
        List.generate(count, (index) => TextEditingController());
    valueSliderControllers =
        List.generate(count, (index) => TextEditingController());
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        if (imageBytesInMemory != null) {
          imageBytesInMemory = null;
        }
        isImageChanged = true;
      } else {
        print('No image selected.');
      }
    });
  }

  _deleteImage() {
    setState(() {
      _image = null;
      imageBytesInMemory = null;
      isImageChanged = true;
    });
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

  showAddingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: const Text('Save changes?'),
            content: const Text('Do you want to save changes?'),
            actions: [
              CupertinoDialogAction(
                child: const Text(
                  'Yes',
                  style: TextStyles.dialogTextStyle,
                ),
                onPressed: () {
                  updateFunction();
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
            title: const Text('Save changes?'),
            content: const Text('Do you want to save changes?'),
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
                  updateFunction();
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

  updateFunction() async {
    if (isImageChanged) {
      _image == null
          ? imageBytesNew = null
          : imageBytesNew = await _image!.readAsBytes();
      await LocalDatabase()
          .saveImage(imageBytesNew, widget.experimentContent.id);
    }
    // if (isChangedForHelpTextAndTextButton) {
    //   if (_formKeyForHelpTextAndTextButton.currentState!.validate()) {
    //     await LocalDatabase().updateHelpTextAndTextButtonInRating(
    //         helpTextInput.text,
    //         textButtonInput.text,
    //         widget.experimentName,
    //         widget.experimentContent.id);
    //   }
    // }
    if (isChangedForHelpText || isChangedForTextButton) {
      if (isCheckedHelpText && isCheckedTextButton) {
        if (_formKeyForTextButton.currentState!.validate() &&
            _formKeyForHelpText.currentState!.validate()) {
          await LocalDatabase().updateHelpTextAndTextButtonInRating(
              helpTextInput.text,
              textButtonInput.text,
              widget.experimentName,
              widget.experimentContent.id);
        }
      }
      if (isCheckedHelpText && !isCheckedTextButton) {
        if (_formKeyForHelpText.currentState!.validate()) {
          await LocalDatabase().updateHelpTextAndTextButtonInRating(
              helpTextInput.text,
              null,
              widget.experimentName,
              widget.experimentContent.id);
        }
      }
      if (!isCheckedHelpText && isCheckedTextButton) {
        if (_formKeyForTextButton.currentState!.validate()) {
          await LocalDatabase().updateHelpTextAndTextButtonInRating(
              null,
              textButtonInput.text,
              widget.experimentName,
              widget.experimentContent.id);
        }
      }
      if (!isCheckedTextButton && !isCheckedHelpText) {
        await LocalDatabase().updateHelpTextAndTextButtonInRating(
            null, null, widget.experimentName, widget.experimentContent.id);
      }
    }
    if (isChangedForAlertSound) {
      await LocalDatabase().updateAlertSoundInRating(
          isCheckedAlertSound, widget.experimentContent.id);
    }
    if (_formKeyForQuestionStage.currentState!.validate()) {
      await LocalDatabase().updateTitleInRating(
          questionTitleInput.text, widget.experimentContent.id);
    }
    if (initialState.answerType == 'Vertical Slider' && isVerticalSlider) {
      if (_formKeyForSlider.currentState!.validate()) {
        if (!isCheckedSwapPoles) {
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              true,
              highAnchorText.text,
              highAnchorValue.text,
              widget.experimentContent.id,
              1);
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              true,
              lowAnchorText.text,
              lowAnchorValue.text,
              widget.experimentContent.id,
              2);
        } else {
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              true,
              lowAnchorText.text,
              highAnchorValue.text,
              widget.experimentContent.id,
              1);
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              true,
              highAnchorText.text,
              lowAnchorValue.text,
              widget.experimentContent.id,
              2);
        }
      }
      if (!isChecked) {
        if (_formKeyForSlider.currentState!.validate()) {
          for (int i = 0; i < widget.verticalSliderData!.length - 2; i++) {
            await LocalDatabase().deleteSliderDataInRating(
                widget.verticalSliderData![i + 2].id, true);
          }
        }
      } else {
        if (_formKeyForAdditionalSlider.currentState!.validate()) {
          if (widget.verticalSliderData!.length - 2 == 0) {
            for (int i = 0; i < tickSliderControllers.length; i++) {
              await LocalDatabase().addSliderOptionsInRating(
                  widget.experimentName,
                  i + 3,
                  int.parse(valueSliderControllers[i].text),
                  tickSliderControllers[i].text,
                  true,
                  widget.experimentContent.id);
            }
          } else {
            if (int.parse(numberSelectedForAdditionalSlider!) ==
                widget.verticalSliderData!.length - 2) {
              //UPDATE TUNG CAI
              for (int i = 0; i < widget.verticalSliderData!.length - 2; i++) {
                await LocalDatabase().updateTickContentInVerticalSliderInRating(
                    tickSliderControllers[i].text,
                    valueSliderControllers[i].text,
                    widget.experimentContent.id,
                    i + 3);
              }
            } else if (widget.verticalSliderData!.length - 2 <
                int.parse(numberSelectedForAdditionalSlider!)) {
              for (int i = 0; i < widget.verticalSliderData!.length - 2; i++) {
                await LocalDatabase().updateTickContentInVerticalSliderInRating(
                    tickSliderControllers[i].text,
                    valueSliderControllers[i].text,
                    widget.experimentContent.id,
                    i + 3);
              }
              for (int i = 0;
                  i <
                      tickSliderControllers.length -
                          widget.verticalSliderData!.length +
                          2;
                  i++) {
                await LocalDatabase().addSliderOptionsInRating(
                    widget.experimentName,
                    (widget.verticalSliderData!.length) + i + 1,
                    int.parse(valueSliderControllers[
                            (widget.verticalSliderData!.length - 2) + i]
                        .text),
                    tickSliderControllers[
                            (widget.verticalSliderData!.length - 2) + i]
                        .text,
                    true,
                    widget.experimentContent.id);
              }
            } else {
              for (int i = 0; i < tickSliderControllers.length; i++) {
                await LocalDatabase().updateTickContentInVerticalSliderInRating(
                    tickSliderControllers[i].text,
                    valueSliderControllers[i].text,
                    widget.experimentContent.id,
                    i + 3);
              }
              for (int i = 0;
                  i <
                      widget.verticalSliderData!.length -
                          tickSliderControllers.length -
                          2;
                  i++) {
                await LocalDatabase().deleteSliderDataInRating(
                    widget
                        .verticalSliderData![i +
                            widget.verticalSliderData!.length -
                            2 +
                            tickSliderControllers.length]
                        .id,
                    true);
              }
            }
          }
        }
      }
    }
    if (initialState.answerType == 'Vertical Slider' && isHorizontalSlider) {
      if (_formKeyForSlider.currentState!.validate()) {
        await LocalDatabase()
            .updateVerticalToHorizontalInRating(widget.experimentContent.id);
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              false,
              widget.experimentContent.id);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              false,
              widget.experimentContent.id);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              false,
              widget.experimentContent.id);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              false,
              widget.experimentContent.id);
        }
      }
      if (isChecked) {
        if (_formKeyForAdditionalSlider.currentState!.validate()) {
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
      }
    }
    if (initialState.answerType == 'Horizontal Slider' && isHorizontalSlider) {
      if (_formKeyForSlider.currentState!.validate()) {
        if (!isCheckedSwapPoles) {
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              false,
              highAnchorText.text,
              highAnchorValue.text,
              widget.experimentContent.id,
              1);
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              false,
              lowAnchorText.text,
              lowAnchorValue.text,
              widget.experimentContent.id,
              2);
        } else {
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              false,
              lowAnchorText.text,
              highAnchorValue.text,
              widget.experimentContent.id,
              1);
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSliderInRating(
              false,
              highAnchorText.text,
              lowAnchorValue.text,
              widget.experimentContent.id,
              2);
        }
      }
      if (!isChecked) {
        if (_formKeyForSlider.currentState!.validate()) {
          for (int i = 0; i < widget.horizontalSliderData!.length - 2; i++) {
            await LocalDatabase().deleteSliderDataInRating(
                widget.horizontalSliderData![i + 2].id, false);
          }
        }
      } else {
        if (_formKeyForAdditionalSlider.currentState!.validate()) {
          if (widget.horizontalSliderData!.length - 2 == 0) {
            for (int i = 0; i < tickSliderControllers.length; i++) {
              await LocalDatabase().addSliderOptionsInRating(
                  widget.experimentName,
                  i + 3,
                  int.parse(valueSliderControllers[i].text),
                  tickSliderControllers[i].text,
                  false,
                  widget.experimentContent.id);
            }
          } else {
            if (int.parse(numberSelectedForAdditionalSlider!) ==
                widget.horizontalSliderData!.length - 2) {
              //UPDATE TUNG CAI
              for (int i = 0;
                  i < widget.horizontalSliderData!.length - 2;
                  i++) {
                await LocalDatabase()
                    .updateTickContentInHorizontalSliderInRating(
                        tickSliderControllers[i].text,
                        valueSliderControllers[i].text,
                        widget.experimentContent.id,
                        i + 3);
              }
            } else if (widget.horizontalSliderData!.length - 2 <
                int.parse(numberSelectedForAdditionalSlider!)) {
              for (int i = 0;
                  i < widget.horizontalSliderData!.length - 2;
                  i++) {
                await LocalDatabase()
                    .updateTickContentInHorizontalSliderInRating(
                        tickSliderControllers[i].text,
                        valueSliderControllers[i].text,
                        widget.experimentContent.id,
                        i + 3);
              }
              for (int i = 0;
                  i <
                      tickSliderControllers.length -
                          widget.horizontalSliderData!.length +
                          2;
                  i++) {
                await LocalDatabase().addSliderOptionsInRating(
                    widget.experimentName,
                    (widget.horizontalSliderData!.length) + i + 1,
                    int.parse(valueSliderControllers[
                            (widget.horizontalSliderData!.length - 2) + i]
                        .text),
                    tickSliderControllers[
                            (widget.horizontalSliderData!.length - 2) + i]
                        .text,
                    false,
                    widget.experimentContent.id);
              }
            } else {
              for (int i = 0; i < tickSliderControllers.length; i++) {
                await LocalDatabase()
                    .updateTickContentInHorizontalSliderInRating(
                        tickSliderControllers[i].text,
                        valueSliderControllers[i].text,
                        widget.experimentContent.id,
                        i + 3);
              }
              for (int i = 0;
                  i <
                      widget.horizontalSliderData!.length -
                          tickSliderControllers.length -
                          2;
                  i++) {
                await LocalDatabase().deleteSliderDataInRating(
                    widget
                        .verticalSliderData![i +
                            widget.verticalSliderData!.length -
                            2 +
                            tickSliderControllers.length]
                        .id,
                    true);
              }
            }
          }
        }
      }
    }
    if (initialState.answerType == 'Horizontal Slider' && isVerticalSlider) {
      if (_formKeyForSlider.currentState!.validate()) {
        await LocalDatabase()
            .updateHorizontalToVerticalInRating(widget.experimentContent.id);
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              true,
              widget.experimentContent.id);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              true,
              widget.experimentContent.id);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              true,
              widget.experimentContent.id);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSliderInRating(
              widget.experimentName,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              true,
              widget.experimentContent.id);
        }
      }
      if (isChecked) {
        if (_formKeyForAdditionalSlider.currentState!.validate()) {
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
      }
    }
    pressingYesButton();
  }

  pressingYesButton() {
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  pressingYesButtonIfTheLastRating() {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    for (int i = 1; i <= 8; i++) {
      listNumberOfModifiedTitleInVerticalSlider.add(i.toString());
    }
    imageBytesInMemory = widget.experimentContent.image;
    initialState = ExperimentContent(
        id: widget.experimentContent.id,
        orderNumber: widget.experimentContent.orderNumber,
        title: widget.experimentContent.title,
        type: widget.experimentContent.type,
        answerType: widget.experimentContent.answerType,
        alertSound: widget.experimentContent.alertSound);
    widget.experimentContent.alertSound == 1
        ? isCheckedAlertSound = true
        : isCheckedAlertSound = false;
    questionTitleInput.text = widget.experimentContent.title;
    if (widget.experimentContent.textButton != null &&
        widget.experimentContent.helpText != null) {
      isCheckedHelpText = true;
      isCheckedTextButton = true;
      textButtonInput.text = widget.experimentContent.textButton!;
      helpTextInput.text = widget.experimentContent.helpText!;
    }
    if (widget.experimentContent.textButton == null &&
        widget.experimentContent.helpText != null) {
      isCheckedHelpText = true;
      isCheckedTextButton = false;
      helpTextInput.text = widget.experimentContent.helpText!;
    }
    if (widget.experimentContent.textButton != null &&
        widget.experimentContent.helpText == null) {
      isCheckedHelpText = false;
      isCheckedTextButton = true;
      textButtonInput.text = widget.experimentContent.textButton!;
    }
    if (widget.experimentContent.textButton == null &&
        widget.experimentContent.helpText == null) {
      isCheckedHelpText = false;
      isCheckedTextButton = false;
    }
    valueChoosed = widget.experimentContent.answerType;
    if (valueChoosed == 'Vertical Slider') {
      isVerticalSlider = true;
      highAnchorText.text = widget.verticalSliderData![0].tickContent;
      lowAnchorText.text = widget.verticalSliderData![1].tickContent;
      highAnchorValue.text = widget.verticalSliderData![0].atValue.toString();
      lowAnchorValue.text = widget.verticalSliderData![1].atValue.toString();
      if (widget.verticalSliderData!.length > 2) {
        isChecked = true;
        numberSelectedForAdditionalSlider =
            '${widget.verticalSliderData!.length - 2}';
        initializeControllersForVertical(
            int.parse(numberSelectedForAdditionalSlider!));
        for (int i = 0; i < tickSliderControllers.length; i++) {
          tickSliderControllers[i].text =
              widget.verticalSliderData![i + 2].tickContent;
          valueSliderControllers[i].text =
              '${widget.verticalSliderData![i + 2].atValue}';
        }
      }
    } else if (valueChoosed == 'Horizontal Slider') {
      isHorizontalSlider = true;
      highAnchorText.text = widget.horizontalSliderData![0].tickContent;
      lowAnchorText.text = widget.horizontalSliderData![1].tickContent;
      highAnchorValue.text = widget.horizontalSliderData![0].atValue.toString();
      lowAnchorValue.text = widget.horizontalSliderData![1].atValue.toString();
      if (widget.horizontalSliderData!.length > 2) {
        isChecked = true;
        numberSelectedForAdditionalSlider =
            '${widget.horizontalSliderData!.length - 2}';
        initializeControllersForVertical(
            int.parse(numberSelectedForAdditionalSlider!));
        for (int i = 0; i < tickSliderControllers.length; i++) {
          tickSliderControllers[i].text =
              widget.horizontalSliderData![i + 2].tickContent;
          valueSliderControllers[i].text =
              '${widget.horizontalSliderData![i + 2].atValue}';
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.experimentContent.type,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                fontSize: 24.0,
              )),
          actions: [
            TextButton(
                onPressed: () {
                  if (_formKeyForQuestionStage.currentState!.validate() &&
                      _formKeyForSlider.currentState!.validate()) {
                    if (int.parse(highAnchorValue.text) <=
                        int.parse(lowAnchorValue.text)) {
                      showDialogAboutLowAndHighValue();
                    } else {
                      if (isChecked) {
                        if (_formKeyForAdditionalSlider.currentState!
                            .validate()) {
                          outerLoop:
                          for (int i = 0;
                              i < tickSliderControllers.length;
                              i++) {
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
                            showAddingDialog();
                          }
                        }
                      } else {
                        showAddingDialog();
                      }
                    }
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue),
                ))
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 12.0,
                        ),
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
                                onChangedFunction: (newValue) {
                                  setState(() {});
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: _pickImage,
                                    child: Text((imageBytesInMemory != null ||
                                            _image != null)
                                        ? 'Change Image'
                                        : 'Pick Image'),
                                  ),
                                  imageBytesInMemory != null || _image != null
                                      ? TextButton(
                                          onPressed: _deleteImage,
                                          child:
                                              const Text('Delete Chosen Image'),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              imageBytesInMemory != null && _image == null
                                  ? Image.memory(imageBytesInMemory!)
                                  : const SizedBox(),
                              imageBytesInMemory == null && _image != null
                                  ? Image.file(_image!)
                                  : const SizedBox(),
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
                                                  style: const TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
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
                              isVerticalSlider || isHorizontalSlider
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
                              isVerticalSlider || isHorizontalSlider
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
                                                child: DropdownButtonFormField(
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Number of ticks',
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
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
                                                      if (initialState
                                                              .answerType ==
                                                          'Vertical Slider') {
                                                        if (widget
                                                                .verticalSliderData!
                                                                .length ==
                                                            2) {
                                                          initializeControllersForVertical(
                                                              int.parse(
                                                                  numberSelectedForAdditionalSlider!));
                                                        } else {
                                                          initializeControllersForVertical(
                                                              int.parse(
                                                                  numberSelectedForAdditionalSlider!));
                                                          if (int.parse(
                                                                  numberSelectedForAdditionalSlider!) >=
                                                              widget.verticalSliderData!
                                                                      .length -
                                                                  2) {
                                                            for (int i = 0;
                                                                i <
                                                                    widget.verticalSliderData!
                                                                            .length -
                                                                        2;
                                                                i++) {
                                                              if (widget
                                                                  .verticalSliderData![
                                                                      i + 2]
                                                                  .tickContent
                                                                  .isNotEmpty) {
                                                                tickSliderControllers[
                                                                            i]
                                                                        .text =
                                                                    widget
                                                                        .verticalSliderData![
                                                                            i + 2]
                                                                        .tickContent;
                                                                valueSliderControllers[
                                                                            i]
                                                                        .text =
                                                                    '${widget.verticalSliderData![i + 2].atValue}';
                                                              }
                                                            }
                                                          }
                                                        }
                                                      } else {
                                                        initializeControllersForVertical(
                                                            int.parse(
                                                                numberSelectedForAdditionalSlider!));
                                                      }
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
                                                                  e,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          17.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black),
                                                                )),
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
                        Row(
                          children: [
                            const Text(
                              'Help text',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w400),
                            ),
                            Checkbox(
                                value: isCheckedHelpText,
                                onChanged: (value) {
                                  setState(() {
                                    isCheckedHelpText = value!;
                                    isChangedForHelpText = true;
                                  });
                                }),
                          ],
                        ),
                        isCheckedHelpText
                            ? Form(
                                key: _formKeyForHelpText,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      textEditingController: helpTextInput,
                                      textFieldLabel: 'Help text',
                                      isLong: true,
                                      onChanged: true,
                                      onChangedFunction: (value) {
                                        setState(() {
                                          isChangedForHelpText = true;
                                        });
                                      },
                                    ),
                                    const SizedBox(),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        Row(
                          children: [
                            const Text(
                              'Adjust text button? (Default is \'Continue\')',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w400),
                            ),
                            Checkbox(
                                value: isCheckedTextButton,
                                onChanged: (value) {
                                  setState(() {
                                    isCheckedTextButton = value!;
                                    isChangedForTextButton = true;
                                  });
                                }),
                          ],
                        ),
                        isCheckedTextButton
                            ? Form(
                                key: _formKeyForTextButton,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      textEditingController: textButtonInput,
                                      textFieldLabel: 'Text button',
                                      isLong: false,
                                      onChanged: true,
                                      onChangedFunction: (value) {
                                        setState(() {
                                          isChangedForTextButton = true;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Play alert sound on screen play?',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w400),
                            ),
                            Checkbox(
                              value: isCheckedAlertSound,
                              onChanged: (value) {
                                setState(() {
                                  isChangedForAlertSound = true;
                                  isCheckedAlertSound = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
