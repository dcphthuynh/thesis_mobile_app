import 'dart:async';
import 'dart:developer';
import 'package:encrypt/encrypt.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:thesis_app/objects/answer.dart';
import 'package:thesis_app/objects/count_of_result.dart';
import 'package:thesis_app/objects/experiment.dart';
import 'package:thesis_app/objects/multiple_choice.dart';
import 'package:thesis_app/objects/experiment_content.dart';
import 'package:thesis_app/objects/order_number.dart';
import 'package:thesis_app/objects/question_id.dart';
import 'package:thesis_app/objects/result.dart';
import 'package:thesis_app/objects/slider_data.dart';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

Database? _database;

class LocalDatabase {
  static final iv = encrypt.IV.fromUtf8('e16ce888a20dadb8');
  static final key = Key.fromUtf8('1245714587458888');
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  Future get database async {
    if (_database != null) return _database;
    _database = await _initializeDatabase('thesis_app.db');
    return _database;
  }

  Future _initializeDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);
    inspect(path);
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future _createDatabase(Database db, int version) async {
    await db.execute('''
CREATE TABLE "user" (
	"user_id"	TEXT NOT NULL,
	"password"	TEXT NOT NULL,
	PRIMARY KEY("user_id")
)
''');
    final adminPassword = await _encryptPassword("admin");
    final userPassword = await _encryptPassword("13112001");

    await db.rawInsert('''
INSERT INTO "user" (user_id, password)
    VALUES ("admin", "$adminPassword")
''');
    await db.rawInsert('''
INSERT INTO "user" (user_id, password)
    VALUES ("dcphthuynh", "$userPassword")
''');

    await db.execute('''
CREATE TABLE "experiment" (
	"experiment_id"	INTEGER NOT NULL,
	"experiment_name"	TEXT NOT NULL,
	"experimenter"	TEXT,
	PRIMARY KEY("experiment_id" AUTOINCREMENT),
	FOREIGN KEY("experimenter") REFERENCES "user"("user_id")
)
''');

    await db.execute('''
CREATE TABLE "experiment_content" (
	"id"	INTEGER NOT NULL,
	"title"	TEXT NOT NULL,
	"type"	TEXT NOT NULL,
	"order_number"	INTEGER NOT NULL,
  "rating_id" INTEGER,
	"experiment_id"	INTEGER NOT NULL,
	"answer_type"	TEXT,
	"text_button"	TEXT,
	"help_text"	TEXT,
  "timer" INTEGER,
  "image"	BLOB,
  "alert_sound" INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("experiment_id") REFERENCES "experiment"("experiment_id")
);
''');

    await db.execute('''
CREATE TABLE "horizontal_slider" (
	"id"	INTEGER NOT NULL,
	"experiment_id"	INTEGER NOT NULL,
	"question_id"	INTEGER NOT NULL,
	"tick_number"	INTEGER NOT NULL,
	"at_value"	INTEGER NOT NULL,
	"tick_content"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("experiment_id") REFERENCES "experiment"("experiment_id"),
	FOREIGN KEY("question_id") REFERENCES "experiment_content"("id")
)
''');
    await db.execute('''
CREATE TABLE "multiple_choice" (
	"id"	INTEGER NOT NULL,
	"experiment_id"	INTEGER NOT NULL,
	"question_id"	INTEGER NOT NULL,
	"choice_number"	INTEGER NOT NULL,
	"choice_content"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("experiment_id") REFERENCES "experiment"("experiment_id"),
	FOREIGN KEY("question_id") REFERENCES "experiment_content"("id")
)
''');

    await db.execute('''
CREATE TABLE "participant" (
	"id"	INTEGER NOT NULL,
	"participant_id"	TEXT NOT NULL,
	"experiment_id"	INTEGER NOT NULL,
	"starting_time"	TEXT NOT NULL,
	"ending_time"	TEXT NOT NULL,
	"duration"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("experiment_id") REFERENCES "experiment"("experiment_id")
)
''');

    await db.execute('''
CREATE TABLE "result" (
	"result_id"	INTEGER NOT NULL,
	"experiment_id"	INTEGER NOT NULL,
	"answer_type"	TEXT NOT NULL,
	"answer_content"	TEXT NOT NULL,
	"participant_info_id"	INTEGER NOT NULL,
	"question_id"	INTEGER NOT NULL,
	PRIMARY KEY("result_id" AUTOINCREMENT),
	FOREIGN KEY("experiment_id") REFERENCES "experiment"("experiment_id"),
	FOREIGN KEY("participant_info_id") REFERENCES "participant"("id"),
	FOREIGN KEY("question_id") REFERENCES "experiment_content"("id")
)
''');

    await db.execute('''
CREATE TABLE "vertical_slider" (
	"id"	INTEGER NOT NULL,
	"experiment_id"	INTEGER NOT NULL,
	"question_id"	INTEGER NOT NULL,
	"tick_number"	INTEGER NOT NULL,
	"at_value"	INTEGER NOT NULL,
	"tick_content"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("experiment_id") REFERENCES "experiment"("experiment_id"),
	FOREIGN KEY("question_id") REFERENCES "experiment_content"("id")
)
''');
  }

//ADDING FUNCTION

  Future addNoticeStage(
      int orderNumber,
      String experimentName,
      String noticeTitle,
      String? helpText,
      String? textButton,
      bool alertSound,
      Uint8List? image) async {
    final Database db = await database;
    alertSound
        ? await db.rawInsert('''
          INSERT INTO experiment_content ( order_number, title, type, experiment_id, text_button, help_text, alert_sound, image) 
          VALUES (?, ?, "Notice", (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, 1, ?)
        ''', [
            orderNumber,
            noticeTitle,
            experimentName,
            textButton,
            helpText,
            image
          ])
        : await db.rawInsert('''
          INSERT INTO experiment_content ( order_number, title, type, experiment_id, text_button, help_text, alert_sound, image) 
          VALUES (?, ?, "Notice", (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, 0, ?)
        ''', [
            orderNumber,
            noticeTitle,
            experimentName,
            textButton,
            helpText,
            image
          ]);
  }

  Future addQuestion(
    String experimentName,
    String questionTitle,
    int orderNumber,
    String questionAnswerType,
    String? helpText,
    String? textButton,
    bool alertSound,
    Uint8List? image,
  ) async {
    final Database db = await database;
    alertSound
        ? await db.rawInsert(
            'INSERT INTO experiment_content (title, type, order_number,  experiment_id, answer_type, text_button, help_text, alert_sound, image) '
            'VALUES (?, "Question", ?, (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ? , ?, 1, ?)',
            [
              questionTitle,
              orderNumber,
              experimentName,
              questionAnswerType,
              textButton,
              helpText,
              image
            ],
          )
        : await db.rawInsert(
            'INSERT INTO experiment_content (title, type, order_number,  experiment_id, answer_type, text_button, help_text, alert_sound, image) '
            'VALUES (?, "Question", ?, (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ? , ?, 0, ?)',
            [
              questionTitle,
              orderNumber,
              experimentName,
              questionAnswerType,
              textButton,
              helpText,
              image
            ],
          );
  }

  Future addRatingContainer(
    String experimentName,
    String questionTitle,
    int orderNumber,
    int ratingid,
    String questionAnswerType,
    String? helpText,
    String? textButton,
    bool alertSound,
    Uint8List? image,
  ) async {
    final Database db = await database;
    alertSound
        ? await db.rawInsert(
            'INSERT INTO experiment_content (title, type, order_number, rating_id, experiment_id, answer_type, text_button, help_text, alert_sound, image) '
            'VALUES (?, "Rating", ?, ?, (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ? , ?, 1, ?)',
            [
              questionTitle,
              orderNumber,
              ratingid,
              experimentName,
              questionAnswerType,
              textButton,
              helpText,
              image
            ],
          )
        : await db.rawInsert(
            'INSERT INTO experiment_content (title, type, order_number, rating_id, experiment_id, answer_type, text_button, help_text, alert_sound, image) '
            'VALUES (?, "Rating", ?, ?, (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ? , ?, 0, ?)',
            [
                questionTitle,
                orderNumber,
                ratingid,
                experimentName,
                questionAnswerType,
                textButton,
                helpText,
                image
              ]);
  }

  Future addTimerStage(String experimentName, String title, int orderNumber,
      int timer, bool alertSound) async {
    final Database db = await database;
    if (alertSound) {
      await db.rawInsert(
        'INSERT INTO experiment_content (title, type, order_number, experiment_id, timer, alert_sound) '
        'VALUES (?, "Timer", ?, (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, 1)',
        [
          title,
          orderNumber,
          experimentName,
          timer,
        ],
      );
    } else {
      await db.rawInsert(
        'INSERT INTO experiment_content (title, type, order_number, experiment_id, timer, alert_sound) '
        'VALUES (?, "Timer", ?, (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, 0)',
        [
          title,
          orderNumber,
          experimentName,
          timer,
        ],
      );
    }
  }

  Future addExperimentName(String experimentName, String experimenterID) async {
    final Database db = await database;
    await db.rawInsert('''
        INSERT INTO "experiment" (experiment_name, experimenter)
        VALUES (?, ?)
        ''', [experimentName, experimenterID]);
  }

  Future addParticipantInfo(String participantID, String experimentName,
      String startingTime, String endingTime, String duration) async {
    final Database db = await database;
    await db.rawInsert('''
        INSERT INTO participant (participant_id, experiment_id, starting_time, ending_time, duration)
        VALUES (?, (SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, ?)
        ''',
        [participantID, experimentName, startingTime, endingTime, duration]);
  }

  Future addMultipleChoice(String experimentName, String questionTitle,
      int choiceNumber, String choiceContent, int orderNumber) async {
    final Database db = await database;
    await db.rawInsert(
      '''
      INSERT INTO multiple_choice (experiment_id, question_id, choice_number, choice_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), (SELECT id FROM experiment_content WHERE title = ? AND order_number = ?), ?, ?)
      ''',
      [experimentName, questionTitle, orderNumber, choiceNumber, choiceContent],
    );
  }

  Future addSliderOptions(String experimentName, String questionTitle,
      int tickNumber, int atValue, String tickContent, bool isVertical) async {
    final Database db = await database;
    if (isVertical) {
      await db.rawInsert(
        '''
      INSERT INTO vertical_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), (SELECT id FROM experiment_content WHERE title = ? AND answer_type = "Vertical Slider"), ?, ?, ?)
      ''',
        [experimentName, questionTitle, tickNumber, atValue, tickContent],
      );
    } else {
      await db.rawInsert(
        '''
      INSERT INTO horizontal_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), (SELECT id FROM experiment_content WHERE title = ? AND answer_type = "Horizontal Slider"), ?, ?, ?)
      ''',
        [experimentName, questionTitle, tickNumber, atValue, tickContent],
      );
    }
  }

  Future addSliderOptionsInRating(String experimentName, int tickNumber,
      int atValue, String tickContent, bool isVertical, int questionId) async {
    final Database db = await database;
    if (isVertical) {
      await db.rawInsert(
        '''
      INSERT INTO vertical_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, ?, ?)
      ''',
        [experimentName, questionId, tickNumber, atValue, tickContent],
      );
    } else {
      await db.rawInsert(
        '''
      INSERT INTO horizontal_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, ?, ?)
      ''',
        [experimentName, questionId, tickNumber, atValue, tickContent],
      );
    }
  }

  Future addMinMaxVerticalAndHorizontalSlider(
      String questionTitle,
      String experimentName,
      int orderNumber,
      int tickNumber,
      String anchorValue,
      String anchorText,
      bool isVerticalSlider) async {
    final Database db = await database;

    isVerticalSlider
        ? await db.rawInsert(
            '''
      INSERT INTO vertical_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ? AND answer_type = 'Vertical Slider' AND title = ?), ?, ?, ?)
      ''',
            [
              experimentName,
              experimentName,
              orderNumber,
              questionTitle,
              tickNumber,
              anchorValue,
              anchorText
            ],
          )
        : await db.rawInsert(
            '''
      INSERT INTO horizontal_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ? AND answer_type = 'Horizontal Slider' AND title = ?), ?, ?, ?)
      ''',
            [
              experimentName,
              experimentName,
              orderNumber,
              questionTitle,
              tickNumber,
              anchorValue,
              anchorText
            ],
          );
  }

  Future addMinMaxVerticalAndHorizontalSliderInRating(
      String experimentName,
      int tickNumber,
      String anchorValue,
      String anchorText,
      bool isVerticalSlider,
      int questionId) async {
    final Database db = await database;

    isVerticalSlider
        ? await db.rawInsert(
            '''
      INSERT INTO vertical_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, ?, ?)
      ''',
            [experimentName, questionId, tickNumber, anchorValue, anchorText],
          )
        : await db.rawInsert(
            '''
     INSERT INTO horizontal_slider (experiment_id, question_id, tick_number, at_value, tick_content) 
      VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, ?, ?)
      ''',
            [experimentName, questionId, tickNumber, anchorValue, anchorText],
          );
  }

  Future<void> insertAnswer(Answer answer, String startingTime) async {
    final Database db = await database;
    await db.rawInsert(
      'INSERT INTO result (experiment_id, answer_type, answer_content, participant_info_id, question_id) '
      'VALUES ((SELECT experiment_id FROM experiment WHERE experiment_name = ?), ?, ?, (SELECT id FROM participant WHERE starting_time = ?), ?)',
      [
        answer.experimentName,
        answer.questionAnswerType,
        answer.answer,
        startingTime,
        answer.questionId
      ],
    );
  }

  Future<String> saveImage(Uint8List? image, int questionId) async {
    final Database db = await database;
    await db.rawQuery('''
UPDATE experiment_content SET image = ? WHERE id = ?
''', [image, questionId]);
    return 'Added';
  }

  Future<String> updateImage(Uint8List? image, int questionId) async {
    final Database db = await database;
    await db.update("experiment_content", {"image": image});
    return 'Added';
  }

//LOGIN FUNCTION
  Future<bool> login(String userId, String enteredPassword) async {
    final isPasswordCorrect = await _checkPassword(userId, enteredPassword);
    return isPasswordCorrect;
  }

  Future<bool> _checkPassword(String userId, String enteredPassword) async {
    final Database db = await database;
    final results = await db.rawQuery('''
SELECT * FROM "user" WHERE user_id = '$userId'
''');
    if (results.isNotEmpty) {
      final user = results.first;
      final encryptedPassword = user['password'];
      final decryptedPassword = await _decryptPassword(encryptedPassword);

      return decryptedPassword == enteredPassword;
    }
    return false;
  }

  Future _decryptPassword(encryptedPassword) async {
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }

  Future _encryptPassword(password) async {
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

//FETCH FUNCTION
  Future getExperimentWithUserID(String userID) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
  SELECT "experiment_name" FROM "experiment" WHERE "experimenter" = "$userID"
''');
    List experimentNames = res.map((experimentMap) {
      return experimentMap["experiment_name"].toString();
    }).toList();
    return experimentNames;
  }

  Future getAllExperiment() async {
    final Database db = await database;
    final List res = await db.rawQuery('''
  SELECT * FROM "experiment"
''');
    if (res.isNotEmpty) {
      return res.map((json) => Experiment.fromJson(json)).toList();
    }
    return null;
  }

  Future getExperimentNameAndCountWithUserID(String userID) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT
  e.experiment_name,
  COUNT(p.participant_id) AS count
FROM
  experiment e
  LEFT JOIN participant p ON e.experiment_id = p.experiment_id
WHERE
  e.experimenter = '$userID'
GROUP BY
  e.experiment_name;
''');
    List experimentNames =
        res.map((json) => CountOfResult.fromJson(json)).toList();
    return experimentNames;
  }

  Future<bool> getSpecificExperiment(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
  SELECT experiment_name FROM experiment WHERE "experiment_name" = "$experimentName"
''');
    if (res.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future getExperimentContentWithoutRating(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
    SELECT id, order_number, title, type, answer_type, text_button, help_text, timer, alert_sound, image
    FROM experiment_content
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName')
    AND type != 'Rating'
    ORDER BY order_number
''');

    if (res.isNotEmpty) {
      return res.map((json) => ExperimentContent.fromJson(json)).toList();
    }
    return null;
  }

  Future getExperimentContentWithRating(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
	SELECT id, order_number, title, type, answer_type, text_button, help_text, alert_sound, image FROM experiment_content
  WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName')
  AND type = 'Rating'
	ORDER BY RANDOM()
''');
    if (res.isNotEmpty) {
      return res.map((json) => ExperimentContent.fromJson(json)).toList();
    }
    return null;
  }

  Future getQuestions(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT id, order_number, title, type, answer_type, text_button, help_text, timer, alert_sound
FROM experiment_content  
JOIN experiment ON experiment.experiment_id = experiment_content.experiment_id 
WHERE experiment_name = "$experimentName"
''');
    if (res.isNotEmpty) {
      return res.map((json) => ExperimentContent.fromJson(json)).toList();
    }
    return null;
  }

  Future getQuestionsForEditing(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
	SELECT id, order_number, title, type, answer_type, text_button, help_text, rating_id, timer, alert_sound, image FROM experiment_content
	WHERE type != 'Rating' AND experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName')
	UNION
	SELECT id, order_number, title, type, answer_type, text_button, help_text, rating_id, timer, alert_sound, image FROM experiment_content
  WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName')
  AND type = 'Rating'
	GROUP BY order_number
  ORDER BY order_number;
''');
    if (res.isNotEmpty) {
      return res.map((json) => ExperimentContent.fromJson(json)).toList();
    }
    return null;
  }

  Future getRatingForEditing(String experimentName, int orderNumber) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
	SELECT id, order_number, title, type, answer_type, text_button, help_text, rating_id, alert_sound, image FROM experiment_content
	WHERE type == 'Rating' AND experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'
''');
    if (res.isNotEmpty) {
      return res.map((json) => ExperimentContent.fromJson(json)).toList();
    }
    return null;
  }

  Future getRatingForEditing1(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
	SELECT id, order_number, title, type, answer_type, text_button, help_text, rating_id, alert_sound, image FROM experiment_content
	WHERE type == 'Rating' AND experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') 
''');
    if (res.isNotEmpty) {
      return res.map((json) => ExperimentContent.fromJson(json)).toList();
    }
    return null;
  }

  Future getMultipleChoice(String experimentName) async {
    final Database db = await database;

    final List res = await db.rawQuery('''
SELECT question_id, title, choice_number, choice_content, order_number
FROM multiple_choice
JOIN experiment_content ON experiment_content.id = multiple_choice.question_id
WHERE multiple_choice.experiment_id = ( SELECT experiment_id FROM experiment
WHERE experiment_name = "$experimentName" )
AND experiment_content.answer_type = "Multiple Choices"
''');
    if (res.isNotEmpty) {
      return res.map((json) => MultipleChoice.fromJson(json)).toList();
    }
    return null;
  }

  Future getSliderData(String experimentName, bool isVertical) async {
    final Database db = await database;

    final List res = isVertical ? await db.rawQuery('''
SELECT vertical_slider.id, question_id, order_number, tick_number, at_value, tick_content 
FROM vertical_slider
JOIN experiment_content ON experiment_content.id = vertical_slider.question_id
WHERE vertical_slider.experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = "$experimentName" )
AND experiment_content.answer_type = "Vertical Slider"
''') : await db.rawQuery('''
SELECT horizontal_slider.id, question_id, order_number, tick_number, at_value, tick_content 
FROM horizontal_slider
JOIN experiment_content ON experiment_content.id = horizontal_slider.question_id
WHERE horizontal_slider.experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = "$experimentName" )
AND experiment_content.answer_type = "Horizontal Slider"
''');
    if (res.isNotEmpty) {
      return res.map((json) => SliderData.fromJson(json)).toList();
    }
    return null;
  }

  Future getQuestionsForEdit(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT  *
FROM experiment_content  
JOIN experiment ON experiment.experiment_id = experiment_content.experiment_id 
WHERE experiment_name = "$experimentName"
''');
    if (res.isNotEmpty) {
      return res.map((json) => ExperimentContent.fromJson(json)).toList();
    }
    return null;
  }

  Future getMultipleChoiceForEdit(String experimentName) async {
    final Database db = await database;

    final List res = await db.rawQuery('''
SELECT title, choice_number, choice_content, order_number
FROM multiple_choice
JOIN experiment_content ON experiment_content.id = multiple_choice.question_id
WHERE multiple_choice.experiment_id = ( SELECT experiment_id FROM experiment
WHERE experiment_name = "$experimentName" )
AND experiment_content.answer_type = "Multiple Choices"
''');
    if (res.isNotEmpty) {
      return res.map((json) => MultipleChoice.fromJson(json)).toList();
    }
    return null;
  }

  Future getSliderDataForEdit(String experimentName, bool isVertical) async {
    final Database db = await database;

    final List res = isVertical ? await db.rawQuery('''
SELECT order_number, tick_number, at_value, tick_content 
FROM vertical_slider
JOIN experiment_content ON experiment_content.id = vertical_slider.question_id
WHERE vertical_slider.experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = "$experimentName" )
AND experiment_content.answer_type = "Vertical Slider"
''') : await db.rawQuery('''
SELECT order_number, tick_number, at_value, tick_content 
FROM horizontal_slider
JOIN experiment_content ON experiment_content.id = horizontal_slider.question_id
WHERE horizontal_slider.experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = "$experimentName" )
AND experiment_content.answer_type = "Horizontal Slider"
''');
    if (res.isNotEmpty) {
      return res.map((json) => SliderData.fromJson(json)).toList();
    }
    return null;
  }

  Future getAllQuestion(String experimentName) async {
    final Database db = await database;

    final List res = await db.rawQuery('''
SELECT * FROM experiment_content WHERE
  experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = "1tt");
''');
    if (res.isNotEmpty) {
      return res.map((json) => MultipleChoice.fromJson(json)).toList();
    }
    return null;
  }

  Future getResultOfExperimenter(String experimenter) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT result_id, result.experiment_id, result.answer_type, result.answer_content, participant.participant_id, experiment_content.id, experiment_content.order_number,experiment_content.title,experiment_content.type
FROM result
INNER JOIN participant  ON result.participant_info_id = participant.id
INNER JOIN experiment_content  ON result.question_id= experiment_content.id
WHERE experiment_content.experiment_id = (SELECT experiment_id FROM experiment WHERE experiment.experiment_name = '$experimenter')
ORDER BY experiment_content.order_number
''');
    if (res.isNotEmpty) {
      return res.map((json) => Result.fromJson(json)).toList();
    }
    return null;
  }

  Future getResultOfExperiment(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT result_id, result.experiment_id, result.answer_type, result.answer_content, participant.participant_id, experiment_content.id, experiment_content.order_number,experiment_content.title,experiment_content.type
FROM result
INNER JOIN participant  ON result.participant_info_id = participant.id
INNER JOIN experiment_content  ON result.question_id= experiment_content.id
WHERE experiment_content.experiment_id = (SELECT experiment_id FROM experiment WHERE experiment.experiment_name = '$experimentName')
ORDER BY experiment_content.order_number
''');
    if (res.isNotEmpty) {
      return res.map((json) => Result.fromJson(json)).toList();
    }
    return null;
  }

  Future getResultOfExperimentGrouped(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT result_id, result.experiment_id, result.answer_type, result.answer_content, participant.participant_id, experiment_content.id, experiment_content.order_number,experiment_content.title,experiment_content.type
FROM result
INNER JOIN participant  ON result.participant_info_id = participant.id
INNER JOIN experiment_content  ON result.question_id= experiment_content.id
WHERE experiment_content.experiment_id = (SELECT experiment_id FROM experiment WHERE experiment.experiment_name = '$experimentName')
GROUP BY experiment_content.order_number
ORDER BY experiment_content.order_number
''');
    if (res.isNotEmpty) {
      return res.map((json) => Result.fromJson(json)).toList();
    }
    return null;
  }

  Future getRatingResultOfExperiment(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT result_id, result.experiment_id, result.answer_type, result.answer_content, participant.participant_id, experiment_content.id, experiment_content.order_number,experiment_content.title,experiment_content.type
FROM result
INNER JOIN participant  ON result.participant_info_id = participant.id
INNER JOIN experiment_content  ON result.question_id= experiment_content.id
WHERE experiment_content.experiment_id = (SELECT experiment_id FROM experiment WHERE experiment.experiment_name = '$experimentName') AND experiment_content.type = 'Rating'
ORDER BY experiment_content.order_number
''');
    if (res.isNotEmpty) {
      return res.map((json) => Result.fromJson(json)).toList();
    }
    return null;
  }

  Future getRatingResultOfExperimentGrouped(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT result_id, result.experiment_id, result.answer_type, result.answer_content, participant.participant_id, experiment_content.id, experiment_content.order_number,experiment_content.title,experiment_content.type
FROM result
INNER JOIN participant  ON result.participant_info_id = participant.id
INNER JOIN experiment_content  ON result.question_id= experiment_content.id
WHERE experiment_content.experiment_id = (SELECT experiment_id FROM experiment WHERE experiment.experiment_name = '$experimentName') AND experiment_content.type = 'Rating'
GROUP BY experiment_content.id
ORDER BY experiment_content.order_number
''');
    if (res.isNotEmpty) {
      return res.map((json) => Result.fromJson(json)).toList();
    }
    return null;
  }

  Future getOrderNumberInResult(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT experiment_content.order_number  FROM result
INNER JOIN participant  ON result.participant_info_id = participant.id
INNER JOIN experiment_content  ON result.question_id= experiment_content.id
WHERE experiment_content.experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = "$experimentName")
GROUP BY experiment_content.order_number
ORDER BY experiment_content.order_number
''');
    if (res.isNotEmpty) {
      return res.map((json) => ListOfOrderNumber.fromJson(json)).toList();
    }
    return null;
  }

  Future getQuestionIdInResult(String experimentName) async {
    final Database db = await database;
    final List res = await db.rawQuery('''
SELECT experiment_content.id  FROM result
INNER JOIN participant  ON result.participant_info_id = participant.id
INNER JOIN experiment_content  ON result.question_id= experiment_content.id
WHERE experiment_content.experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = "$experimentName")
ORDER BY experiment_content.order_number
''');
    if (res.isNotEmpty) {
      return res.map((json) => ListOfQuestionId.fromJson(json)).toList();
    }
    return null;
  }

  // DELETE FUNCTION
  Future deleteChosenExperiment(String experimentName) async {
    final Database db = await database;
    await db.rawDelete(
        'DELETE FROM experiment_content WHERE experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = ?)',
        [experimentName]);
    await db.rawDelete(
        'DELETE FROM participant WHERE experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = ?)',
        [experimentName]);
    await db.rawDelete(
        'DELETE FROM horizontal_slider WHERE experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = ?)',
        [experimentName]);
    await db.rawDelete(
        'DELETE FROM vertical_slider WHERE experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = ?)',
        [experimentName]);
    await db.rawDelete(
        'DELETE FROM multiple_choice WHERE experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = ?)',
        [experimentName]);
    await db.rawDelete(
        'DELETE FROM result WHERE experiment_id = ( SELECT experiment_id FROM experiment WHERE experiment_name = ?)',
        [experimentName]);
    await db.rawDelete(
        'DELETE FROM experiment WHERE experiment_name = ?', [experimentName]);
  }

  Future deleteChoosenNotice(String experimentName, int questionId) async {
    final Database db = await database;
    await db.rawDelete('''
DELETE FROM experiment_content
WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND id = '$questionId'
''');
  }

  Future deleteChoosenTimer(String experimentName, int questionId) async {
    final Database db = await database;
    await db.rawDelete('''
DELETE FROM experiment_content
WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND id = '$questionId' 
''');
  }

  Future deleteRatingQuestion(int questionId, bool isVertical) async {
    final Database db = await database;
    await db.rawDelete('''
DELETE FROM experiment_content
WHERE id = ?
''', [questionId]);
    if (isVertical) {
      await db.rawDelete('''
DELETE FROM vertical_slider
WHERE question_id = ?
''', [questionId]);
    } else {
      await db.rawDelete('''
DELETE FROM horizontal_slider
WHERE question_id = ?
''', [questionId]);
    }
  }

  Future deleteChoosenQuestion(String experimentName, int questionId,
      bool isVertical, bool isHorizontal, bool isMCQS) async {
    final Database db = await database;
    await db.rawDelete('''
DELETE FROM experiment_content
WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND id = '$questionId'
''');
    if (isVertical) {
      await db.rawDelete('''
DELETE FROM vertical_slider
WHERE question_id = ?
AND experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?)
''', [questionId, experimentName]);
    }

    if (isHorizontal) {
      await db.rawDelete('''
DELETE FROM horizontal_slider
WHERE question_id = ?
AND experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?)
''', [questionId, experimentName]);
    }

    if (isMCQS) {
      await db.rawDelete('''
DELETE FROM multiple_choice
WHERE question_id = ?
AND experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?)
''', [questionId, experimentName]);
    }
  }

  Future deleteSliderData(String experimentName, String atValue, int questionId,
      bool isVertical) async {
    final Database db = await database;
    isVertical ? await db.rawDelete('''
DELETE FROM vertical_slider
WHERE at_value = ?
AND question_id = ?
''', [atValue, questionId]) : await db.rawDelete('''
DELETE FROM horizontal_slider
WHERE at_value = ?
AND question_id = ?
''', [atValue, questionId]);
  }

  Future deleteSliderDataInRating(int id, bool isVertical) async {
    final Database db = await database;
    isVertical ? await db.rawDelete('''
DELETE FROM vertical_slider
WHERE id = ?
''', [id]) : await db.rawDelete('''
DELETE FROM horizontal_slider
WHERE id = ?
''', [id]);
  }

  Future deleteSliderDataInRatingEdit(int questionId, String isVertical) async {
    final Database db = await database;
    isVertical == 'Vertical Slider' ? await db.rawDelete('''
DELETE FROM vertical_slider
WHERE question_id = ?
''', [questionId]) : await db.rawDelete('''
DELETE FROM horizontal_slider
WHERE question_id = ?
''', [questionId]);
  }

  Future deleteMCQsData(
      String experimentName, int choiceNumber, int orderNumber) async {
    final Database db = await database;
    await db.rawDelete('''
DELETE FROM multiple_choice
WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) 
AND order_number = ?)
AND choice_number = ?
''', [experimentName, orderNumber, choiceNumber]);
  }

  Future deleteRatingContainer(int questionId) async {
    final Database db = await database;
    await db.rawDelete('''
  DELETE FROM experiment_content
  WHERE type = 'Rating' 
  AND id = ?
''', [questionId]);
  }

  Future deleteChoosenQuestionInResult(int questionId) async {
    final Database db = await database;
    await db.rawDelete('''
DELETE FROM result
WHERE question_id = $questionId
''');
  }

  //UPDATE FUNCTION
  Future updateExperimentName(
      String newExperimentName, String oldExperimentName, String userID) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment SET experiment_name = '$newExperimentName' WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$oldExperimentName') AND experimenter = '$userID'");
  }

  Future updateTitle(
      String title, String experimentName, int orderNumber) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET title = '$title' WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'");
  }

  Future updateNoticeToTimer(
      String title, String experimentName, int orderNumber, int timer) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET title = '$title', type = 'Timer', timer = '$timer', text_button = null, help_text = null WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'");
  }

  Future updateTimer(String title, String experimentName, int orderNumber,
      int timerValue) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET title = '$title', timer = '$timerValue' WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'");
  }

  Future updateTimerToNotice(
      String title, String experimentName, int orderNumber) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET title = '$title', timer = null, type = 'Notice' WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'");
  }

  Future updateTitleInRating(String title, int questionId) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET title = '$title' WHERE id = ?",
        [questionId]);
  }

  Future updateHelpTextAndTextButton(String? helpText, String? textButton,
      String experimentName, int orderNumber) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET help_text = ?, text_button = ? WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'",
        [helpText, textButton]);
  }

  Future updateAlertSound(
      bool alertSound, String experimentName, int orderNumber) async {
    final Database db = await database;
    alertSound
        ? await db.rawQuery(
            "UPDATE experiment_content SET alert_sound = 1 WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'")
        : await db.rawQuery(
            "UPDATE experiment_content SET alert_sound = 0 WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND order_number = '$orderNumber'");
  }

  Future updateHelpTextAndTextButtonInRating(String? helpText,
      String? textButton, String experimentName, int questionID) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET help_text = ?, text_button = ? WHERE id = '$questionID'",
        [helpText, textButton]);
  }

  Future updateAlertSoundInRating(bool alertSound, int questionID) async {
    final Database db = await database;
    alertSound
        ? await db.rawQuery(
            "UPDATE experiment_content SET alert_sound = 1 WHERE id = '$questionID'")
        : await db.rawQuery(
            "UPDATE experiment_content SET alert_sound = 0 WHERE id = '$questionID'");
  }

  Future updateMaxMinVeritcalOrHorizontalSlider(
      bool isVertical,
      String tickContent,
      int tickNumber,
      String atValue,
      int questionId) async {
    final Database db = await database;
    if (isVertical) {
      await db.rawQuery('''
        UPDATE vertical_slider
        SET tick_content = ?, at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atValue, questionId, tickNumber]);
    } else {
      await db.rawQuery('''
        UPDATE horizontal_slider
        SET tick_content = ?, at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atValue, questionId, tickNumber]);
    }
  }

  Future updateMaxMinVeritcalOrHorizontalSliderInRating(bool isVertical,
      String tickContent, String atValue, int id, int tickNumber) async {
    final Database db = await database;
    if (isVertical) {
      await db.rawQuery('''
        UPDATE vertical_slider
        SET tick_content = ?, at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atValue, id, tickNumber]);
    } else {
      await db.rawQuery('''
        UPDATE horizontal_slider
        SET tick_content = ? , at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atValue, id, tickNumber]);
    }
  }

  Future updateTickContentInVerticalOrHorizontalSlider(
      String tickContent,
      String atNewValue,
      int tickNumber,
      int questionId,
      bool isVertical) async {
    final Database db = await database;
    isVertical
        ? await db.rawQuery('''
        UPDATE vertical_slider
        SET tick_content = ? , at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atNewValue, questionId, tickNumber])
        : await db.rawQuery('''
        UPDATE horizontal_slider
        SET tick_content = ? , at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atNewValue, questionId, tickNumber]);
  }

  Future updateTickContentInVerticalSliderInRating(
      String tickContent, String atValue, int id, int tickNumber) async {
    final Database db = await database;
    await db.rawQuery('''
        UPDATE vertical_slider
        SET tick_content = ? , at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atValue, id, tickNumber]);
  }

  Future updateTickContentInHorizontalSliderInRating(
      String tickContent, String atValue, int id, int tickNumber) async {
    final Database db = await database;
    await db.rawQuery('''
        UPDATE horizontal_slider
        SET tick_content = ? , at_value = ?
        WHERE question_id = ? AND tick_number = ?
        ''', [tickContent, atValue, id, tickNumber]);
  }

  Future updateVerticalToHorizontal(
      String title, String experimentName, int orderNumber) async {
    final Database db = await database;
    await db.rawDelete('''
    DELETE FROM vertical_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Horizontal Slider', title = ?
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [title, experimentName, orderNumber]);
  }

  Future updateVerticalToMCQsOrInput(
      bool isMCQs, String title, String experimentName, int orderNumber) async {
    final Database db = await database;
    await db.rawDelete('''
    DELETE FROM vertical_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = ?, title = ?
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [
      isMCQs ? 'Multiple Choices' : 'Input Answer',
      title,
      experimentName,
      orderNumber
    ]);
  }

  Future updateVerticalOrHorizontalToNoticeStage(bool isVertical, String title,
      String experimentName, int orderNumber) async {
    final Database db = await database;
    if (isVertical) {
      await db.rawDelete('''
    DELETE FROM vertical_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);
    } else {
      await db.rawDelete('''
    DELETE FROM horizontal_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);
    }

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = ?, title = ?, type = 'Notice'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [null, title, experimentName, orderNumber]);
  }

  Future updateVerticalOrHorizontalToTimerStage(bool isVertical, String title,
      String experimentName, int orderNumber, int timer) async {
    final Database db = await database;
    if (isVertical) {
      await db.rawDelete('''
    DELETE FROM vertical_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);
    } else {
      await db.rawDelete('''
    DELETE FROM horizontal_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);
    }

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = ?, title = ?, type = 'Timer', timer = ?
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [null, title, timer, experimentName, orderNumber]);
  }

  Future updateHorizontalToMCQsOrInput(
      bool isMCQS, String title, String experimentName, int orderNumber) async {
    final Database db = await database;
    await db.rawDelete('''
    DELETE FROM horizontal_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = ?, title = ?
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [
      isMCQS ? 'Multiple Choices' : 'Input Answer',
      title,
      experimentName,
      orderNumber
    ]);
  }

  Future updateHorizontalToVertical(
      String title, String experimentName, int orderNumber) async {
    final Database db = await database;
    await db.rawDelete('''
    DELETE FROM horizontal_slider
    WHERE question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
  ''', [experimentName, orderNumber]);

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Vertical Slider', title = ?
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [title, experimentName, orderNumber]);
  }

  Future updateMCQsData(String choiceContent, String experimentName,
      int orderNumber, int choiceNumber) async {
    Database db = await database;
    await db.rawQuery('''
    UPDATE multiple_choice SET choice_content = ?
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?)
    AND question_id = (SELECT id FROM experiment_content WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?)
    AND choice_number = ?
''', [
      choiceContent,
      experimentName,
      experimentName,
      orderNumber,
      choiceNumber
    ]);
  }

  Future updateMCQs(bool isHorizontal, bool isVertical, bool isInput,
      bool isNotice, String experimentName, int orderNumber) async {
    final Database db = await database;
    if (isHorizontal) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Horizontal Slider'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isVertical) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Vertical Slider'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isInput) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Input Answer'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isNotice) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = ?, type = 'Notice'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [null, experimentName, orderNumber]);
    }
  }

  Future updateMCQsToTimer(
      String title, String experimentName, int orderNumber, int timer) async {
    final Database db = await database;

    await db.rawQuery('''
    UPDATE experiment_content 
    SET title = ?,answer_type = ?, type = 'Timer', timer = ?, text_button = null, help_text = null
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [title, null, timer, experimentName, orderNumber]);
  }

  Future updateInputAnswer(bool isHorizontal, bool isVertical, bool isMCQs,
      bool isNotice, String experimentName, int orderNumber) async {
    final Database db = await database;
    if (isHorizontal) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Horizontal Slider'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isVertical) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Vertical Slider'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isMCQs) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Multiple Choices'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isNotice) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = ?, type = 'Notice'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [null, experimentName, orderNumber]);
    }
  }

  Future updateInputAnswerToTimer(
      String title, String experimentName, int orderNumber, int timer) async {
    final Database db = await database;

    await db.rawQuery('''
    UPDATE experiment_content 
    SET title = ?, answer_type = null, type = 'Timer', text_button = null, help_text = null, timer = ?
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [title, timer, experimentName, orderNumber]);
  }

  Future updateNoticeStage(bool isHorizontal, bool isVertical, bool isMCQs,
      bool isInput, String experimentName, int orderNumber) async {
    final Database db = await database;
    if (isHorizontal) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Horizontal Slider', type = 'Question'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isVertical) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Vertical Slider', type = 'Question'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isMCQs) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Multiple Choices', type = 'Question'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    } else if (isInput) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Input Answer', type = 'Question'
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [experimentName, orderNumber]);
    }
  }

  Future updateTimerToQuestion(
      bool isHorizontal,
      bool isVertical,
      bool isMCQs,
      bool isInput,
      String experimentName,
      int orderNumber,
      String? helpText,
      String? textButton) async {
    final Database db = await database;
    if (isHorizontal) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Horizontal Slider', type = 'Question', text_button = ?, help_text = ?, timer = null
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [textButton, helpText, experimentName, orderNumber]);
    } else if (isVertical) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Vertical Slider', type = 'Question', text_button = ?, help_text = ?, timer = null
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [textButton, helpText, experimentName, orderNumber]);
    } else if (isMCQs) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Multiple Choices', type = 'Question', text_button = ?, help_text = ?, timer = null
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [textButton, helpText, experimentName, orderNumber]);
    } else if (isInput) {
      await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Input Answer', type = 'Question', text_button = ?, help_text = ?, timer = null
    WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = ?) AND order_number = ?
  ''', [textButton, helpText, experimentName, orderNumber]);
    }
  }

  Future updateOrderOfExperiment(int orderNumber, int questionID) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET order_number = '$orderNumber' WHERE id = '$questionID'");
  }

  Future updateRatingOrderOfExperiment(
      int newOrderNumber, String experimentName, int ratingId) async {
    final Database db = await database;
    await db.rawQuery(
        "UPDATE experiment_content SET order_number = '$newOrderNumber' WHERE experiment_id = (SELECT experiment_id FROM experiment WHERE experiment_name = '$experimentName') AND rating_id = '$ratingId' AND type = 'Rating'");
  }

  Future asd1() async {
    final Database db = await database;
    await db.rawQuery('''    UPDATE participant
    SET participant_id = 'Tran Binh Nhi'
    WHERE id = 16''');
  }

  Future updateVerticalToHorizontalInRating(int questionId) async {
    final Database db = await database;
    await db.rawDelete('''
    DELETE FROM vertical_slider
    WHERE question_id = '$questionId' 
  ''');

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Horizontal Slider'
    WHERE id = '$questionId'
  ''');
  }

  Future updateHorizontalToVerticalInRating(int questionId) async {
    final Database db = await database;
    await db.rawDelete('''
    DELETE FROM horizontal_slider
    WHERE question_id = '$questionId' 
  ''');

    await db.rawQuery('''
    UPDATE experiment_content 
    SET answer_type = 'Vertical Slider'
    WHERE id = '$questionId'
  ''');
  }

  Future asd() async {
    final Database db = await database;
    for (int i = 41; i <= 43; i++) {
      await db.rawQuery('''
INSERT INTO "experiment_content" ("title","type","order_number","rating_id","experiment_id","answer_type","text_button","help_text","timer","alert_sound","image") VALUES ('Welcome to Sweet Tasting Study experiment','Notice',1,NULL,${i},NULL,NULL,NULL,NULL,0,NULL),
 ('You will be asked to look at the picture of a food/drink and then please drag your answer base on your feeling. ','Notice',2,NULL,${i},NULL,NULL,NULL,NULL,0,NULL),
 ('How much do you like strawberry smell?','Question',3,NULL,${i},'Horizontal Slider',NULL,NULL,NULL,0,NULL),
 ('How sweet does it smell?','Rating',4,1,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How bitter does it smell?','Rating',4,1,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How strong does it smell?','Rating',4,1,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How much do you like strawberry taste?','Question',5,NULL,${i},'Horizontal Slider',NULL,NULL,NULL,0,NULL),
 ('How sweet does it taste?','Rating',6,2,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How bitter does it taste?','Rating',6,2,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How strong does it taste?','Rating',6,2,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How often do you eat strawberry?','Question',7,NULL,${i},'Multiple Choices',NULL,NULL,NULL,0,NULL),
 ('What is your favorite way to eat strawberry?','Question',8,NULL,${i},'Input Answer',NULL,NULL,NULL,0,NULL),
 ('Let’s move to next food/drink','Notice',9,NULL,${i},NULL,NULL,NULL,NULL,0,NULL),
 ('How much do you like coffee smell?','Question',10,NULL,${i},'Horizontal Slider',NULL,NULL,NULL,0,NULL),
 ('How sweet does it smell?','Rating',11,3,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How bitter does it smell?','Rating',11,3,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How strong does it smell?','Rating',11,3,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How much do you like coffee taste?','Question',12,NULL,${i},'Horizontal Slider',NULL,NULL,NULL,0,NULL),
 ('How sweet does it taste?','Rating',13,4,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How bitter does it taste?','Rating',13,4,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How strong does it taste?','Rating',13,4,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How often do you drink coffee?','Question',14,NULL,${i},'Multiple Choices',NULL,NULL,NULL,0,NULL),
 ('What is your favorite way to drink coffee?','Question',15,NULL,${i},'Input Answer',NULL,NULL,NULL,0,NULL),
 ('Let’s move to the last drink','Notice',16,NULL,${i},NULL,NULL,NULL,NULL,0,NULL),
 ('How much do you like a cup of tea smell?','Question',17,NULL,${i},'Horizontal Slider',NULL,NULL,NULL,0,NULL),
 ('How sweet does it smell?','Rating',18,5,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How bitter does it smell?','Rating',18,5,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How strong does it smell?','Rating',18,5,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How much do you like a cup of tea taste?','Question',19,NULL,${i},'Horizontal Slider',NULL,NULL,NULL,0,NULL),
 ('How sweet does it taste?','Rating',20,6,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How bitter does it taste?','Rating',20,6,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How strong does it taste?','Rating',20,6,${i},'Vertical Slider',NULL,NULL,NULL,0,NULL),
 ('How often do you drink a cup of tea?','Question',21,NULL,${i},'Multiple Choices',NULL,NULL,NULL,0,NULL),
 ('What is your favorite way to drink a cup of tea?','Question',22,NULL,${i},'Input Answer',NULL,NULL,NULL,0,NULL),
 ('That’s the end of the experiment. 

Your answers will contribute a lot in this study.

THANK YOU FOR YOUR TIME!!!','Notice',23,NULL,${i},NULL,NULL,NULL,NULL,0,NULL);

''');
    }
  }
}
