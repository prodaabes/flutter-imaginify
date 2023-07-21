import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imaginify/events/my_events.dart';
import 'package:imaginify/models/generated.dart';
import 'package:imaginify/my_global.dart';

class DbManager {

  static GeneratedProvider generatedProvider = GeneratedProvider();

  static List<Map<dynamic, dynamic>> records = [];

  static void getAllRecords() async {
    if (generatedProvider.db == null) {
      await generatedProvider.open('imaginify_db.db');
    }
    final list = await generatedProvider.getAll();
    records.addAll(list);
  }

  static void insert(Generated generated) async {
    if (generatedProvider.db == null) {
      await generatedProvider.open('imaginify_db.db');
    }
    Generated generated2 = await generatedProvider.insert(generated);
    records.insert(0, generated2.toMap());
    MyGlobal.eventBus.fire(UpdateListViewEvent());
  }

  static void delete(int position) async {
    if (generatedProvider.db == null) {
      await generatedProvider.open('imaginify_db.db');
    }
    Map<dynamic, dynamic> map = records[position];
    await generatedProvider.delete(map['_id']);

    File file = File(map['image']);
    file.delete();

    records.removeAt(position);
    MyGlobal.eventBus.fire(UpdateListViewEvent());
  }
}