import 'package:fckapi/core/models/note.dart';
import 'package:fckapi/core/services/rest_fire_service.dart';
import 'package:fckapi/views/add_note.dart';
import 'package:fckapi/views/components/animated_custom_fab.dart';
import 'package:fckapi/views/components/failed.dart';
import 'package:fckapi/views/components/loading.dart';
import 'package:fckapi/views/widgets/custom_appbar.dart';
import 'package:fckapi/views/widgets/note_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_button/custom/opacity_button.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RestFireService fireService;

  @override
  void initState() {
    super.initState();
    fireService = RestFireService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(),
      body: buildBody(),
      floatingActionButton: buildAnimatedCustomFAB(() async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddNote(),
          ),
        );
        setState(() {});
      }),
    );
  }

  FutureBuilder<List<Note>> buildBody() {
    return FutureBuilder<List<Note>>(
      future: fireService.fetchNotes(),
      builder: (context, snaphot) {
        switch (snaphot.connectionState) {
          case ConnectionState.done:
            if (snaphot.data != null) {
              return buildNoteList(snaphot);
            } else {
              return failed;
            }
            break;
          default:
            return loading;
        }
      },
    );
  }

  Padding buildNoteList(AsyncSnapshot<List<Note>> snaphot) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: snaphot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return NoteCard(
            title: snaphot.data[index].title,
            description: snaphot.data[index].description,
            onTap: () async {
              await fireService.deleteNote(
                Note(
                  key: snaphot.data[index].key,
                  title: snaphot.data[index].title,
                  description: snaphot.data[index].description,
                ),
              );
              setState(() {});
            },
          );
        },
      ),
    );
  }

  CustomAppBar buildCustomAppBar() {
    return CustomAppBar(
      title: "Rest Note",
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 10),
        child: OpacityButton(
          child: Icon(
            Icons.refresh,
            color: Colors.black,
            size: 30,
          ),
          onTap: () {
            setState(() {});
          },
          opacityValue: .3,
        ),
      ),
    );
  }
}
