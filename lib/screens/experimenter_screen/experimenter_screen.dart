import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis_app/components/squared_button.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/count_of_result.dart';
import 'package:thesis_app/objects/result.dart';
import 'package:thesis_app/screens/experimenter_screen/create_screen/create_expname_screen.dart';
import 'package:thesis_app/screens/experimenter_screen/edit_screen/edit_expname_screen.dart';
import 'package:thesis_app/screens/experimenter_screen/experiment_screen/experiment_screen.dart';
import 'package:thesis_app/screens/experimenter_screen/show_result_screen.dart';

class ExperimenterScreen extends StatefulWidget {
  const ExperimenterScreen({super.key, required this.userID});
  final String userID;

  @override
  State<ExperimenterScreen> createState() => _ExperimenterScreenState();
}

class _ExperimenterScreenState extends State<ExperimenterScreen> {
  List<CountOfResult> listOfResult = [];
  String? valueChoosed;
  Future<List>? future;
  int count = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    future = _initializeData(widget.userID);
    super.initState();
  }

  void backToPreviousScreen() {
    Navigator.pop(context);
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateExperimentNameScreen(
                  userID: widget.userID,
                )));
    inspect(result);
    if (result == true) {
      var res = await LocalDatabase().getExperimentWithUserID(widget.userID);
      setState(() {
        listOfResult = res;
      });
    }
  }

  void editButton() {
    _navigateAndEdit(context);
  }

  void deleteButton() async {
    // await LocalDatabase().asd1();
    await LocalDatabase().deleteChosenExperiment(valueChoosed!);
    await _initializeData(widget.userID);
    // Clear the selected value
    setState(() {
      valueChoosed = null;
      _searchController.text = '';
    });
  }

  void runExperiment() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ExperimentScreen(
                  experimentName: valueChoosed!,
                  userId: widget.userID,
                  isParticipant: false,
                )));
    setState(() {
      valueChoosed = null;
      _searchController.text = '';
    });
  }

  void showResult() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowResultScreen(
                  experimentName: valueChoosed!,
                )));
    setState(() {
      valueChoosed = null;
      _searchController.text = '';
    });
  }

  Future<void> _navigateAndEdit(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditExperimentNameScreen(
                experimentName: valueChoosed!, userId: widget.userID)));
    setState(() {
      valueChoosed = null;
      _searchController.text = '';
    });
    var res = await LocalDatabase().getExperimentWithUserID(widget.userID);
    setState(() {
      listOfResult = res;
      valueChoosed = null;
    });
  }

  Future<List<CountOfResult>> _initializeData(String userID) async {
    final result =
        await LocalDatabase().getExperimentNameAndCountWithUserID(userID);
    setState(() {
      listOfResult = result;
    });
    return listOfResult;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                // inspect(prefs);
                backToPreviousScreen();
              },
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SafeArea(
            child: FutureBuilder(
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
                          Text(snapshot.error.toString()),
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
                                borderRadius: BorderRadius.circular(
                                    30.0), // Rounded corners
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: DropdownMenu(
                            controller: _searchController,
                            enableSearch: false,
                            enableFilter: true,
                            expandedInsets:
                                const EdgeInsets.fromLTRB(8.0, 0, 12.0, 0),
                            enabled: listOfResult.isNotEmpty ? true : false,
                            // requestFocusOnTap is enabled/disabled by platforms when it is null.
                            // On mobile platforms, this is false by default. Setting this to true will
                            // trigger focus request on the text field and virtual keyboard will appear
                            // afterward. On desktop platforms however, this defaults to true.
                            requestFocusOnTap: true,
                            label: const Text(
                              'Experiment',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700),
                            ),
                            onSelected: (CountOfResult? value) {
                              setState(() {
                                if (value != null) {
                                  valueChoosed = value.experimentName;
                                  count = value.count;
                                }
                              });
                            },
                            hintText: 'Select an experiment',
                            dropdownMenuEntries: listOfResult
                                .map<DropdownMenuEntry<CountOfResult>>(
                                    (CountOfResult value) {
                              return DropdownMenuEntry<CountOfResult>(
                                value: value,
                                label:
                                    'Name: ${value.experimentName}\nnumber of results: ${value.count}',
                                style: MenuItemButton.styleFrom(),
                              );
                            }).toList(),
                          ),
                        ),
                        // Expanded(
                        //   child: DropdownButtonFormField<String>(
                        //     focusNode: FocusNode(canRequestFocus: false),
                        //     decoration: const InputDecoration(
                        //       enabledBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color: Colors.grey,
                        //           width: 1.0,
                        //         ),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color: Colors.black,
                        //           width: 2.0,
                        //         ),
                        //       ),
                        //       border: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color: Colors.black,
                        //           width: 2.0,
                        //         ),
                        //       ),
                        //     ),
                        //     isExpanded: true,
                        //     hint: listOfResult.isNotEmpty
                        //         ? const Text(
                        //             'Select an experiment',
                        //             style: TextStyle(
                        //                 fontFamily: 'Urbanist',
                        //                 fontSize: 18.0,
                        //                 fontWeight: FontWeight.w700),
                        //           )
                        //         : const Text(
                        //             'There is no experiment here.',
                        //             style: TextStyle(
                        //                 fontFamily: 'Urbanist',
                        //                 fontSize: 18.0,
                        //                 fontWeight: FontWeight.w700),
                        //           ),
                        //     value: valueChoosed,
                        //     onChanged: (newValue) {
                        //       setState(() {
                        //         valueChoosed = newValue;
                        //         for (CountOfResult counts in listOfResult) {
                        //           if (valueChoosed == counts.experimentName) {
                        //             count = counts.count;
                        //           }
                        //         }
                        //         FocusScope.of(context).unfocus();
                        //       });
                        //     },
                        //     items: listOfResult
                        //         .map(
                        //           (e) => DropdownMenuItem(
                        //             value: e.experimentName,
                        //             child: Row(
                        //               children: [
                        //                 Expanded(
                        //                   flex: 3,
                        //                   child: RichText(
                        //                     text: TextSpan(
                        //                       children: [
                        //                         TextSpan(
                        //                           text: e.experimentName,
                        //                           style: const TextStyle(
                        //                             fontFamily: 'Urbanist',
                        //                             color: Colors.black,
                        //                             fontSize: 16.0,
                        //                             fontWeight: FontWeight.w600,
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   child: Center(
                        //                     child: RichText(
                        //                       text: const TextSpan(
                        //                         children: [
                        //                           TextSpan(
                        //                             text: 'num. of results:',
                        //                             style: TextStyle(
                        //                               fontFamily: 'Urbanist',
                        //                               color: Colors.black,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 3,
                        //                   child: Align(
                        //                     alignment: Alignment.centerRight,
                        //                     child: RichText(
                        //                       text: TextSpan(
                        //                         children: [
                        //                           TextSpan(
                        //                             text: e.count.toString(),
                        //                             style: const TextStyle(
                        //                               fontFamily: 'Urbanist',
                        //                               color: Colors.black,
                        //                               fontSize: 16.0,
                        //                               fontWeight:
                        //                                   FontWeight.w600,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         )
                        //         .toList(),
                        //   ),
                        // ),
                        Expanded(
                          child: IconButton(
                              onPressed: () async {
                                var res = await LocalDatabase()
                                    .getExperimentNameAndCountWithUserID(
                                        widget.userID);
                                setState(() {
                                  listOfResult = res;
                                });
                              },
                              icon: const Icon(Icons.refresh)),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 5,
                      child: Image.asset(
                        'assets/images/IU_logo.png',
                        opacity: const AlwaysStoppedAnimation(.85),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SquaredButton(
                            buttonLabel: 'Create\nExperiment',
                            buttonIcon: const Icon(Icons.post_add, size: 80.0),
                            onPressed: () {
                              _navigateAndDisplaySelection(context);
                            },
                            fillColor: Colors.white,
                            borderColor: Colors.black,
                            elevation: 6.0,
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          SquaredButton(
                            buttonLabel: 'Edit\nExperiment',
                            buttonIcon: Icon(
                              Icons.edit_document,
                              size: 80.0,
                              color:
                                  (listOfResult.isEmpty || valueChoosed == null)
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                            onPressed:
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? null
                                    : editButton,
                            fillColor:
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? Colors.grey.shade200
                                    : Colors.white,
                            borderColor:
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? Colors.grey.shade200
                                    : Colors.black,
                            elevation:
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? 0.0
                                    : 6.0,
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          SquaredButton(
                            buttonLabel: 'Delete\nExperiment',
                            buttonIcon: Icon(
                              Icons.delete,
                              size: 80.0,
                              color:
                                  (listOfResult.isEmpty || valueChoosed == null)
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                            onPressed:
                                // await LocalDatabase().asd();
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? null
                                    : deleteButton,
                            fillColor:
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? Colors.grey.shade200
                                    : Colors.white,
                            borderColor:
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? Colors.grey.shade200
                                    : Colors.black,
                            elevation:
                                (listOfResult.isEmpty || valueChoosed == null)
                                    ? 0.0
                                    : 6.0,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: RawMaterialButton(
                              onPressed:
                                  (listOfResult.isEmpty || valueChoosed == null)
                                      ? null
                                      : runExperiment,
                              fillColor:
                                  (listOfResult.isEmpty || valueChoosed == null)
                                      ? Colors.grey.shade200
                                      : Colors.black,
                              elevation:
                                  (listOfResult.isEmpty || valueChoosed == null)
                                      ? 0.0
                                      : 6.0,
                              // padding: const EdgeInsets.all(10.5), // Set padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(38.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Run Experiment',
                                        style: TextStyle(
                                            color: (listOfResult.isEmpty ||
                                                    valueChoosed == null)
                                                ? Colors.grey
                                                : Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Urbanist'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Expanded(
                            child: RawMaterialButton(
                              onPressed: ((listOfResult.isEmpty ||
                                          valueChoosed == null) ||
                                      count == 0)
                                  ? null
                                  : showResult,
                              fillColor: ((listOfResult.isEmpty ||
                                          valueChoosed == null) ||
                                      count == 0)
                                  ? Colors.grey.shade200
                                  : Colors.black,
                              elevation: ((listOfResult.isEmpty ||
                                          valueChoosed == null) ||
                                      count == 0)
                                  ? 0.0
                                  : 6.0,
                              // padding: const EdgeInsets.all(10.5), // Set padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(38.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Show Result',
                                        style: TextStyle(
                                            color: ((listOfResult.isEmpty ||
                                                        valueChoosed == null) ||
                                                    count == 0)
                                                ? Colors.grey
                                                : Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Urbanist'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
