import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/experiment_content.dart';
import 'package:thesis_app/objects/slider_data.dart';
import 'package:thesis_app/screens/experimenter_screen/edit_screen/adding_rating_screen.dart';

import 'package:thesis_app/screens/experimenter_screen/edit_screen/rating_detail_screen.dart';

class EditRatingScreen extends StatefulWidget {
  const EditRatingScreen(
      {super.key, required this.experimentName, required this.orderNumber});

  final String experimentName;
  final int orderNumber;

  @override
  State<EditRatingScreen> createState() => _EditRatingScreenState();
}

class _EditRatingScreenState extends State<EditRatingScreen> {
  late List<ExperimentContent>? experimentContents;
  late List<SliderData>? verticalSliderData;
  late List<SliderData>? horizontalSliderData;

  Future<void>? future;

  @override
  void initState() {
    super.initState();
    future = fetchData();
  }

  pressingYesButton() {
    Navigator.pop(context);
  }

  deleteFunction(ExperimentContent item, int index) async {
    if (item.answerType == 'Vertical Slider') {
      await LocalDatabase().deleteRatingQuestion(item.id, true);
    } else if (item.answerType == 'Horizontal Slider') {
      await LocalDatabase().deleteRatingQuestion(item.id, false);
    }
    await LocalDatabase().deleteChoosenQuestionInResult(item.id);
    experimentContents!.removeAt(index);
    setState(() {
      if (index < experimentContents!.length) {
        for (int i = 1; i <= experimentContents!.length; i++) {
          experimentContents![i - 1].orderNumber = i;
        }
      }
    });
    pressingYesButton();
  }

  Future<void> _navigateToAddRatingContainer(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddingRatingScreen(
                  experimentName: widget.experimentName,
                  orderNumber: widget.orderNumber,
                  ratingId: experimentContents!.first.ratingId!,
                )));
    if (result == true) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    final data1 = await LocalDatabase()
        .getRatingForEditing(widget.experimentName, widget.orderNumber);

    final data2 =
        await LocalDatabase().getSliderData(widget.experimentName, true);
    final data3 =
        await LocalDatabase().getSliderData(widget.experimentName, false);
    setState(() {
      experimentContents = data1;
      verticalSliderData = data2;
      horizontalSliderData = data3;
    });
  }

  Future<void> _navigateToEdit(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RatingDetailScreen(
                experimentContent: experimentContents![index],
                experimentName: widget.experimentName,
                horizontalSliderData: [
                  if (experimentContents![index].answerType ==
                      'Horizontal Slider')
                    for (int i = 0; i < horizontalSliderData!.length; i++)
                      if (horizontalSliderData![i].questionId ==
                          experimentContents![index].id)
                        horizontalSliderData![i]
                ],
                verticalSliderData: [
                  if (experimentContents![index].answerType ==
                      'Vertical Slider')
                    for (int i = 0; i < verticalSliderData!.length; i++)
                      if (verticalSliderData![i].questionId ==
                          experimentContents![index].id)
                        verticalSliderData![i]
                ],
                ratingItems: experimentContents!.length,
              )),
    );
    if (result == true) {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color? oddItemColor = Colors.grey[400];
    const Color evenItemColor = Colors.white;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Rating'),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToAddRatingContainer(context);
              },
              icon: const Icon(Icons.add))
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
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    itemCount: experimentContents!.length,
                    // itemBuilder: (context, index) {
                    //   return ListTile(
                    //     title: Text(experimentContents![index].answerType!),
                    //     onTap: () {
                    //       _navigateToEdit(context, index);
                    //     },
                    //   );
                    // },
                    itemBuilder: (context, index) {
                      final item = experimentContents![index];
                      return Dismissible(
                        key: Key('$index'),
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
                                      child: const Text('Yes'),
                                      onPressed: () {
                                        deleteFunction(item, index);
                                        if (experimentContents!.isEmpty) {
                                          Navigator.pop(context, true);
                                        }
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: const Text('No'),
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
                                    CupertinoDialogAction(
                                      child: const Text('Yes'),
                                      onPressed: () {
                                        deleteFunction(item, index);
                                      },
                                    ),
                                    CupertinoDialogAction(
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
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.redAccent,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                            onTap: () {
                              _navigateToEdit(context, index);
                            },
                            key: Key('$index'),
                            tileColor:
                                (index % 2 != 0) ? oddItemColor : evenItemColor,
                            title: Text(
                              experimentContents![index].answerType!,
                              style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
