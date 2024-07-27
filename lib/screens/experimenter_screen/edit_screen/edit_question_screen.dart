import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/styles.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/experiment_content.dart';
import 'package:thesis_app/objects/multiple_choice.dart';
import 'package:thesis_app/objects/slider_data.dart';
import 'package:thesis_app/screens/experimenter_screen/edit_screen/adding_rating_screen.dart';
import 'package:thesis_app/screens/experimenter_screen/edit_screen/adding_screen.dart';
import 'package:thesis_app/screens/experimenter_screen/edit_screen/detail_screen.dart';
import 'package:thesis_app/screens/experimenter_screen/edit_screen/edit_rating_screen.dart';

class EditQuestionScreen extends StatefulWidget {
  const EditQuestionScreen({
    super.key,
    required this.experimentName,
  });

  final String experimentName;

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  late List<ExperimentContent>? experimentContents;
  late List<ExperimentContent>? ratingList;
  late List<SliderData>? verticalSliderData;
  late List<SliderData>? horizontalSliderData;
  late List<MultipleChoice>? mCQsData;
  List<ExperimentContent> oldExperimentContents = [];
  List<int> ratingIdNumbers = [];
  bool _isLoading = false;

  Future<void>? future;

  @override
  void initState() {
    super.initState();
    future = fetchData();
  }

  pressingYesButton() {
    Navigator.pop(context);
  }

  Future<void> fetchData() async {
    // await LocalDatabase().asd();
    final data1 =
        await LocalDatabase().getQuestionsForEditing(widget.experimentName);
    final data2 =
        await LocalDatabase().getSliderData(widget.experimentName, true);
    final data3 =
        await LocalDatabase().getSliderData(widget.experimentName, false);
    final data4 =
        await LocalDatabase().getMultipleChoice(widget.experimentName);
    final data5 =
        await LocalDatabase().getRatingForEditing1(widget.experimentName);
    setState(() {
      experimentContents = data1;
      verticalSliderData = data2;
      horizontalSliderData = data3;
      mCQsData = data4;
      ratingList = data5;
    });

    for (int i = 0; i < experimentContents!.length; i++) {
      if (experimentContents![i].type == 'Rating') {
        ratingIdNumbers.add(experimentContents![i].ratingId!);
      }
    }
    if (ratingIdNumbers.isNotEmpty) {
      ratingIdNumbers.sort();
    } else {
      ratingIdNumbers.add(0);
    }
  }

  updateOrder() async {
    for (int i = 1; i <= experimentContents!.length; i++) {
      if (experimentContents![i - 1].type == 'Timer' ||
          experimentContents![i - 1].type == 'Notice' ||
          experimentContents![i - 1].type == 'Question') {
        await LocalDatabase().updateOrderOfExperiment(
            experimentContents![i - 1].orderNumber,
            experimentContents![i - 1].id);
      }
      if (experimentContents![i - 1].type == 'Rating') {
        await LocalDatabase().updateRatingOrderOfExperiment(
          experimentContents![i - 1].orderNumber,
          widget.experimentName,
          experimentContents![i - 1].ratingId!,
        );
      }
    }

    fetchData();
  }

  deleteFunction(int index) {
    pressingYesButton();
    deleteInDatabase(experimentContents![index]);
    print(experimentContents!.length);
    experimentContents!.removeAt(index);
    print(experimentContents!.length);
    print(index);
    if (index < experimentContents!.length) {
      for (int i = 1; i <= experimentContents!.length; i++) {
        setState(() {
          experimentContents![i - 1].orderNumber = i;
        });
      }
    }
    updateOrder();
    // fetchData();
  }

  deleteInDatabase(ExperimentContent item) async {
    if (item.type == 'Question') {
      if (item.answerType == 'Vertical Slider') {
        await LocalDatabase().deleteChoosenQuestion(
            widget.experimentName, item.id, true, false, false);
      } else if (item.answerType == 'Horizontal Slider') {
        await LocalDatabase().deleteChoosenQuestion(
            widget.experimentName, item.id, false, true, false);
      } else if (item.answerType == 'Multiple Choices') {
        await LocalDatabase().deleteChoosenQuestion(
            widget.experimentName, item.id, false, false, true);
      } else if (item.answerType == 'Input Answer') {
        await LocalDatabase().deleteChoosenQuestion(
            widget.experimentName, item.id, false, false, false);
      }
      await LocalDatabase().deleteChoosenQuestionInResult(item.id);
    } else if (item.type == 'Notice') {
      await LocalDatabase().deleteChoosenNotice(widget.experimentName, item.id);
    } else if (item.type == 'Timer') {
      await LocalDatabase().deleteChoosenTimer(widget.experimentName, item.id);
    } else {
      for (int i = 0; i < ratingList!.length; i++) {
        if (ratingList![i].orderNumber == item.orderNumber) {
          await LocalDatabase().deleteRatingContainer(ratingList![i].id);
          await LocalDatabase().deleteSliderDataInRatingEdit(
              ratingList![i].id, ratingList![i].answerType!);
          await LocalDatabase().deleteChoosenQuestionInResult(item.id);
        }
      }
    }
  }

  Future<void> _navigateAddingQuestion(BuildContext context) async {
    Navigator.pop(context);
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddingQuestionScreen(
                  experimentName: widget.experimentName,
                  orderNumber: experimentContents!.length + 1,
                )));
    if (result == true) {
      fetchData();
    }
  }

  Future<void> _navigateAddingRating(BuildContext context) async {
    Navigator.pop(context);
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddingRatingScreen(
                  experimentName: widget.experimentName,
                  orderNumber: experimentContents!.length + 1,
                  ratingId: ratingIdNumbers.last + 1,
                )));
    if (result == true) {
      fetchData();
    }
  }

  Future<void> _navigateToEdit(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          experimentContent: experimentContents![index],
          verticalSliderData: [
            if (verticalSliderData != null)
              for (int i = 0; i < verticalSliderData!.length; i++)
                if (verticalSliderData![i].orderNumber == index + 1)
                  verticalSliderData![i]
          ],
          horizontalSliderData: [
            if (horizontalSliderData != null)
              for (int i = 0; i < horizontalSliderData!.length; i++)
                if (horizontalSliderData![i].orderNumber == index + 1)
                  horizontalSliderData![i]
          ],
          mCQsData: [
            if (mCQsData != null)
              for (int i = 0; i < mCQsData!.length; i++)
                if (mCQsData![i].orderNumber == index + 1) mCQsData![i]
          ],
          experimentName: widget.experimentName,
          orderNumber: index + 1,
        ),
      ),
    );
    if (result == true) {
      fetchData();
    }
  }

  Future<void> _navigateToEditRatingContainer(
      BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditRatingScreen(
              experimentName: widget.experimentName, orderNumber: index + 1)),
    );
    if (result == true) {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final Color? oddItemColor = Colors.grey[400];
    const Color evenItemColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Experiment',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
            )),
        actions: [
          IconButton(
              onPressed: () {
                if (experimentContents!.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      if (Theme.of(context).platform == TargetPlatform.iOS) {
                        return CupertinoAlertDialog(
                          title: const Text('Add new?'),
                          content: const Text('Do you want to add new?'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(
                                'Add Notice/Question/Timer Stage',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[600],
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {
                                _navigateAddingQuestion(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                'Add Rating Container',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[600],
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {
                                _navigateAddingRating(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      } else {
                        return AlertDialog(
                          title: const Text('Add new?'),
                          content: const Text(
                            'Do you want to add new?',
                            style: TextStyle(fontSize: 18),
                          ),
                          actions: [
                            DialogButton(
                              child: const Text(
                                'Add Notice/Question/Timer Stage',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              onPressed: () {
                                _navigateAddingQuestion(context);
                              },
                            ),
                            DialogButton(
                              child: const Text(
                                'Add Rating Container',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              onPressed: () {
                                _navigateAddingRating(context);
                              },
                            ),
                            DialogButton(
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
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
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    if (experimentContents == null) {
                      return const Center(child: Text("No data"));
                    }
                    return ReorderableListView(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      children: <Widget>[
                        for (int index = 0;
                            index < experimentContents!.length;
                            index += 1)
                          Dismissible(
                            direction: DismissDirection.endToStart,
                            key: Key('$index'),
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors
                                    .red[600], // Rounded corners (optional)
                              ),
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              // Show a confirmation dialog
                              final result = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  if (Theme.of(context).platform ==
                                      TargetPlatform.iOS) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                          'Are you sure you want to dismiss this item?'),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text(
                                            'Yes',
                                            style: TextStyles.dialogTextStyle,
                                          ),
                                          onPressed: () {
                                            deleteFunction(index);
                                            if (experimentContents!.isEmpty) {
                                              Navigator.pop(context, true);
                                            }
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
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                          'Are you sure you want to dismiss this item?'),
                                      actions: [
                                        DialogButton(
                                          child: const Text('Yes'),
                                          onPressed: () {
                                            deleteFunction(index);
                                            if (experimentContents!.isEmpty) {
                                              Navigator.pop(context, true);
                                            }
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
                              // Return true if the user confirmed the dismissal, false otherwise
                              return result;
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black,
                                    width: 2.0), // Border color and width
                                borderRadius: BorderRadius.circular(
                                    8.0), // Rounded corners (optional)
                              ),
                              child: ListTile(
                                trailing: const Icon(Icons.list),
                                iconColor:
                                    (experimentContents![index].orderNumber %
                                                2 !=
                                            0)
                                        ? Colors.grey[600]
                                        : Colors.grey,
                                onTap: () {
                                  if (experimentContents![index].type ==
                                          'Notice' ||
                                      experimentContents![index].type ==
                                          'Question' ||
                                      experimentContents![index].type ==
                                          'Timer') {
                                    _navigateToEdit(context, index);
                                  } else {
                                    _navigateToEditRatingContainer(
                                        context, index);
                                  }
                                },
                                key: Key('$index'),
                                tileColor:
                                    (experimentContents![index].orderNumber %
                                                2 !=
                                            0)
                                        ? oddItemColor
                                        : evenItemColor,
                                title: Text(
                                  experimentContents![index].type == 'Notice' ||
                                          experimentContents![index].type ==
                                              'Timer'
                                      ? '${experimentContents![index].type} Stage'
                                      : experimentContents![index].type ==
                                              'Rating'
                                          ? '${experimentContents![index].type} Container'
                                          : '${experimentContents![index].type} Stage (${experimentContents![index].answerType ?? ''})',
                                  style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.0,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = experimentContents!.removeAt(oldIndex);
                        experimentContents!.insert(newIndex, item);
                        for (int i = 1; i <= experimentContents!.length; i++) {
                          setState(() {
                            experimentContents![i - 1].orderNumber = i;
                          });
                        }

                        updateOrder();
                      },
                    );
                  }),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     RoundedButton(
            //         buttonLabel: 'Save changes',
            //         onPressed: () {
            //           Navigator.pop(context);
            //           Navigator.pop(context, true);
            //         })
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
