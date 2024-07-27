import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thesis_app/components/rounded_button.dart';
import 'package:thesis_app/components/text_field.dart';
import 'package:thesis_app/database/local_database.dart';
import 'package:thesis_app/objects/experiment.dart';
import 'package:thesis_app/screens/experimenter_screen/experiment_screen/experiment_screen.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({super.key});

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  final userIDInput = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late List<Experiment> listExperiments;
  String? selectedValue;
  bool isWrong = false;
  bool isTrue = false;
  Future<void>? future;

  @override
  void initState() {
    super.initState();
    future = _initializeData();
  }

  Future<List> _initializeData() async {
    var res = await LocalDatabase().getAllExperiment();
    listExperiments = res;
    return res;
  }

  runExperiment() {
    if (_formKey.currentState!.validate()) {
      moveToNextScreen();
    }
  }

  void moveToNextScreen() {
    bool isOwnExperiment = listExperiments.any((experiment) =>
        experiment.experimentName == selectedValue &&
        experiment.experimenter == userIDInput.text);

    if (isOwnExperiment) {
      _showErrorDialog("You can not participate in your own experiment.");
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ExperimentScreen(
                  experimentName: selectedValue!,
                  userId: userIDInput.text,
                  isParticipant: true)));
    }
  }

  void _showErrorDialog(String errorMessage) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "ERROR",
      desc: errorMessage,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
          // Build the widget tree using the snapshot.data
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.only(top: 28.0),
                            child: const Text(
                              'Welcome! Glad to see you, enjoy the experiment!',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 38.0,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Urbanist'),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 38.0,
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                textFieldLabel: 'UserID',
                                textEditingController: userIDInput,
                                onChanged: true,
                                onChangedFunction: (value) {
                                  setState(() {
                                    userIDInput.text = value;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownMenu(
                                expandedInsets:
                                    const EdgeInsets.fromLTRB(0.0, 0, 0.0, 0),
                                enableFilter: false,
                                enabled:
                                    listExperiments.isNotEmpty ? true : false,
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                requestFocusOnTap: true,
                                label: const Text(
                                  'Experiment',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Urbanist'),
                                ),
                                onSelected: (Experiment? value) {
                                  setState(() {
                                    if (value != null) {
                                      selectedValue = value.experimentName;
                                    }
                                  });
                                },
                                hintText: 'Select an experiment',
                                dropdownMenuEntries: listExperiments
                                    .map<DropdownMenuEntry<Experiment>>(
                                        (Experiment value) {
                                  return DropdownMenuEntry<Experiment>(
                                    value: value,
                                    label: value.experimentName,
                                    // style: MenuItemButton.styleFrom(
                                    //   foregroundColor: color.color,
                                    // ),
                                  );
                                }).toList(),
                              ),
                              // DropdownButtonFormField(
                              //   menuMaxHeight:
                              //       MediaQuery.of(context).size.height / 3,
                              //   autovalidateMode:
                              //       AutovalidateMode.onUserInteraction,
                              //   focusNode: FocusNode(canRequestFocus: false),
                              //   decoration: const InputDecoration(
                              //     enabledBorder: OutlineInputBorder(
                              //       borderSide: BorderSide(
                              //         color: Colors.grey,
                              //         width: 1.0,
                              //       ),
                              //     ),
                              //     focusedBorder: OutlineInputBorder(
                              //       borderSide: BorderSide(
                              //         color: Colors.black,
                              //         width: 2.0,
                              //       ),
                              //     ),
                              //     border: OutlineInputBorder(
                              //       borderSide: BorderSide(
                              //         color: Colors.black,
                              //         width: 2.0,
                              //       ),
                              //     ),
                              //   ),
                              //   isExpanded: true,
                              //   value: selectedValue,
                              //   hint: const Text(
                              //     'Select an experiment',
                              //     style: TextStyle(
                              //         color: Colors.black,
                              //         fontSize: 18.0,
                              //         fontWeight: FontWeight.w500,
                              //         fontFamily: 'Urbanist'),
                              //   ),
                              //   items: listExperiments
                              //       .map(
                              //         (e) => DropdownMenuItem(
                              //           value: e.experimentName,
                              //           child: Row(
                              //             children: [
                              //               Expanded(
                              //                 child: RichText(
                              //                   text: TextSpan(
                              //                     children: [
                              //                       TextSpan(
                              //                         text: e.experimentName,
                              //                         style: const TextStyle(
                              //                           fontFamily: 'Urbanist',
                              //                           color: Colors.black,
                              //                           fontSize: 16.0,
                              //                           fontWeight:
                              //                               FontWeight.w600,
                              //                         ),
                              //                       ),
                              //                     ],
                              //                   ),
                              //                 ),
                              //               ),
                              //               Expanded(
                              //                 child: Center(
                              //                   child: RichText(
                              //                     text: const TextSpan(
                              //                       children: [
                              //                         TextSpan(
                              //                           text: 'by',
                              //                           style: TextStyle(
                              //                             fontFamily:
                              //                                 'Urbanist',
                              //                             color: Colors.black,
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //               Expanded(
                              //                 child: Align(
                              //                   alignment:
                              //                       Alignment.centerRight,
                              //                   child: RichText(
                              //                     text: TextSpan(
                              //                       children: [
                              //                         TextSpan(
                              //                           text: e.experimenter,
                              //                           style: const TextStyle(
                              //                             fontFamily:
                              //                                 'Urbanist',
                              //                             color: Colors.black,
                              //                             fontSize: 16.0,
                              //                             fontWeight:
                              //                                 FontWeight.w600,
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       )
                              //       .toList(),
                              //   onChanged: (newValue) {
                              //     setState(() {
                              //       selectedValue = newValue;
                              //       FocusScope.of(context).unfocus();
                              //     });
                              //   },
                              //   validator: (value) {
                              //     if (value == null || value.isEmpty) {
                              //       return 'Please select an option';
                              //     }
                              //     return null; // Validation passed
                              //   },
                              // ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RawMaterialButton(
                            onPressed: (listExperiments.isEmpty ||
                                    selectedValue == null ||
                                    userIDInput.text.isEmpty)
                                ? null
                                : runExperiment,
                            fillColor: (listExperiments.isEmpty ||
                                    selectedValue == null ||
                                    userIDInput.text.isEmpty)
                                ? Colors.grey.shade200
                                : Colors.black,
                            elevation: (listExperiments.isEmpty ||
                                    selectedValue == null ||
                                    userIDInput.text.isEmpty)
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
                                      'Start',
                                      style: TextStyle(
                                          color: (listExperiments.isEmpty ||
                                                  selectedValue == null ||
                                                  userIDInput.text.isEmpty)
                                              ? Colors.grey
                                              : Colors.white,
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Urbanist'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // RoundedButton(
                        //   isBlack: true,
                        //   buttonLabel: 'Start',
                        //   onPressed: () async {
                        //     if (_formKey.currentState!.validate()) {
                        //       moveToNextScreen();
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
