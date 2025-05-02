import 'package:ch11_method_channel/classes/database.dart';
import 'package:ch11_method_channel/home.dart';
import 'package:ch11_method_channel/pages/edit_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Persistence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.blueAccent),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Database _database = Database();

  Future<List<Journal>?> _loadJournals() async {
    await DatabaseFileRoutines().readJournals().then((journalsJson) {
      _database = DatabaseFileRoutines().databaseFromJson(journalsJson);
      _database.journal!
          .sort((comp1, comp2) => comp2.date!.compareTo(comp1.date!));
    });
    return _database.journal;
  }

  void _addOrEditJournal({bool? add, int? index, Journal? journal}) async {
    JournalEdit _journalEdit = JournalEdit(action: '', journal: journal);
    _journalEdit = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditEntry(
                  add: add,
                  index: index,
                  journalEdit: _journalEdit,
                ),
            fullscreenDialog: true));

    switch (_journalEdit.action) {
      case 'Save':
        if (add!) {
          setState(() {
            _database.journal!.add(_journalEdit.journal!);
          });
        } else {
          setState(() {
            _database.journal![index!] = _journalEdit.journal!;
          });
        }
        DatabaseFileRoutines()
            .writeJournals(DatabaseFileRoutines().databaseToJson(_database));
        break;
      case 'Cancel':
        break;
    }
  }

  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        String _titleDate = DateFormat.yMMMEd()
            .format(DateTime.parse(snapshot.data[index].date!));
        String _subtitle =
            snapshot.data[index].mood! + "\n" + snapshot.data[index].note!;
        return Dismissible(
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          key: Key(snapshot.data[index].id!),
          child: ListTile(
              onTap: () {
                _addOrEditJournal(
                    add: false, index: index, journal: snapshot.data[index]);
              },
              subtitle: Text(_subtitle),
              title: Text(
                _titleDate,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  DateFormat.d()
                      .format(DateTime.parse(snapshot.data[index].date!)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.blue,
                  ),
                ),
                Text(DateFormat.E()
                    .format(DateTime.parse(snapshot.data[index].date!)))
              ])),
          onDismissed: (direction) {
            setState(() {
              _database.journal!.removeAt(index);
            });
            DatabaseFileRoutines().writeJournals(
                DatabaseFileRoutines().databaseToJson(_database));
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: EdgeInsets.all(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          _addOrEditJournal(add: true, index: -1, journal: Journal());
        },
        tooltip: 'Add Journal Entry',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Local Persistence'),
      ),
      body: FutureBuilder(
          future: _loadJournals(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return _buildListViewSeparated(snapshot);
          }),
    );
  }
}
