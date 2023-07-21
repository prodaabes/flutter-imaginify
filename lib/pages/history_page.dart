import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imaginify/db_manager.dart';
import 'package:imaginify/events/my_events.dart';
import 'package:imaginify/my_global.dart';
import 'package:imaginify/my_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    MyGlobal.eventBus.on<UpdateListViewEvent>().listen((event) {
      setState(() {
        //
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: DbManager.records.length,
      itemBuilder: (BuildContext context, int position) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            child: Container(
              color: Colors.black12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child:
                        Image.file(File(DbManager.records[position]['image'])),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DbManager.records[position]['prompt'],
                      style: const TextStyle(
                          color: Colors.black, fontFamily: 'RobotoRegular'),
                    ),
                  ),
                ],
              ),
            ),
            onLongPress: () {
              MyWidgets.showAlertDialog(
                context,
                'Delete',
                'Are you sure you want to delete "${DbManager.records[position]['prompt']}" ?',
                'No',
                () {
                  Navigator.pop(context);
                },
                'Yes',
                () {
                  Navigator.pop(context);
                  DbManager.delete(position);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
