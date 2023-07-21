import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imaginify/ads_manager.dart';
import 'package:imaginify/api.dart';
import 'package:imaginify/db_manager.dart';
import 'package:imaginify/events/my_events.dart';
import 'package:imaginify/my_widgets.dart';
import 'package:imaginify/pages/generate_page.dart';
import 'package:imaginify/pages/history_page.dart';
import 'package:imaginify/my_colors.dart';
import 'package:imaginify/my_global.dart';
import 'package:intl/intl.dart' as intl;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formatter = intl.NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();

    fetchRemoteConfig();
    getUserData();
    AdsManager.loadRewardedAd();
    DbManager.getAllRecords();

    MyGlobal.eventBus.on<UpdateCoinsEvent>().listen((event) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          surfaceVariant: Colors.transparent,
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                myAppBar(),
                Material(
                  child: Container(
                    height: 60,
                    color: MyColors.zircon,
                    child: TabBar(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      unselectedLabelColor: MyColors.bismark,
                      labelColor: MyColors.zircon,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: MyColors.bismark),
                      indicatorColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: MyColors.bismark, width: 1)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Generate"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: MyColors.bismark, width: 1)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("History"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: const TabBarView(
                      children: [GeneratePage(), HistoryPage()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget myAppBar() {
    return Container(
      height: 55,
      color: MyColors.zircon,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'Imaginify',
              style: TextStyle(
                  color: MyColors.bismark, fontFamily: 'RobotoMedium'),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: SizedBox(
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'images/coins.png',
                        scale: 7.0,
                        color: MyColors.bismark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatter.format(MyGlobal.userCoins),
                        style: TextStyle(
                            color: MyColors.bismark,
                            fontFamily: 'RobotoMedium'),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                final text =
                    'You have ${MyGlobal.userCoins} coins.\nWatch a video and get ${MyGlobal.rewardCoins} free coins !';
                MyWidgets.showAlertDialog(
                    context,
                    'Coins',
                    text,
                    'Cancel',
                    () {
                      Navigator.pop(context);
                    },
                    'Watch Now',
                    () {
                      Navigator.pop(context);

                      if (AdsManager.isRewardedAdReady) {
                        AdsManager.showRewardedAd((ad, item) {
                          final coins = item.amount.toInt();
                          API.increaseUserCoins(coins);

                          setState(() {
                            MyGlobal.userCoins += item.amount.toInt();
                          });
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Video ad not available right now')));
                      }
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  void fetchRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    bool isActivated = await remoteConfig.fetchAndActivate();
    if (isActivated) {
      MyGlobal.openaiKey = remoteConfig.getString('openai_key');
      MyGlobal.rewardCoins = remoteConfig.getInt('reward_coins');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('An error occurred')));
    }
  }

  void getUserData() async {
    final coins = await API.getUserData();
    setState(() {
      MyGlobal.userCoins = coins;
    });
  }
}
