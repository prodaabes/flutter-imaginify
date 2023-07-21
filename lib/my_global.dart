import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyGlobal {

  static EventBus eventBus = EventBus();
  static String openaiKey = "";
  static int rewardCoins = 0;
  static int userCoins = 0;

  static SharedPreferences? prefs;
}