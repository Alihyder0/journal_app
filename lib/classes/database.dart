import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  Future<String> readJournals() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        developer.log('${file.absolute}',
            name: 'DatabaseFileRoutines.readJournals File not found');
        await writeJournals('{"journals": []}'); //create file if not found
      }
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      developer.log(e.toString(), name: 'DatabaseFileRoutines.readJournals');
      return '';
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    return file.writeAsString(json);
  }

  Database databaseFromJson(String str) {
    final dataFromJson = jsonDecode(str);
    return Database.fromJson(dataFromJson);
  }

  String databaseToJson(Database data) {
    final dataToJson = data.toJson();
    return jsonEncode(dataToJson);
  }
}

class Database {
  List<Journal>? journal;

  Database({this.journal});

  factory Database.fromJson(Map<String, dynamic> json) => Database(
        journal: json["journals"] == null
            ? null
            : List<Journal>.from(json["journals"].map((x) => Journal.fromJson(
                x))), //Journal.fromJson to convert to Journal Object
      );

  Map<String, dynamic> toJson() => {
        "journals": journal == null
            ? null
            : List<dynamic>.from(
                journal!.map((x) => x.toJson())), // each journal
      };
}

class Journal {
  String? id;
  String? date;
  String? mood;
  String? note;
  Journal({
    this.id,
    this.date,
    this.mood,
    this.note,
  });

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
        id: json["id"],
        date: json["date"],
        mood: json["mood"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "mood": mood,
        "note": note,
      };
}

class JournalEdit {
  String? action;
  Journal? journal;

  JournalEdit({this.action, this.journal});
}
