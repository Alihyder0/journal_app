import 'dart:math';

import 'package:ch11_method_channel/classes/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEntry extends StatefulWidget {
  final bool? add;
  final int? index;
  final JournalEdit? journalEdit;
  const EditEntry({this.add, this.index, this.journalEdit, super.key});

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  JournalEdit? _journalEdit;
  String? _title;
  DateTime? _selectedDate;
  TextEditingController _moodController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  FocusNode _moodFocus = FocusNode();
  FocusNode _noteFocus = FocusNode();
  Database _database = Database();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _journalEdit =
        JournalEdit(action: 'Cancel', journal: widget.journalEdit!.journal);
    _title = widget.add! ? 'Add' : 'Edit';
    _journalEdit!.journal = widget.journalEdit!.journal;
    if (widget.add!) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = DateTime.parse(_journalEdit!.journal!.date!);
      _moodController.text = _journalEdit!.journal!.mood!;
      _noteController.text = _journalEdit!.journal!.note!;
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<DateTime> _selectDate(DateTime selectedDate) async {
    DateTime initialDate = selectedDate;

    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));

    if (pickedDate != null) {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialDate.hour,
        initialDate.minute,
        initialDate.second,
        initialDate.millisecond,
        initialDate.microsecond,
      );
    }
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title!),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                DateTime _pickerDate = await _selectDate(_selectedDate!);
                setState(() {
                  _selectedDate = _pickerDate;
                });
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 22,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    DateFormat.yMMMEd().format(
                      _selectedDate!,
                    ),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            TextField(
              autofocus: true,
              controller: _moodController,
              textInputAction: TextInputAction.next,
              focusNode: _moodFocus,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Mood',
                icon: Icon(Icons.mood),
              ),
              onSubmitted: (mood) {
                FocusScope.of(context).requestFocus(_noteFocus);
              },
            ),
            TextField(
              controller: _noteController,
              textInputAction: TextInputAction.newline,
              focusNode: _noteFocus,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Note',
                icon: Icon(Icons.note),
              ),
              maxLines: null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                  onPressed: () {
                    _journalEdit!.action = 'Cancel';
                    Navigator.pop(context, _journalEdit);
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(
                  width: 8,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade100,
                  ),
                  onPressed: () {
                    _journalEdit!.action = 'Save';
                    String _id = widget.add!
                        ? Random().nextInt(1000).toString()
                        : _journalEdit!.journal!.id!;

                    _journalEdit!.journal = Journal(
                      id: _id,
                      date: _selectedDate.toString(),
                      mood: _moodController.text,
                      note: _noteController.text,
                    );
                    Navigator.pop(context, _journalEdit);
                  },
                  child: Text('Save'),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
