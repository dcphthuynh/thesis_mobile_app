import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/order_number.dart';
import 'package:thesis_app/objects/result.dart';

class ShowResultScreen extends StatefulWidget {
  final String experimentName;
  const ShowResultScreen({super.key, required this.experimentName});

  @override
  State<ShowResultScreen> createState() => _ShowResultScreenState();
}

class _ShowResultScreenState extends State<ShowResultScreen> {
  List<Result> listOfResult = [];
  List<Result> listOfGroupedResult = [];
  List<Result>? listOfRatingResult = [];
  List<Result>? listOfRatingGroupedResult = [];
  List<ListOfOrderNumber> listOfOrderNumber = [];
  Future<void>? future;

  @override
  void initState() {
    future = initializeData();
    super.initState();
  }

  Future<void> initializeData() async {
    final result =
        await LocalDatabase().getResultOfExperiment(widget.experimentName);
    final resultGrouped = await LocalDatabase()
        .getResultOfExperimentGrouped(widget.experimentName);
    final rating = await LocalDatabase()
        .getRatingResultOfExperiment(widget.experimentName);
    final ratingGrouped = await LocalDatabase()
        .getRatingResultOfExperimentGrouped(widget.experimentName);
    final orderNumber =
        await LocalDatabase().getOrderNumberInResult(widget.experimentName);
    setState(() {
      listOfResult = result;
      listOfGroupedResult = resultGrouped;
      listOfOrderNumber = orderNumber;
      if (rating != null) {
        listOfRatingResult = rating;
      }
      if (ratingGrouped != null) {
        listOfRatingGroupedResult = ratingGrouped;
      }
    });
    inspect(listOfResult);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Expanded(
          child: Text(
            '${widget.experimentName}\'s Result',
            style: const TextStyle(
                fontFamily: 'Urbanist', fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Container(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Error: ${snapshot.error}"),
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
                      'Something went wrong. Please contact the experimenter.',
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
          }
          return Container(
            margin: const EdgeInsets.all(16.0),
            child: SafeArea(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < listOfOrderNumber.length; i++)
                    Card(
                      child: ExpansionTile(
                        subtitle:
                            listOfGroupedResult[i].questionType == 'Question'
                                ? Text(listOfGroupedResult[i].questionTitle)
                                : null,
                        title: listOfGroupedResult[i].questionType == 'Question'
                            ? Text(
                                'Question ${listOfOrderNumber[i].orderNumber}')
                            : Text(
                                'Rating Container ${listOfOrderNumber[i].orderNumber}'),
                        children: [
                          for (int a = 0; a < listOfGroupedResult.length; a++)
                            if (listOfGroupedResult[a].orderNumber ==
                                listOfOrderNumber[i].orderNumber)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: (listOfGroupedResult[a].questionType ==
                                        'Question')
                                    ? DataTable(
                                        columnSpacing: 120,
                                        columns: const [
                                          DataColumn(
                                            label: Text('Participant ID'),
                                          ),
                                          DataColumn(
                                            label: Text('Answer Content'),
                                          ),
                                        ],
                                        rows: [
                                          for (int j = 0;
                                              j < listOfResult.length;
                                              j++)
                                            if (listOfResult[j].orderNumber ==
                                                listOfOrderNumber[i]
                                                    .orderNumber)
                                              DataRow(
                                                cells: [
                                                  DataCell(Text(listOfResult[j]
                                                      .participantId)),
                                                  DataCell(Text(listOfResult[j]
                                                      .answerContent)),
                                                ],
                                              ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ),
                          if (listOfRatingGroupedResult != null &&
                              listOfRatingResult != null)
                            for (int a = 0;
                                a < listOfRatingGroupedResult!.length;
                                a++)
                              if (listOfRatingGroupedResult![a].orderNumber ==
                                  listOfOrderNumber[i].orderNumber)
                                ExpansionTile(
                                  title: Text(
                                      'Question ${a + 1} in Rating Container ${listOfOrderNumber[i].orderNumber}'),
                                  subtitle: Text(listOfRatingGroupedResult![a]
                                      .questionTitle),
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: (listOfRatingGroupedResult![a]
                                                  .questionType ==
                                              'Rating')
                                          ? DataTable(
                                              columnSpacing: 120,
                                              columns: const [
                                                DataColumn(
                                                  label: Text('Participant ID'),
                                                ),
                                                DataColumn(
                                                  label: Text('Answer Content'),
                                                ),
                                              ],
                                              rows: [
                                                for (int j = 0;
                                                    j <
                                                        listOfRatingResult!
                                                            .length;
                                                    j++)
                                                  if (listOfRatingResult![j]
                                                          .questionId ==
                                                      listOfRatingGroupedResult![
                                                              a]
                                                          .questionId)
                                                    DataRow(
                                                      cells: [
                                                        DataCell(Text(
                                                            listOfRatingResult![
                                                                    j]
                                                                .participantId)),
                                                        DataCell(Text(
                                                            listOfRatingResult![
                                                                    j]
                                                                .answerContent)),
                                                      ],
                                                    ),
                                              ],
                                            )
                                          : const SizedBox(),
                                    ),
                                  ],
                                )
                        ],
                      ),
                    ),
                ],
              ),
            )),
          );
        },
      ),
    );
  }
}
