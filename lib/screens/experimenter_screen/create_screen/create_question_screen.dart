import 'dart:developer';
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

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key, required this.experimentName});
  final String experimentName;

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final questionTitleInput = TextEditingController();
  final noticeInput = TextEditingController();
  final timerTitleInput = TextEditingController();
  final timerValueInput = TextEditingController();
  final helpTextInput = TextEditingController();
  final textButtonInput = TextEditingController();
  final highAnchorText = TextEditingController();
  final lowAnchorText = TextEditingController();
  final highAnchorValue = TextEditingController();
  final lowAnchorValue = TextEditingController();
  final _formKeyForNoticeStage = GlobalKey<FormState>();
  final _formKeyForTimerStage = GlobalKey<FormState>();
  final _formKeyForRatingContainer = GlobalKey<FormState>();
  final _formKeyForQuestionStage = GlobalKey<FormState>();
  final _formKeyForMCQs = GlobalKey<FormState>();
  final _formKeyForSlider = GlobalKey<FormState>();
  final _formKeyForModifyTicks = GlobalKey<FormState>();
  final _formKeyForHelpText = GlobalKey<FormState>();
  final _formKeyForTextButton = GlobalKey<FormState>();
  final _formKeyForNumberOfTicks = GlobalKey<FormState>();
  final _formKeyForQuestionType = GlobalKey<FormState>();
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
  List listOptions = [
    'Notice Stage',
    'Question Stage',
    'Rating Container',
    'Timer Stage'
  ];
  List ratingOptions = [
    'Vertical Slider',
    'Horizontal Slider',
  ];
  late List savedQuestion = [];
  bool isVisibleForMCQs = false;
  bool isRatingContainer = false;
  bool isNoticeStage = false;
  bool isQuestionStage = false;
  bool isTimerStage = false;
  bool isVerticalSlider = false;
  bool isHorizontalSlider = false;
  bool isCheckedModifyTick = false;
  bool isCheckedSwapPoles = false;
  bool isCheckedHelpText = false;
  bool isCheckedTextButton = false;
  String? numberSelectedForMCQs;
  String? numberSelectedForVerticalSlider;
  List<TextEditingController> mCQsControllers = [];
  List<TextEditingController> tickSliderControllers = [];
  List<TextEditingController> valueSliderControllers = [];
  int currentOrderNumber = 1;
  int currentRatingNumber = 1;
  bool isVisible = false;
  bool isRatingContainerBefore = false;
  bool isCheckedAlertSound = false;
  bool isShowDialogModifyTick = false;
  bool isShowDialogModifyTickEqually = false;
  bool isShowDialogAboutHighAndLow = false;
  File? _image;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();

    for (int i = 2; i <= 5; i++) {
      listNumberOfChoices.add(i.toString());
    }
    for (int i = 1; i <= 5; i++) {
      listNumberOfModifiedTitleInVerticalSlider.add(i.toString());
    }
    selectedValue == null ? isVisible = false : isVisible = true;
  }

  backToPreviousScreen() {
    Navigator.pop(context);
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

  void movetoNextContent() {
    setState(() {
      if (isQuestionStage || isNoticeStage) {
        numberSelectedForMCQs = null;
        isRatingContainer = false;
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
        isCheckedModifyTick = false;
        isVisible = false;
        currentOrderNumber++;
        lowAnchorValue.clear();
        highAnchorValue.clear();
        isCheckedSwapPoles = false;
        isCheckedAlertSound = false;
        isCheckedHelpText = false;
        isCheckedTextButton = false;
        _image = null;
      }
      if (isRatingContainer) {
        _image = null;
        isRatingContainer = true;
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
        lowAnchorValue.clear();
        highAnchorValue.clear();
        valueChoosed = null;
        mCQsControllers.clear();
        helpTextInput.clear();
        textButtonInput.clear();
        selectedValue = 'Rating Container';
        numberSelectedForVerticalSlider = null;
        isCheckedModifyTick = false;
        isCheckedSwapPoles = false;
        isCheckedAlertSound = false;
        isCheckedHelpText = false;
        isCheckedTextButton = false;
      }
      if (isTimerStage) {
        isTimerStage = false;
        timerTitleInput.clear();
        timerValueInput.clear();
        currentOrderNumber++;
        isCheckedAlertSound = false;
        selectedValue = null;
      }
    });
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

  addNewFunction() async {
    _image == null
        ? imageBytes = null
        : imageBytes = await _image!.readAsBytes();
    if (isTimerStage) {
      if (isRatingContainerBefore) {
        currentOrderNumber++;
        currentRatingNumber++;
        isRatingContainerBefore = false;
      }
      await LocalDatabase().addTimerStage(
          widget.experimentName,
          timerTitleInput.text,
          currentOrderNumber,
          int.parse(timerValueInput.text),
          isCheckedAlertSound);
      movetoNextContent();
    }
    if (isRatingContainer) {
      isRatingContainerBefore = true;

      if (isVerticalSlider) {
        if (isCheckedHelpText && !isCheckedTextButton) {
          if (_formKeyForHelpText.currentState!.validate()) {
            await LocalDatabase().addRatingContainer(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                currentRatingNumber,
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
                currentOrderNumber,
                currentRatingNumber,
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
                currentOrderNumber,
                currentRatingNumber,
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
              currentOrderNumber,
              currentRatingNumber,
              valueChoosed!,
              null,
              null,
              isCheckedAlertSound,
              imageBytes);
        }
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              true);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              true);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              true);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              true);
        }
        if (isCheckedModifyTick) {
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
        movetoNextContent();
      } else if (isHorizontalSlider) {
        if (isCheckedHelpText && !isCheckedTextButton) {
          if (_formKeyForHelpText.currentState!.validate()) {
            await LocalDatabase().addRatingContainer(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                currentRatingNumber,
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
                currentOrderNumber,
                currentRatingNumber,
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
                currentOrderNumber,
                currentRatingNumber,
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
              currentOrderNumber,
              currentRatingNumber,
              valueChoosed!,
              null,
              null,
              isCheckedAlertSound,
              imageBytes);
        }
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              false);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              false);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              false);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              false);
        }
        if (isCheckedModifyTick) {
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
        movetoNextContent();
      }
    } else if (isQuestionStage) {
      if (isRatingContainerBefore) {
        currentOrderNumber++;
        currentRatingNumber++;
        isRatingContainerBefore = false;
      }
      if (isVisibleForMCQs) {
        if (isCheckedHelpText && !isCheckedTextButton) {
          if (_formKeyForHelpText.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                null,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (isCheckedTextButton && !isCheckedHelpText) {
          if (_formKeyForTextButton.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
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
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                textButtonInput.text,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (!isCheckedHelpText && !isCheckedTextButton) {
          await LocalDatabase().addQuestion(
              widget.experimentName,
              questionTitleInput.text,
              currentOrderNumber,
              valueChoosed!,
              null,
              null,
              isCheckedAlertSound,
              imageBytes);
        }
        for (int i = 0; i < mCQsControllers.length; i++) {
          await LocalDatabase().addMultipleChoice(
              widget.experimentName,
              questionTitleInput.text,
              i + 1,
              mCQsControllers[i].text,
              currentOrderNumber);
        }
        movetoNextContent();
      }
      if (isVerticalSlider) {
        if (isCheckedHelpText && !isCheckedTextButton) {
          if (_formKeyForHelpText.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                null,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (isCheckedTextButton && !isCheckedHelpText) {
          if (_formKeyForTextButton.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
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
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                textButtonInput.text,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (!isCheckedHelpText && !isCheckedTextButton) {
          await LocalDatabase().addQuestion(
              widget.experimentName,
              questionTitleInput.text,
              currentOrderNumber,
              valueChoosed!,
              null,
              null,
              isCheckedAlertSound,
              imageBytes);
        }
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              true);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              true);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              true);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              true);
        }
        if (isCheckedModifyTick) {
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
        movetoNextContent();
      } else if (isHorizontalSlider) {
        if (isCheckedHelpText && !isCheckedTextButton) {
          if (_formKeyForHelpText.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                null,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (isCheckedTextButton && !isCheckedHelpText) {
          if (_formKeyForTextButton.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
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
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                textButtonInput.text,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (!isCheckedHelpText && !isCheckedTextButton) {
          await LocalDatabase().addQuestion(
              widget.experimentName,
              questionTitleInput.text,
              currentOrderNumber,
              valueChoosed!,
              null,
              null,
              isCheckedAlertSound,
              imageBytes);
        }
        if (!isCheckedSwapPoles) {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              highAnchorText.text,
              false);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              lowAnchorText.text,
              false);
        } else {
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              1,
              highAnchorValue.text,
              lowAnchorText.text,
              false);
          await LocalDatabase().addMinMaxVerticalAndHorizontalSlider(
              questionTitleInput.text,
              widget.experimentName,
              currentOrderNumber,
              2,
              lowAnchorValue.text,
              highAnchorText.text,
              false);
        }
        if (isCheckedModifyTick) {
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
        movetoNextContent();
      } else {
        if (isCheckedHelpText && !isCheckedTextButton) {
          if (_formKeyForHelpText.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                null,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (isCheckedTextButton && !isCheckedHelpText) {
          if (_formKeyForTextButton.currentState!.validate()) {
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
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
            await LocalDatabase().addQuestion(
                widget.experimentName,
                questionTitleInput.text,
                currentOrderNumber,
                valueChoosed!,
                helpTextInput.text,
                textButtonInput.text,
                isCheckedAlertSound,
                imageBytes);
          }
        }
        if (!isCheckedHelpText && !isCheckedTextButton) {
          await LocalDatabase().addQuestion(
              widget.experimentName,
              questionTitleInput.text,
              currentOrderNumber,
              valueChoosed!,
              null,
              null,
              isCheckedAlertSound,
              imageBytes);
        }
        movetoNextContent();
      }
    }
    if (isNoticeStage) {
      if (isRatingContainerBefore) {
        currentOrderNumber++;
        currentRatingNumber++;
        isRatingContainerBefore = false;
      }

      if (!isCheckedTextButton && isCheckedHelpText) {
        if (_formKeyForHelpText.currentState!.validate()) {
          await LocalDatabase().addNoticeStage(
              currentOrderNumber,
              widget.experimentName,
              noticeInput.text,
              helpTextInput.text,
              null,
              isCheckedAlertSound,
              imageBytes);
        }
      }
      if (isCheckedTextButton && !isCheckedHelpText) {
        if (_formKeyForTextButton.currentState!.validate()) {
          await LocalDatabase().addNoticeStage(
              currentOrderNumber,
              widget.experimentName,
              noticeInput.text,
              null,
              textButtonInput.text,
              isCheckedAlertSound,
              imageBytes);
        }
      }
      if (isCheckedHelpText && isCheckedTextButton) {
        if (_formKeyForTextButton.currentState!.validate() &&
            _formKeyForHelpText.currentState!.validate()) {
          await LocalDatabase().addNoticeStage(
              currentOrderNumber,
              widget.experimentName,
              noticeInput.text,
              helpTextInput.text,
              textButtonInput.text,
              isCheckedAlertSound,
              imageBytes);
        }
      }
      if (!isCheckedHelpText && !isCheckedTextButton) {
        await LocalDatabase().addNoticeStage(
            currentOrderNumber,
            widget.experimentName,
            noticeInput.text,
            null,
            null,
            isCheckedAlertSound,
            imageBytes);
      }
      movetoNextContent();
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
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                            focusNode: FocusNode(canRequestFocus: false),
                            isExpanded: true,
                            value: selectedValue,
                            hint: const Text(
                              'Select an option',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20.0),
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                selectedValue = newValue.toString();
                                isVisible = true;
                                if (selectedValue == 'Notice Stage') {
                                  isNoticeStage = true;
                                  isQuestionStage = false;
                                  isRatingContainer = false;
                                  isVisible = true;
                                  isTimerStage = false;
                                } else if (selectedValue == 'Question Stage') {
                                  isQuestionStage = true;
                                  isNoticeStage = false;
                                  isTimerStage = false;
                                  isVisible = true;
                                  isRatingContainer = false;
                                } else if (selectedValue ==
                                    'Rating Container') {
                                  isQuestionStage = false;
                                  isNoticeStage = false;
                                  isTimerStage = false;
                                  isVisible = true;
                                  isRatingContainer = true;
                                } else {
                                  isQuestionStage = false;
                                  isNoticeStage = false;
                                  isRatingContainer = false;
                                  isTimerStage = true;
                                  isVisible = false;
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
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18.0),
                                      ),
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
                                    const SizedBox(),
                                    CustomTextField(
                                      textEditingController: timerTitleInput,
                                      textFieldLabel:
                                          'Instruction to show whilst waiting',
                                      isLong: true,
                                    ),
                                    const SizedBox(
                                      height: 12.0,
                                    ),
                                    CustomTextField(
                                      textFieldLabel: 'Time to wait in seconds',
                                      textEditingController: timerValueInput,
                                      isTimer: true,
                                    )
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        isNoticeStage
                            ? Column(
                                children: [
                                  Form(
                                    key: _formKeyForNoticeStage,
                                    child: Column(
                                      children: [
                                        const SizedBox(),
                                        CustomTextField(
                                          textEditingController: noticeInput,
                                          textFieldLabel: 'Instruction',
                                          isLong: true,
                                        ),
                                        const SizedBox(),
                                      ],
                                    ),
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
                                              child:
                                                  Text('Delete Chosen Image'),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                  _image == null
                                      ? const SizedBox()
                                      : Image.file(_image!),
                                ],
                              )
                            : const SizedBox(),
                        isRatingContainer
                            ? Form(
                                key: _formKeyForRatingContainer,
                                child: Column(
                                  children: [
                                    const SizedBox(),
                                    CustomTextField(
                                      textFieldLabel: 'Question',
                                      textEditingController: questionTitleInput,
                                    ),
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
                                                child:
                                                    Text('Delete Chosen Image'),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    _image == null
                                        ? const SizedBox()
                                        : Image.file(_image!),
                                    DropdownButtonFormField(
                                      focusNode:
                                          FocusNode(canRequestFocus: false),
                                      isExpanded: true,
                                      hint: const Text(
                                        'Select an option',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20.0),
                                      ),
                                      value: valueChoosed,
                                      onChanged: (newValue) {
                                        setState(() {
                                          valueChoosed = newValue.toString();
                                          if (newValue.toString() ==
                                              'Vertical Slider') {
                                            isVerticalSlider = true;
                                            isVisibleForMCQs = false;
                                            isHorizontalSlider = false;
                                          } else if (newValue.toString() ==
                                              'Horizontal Slider') {
                                            isHorizontalSlider = true;
                                            isVerticalSlider = false;
                                            isVisibleForMCQs = false;
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select an option';
                                        }
                                        return null; // Validation passed
                                      },
                                      items: ratingOptions
                                          .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  e,
                                                  style: const TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18.0),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
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
                                    const SizedBox(
                                      height: 8.0,
                                    ),
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
                                                child:
                                                    Text('Delete Chosen Image'),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    _image == null
                                        ? const SizedBox()
                                        : Image.file(_image!),
                                    Row(
                                      mainAxisAlignment: isVisibleForMCQs
                                          ? MainAxisAlignment.spaceAround
                                          : MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: isVisibleForMCQs ? 2 : 1,
                                            child: const Text(
                                              "Answer type",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.0),
                                              textAlign: TextAlign.center,
                                            )),
                                        isVisibleForMCQs
                                            ? const Expanded(
                                                child: Text(
                                                'Number of choice',
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16.0),
                                              ))
                                            : const SizedBox()
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: isVisibleForMCQs ? 2 : 1,
                                          child: DropdownButtonFormField(
                                            focusNode: FocusNode(
                                                canRequestFocus: false),
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            isExpanded: true,
                                            hint: const Text(
                                              'Select an option',
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20.0),
                                            ),
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
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18.0),
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
                                                  focusNode: FocusNode(
                                                      canRequestFocus: false),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Choices',
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 20.0),
                                                  ),
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
                                                                child: Text(
                                                              e,
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      18.0),
                                                            )),
                                                          ))
                                                      .toList(),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
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
                        (isHorizontalSlider || isVerticalSlider) &&
                                (isQuestionStage || isRatingContainer)
                            ? Form(
                                key: _formKeyForSlider,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 12.0),
                                      child: Row(children: [
                                        Expanded(
                                          flex: 4,
                                          child: SliderValueTextField(
                                            isValue: false,
                                            textFieldLabel: 'Low Anchor Text',
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
                                            textFieldLabel: 'Low Anchor Value',
                                            textEditingController:
                                                lowAnchorValue,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 12.0),
                                      child: Row(children: [
                                        Expanded(
                                          flex: 4,
                                          child: SliderValueTextField(
                                            isValue: false,
                                            textFieldLabel: 'High Anchor Text',
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
                                            textFieldLabel: 'High Anchor Value',
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
                        (isHorizontalSlider || isVerticalSlider) &&
                                (isQuestionStage || isRatingContainer)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                        (isHorizontalSlider || isVerticalSlider) &&
                                (isQuestionStage || isRatingContainer)
                            ? Form(
                                key: _formKeyForNumberOfTicks,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Modify the tick?',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Checkbox(
                                      value: isCheckedModifyTick,
                                      onChanged: (value) {
                                        setState(() {
                                          isCheckedModifyTick = value!;
                                        });
                                      },
                                    ),
                                    isCheckedModifyTick
                                        ? Expanded(
                                            child: DropdownButtonFormField(
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              focusNode: FocusNode(
                                                  canRequestFocus: false),
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
                                                  numberSelectedForVerticalSlider,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  numberSelectedForVerticalSlider =
                                                      newValue.toString();
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
                                                                child: Text(e)),
                                                          ))
                                                      .toList(),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        (isVerticalSlider || isHorizontalSlider) &&
                                isCheckedModifyTick
                            ? Form(
                                key: _formKeyForModifyTicks,
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
                                                  'Anchor ${i + 1} Value',
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
                                  addNewFunction();
                                }
                              } else if (isHorizontalSlider ||
                                  isVerticalSlider) {
                                if (_formKeyForSlider.currentState!
                                    .validate()) {
                                  if (int.parse(highAnchorValue.text) <=
                                      int.parse(lowAnchorValue.text)) {
                                    showDialogAboutLowAndHighValue();
                                  } else {
                                    if (isCheckedModifyTick) {
                                      if (_formKeyForModifyTicks.currentState!
                                              .validate() &&
                                          _formKeyForNumberOfTicks.currentState!
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
                                          addNewFunction();
                                        }
                                      }
                                    } else {
                                      addNewFunction();
                                    }
                                  }
                                }
                              } else {
                                addNewFunction();
                              }
                            }
                          } else if (isTimerStage) {
                            if (_formKeyForTimerStage.currentState!
                                .validate()) {
                              addNewFunction();
                            }
                          } else if (isNoticeStage) {
                            if (_formKeyForNoticeStage.currentState!
                                .validate()) {
                              addNewFunction();
                            }
                          } else {
                            if (_formKeyForRatingContainer.currentState!
                                    .validate() &&
                                _formKeyForSlider.currentState!.validate()) {
                              if (int.parse(highAnchorValue.text) <=
                                  int.parse(lowAnchorValue.text)) {
                                showDialogAboutLowAndHighValue();
                              } else {
                                if (isCheckedModifyTick) {
                                  if (_formKeyForModifyTicks.currentState!
                                          .validate() &&
                                      _formKeyForNumberOfTicks.currentState!
                                          .validate()) {
                                    outerLoop:
                                    for (int i = 0;
                                        i < tickSliderControllers.length;
                                        i++) {
                                      if (int.parse(valueSliderControllers[i]
                                                  .text) >=
                                              int.parse(highAnchorValue.text) ||
                                          int.parse(valueSliderControllers[i]
                                                  .text) <=
                                              int.parse(lowAnchorValue.text)) {
                                        isShowDialogModifyTick = true;
                                        isShowDialogModifyTickEqually = false;
                                        break;
                                      } else {
                                        isShowDialogModifyTick = false;
                                        isShowDialogModifyTickEqually = false;
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
                                      addNewFunction();
                                    }
                                  }
                                } else {
                                  addNewFunction();
                                }
                              }
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    RoundedButton(
                      isBlack: false,
                      buttonLabel: 'Go Back',
                      onPressed: () {
                        if (selectedValue != null) {
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

//if (isTimerStage) {
//   if (isRatingContainerBefore) {
//     currentOrderNumber++;
//     currentRatingNumber++;
//     isRatingContainerBefore = false;
//   }
//   if (_formKeyForTimerStage.currentState!.validate()) {
//     await LocalDatabase().addTimerStage(
//         experimentName,
//         timerTitleInput.text,
//         currentOrderNumber,
//         int.parse(timerValueInput.text),
//         isCheckedAlertSound);
//   }
// }
// if (isRatingContainer) {
//   isRatingContainerBefore = true;
//   if (_formKeyForSlider.currentState!.validate()) {
//     if (int.parse(highAnchorValue.text) <=
//         int.parse(lowAnchorValue.text)) {
//       showDialogAboutLowAndHighValue();
//     } else {
//       if (isVerticalSlider) {
//         if (_formKeyForRatingContainer.currentState!
//             .validate()) {
//           if (!isCheckedTextButton && isCheckedHelpText) {
//             if (_formKeyForHelpText.currentState!
//                 .validate()) {
//               await LocalDatabase().addRatingContainer(
//                   experimentName,
//                   questionTitleInput.text,
//                   currentOrderNumber,
//                   currentRatingNumber,
//                   valueChoosed!,
//                   helpTextInput.text,
//                   null,
//                   isCheckedAlertSound);
//             }
//           }
//           if (isCheckedTextButton && !isCheckedHelpText) {
//             if (_formKeyForTextButton.currentState!
//                 .validate()) {
//               await LocalDatabase().addRatingContainer(
//                   experimentName,
//                   questionTitleInput.text,
//                   currentOrderNumber,
//                   currentRatingNumber,
//                   valueChoosed!,
//                   null,
//                   textButtonInput.text,
//                   isCheckedAlertSound);
//             }
//           }
//           if (isCheckedHelpText && isCheckedTextButton) {
//             if (_formKeyForTextButton.currentState!
//                     .validate() &&
//                 _formKeyForHelpText.currentState!
//                     .validate()) {
//               await LocalDatabase().addRatingContainer(
//                   experimentName,
//                   questionTitleInput.text,
//                   currentOrderNumber,
//                   currentRatingNumber,
//                   valueChoosed!,
//                   helpTextInput.text,
//                   textButtonInput.text,
//                   isCheckedAlertSound);
//             }
//           }
//           if (!isCheckedHelpText && !isCheckedTextButton) {
//             await LocalDatabase().addRatingContainer(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 currentRatingNumber,
//                 valueChoosed!,
//                 null,
//                 null,
//                 isCheckedAlertSound);
//           }
//           if (!isCheckedSwapPoles) {
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     1,
//                     highAnchorValue.text,
//                     highAnchorText.text,
//                     true);
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     2,
//                     lowAnchorValue.text,
//                     lowAnchorText.text,
//                     true);
//           } else {
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     1,
//                     highAnchorValue.text,
//                     lowAnchorText.text,
//                     true);
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     2,
//                     lowAnchorValue.text,
//                     highAnchorText.text,
//                     true);
//           }
//           if (isCheckedModifyTick) {
//             if (_formKeyForModifyTicks.currentState!
//                 .validate()) {
//               for (int i = 0;
//                   i < tickSliderControllers.length;
//                   i++) {
//                 await LocalDatabase().addSliderOptions(
//                     experimentName,
//                     questionTitleInput.text,
//                     i + 3,
//                     int.parse(valueSliderControllers[i].text),
//                     tickSliderControllers[i].text,
//                     true);
//               }
//             }
//           }
//         }
//       } else if (isHorizontalSlider) {
//         if (_formKeyForRatingContainer.currentState!
//             .validate()) {
//           if (isCheckedHelpText && !isCheckedTextButton) {
//             if (_formKeyForHelpText.currentState!
//                 .validate()) {
//               await LocalDatabase().addRatingContainer(
//                   experimentName,
//                   questionTitleInput.text,
//                   currentOrderNumber,
//                   currentRatingNumber,
//                   valueChoosed!,
//                   helpTextInput.text,
//                   null,
//                   isCheckedAlertSound);
//             }
//           }
//           if (!isCheckedHelpText && isCheckedTextButton) {
//             if (_formKeyForTextButton.currentState!
//                 .validate()) {
//               await LocalDatabase().addRatingContainer(
//                   experimentName,
//                   questionTitleInput.text,
//                   currentOrderNumber,
//                   currentRatingNumber,
//                   valueChoosed!,
//                   null,
//                   textButtonInput.text,
//                   isCheckedAlertSound);
//             }
//           }
//           if (isCheckedHelpText && isCheckedTextButton) {
//             if (_formKeyForTextButton.currentState!
//                     .validate() &&
//                 _formKeyForHelpText.currentState!
//                     .validate()) {
//               await LocalDatabase().addRatingContainer(
//                   experimentName,
//                   questionTitleInput.text,
//                   currentOrderNumber,
//                   currentRatingNumber,
//                   valueChoosed!,
//                   helpTextInput.text,
//                   textButtonInput.text,
//                   isCheckedAlertSound);
//             }
//           }
//           if (!isCheckedHelpText && !isCheckedTextButton) {
//             await LocalDatabase().addRatingContainer(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 currentRatingNumber,
//                 valueChoosed!,
//                 null,
//                 null,
//                 isCheckedAlertSound);
//           }
//           if (!isCheckedSwapPoles) {
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     1,
//                     highAnchorValue.text,
//                     highAnchorText.text,
//                     false);
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     2,
//                     lowAnchorValue.text,
//                     lowAnchorText.text,
//                     false);
//           } else {
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     1,
//                     highAnchorValue.text,
//                     lowAnchorText.text,
//                     false);
//             await LocalDatabase()
//                 .addMinMaxVerticalAndHorizontalSlider(
//                     questionTitleInput.text,
//                     experimentName,
//                     currentOrderNumber,
//                     2,
//                     lowAnchorValue.text,
//                     highAnchorText.text,
//                     false);
//           }
//           if (isCheckedModifyTick) {
//             if (_formKeyForModifyTicks.currentState!
//                 .validate()) {
//               for (int i = 0;
//                   i < tickSliderControllers.length;
//                   i++) {
//                 await LocalDatabase().addSliderOptions(
//                     experimentName,
//                     questionTitleInput.text,
//                     i + 3,
//                     int.parse(valueSliderControllers[i].text),
//                     tickSliderControllers[i].text,
//                     false);
//               }
//             }
//           }
//         }
//       }
//     }
//   }
// } else if (isQuestionStage) {
//   if (isRatingContainerBefore) {
//     currentOrderNumber++;
//     isRatingContainerBefore = false;
//     currentRatingNumber++;
//   }
//   if (isVisibleForMCQs) {
//     if (_formKeyForQuestionStage.currentState!.validate() &&
//         _formKeyForMCQs.currentState!.validate()) {
//       if (isCheckedHelpText && !isCheckedTextButton) {
//         if (_formKeyForHelpText.currentState!.validate()) {
//           await LocalDatabase().addQuestion(
//               experimentName,
//               questionTitleInput.text,
//               currentOrderNumber,
//               valueChoosed!,
//               helpTextInput.text,
//               null,
//               isCheckedAlertSound);
//         }
//       }
//       if (!isCheckedHelpText && isCheckedTextButton) {
//         if (_formKeyForTextButton.currentState!.validate()) {
//           await LocalDatabase().addQuestion(
//               experimentName,
//               questionTitleInput.text,
//               currentOrderNumber,
//               valueChoosed!,
//               null,
//               textButtonInput.text,
//               isCheckedAlertSound);
//         }
//       }
//       if (isCheckedHelpText && isCheckedTextButton) {
//         if (_formKeyForTextButton.currentState!.validate() &&
//             _formKeyForHelpText.currentState!.validate()) {
//           await LocalDatabase().addQuestion(
//               experimentName,
//               questionTitleInput.text,
//               currentOrderNumber,
//               valueChoosed!,
//               helpTextInput.text,
//               textButtonInput.text,
//               isCheckedAlertSound);
//         }
//       }
//       if (!isCheckedHelpText && !isCheckedTextButton) {
//         await LocalDatabase().addQuestion(
//             experimentName,
//             questionTitleInput.text,
//             currentOrderNumber,
//             valueChoosed!,
//             null,
//             null,
//             isCheckedAlertSound);
//       }
//       for (int i = 0; i < mCQsControllers.length; i++) {
//         await LocalDatabase().addMultipleChoice(
//             experimentName,
//             questionTitleInput.text,
//             i + 1,
//             mCQsControllers[i].text,
//             currentOrderNumber);
//       }
//     }
//   }
//   if (isVerticalSlider) {
//     if (int.parse(highAnchorValue.text) <=
//         int.parse(lowAnchorValue.text)) {
//       showDialogAboutLowAndHighValue();
//     } else {
//       if (_formKeyForQuestionStage.currentState!.validate() &&
//           _formKeyForSlider.currentState!.validate()) {
//         if (isCheckedHelpText && !isCheckedTextButton) {
//           if (_formKeyForHelpText.currentState!.validate()) {
//             await LocalDatabase().addQuestion(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 valueChoosed!,
//                 helpTextInput.text,
//                 null,
//                 isCheckedAlertSound);
//           }
//         }
//         if (!isCheckedHelpText && isCheckedTextButton) {
//           if (_formKeyForTextButton.currentState!
//               .validate()) {
//             await LocalDatabase().addQuestion(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 valueChoosed!,
//                 null,
//                 textButtonInput.text,
//                 isCheckedAlertSound);
//           }
//         }
//         if (isCheckedHelpText && isCheckedTextButton) {
//           if (_formKeyForTextButton.currentState!
//                   .validate() &&
//               _formKeyForHelpText.currentState!.validate()) {
//             await LocalDatabase().addQuestion(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 valueChoosed!,
//                 helpTextInput.text,
//                 textButtonInput.text,
//                 isCheckedAlertSound);
//           }
//         }
//         if (!isCheckedHelpText && !isCheckedTextButton) {
//           await LocalDatabase().addQuestion(
//               experimentName,
//               questionTitleInput.text,
//               currentOrderNumber,
//               valueChoosed!,
//               null,
//               null,
//               isCheckedAlertSound);
//         }
//         if (!isCheckedSwapPoles) {
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   1,
//                   highAnchorValue.text,
//                   highAnchorText.text,
//                   true);
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   2,
//                   lowAnchorValue.text,
//                   lowAnchorText.text,
//                   true);
//         } else {
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   1,
//                   highAnchorValue.text,
//                   lowAnchorText.text,
//                   true);
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   2,
//                   lowAnchorValue.text,
//                   highAnchorText.text,
//                   true);
//         }
//         if (isCheckedModifyTick) {
//           if (_formKeyForModifyTicks.currentState!
//               .validate()) {
//             for (int i = 0;
//                 i < tickSliderControllers.length;
//                 i++) {
//               await LocalDatabase().addSliderOptions(
//                   experimentName,
//                   questionTitleInput.text,
//                   i + 3,
//                   int.parse(valueSliderControllers[i].text),
//                   tickSliderControllers[i].text,
//                   true);
//             }
//           }
//         }
//       }
//     }
//   } else if (isHorizontalSlider) {
//     if (int.parse(highAnchorValue.text) <=
//         int.parse(lowAnchorValue.text)) {
//       showDialogAboutLowAndHighValue();
//     } else {
//       if (_formKeyForQuestionStage.currentState!.validate() &&
//           _formKeyForSlider.currentState!.validate()) {
//         if (!isCheckedTextButton && isCheckedHelpText) {
//           if (_formKeyForHelpText.currentState!.validate()) {
//             await LocalDatabase().addQuestion(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 valueChoosed!,
//                 helpTextInput.text,
//                 null,
//                 isCheckedAlertSound);
//           }
//         }
//         if (isCheckedTextButton && !isCheckedHelpText) {
//           if (_formKeyForTextButton.currentState!
//               .validate()) {
//             await LocalDatabase().addQuestion(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 valueChoosed!,
//                 null,
//                 textButtonInput.text,
//                 isCheckedAlertSound);
//           }
//         }
//         if (isCheckedHelpText && isCheckedTextButton) {
//           if (_formKeyForTextButton.currentState!
//                   .validate() &&
//               _formKeyForHelpText.currentState!.validate()) {
//             await LocalDatabase().addQuestion(
//                 experimentName,
//                 questionTitleInput.text,
//                 currentOrderNumber,
//                 valueChoosed!,
//                 helpTextInput.text,
//                 textButtonInput.text,
//                 isCheckedAlertSound);
//           }
//         }
//         if (!isCheckedHelpText && !isCheckedTextButton) {
//           await LocalDatabase().addQuestion(
//               experimentName,
//               questionTitleInput.text,
//               currentOrderNumber,
//               valueChoosed!,
//               null,
//               null,
//               isCheckedAlertSound);
//         }
//         if (!isCheckedSwapPoles) {
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   1,
//                   highAnchorValue.text,
//                   highAnchorText.text,
//                   false);
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   2,
//                   lowAnchorValue.text,
//                   lowAnchorText.text,
//                   false);
//         } else {
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   1,
//                   highAnchorValue.text,
//                   lowAnchorText.text,
//                   false);
//           await LocalDatabase()
//               .addMinMaxVerticalAndHorizontalSlider(
//                   questionTitleInput.text,
//                   experimentName,
//                   currentOrderNumber,
//                   2,
//                   lowAnchorValue.text,
//                   highAnchorText.text,
//                   false);
//         }
//         if (isCheckedModifyTick) {
//           if (_formKeyForModifyTicks.currentState!
//               .validate()) {
//             for (int i = 0;
//                 i < tickSliderControllers.length;
//                 i++) {
//               await LocalDatabase().addSliderOptions(
//                   experimentName,
//                   questionTitleInput.text,
//                   i + 3,
//                   int.parse(valueSliderControllers[i].text),
//                   tickSliderControllers[i].text,
//                   false);
//             }
//           }
//         }
//       }
//     }
//   } else {
//     if (isCheckedHelpText && !isCheckedTextButton) {
//       if (_formKeyForHelpText.currentState!.validate()) {
//         await LocalDatabase().addQuestion(
//             experimentName,
//             questionTitleInput.text,
//             currentOrderNumber,
//             valueChoosed!,
//             helpTextInput.text,
//             null,
//             isCheckedAlertSound);
//       }
//     }
//     if (!isCheckedHelpText && isCheckedTextButton) {
//       if (_formKeyForTextButton.currentState!.validate()) {
//         await LocalDatabase().addQuestion(
//             experimentName,
//             questionTitleInput.text,
//             currentOrderNumber,
//             valueChoosed!,
//             null,
//             textButtonInput.text,
//             isCheckedAlertSound);
//       }
//     }
//     if (isCheckedHelpText && isCheckedTextButton) {
//       if (_formKeyForTextButton.currentState!.validate() &&
//           _formKeyForHelpText.currentState!.validate()) {
//         await LocalDatabase().addQuestion(
//             experimentName,
//             questionTitleInput.text,
//             currentOrderNumber,
//             valueChoosed!,
//             helpTextInput.text,
//             textButtonInput.text,
//             isCheckedAlertSound);
//       }
//     }
//     if (!isCheckedHelpText && !isCheckedTextButton) {
//       await LocalDatabase().addQuestion(
//           experimentName,
//           questionTitleInput.text,
//           currentOrderNumber,
//           valueChoosed!,
//           null,
//           null,
//           isCheckedAlertSound);
//     }
//   }
// }
// if (isNoticeStage) {
//   if (isRatingContainerBefore) {
//     currentOrderNumber++;
//     currentRatingNumber++;
//     isRatingContainerBefore = false;
//   }
//   if (_formKeyForNoticeStage.currentState!.validate()) {
//     if (isCheckedHelpText && !isCheckedTextButton) {
//       if (_formKeyForHelpText.currentState!.validate()) {
//         await LocalDatabase().addNoticeStage(
//             currentOrderNumber,
//             experimentName,
//             noticeInput.text,
//             helpTextInput.text,
//             null,
//             isCheckedAlertSound);
//       }
//     }
//     if (isCheckedTextButton && !isCheckedHelpText) {
//       if (_formKeyForTextButton.currentState!.validate()) {
//         await LocalDatabase().addNoticeStage(
//             currentOrderNumber,
//             experimentName,
//             noticeInput.text,
//             null,
//             textButtonInput.text,
//             isCheckedAlertSound);
//       }
//     }
//     if (isCheckedHelpText && isCheckedTextButton) {
//       if (_formKeyForTextButton.currentState!.validate() &&
//           _formKeyForHelpText.currentState!.validate()) {
//         await LocalDatabase().addNoticeStage(
//             currentOrderNumber,
//             experimentName,
//             noticeInput.text,
//             helpTextInput.text,
//             textButtonInput.text,
//             isCheckedAlertSound);
//       }
//     }
//     if (!isCheckedHelpText && !isCheckedTextButton) {
//       await LocalDatabase().addNoticeStage(
//           currentOrderNumber,
//           experimentName,
//           noticeInput.text,
//           null,
//           null,
//           isCheckedAlertSound);
//     }
//   }
// }
