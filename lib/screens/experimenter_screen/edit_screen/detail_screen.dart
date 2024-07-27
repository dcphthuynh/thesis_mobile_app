import 'dart:developer';
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
import 'package:thesis_app/objects/experiment_content.dart';
import 'package:thesis_app/objects/multiple_choice.dart';
import 'package:thesis_app/objects/slider_data.dart';

class DetailScreen extends StatefulWidget {
  // In the constructor, require a Todo.
  const DetailScreen(
      {super.key,
      required this.experimentContent,
      this.verticalSliderData,
      this.horizontalSliderData,
      this.mCQsData,
      required this.experimentName,
      required this.orderNumber});

  // Declare a field that holds the Todo.
  final String experimentName;
  final int orderNumber;
  final ExperimentContent experimentContent;
  final List<SliderData>? verticalSliderData;
  final List<SliderData>? horizontalSliderData;
  final List<MultipleChoice>? mCQsData;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late ExperimentContent initialState;
  late List<SliderData> initialStateOfVerticalSlider;
  String? selectedValue;
  List listOptions = ['Notice Stage', 'Question Stage', 'Timer Stage'];
  bool isNoticeStage = false;
  bool isQuestionStage = false;
  bool isTimerStage = false;
  final questionTitleInput = TextEditingController();
  final noticeInput = TextEditingController();
  final _formKeyForNoticeStage = GlobalKey<FormState>();
  final _formKeyForQuestionStage = GlobalKey<FormState>();
  bool isVisibleForMCQs = false;
  bool isVisible = false;
  bool isInputAnswer = false;
  String? valueChoosed;
  bool isVerticalSlider = false;
  bool isHorizontalSlider = false;
  List listAnswerType = [
    'Vertical Slider',
    'Horizontal Slider',
    'Multiple Choices',
    'Input Answer',
  ];
  List<TextEditingController> mCQsControllers = [];
  String? numberSelectedForMCQs;
  String? numberSelectedForAdditionalSlider;
  List listNumberOfChoices = [];
  List listNumberOfModifiedTitleInVerticalSlider = [];
  bool isChecked = false;
  final _formKeyForMCQs = GlobalKey<FormState>();
  final _formKeyForSlider = GlobalKey<FormState>();
  final _formKeyForAdditionalSlider = GlobalKey<FormState>();
  List<TextEditingController> tickSliderControllers = [];
  List<TextEditingController> valueSliderControllers = [];
  final highAnchorText = TextEditingController();
  final lowAnchorText = TextEditingController();
  final highAnchorValue = TextEditingController();
  final lowAnchorValue = TextEditingController();
  bool isChangedForHelpText = false;
  bool isChangedForTextButton = false;
  bool isCheckedSwapPoles = false;
  final helpTextInput = TextEditingController();
  final textButtonInput = TextEditingController();
  final timerTitleInput = TextEditingController();
  final timerValueInput = TextEditingController();
  final _formKeyForTimerStage = GlobalKey<FormState>();
  final _formKeyForHelpText = GlobalKey<FormState>();
  final _formKeyForTextButton = GlobalKey<FormState>();
  bool isCheckedAlertSound = false;
  bool isChangedForAlertSound = false;
  bool isCheckedHelpText = false;
  bool isCheckedTextButton = false;
  bool isShowDialogModifyTick = false;
  bool isShowDialogModifyTickEqually = false;
  bool isShowDialogAboutHighAndLow = false;
  File? _image;
  Uint8List? imageBytesInMemory;
  Uint8List? imageBytesNew;
  bool isImageChanged = false;

  void initializeControllersForMCQs(int count) {
    mCQsControllers = List.generate(count, (index) => TextEditingController());
  }

  void initializeControllersForSlider(int count) {
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

  pressingYesButton() {
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  updateFunction() async {
    if (initialState.type == 'Timer') {
      if (isTimerStage) {
        await LocalDatabase().updateTimer(
            timerTitleInput.text,
            widget.experimentName,
            widget.orderNumber,
            int.parse(timerValueInput.text));
      }
      if (isNoticeStage) {
        await LocalDatabase().updateTimerToNotice(
            noticeInput.text, widget.experimentName, widget.orderNumber);
      }
      if (isQuestionStage) {
        if (isCheckedTextButton && isCheckedHelpText) {
          if (_formKeyForHelpText.currentState!.validate() &&
              _formKeyForTextButton.currentState!.validate()) {
            await LocalDatabase().updateTimerToQuestion(
                isHorizontalSlider,
                isVerticalSlider,
                isVisibleForMCQs,
                isInputAnswer,
                widget.experimentName,
                widget.orderNumber,
                helpTextInput.text,
                textButtonInput.text);
          }
        }
        if (isCheckedTextButton) {
          if (_formKeyForTextButton.currentState!.validate()) {
            await LocalDatabase().updateTimerToQuestion(
                isHorizontalSlider,
                isVerticalSlider,
                isVisibleForMCQs,
                isInputAnswer,
                widget.experimentName,
                widget.orderNumber,
                null,
                textButtonInput.text);
          }
        }
        if (isCheckedHelpText) {
          if (_formKeyForHelpText.currentState!.validate()) {
            await LocalDatabase().updateTimerToQuestion(
                isHorizontalSlider,
                isVerticalSlider,
                isVisibleForMCQs,
                isInputAnswer,
                widget.experimentName,
                widget.orderNumber,
                helpTextInput.text,
                null);
          }
        }
        if (!isCheckedHelpText && !isCheckedTextButton) {
          await LocalDatabase().updateTimerToQuestion(
              isHorizontalSlider,
              isVerticalSlider,
              isVisibleForMCQs,
              isInputAnswer,
              widget.experimentName,
              widget.orderNumber,
              null,
              null);
        }

        if (isVisibleForMCQs) {
          for (int i = 0; i < mCQsControllers.length; i++) {
            await LocalDatabase().addMultipleChoice(
                widget.experimentName,
                questionTitleInput.text,
                i + 1,
                mCQsControllers[i].text,
                widget.orderNumber);
          }
        }
        if (isHorizontalSlider) {
          if (_formKeyForSlider.currentState!.validate()) {
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
          }
        } else if (isVerticalSlider) {
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
        }
      }
    }

    if (isImageChanged) {
      _image == null
          ? imageBytesNew = null
          : imageBytesNew = await _image!.readAsBytes();
      await LocalDatabase()
          .saveImage(imageBytesNew, widget.experimentContent.id);
    }
    if (isChangedForHelpText || isChangedForTextButton) {
      if (isCheckedHelpText && isCheckedTextButton) {
        if (_formKeyForTextButton.currentState!.validate() &&
            _formKeyForHelpText.currentState!.validate()) {
          await LocalDatabase().updateHelpTextAndTextButton(helpTextInput.text,
              textButtonInput.text, widget.experimentName, widget.orderNumber);
        }
      }
      if (isCheckedHelpText && !isCheckedTextButton) {
        if (_formKeyForHelpText.currentState!.validate()) {
          await LocalDatabase().updateHelpTextAndTextButton(helpTextInput.text,
              null, widget.experimentName, widget.orderNumber);
        }
      }
      if (!isCheckedHelpText && isCheckedTextButton) {
        if (_formKeyForTextButton.currentState!.validate()) {
          await LocalDatabase().updateHelpTextAndTextButton(null,
              textButtonInput.text, widget.experimentName, widget.orderNumber);
        }
      }
      if (!isCheckedTextButton && !isCheckedHelpText) {
        await LocalDatabase().updateHelpTextAndTextButton(
            null, null, widget.experimentName, widget.orderNumber);
      }
    }

    if (isChangedForAlertSound) {
      await LocalDatabase().updateAlertSound(
          isCheckedAlertSound, widget.experimentName, widget.orderNumber);
    }
    if (isTimerStage && initialState.type == 'Notice') {
      await LocalDatabase().updateNoticeToTimer(
          timerTitleInput.text,
          widget.experimentName,
          widget.orderNumber,
          int.parse(timerValueInput.text));
    } else if (isNoticeStage && initialState.type == 'Notice') {
      await LocalDatabase().updateTitle(
          noticeInput.text, widget.experimentName, widget.orderNumber);
    } else if (isQuestionStage && initialState.type == 'Notice') {
      await LocalDatabase().updateNoticeStage(
          isHorizontalSlider,
          isVerticalSlider,
          isVisibleForMCQs,
          isInputAnswer,
          widget.experimentName,
          widget.orderNumber);

      await LocalDatabase().updateTitle(
          questionTitleInput.text, widget.experimentName, widget.orderNumber);
      if (isVisibleForMCQs) {
        if (_formKeyForMCQs.currentState!.validate()) {
          for (int i = 0; i < mCQsControllers.length; i++) {
            await LocalDatabase().addMultipleChoice(
                widget.experimentName,
                questionTitleInput.text,
                i + 1,
                mCQsControllers[i].text,
                widget.orderNumber);
          }
        }
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
      } else if (isVerticalSlider) {
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
    } else if (isQuestionStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Vertical Slider' &&
        isVerticalSlider) {
      if (!isCheckedSwapPoles) {
        await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
            true,
            highAnchorText.text,
            1,
            highAnchorValue.text,
            widget.experimentContent.id);
        await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
            true,
            lowAnchorText.text,
            2,
            lowAnchorValue.text,
            widget.experimentContent.id);
      } else {
        await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
            true,
            lowAnchorText.text,
            1,
            highAnchorValue.text,
            widget.experimentContent.id);
        await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
            true,
            highAnchorText.text,
            2,
            lowAnchorValue.text,
            widget.experimentContent.id);
      }
      if (!isChecked) {
        for (int i = 0; i < widget.verticalSliderData!.length - 2; i++) {
          await LocalDatabase().deleteSliderData(
              widget.experimentName,
              widget.verticalSliderData![i + 2].atValue.toString(),
              widget.experimentContent.id,
              true);
        }
      } else {
        if (widget.verticalSliderData!.length - 2 == 0) {
          for (int i = 0; i < tickSliderControllers.length; i++) {
            await LocalDatabase().addSliderOptions(
                widget.experimentName,
                questionTitleInput.text,
                i + 3,
                int.parse(valueSliderControllers[i].text),
                tickSliderControllers[i].text,
                true);
          }
        } else {
          if (int.parse(numberSelectedForAdditionalSlider!) ==
              widget.verticalSliderData!.length - 2) {
            //UPDATE TUNG CAI
            for (int i = 0; i < widget.verticalSliderData!.length - 2; i++) {
              await LocalDatabase()
                  .updateTickContentInVerticalOrHorizontalSlider(
                      tickSliderControllers[i].text,
                      valueSliderControllers[i].text,
                      i + 3,
                      widget.experimentContent.id,
                      true);
            }
          } else if (widget.verticalSliderData!.length - 2 <
              int.parse(numberSelectedForAdditionalSlider!)) {
            for (int i = 0; i < widget.verticalSliderData!.length - 2; i++) {
              await LocalDatabase()
                  .updateTickContentInVerticalOrHorizontalSlider(
                      tickSliderControllers[i].text,
                      valueSliderControllers[i].text,
                      i + 3,
                      widget.experimentContent.id,
                      true);
            }
            for (int i = 0;
                i <
                    tickSliderControllers.length -
                        widget.verticalSliderData!.length +
                        2;
                i++) {
              await LocalDatabase().addSliderOptions(
                  widget.experimentName,
                  questionTitleInput.text,
                  (widget.verticalSliderData!.length) + i + 1,
                  int.parse(valueSliderControllers[
                          (widget.verticalSliderData!.length - 2) + i]
                      .text),
                  tickSliderControllers[
                          (widget.verticalSliderData!.length - 2) + i]
                      .text,
                  true);
            }
          } else {
            for (int i = 0; i < tickSliderControllers.length; i++) {
              await LocalDatabase()
                  .updateTickContentInVerticalOrHorizontalSlider(
                      tickSliderControllers[i].text,
                      valueSliderControllers[i].text,
                      i + 3,
                      widget.experimentContent.id,
                      true);
            }
            for (int i = 0;
                i <
                    widget.verticalSliderData!.length -
                        tickSliderControllers.length -
                        2;
                i++) {
              await LocalDatabase().deleteSliderData(
                  widget.experimentName,
                  widget
                      .verticalSliderData![
                          i + widget.verticalSliderData!.length - 2]
                      .atValue
                      .toString(),
                  widget.experimentContent.id,
                  true);
            }
          }
        }
      }
    } else if (isQuestionStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Vertical Slider' &&
        isHorizontalSlider) {
      await LocalDatabase().updateVerticalToHorizontal(
          questionTitleInput.text, widget.experimentName, widget.orderNumber);
      if (_formKeyForSlider.currentState!.validate()) {
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
      }
    } else if (isQuestionStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Vertical Slider' &&
        (isVisibleForMCQs || isInputAnswer)) {
      await LocalDatabase().updateVerticalToMCQsOrInput(isVisibleForMCQs,
          questionTitleInput.text, widget.experimentName, widget.orderNumber);

      if (isVisibleForMCQs) {
        for (int i = 0; i < mCQsControllers.length; i++) {
          await LocalDatabase().addMultipleChoice(
              widget.experimentName,
              questionTitleInput.text,
              i + 1,
              mCQsControllers[i].text,
              widget.orderNumber);
        }
      }
    } else if (isNoticeStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Vertical Slider') {
      await LocalDatabase().updateVerticalOrHorizontalToNoticeStage(
          true, noticeInput.text, widget.experimentName, widget.orderNumber);
    } else if (initialState.answerType == 'Vertical Slider' && isTimerStage) {
      await LocalDatabase().updateVerticalOrHorizontalToTimerStage(
          true,
          timerTitleInput.text,
          widget.experimentName,
          widget.orderNumber,
          int.parse(timerValueInput.text));
    } else if (isQuestionStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Horizontal Slider') {
      if (isHorizontalSlider) {
        await LocalDatabase().updateTitle(
            questionTitleInput.text, widget.experimentName, widget.orderNumber);

        if (!isCheckedSwapPoles) {
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
              false,
              highAnchorText.text,
              1,
              highAnchorValue.text,
              widget.experimentContent.id);
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
              false,
              lowAnchorText.text,
              2,
              lowAnchorValue.text,
              widget.experimentContent.id);
        } else {
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
              false,
              lowAnchorText.text,
              1,
              highAnchorValue.text,
              widget.experimentContent.id);
          await LocalDatabase().updateMaxMinVeritcalOrHorizontalSlider(
              false,
              highAnchorText.text,
              2,
              lowAnchorValue.text,
              widget.experimentContent.id);
        }
        if (!isChecked) {
          for (int i = 0; i < widget.horizontalSliderData!.length - 2; i++) {
            await LocalDatabase().deleteSliderData(
                widget.experimentName,
                widget.horizontalSliderData![i + 2].atValue.toString(),
                widget.experimentContent.id,
                false);
          }
        } else {
          if (widget.horizontalSliderData!.length - 2 == 0) {
            for (int i = 0; i < tickSliderControllers.length; i++) {
              await LocalDatabase().addSliderOptions(
                  widget.experimentName,
                  questionTitleInput.text,
                  i + 3,
                  int.parse(valueSliderControllers[i].text),
                  tickSliderControllers[i].text,
                  false);
            }
          } else {
            if (int.parse(numberSelectedForAdditionalSlider!) ==
                widget.horizontalSliderData!.length - 2) {
              //UPDATE TUNG CAI
              for (int i = 0;
                  i < widget.horizontalSliderData!.length - 2;
                  i++) {
                await LocalDatabase()
                    .updateTickContentInVerticalOrHorizontalSlider(
                        tickSliderControllers[i].text,
                        valueSliderControllers[i].text,
                        i + 3,
                        widget.experimentContent.id,
                        false);
              }
            } else if (widget.horizontalSliderData!.length - 2 <
                int.parse(numberSelectedForAdditionalSlider!)) {
              for (int i = 0;
                  i < widget.horizontalSliderData!.length - 2;
                  i++) {
                await LocalDatabase()
                    .updateTickContentInVerticalOrHorizontalSlider(
                        tickSliderControllers[i].text,
                        valueSliderControllers[i].text,
                        i + 3,
                        widget.experimentContent.id,
                        false);
              }
              for (int i = 0;
                  i <
                      tickSliderControllers.length -
                          widget.horizontalSliderData!.length +
                          2;
                  i++) {
                await LocalDatabase().addSliderOptions(
                    widget.experimentName,
                    questionTitleInput.text,
                    (widget.horizontalSliderData!.length) + i + 1,
                    int.parse(valueSliderControllers[
                            (widget.horizontalSliderData!.length - 2) + i]
                        .text),
                    tickSliderControllers[
                            (widget.horizontalSliderData!.length - 2) + i]
                        .text,
                    true);
              }
            } else {
              for (int i = 0; i < tickSliderControllers.length; i++) {
                await LocalDatabase()
                    .updateTickContentInVerticalOrHorizontalSlider(
                        tickSliderControllers[i].text,
                        valueSliderControllers[i].text,
                        i + 3,
                        widget.experimentContent.id,
                        false);
              }
              for (int i = 0;
                  i <
                      widget.horizontalSliderData!.length -
                          tickSliderControllers.length -
                          2;
                  i++) {
                await LocalDatabase().deleteSliderData(
                    widget.experimentName,
                    widget
                        .horizontalSliderData![
                            i + widget.horizontalSliderData!.length - 2]
                        .atValue
                        .toString(),
                    widget.experimentContent.id,
                    false);
              }
            }
          }
        }
      } else if (isVisibleForMCQs) {
        await LocalDatabase().updateHorizontalToMCQsOrInput(isVisibleForMCQs,
            questionTitleInput.text, widget.experimentName, widget.orderNumber);
        for (int i = 0; i < mCQsControllers.length; i++) {
          await LocalDatabase().addMultipleChoice(
              widget.experimentName,
              questionTitleInput.text,
              i + 1,
              mCQsControllers[i].text,
              widget.orderNumber);
        }
      } else if (isInputAnswer) {
        await LocalDatabase().updateHorizontalToMCQsOrInput(isVisibleForMCQs,
            questionTitleInput.text, widget.experimentName, widget.orderNumber);
      } else if (isVerticalSlider) {
        await LocalDatabase().updateHorizontalToVertical(
            questionTitleInput.text, widget.experimentName, widget.orderNumber);
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
        }
      } else if (initialState.type == 'Question' &&
          initialState.answerType == 'Horizontal Slider' &&
          isNoticeStage) {
        await LocalDatabase().updateVerticalOrHorizontalToNoticeStage(
            false, noticeInput.text, widget.experimentName, widget.orderNumber);
      } else if (initialState.answerType == 'Horizontal Slider' &&
          isTimerStage) {
        await LocalDatabase().updateVerticalOrHorizontalToTimerStage(
            false,
            noticeInput.text,
            widget.experimentName,
            widget.orderNumber,
            int.parse(timerValueInput.text));
      }
    } else if (isQuestionStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Multiple Choices') {
      await LocalDatabase().updateTitle(
          questionTitleInput.text, widget.experimentName, widget.orderNumber);
      if (isVisibleForMCQs) {
        if (int.parse(numberSelectedForMCQs!) == widget.mCQsData!.length) {
          if (_formKeyForMCQs.currentState!.validate()) {
            for (int i = 0; i < mCQsControllers.length; i++) {
              await LocalDatabase().updateMCQsData(mCQsControllers[i].text,
                  widget.experimentName, widget.orderNumber, i + 1);
            }
          }
        } else if (int.parse(numberSelectedForMCQs!) >
            widget.mCQsData!.length) {
          for (int i = 0; i < widget.mCQsData!.length; i++) {
            await LocalDatabase().updateMCQsData(mCQsControllers[i].text,
                widget.experimentName, widget.orderNumber, i + 1);
          }
          for (int i = 0;
              i < int.parse(numberSelectedForMCQs!) - widget.mCQsData!.length;
              i++) {
            await LocalDatabase().addMultipleChoice(
                widget.experimentName,
                questionTitleInput.text,
                widget.mCQsData!.length + i + 1,
                mCQsControllers[widget.mCQsData!.length + i].text,
                widget.orderNumber);
          }
        } else {
          for (int i = 0; i < int.parse(numberSelectedForMCQs!); i++) {
            await LocalDatabase().updateMCQsData(mCQsControllers[i].text,
                widget.experimentName, widget.orderNumber, i + 1);
          }
          for (int i = 0;
              i < widget.mCQsData!.length - int.parse(numberSelectedForMCQs!);
              i++) {
            await LocalDatabase().deleteMCQsData(widget.experimentName,
                widget.mCQsData!.length + i, widget.orderNumber);
          }
        }
      } else {
        await LocalDatabase().updateMCQs(
            isHorizontalSlider,
            isVerticalSlider,
            isInputAnswer,
            isNoticeStage,
            widget.experimentName,
            widget.orderNumber);
        for (int i = 0; i < widget.mCQsData!.length; i++) {
          await LocalDatabase()
              .deleteMCQsData(widget.experimentName, i + 1, widget.orderNumber);
        }
        if (isHorizontalSlider) {
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
        } else if (isVerticalSlider) {
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
        }
      }
    } else if (isNoticeStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Multiple Choices') {
      await LocalDatabase().updateMCQs(
          isHorizontalSlider,
          isVerticalSlider,
          isInputAnswer,
          isNoticeStage,
          widget.experimentName,
          widget.orderNumber);
      for (int i = 0; i < widget.mCQsData!.length; i++) {
        await LocalDatabase()
            .deleteMCQsData(widget.experimentName, i + 1, widget.orderNumber);
      }
    } else if (isTimerStage && initialState.answerType == 'Multiple Choices') {
      await LocalDatabase().updateMCQsToTimer(
          timerTitleInput.text,
          widget.experimentName,
          widget.orderNumber,
          int.parse(timerValueInput.text));
      for (int i = 0; i < widget.mCQsData!.length; i++) {
        await LocalDatabase()
            .deleteMCQsData(widget.experimentName, i + 1, widget.orderNumber);
      }
    } else if (isNoticeStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Input Answer') {
      await LocalDatabase().updateInputAnswer(
          false, false, false, true, widget.experimentName, widget.orderNumber);

      await LocalDatabase().updateTitle(
          noticeInput.text, widget.experimentName, widget.orderNumber);
    } else if (isTimerStage && initialState.answerType == 'Input Answer') {
      await LocalDatabase().updateInputAnswerToTimer(
          timerTitleInput.text,
          widget.experimentName,
          widget.orderNumber,
          int.parse(timerValueInput.text));
    } else if (isQuestionStage &&
        initialState.type == 'Question' &&
        initialState.answerType == 'Input Answer') {
      await LocalDatabase().updateTitle(
          questionTitleInput.text, widget.experimentName, widget.orderNumber);
      if (isVisibleForMCQs) {
        await LocalDatabase().updateInputAnswer(false, false, true, false,
            widget.experimentName, widget.orderNumber);

        for (int i = 0; i < mCQsControllers.length; i++) {
          await LocalDatabase().addMultipleChoice(
              widget.experimentName,
              questionTitleInput.text,
              i + 1,
              mCQsControllers[i].text,
              widget.orderNumber);
        }
      } else if (isHorizontalSlider) {
        await LocalDatabase().updateInputAnswer(true, false, false, false,
            widget.experimentName, widget.orderNumber);

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
      } else if (isVerticalSlider) {
        await LocalDatabase().updateInputAnswer(false, true, false, false,
            widget.experimentName, widget.orderNumber);

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
      }
    }
    pressingYesButton();
  }

  @override
  void initState() {
    print(widget.experimentContent.id);
    for (int i = 2; i <= 5; i++) {
      listNumberOfChoices.add(i.toString());
    }
    for (int i = 1; i <= 8; i++) {
      listNumberOfModifiedTitleInVerticalSlider.add(i.toString());
    }
    selectedValue = '${widget.experimentContent.type} Stage';
    if (selectedValue != 'Timer Stage') {
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
    }
    imageBytesInMemory = widget.experimentContent.image;
    initialState = ExperimentContent(
        id: widget.experimentContent.id,
        orderNumber: widget.experimentContent.orderNumber,
        title: widget.experimentContent.title,
        type: widget.experimentContent.type,
        answerType: widget.experimentContent.answerType,
        alertSound: widget.experimentContent.alertSound,
        image: widget.experimentContent.image);
    widget.experimentContent.alertSound == 1
        ? isCheckedAlertSound = true
        : isCheckedAlertSound = false;
    if (selectedValue == 'Notice Stage') {
      noticeInput.text = widget.experimentContent.title;
      isNoticeStage = true;
      isQuestionStage = false;
      isVisible = true;
    } else if (selectedValue == 'Question Stage') {
      questionTitleInput.text = widget.experimentContent.title;
      valueChoosed = widget.experimentContent.answerType;
      isVisible = true;
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
          initializeControllersForSlider(
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
        highAnchorValue.text =
            widget.horizontalSliderData![0].atValue.toString();
        lowAnchorValue.text =
            widget.horizontalSliderData![1].atValue.toString();

        if (widget.horizontalSliderData!.length > 2) {
          isChecked = true;
          numberSelectedForAdditionalSlider =
              '${widget.horizontalSliderData!.length - 2}';
          initializeControllersForSlider(
              int.parse(numberSelectedForAdditionalSlider!));
          for (int i = 0; i < tickSliderControllers.length; i++) {
            tickSliderControllers[i].text =
                widget.horizontalSliderData![i + 2].tickContent;
            valueSliderControllers[i].text =
                '${widget.horizontalSliderData![i + 2].atValue}';
          }
        }
      } else if (valueChoosed == 'Multiple Choices') {
        isVisibleForMCQs = true;
        numberSelectedForMCQs = '${widget.mCQsData!.length}';
        initializeControllersForMCQs(int.parse(numberSelectedForMCQs!));
        for (int i = 0; i < mCQsControllers.length; i++) {
          mCQsControllers[i].text = widget.mCQsData![i].choiceContent;
        }
      } else {
        isInputAnswer = true;
      }
      isQuestionStage = true;
      isNoticeStage = false;
    } else {
      timerTitleInput.text = widget.experimentContent.title;
      timerValueInput.text = widget.experimentContent.timer.toString();
      isQuestionStage = false;
      isNoticeStage = false;
      isTimerStage = true;
      isVisible = false;
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
          title: Text(
            widget.experimentContent.type,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (isQuestionStage) {
                    if (_formKeyForQuestionStage.currentState!.validate()) {
                      if (isVisibleForMCQs) {
                        if (_formKeyForMCQs.currentState!.validate()) {
                          showAddingDialog();
                        }
                      } else if (isHorizontalSlider || isVerticalSlider) {
                        if (_formKeyForSlider.currentState!.validate()) {
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
                                  if (int.parse(
                                              valueSliderControllers[i].text) >=
                                          int.parse(highAnchorValue.text) ||
                                      int.parse(
                                              valueSliderControllers[i].text) <=
                                          int.parse(lowAnchorValue.text)) {
                                    isShowDialogModifyTick = true;
                                    isShowDialogModifyTickEqually = false;
                                    break;
                                  } else {
                                    isShowDialogModifyTick = false;
                                    isShowDialogModifyTickEqually = false;
                                    for (int j = 0; j < i; j++) {
                                      if (int.parse(
                                              valueSliderControllers[i].text) ==
                                          int.parse(
                                              valueSliderControllers[j].text)) {
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
                      } else {
                        showAddingDialog();
                      }
                    }
                  } else if (isTimerStage) {
                    if (_formKeyForTimerStage.currentState!.validate()) {
                      showAddingDialog();
                    }
                  } else {
                    if (_formKeyForNoticeStage.currentState!.validate()) {
                      showAddingDialog();
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField(
                          isExpanded: true,
                          value: selectedValue,
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue = newValue.toString();
                              if (newValue.toString() == 'Notice Stage') {
                                isNoticeStage = true;
                                isQuestionStage = false;
                                isTimerStage = false;
                                isVisible = true;
                                _image = null;
                                isImageChanged = true;
                              } else if (newValue.toString() ==
                                  'Question Stage') {
                                isQuestionStage = true;
                                isNoticeStage = false;
                                isTimerStage = false;
                                isVisible = true;
                              } else {
                                isQuestionStage = false;
                                isNoticeStage = false;
                                isTimerStage = true;
                                isVisible = false;
                                isImageChanged = true;
                                _image = null;
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
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        isTimerStage
                            ? Form(
                                key: _formKeyForTimerStage,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 40,
                                    ),
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
                                      textFieldLabel: 'Time to wait in second',
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
                                      onChanged: true,
                                      textEditingController: noticeInput,
                                      textFieldLabel: 'Instruction',
                                      isLong: true,
                                      onChangedFunction: (newValue) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: _pickImage,
                                        child: Text(
                                            (imageBytesInMemory != null ||
                                                    imageBytesNew != null)
                                                ? 'Change Image'
                                                : 'Pick Image'),
                                      ),
                                      imageBytesInMemory != null ||
                                              _image != null
                                          ? TextButton(
                                              onPressed: _deleteImage,
                                              child: const Text(
                                                  'Delete Chosen Image'),
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
                                      onChanged: true,
                                      onChangedFunction: (newValue) {
                                        setState(() {});
                                      },
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: _pickImage,
                                              child: Text(
                                                  (imageBytesInMemory != null ||
                                                          imageBytesNew != null)
                                                      ? 'Change Image'
                                                      : 'Pick Image'),
                                            ),
                                            imageBytesInMemory != null ||
                                                    _image != null
                                                ? TextButton(
                                                    onPressed: _deleteImage,
                                                    child: const Text(
                                                        'Delete Chosen Image'),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                        imageBytesInMemory != null &&
                                                _image == null
                                            ? Image.memory(imageBytesInMemory!)
                                            : const SizedBox(),
                                        imageBytesInMemory == null &&
                                                _image != null
                                            ? Image.file(_image!)
                                            : const SizedBox(),
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
                                                  isInputAnswer = false;
                                                  isVerticalSlider = false;
                                                  isHorizontalSlider = false;
                                                } else if (newValue
                                                        .toString() ==
                                                    'Vertical Slider') {
                                                  isInputAnswer = false;
                                                  isVerticalSlider = true;
                                                  isVisibleForMCQs = false;
                                                  isHorizontalSlider = false;
                                                } else if (newValue
                                                        .toString() ==
                                                    'Horizontal Slider') {
                                                  isInputAnswer = false;
                                                  isHorizontalSlider = true;
                                                  isVerticalSlider = false;
                                                  isVisibleForMCQs = false;
                                                } else {
                                                  isInputAnswer = true;
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
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black),
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
                                                      if (initialState
                                                              .answerType ==
                                                          'Multiple Choices') {
                                                        if (int.parse(
                                                                numberSelectedForMCQs!) >=
                                                            widget.mCQsData!
                                                                .length) {
                                                          for (int i = 0;
                                                              i <
                                                                  widget
                                                                      .mCQsData!
                                                                      .length;
                                                              i++) {
                                                            mCQsControllers[i]
                                                                    .text =
                                                                widget
                                                                    .mCQsData![
                                                                        i]
                                                                    .choiceContent;
                                                          }
                                                        }
                                                      }
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
                                    const SizedBox(
                                      height: 12.0,
                                    ),
                                    isHorizontalSlider || isVerticalSlider
                                        ? Form(
                                            key: _formKeyForSlider,
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.only(),
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
                                                const SizedBox(
                                                  height: 12.0,
                                                ),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.only(),
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
                                                            numberSelectedForAdditionalSlider,
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            numberSelectedForAdditionalSlider =
                                                                newValue
                                                                    .toString();
                                                            if (initialState
                                                                    .answerType ==
                                                                'Vertical Slider') {
                                                              if (widget
                                                                      .verticalSliderData!
                                                                      .length ==
                                                                  2) {
                                                                initializeControllersForSlider(
                                                                    int.parse(
                                                                        numberSelectedForAdditionalSlider!));
                                                              } else {
                                                                initializeControllersForSlider(
                                                                    int.parse(
                                                                        numberSelectedForAdditionalSlider!));
                                                                if (int.parse(
                                                                        numberSelectedForAdditionalSlider!) >=
                                                                    widget.verticalSliderData!
                                                                            .length -
                                                                        2) {
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          widget.verticalSliderData!.length -
                                                                              2;
                                                                      i++) {
                                                                    if (widget
                                                                        .verticalSliderData![
                                                                            i + 2]
                                                                        .tickContent
                                                                        .isNotEmpty) {
                                                                      tickSliderControllers[i].text = widget
                                                                          .verticalSliderData![i +
                                                                              2]
                                                                          .tickContent;
                                                                      valueSliderControllers[i]
                                                                              .text =
                                                                          '${widget.verticalSliderData![i + 2].atValue}';
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            } else if (initialState
                                                                    .answerType ==
                                                                'Horizontal Slider') {
                                                              if (widget
                                                                      .horizontalSliderData!
                                                                      .length ==
                                                                  2) {
                                                                initializeControllersForSlider(
                                                                    int.parse(
                                                                        numberSelectedForAdditionalSlider!));
                                                              } else {
                                                                initializeControllersForSlider(
                                                                    int.parse(
                                                                        numberSelectedForAdditionalSlider!));
                                                                if (int.parse(
                                                                        numberSelectedForAdditionalSlider!) >=
                                                                    widget.horizontalSliderData!
                                                                            .length -
                                                                        2) {
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          widget.horizontalSliderData!.length -
                                                                              2;
                                                                      i++) {
                                                                    if (widget
                                                                        .horizontalSliderData![
                                                                            i + 2]
                                                                        .tickContent
                                                                        .isNotEmpty) {
                                                                      tickSliderControllers[i].text = widget
                                                                          .horizontalSliderData![i +
                                                                              2]
                                                                          .tickContent;
                                                                      valueSliderControllers[i]
                                                                              .text =
                                                                          '${widget.horizontalSliderData![i + 2].atValue}';
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            } else {
                                                              initializeControllersForSlider(
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
                            ? Container(
                                margin: const EdgeInsets.only(top: 12.0),
                                child: Form(
                                  key: _formKeyForAdditionalSlider,
                                  child: Column(
                                    children: [
                                      for (int i = 0;
                                          i < tickSliderControllers.length;
                                          i++)
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 12.0),
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
                                            onChanged: true,
                                            onChangedFunction: (newValue) {
                                              setState(() {});
                                            },
                                            textFieldLabel: 'Choice ${i + 1}',
                                            textEditingController:
                                                mCQsControllers[i]),
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
                                          isChangedForHelpText = true;
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
                        isVisible
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
                                          isChangedForTextButton = true;
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
                        // isNoticeStage
                        //     ? SizedBox(
                        //         height: MediaQuery.of(context).size.height / 3,
                        //       )
                        //     : const SizedBox(),
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
