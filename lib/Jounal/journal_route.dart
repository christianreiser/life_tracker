import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import '../Database/Route/edit_entries.dart';
import '../Database/database_helper_entry.dart';
import '../Database/entry.dart';

class JournalRoute extends StatefulWidget {
  JournalRoute({Key key, this.title}) : super(key: key);
  final String title;

  @override
  JournalRouteState createState() => JournalRouteState();
}

class JournalRouteState extends State<JournalRoute> {
  List<Entry> entryList;
  int countEntry = 0;

  @override
  Widget build(BuildContext context) {
    if (entryList == null) {
      entryList = List<Entry>();
      _updateEntryListView();
    }
    return RefreshIndicator(
      //key: refreshKey,
      onRefresh: () async {
        _updateEntryListView();
      },
      child: _getEntryListView(),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }

// ENTRY LIST
  ListView _getEntryListView() {
    return ListView.builder(
      itemCount: countEntry,
      itemBuilder: (BuildContext context, int position) {
        return Container(
          padding: EdgeInsets.fromLTRB(4,0,4,0),
          color: Theme.of(context).backgroundColor,
          child: Card(
            //color: Colors.white,
            //shadowColor: Colors.black,
            //elevation: 3.0,
            child: ListTile(
              // YELLOW CIRCLE AVATAR
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  getFirstLetter(this.entryList[position].title),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Label
              title: Text(
                this.entryList[position].title,
                style: TextStyle(fontWeight: FontWeight.bold,),
              ),

              // Value
              subtitle: Text(this.entryList[position].value),

              // Time and comment
              trailing: Column(
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(this.entryList[position].date),
                  Text(this.entryList[position].comment),
                ],
              ),

              // onTAP TO EDIT
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToEditEntry(this.entryList[position], 'Edit Entry');
              },
            ),
          ),
        );
      },
    );
  }

  // for yellow circle avatar
  getFirstLetter(String title) {
    return title.substring(0, 1);
  }

  // navigation for editing entry
  void navigateToEditEntry(Entry entry, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditEntry(entry, title);
    }));

    if (result == true) {
      _updateEntryListView();
    }
  }

  // updateEntryListView depends on state
  // TODO functions also in journal_route but using it from there breaks it
  void _updateEntryListView() async {
    DatabaseHelperEntry databaseHelperEntry = DatabaseHelperEntry();
    Future<List<Entry>> entryListFuture = databaseHelperEntry.getEntryList();
    entryList = await entryListFuture;
    setState(() {
      this.entryList = entryList;
      this.countEntry = entryList.length;
    });
  }
}
