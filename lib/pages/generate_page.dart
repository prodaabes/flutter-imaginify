import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:imaginify/ads_manager.dart';
import 'package:imaginify/db_manager.dart';
import 'package:imaginify/events/my_events.dart';
import 'package:imaginify/models/generated.dart';
import 'package:imaginify/my_global.dart';
import 'package:imaginify/my_widgets.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import '../api.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

class GeneratePage extends StatefulWidget {
  const GeneratePage({Key? key}) : super(key: key);

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage>
    with SingleTickerProviderStateMixin {
  GlobalKey mainKey = GlobalKey();

  final TextEditingController promptController = TextEditingController();

  late AnimationController animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);
  late Animation<double> animation =
      CurvedAnimation(parent: animationController, curve: Curves.easeIn);

  bool _isActionButtonsVisible = false;

  File? _displayImage;
  bool _isDownloading = false;
  String _url = '';

  String promptCostText = "This prompt will cost you 1 coins";

  String _warningMessage = """
Please be aware that while Imaginify strives to deliver amazing and imaginative results, the generated images may not always be entirely accurate representations of your prompts. Our AI-driven system is constantly evolving, and its creative interpretations can lead to diverse and unexpected outcomes.

Embrace the artistic possibilities and enjoy the unique surprises that Imaginify has to offer. Remember, the real magic lies in the journey of exploration and creativity!

Happy Imagining! 🎨✨
""";

  String shareText = """
Check out this amazing image generated with Imaginify! ✨🎨

Unleash your imagination with Imaginify - the app that brings your ideas to life. Create stunning visuals from simple prompts.
  
Download now: https://imaginify-f55b4.web.app/
""";

  String noCoinsText = """
Sorry, you don\'t have enough coins to send this request.
Watch a video and get ${MyGlobal.rewardCoins} free coins !
""";

  @override
  void initState() {
    super.initState();

    promptController.addListener(() {
      int length = promptController.text.trim().length;
      int cost = (length / 4).ceil();

      setState(() {
        promptCostText = "This prompt will cost you $cost coins.";
      });
    });
  }

  @override
  void dispose() {
    promptController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 145,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Visibility(
                        visible: _isDownloading,
                        child: Center(
                          child: SizedBox(
                            width: 200,
                            child: FadeTransition(
                              opacity: animation,
                              child: Image.asset('images/imaginify_logo.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Visibility(
                        visible: _displayImage != null,
                        // child: FadeInImage.memoryNetwork(
                        //   placeholder: kTransparentImage,
                        //   image: imgUrl,
                        //   fit: BoxFit.cover,
                        // ),
                        child: _displayImage != null
                            ? Image.file(_displayImage!)
                            : Image.memory(kTransparentImage),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isActionButtonsVisible,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Share.shareXFiles([XFile(_displayImage!.path)],
                              text: shareText);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        child: const Icon(Icons.share),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          bool? isSaved = await GallerySaver.saveImage(
                              _displayImage!.path,
                              albumName: 'Imaginify');
                          if (isSaved == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image saved')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('An error occurred')));
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        child: const Icon(Icons.save_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: Visibility(
                  visible: promptController.text.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      promptCostText,
                      style: TextStyle(
                          fontFamily: 'RobotoLight', color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: _isDownloading ? 0.3 : 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: _isDownloading,
                        controller: promptController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'What do you imagine',
                          isDense: true,
                          contentPadding: EdgeInsets.all(15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(14),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Image.asset('images/send.png'),
                          ),
                        ),
                        onTap: (_isDownloading ||
                                promptController.text.trim().isEmpty)
                            ? null
                            : () async {
                                int length =
                                    promptController.text.trim().length;
                                int cost = (length / 4).ceil();

                                if (MyGlobal.userCoins < cost) {
                                  MyWidgets.showAlertDialog(
                                    context,
                                    'Alert',
                                    noCoinsText,
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

                                          MyGlobal.userCoins += item.amount.toInt();
                                          MyGlobal.eventBus.fire(UpdateCoinsEvent());
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content:
                                                Text('Video ad not available right now')));
                                      }
                                    },
                                  );
                                  return;
                                }

                                showWarningMessage(context);

                                setState(() {
                                  _isDownloading = true;
                                  _isActionButtonsVisible = false;
                                  _displayImage = null;
                                });

                                final userCoins = await API.getUserCoins();
                                if (userCoins >= cost) {
                                  API.decreaseUserCoins(cost);

                                  MyGlobal.userCoins -= cost;
                                  MyGlobal.eventBus.fire(UpdateCoinsEvent());

                                  var response = await API.generateImage(
                                      promptController.text.trim());

                                  if (response.statusCode == 200) {
                                    final responseBody =
                                        json.decode(response.body);
                                    final data = responseBody['data'];

                                    String url = data[0]['url'];

                                    _url = url;
                                    _download();
                                  } else {
                                    API.increaseUserCoins(cost);

                                    MyGlobal.userCoins += cost;
                                    MyGlobal.eventBus.fire(UpdateCoinsEvent());

                                    if (response.statusCode == 400) {
                                      final responseBody =
                                          json.decode(response.body);
                                      final error = responseBody['error'];

                                      setState(() {
                                        _isDownloading = false;
                                        _isActionButtonsVisible = false;
                                      });

                                      MyWidgets.showAlertDialog(context,
                                          'Alert', error['message'], 'OK', () {
                                        Navigator.pop(context);
                                      }, null, null);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('An error occurred')));

                                      setState(() {
                                        _isDownloading = false;
                                        _isActionButtonsVisible = false;
                                      });
                                    }
                                  }
                                } else {
                                  setState(() {
                                    _isDownloading = false;
                                    _isActionButtonsVisible = false;
                                  });

                                  MyWidgets.showAlertDialog(
                                      context,
                                      'Alert',
                                      'Sorry, you don\'t have enough coins to send this request.',
                                      'OK', () {
                                    Navigator.pop(context);
                                  }, null, null);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;

  Future<void> _download() async {
    final response = await http.get(Uri.parse(_url));

    // Get the image name
    //final imageName = path.basename(_url);
    DateTime now = DateTime.now();
    String formatted = DateFormat('yyyyMMdd_HHmmssms').format(now);
    String imageName = "$formatted.png";

    // Get the document directory path
    final appDir = await path_provider.getApplicationDocumentsDirectory();

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);

    // Download the image
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);

    setState(() {
      _isDownloading = false;
      _isActionButtonsVisible = true;
      _displayImage = imageFile;
    });

    // insert to database

    Map<String, Object?> map = HashMap();
    map['prompt'] = promptController.text;
    map['image'] = localPath;

    Generated generated = Generated.fromMap(map);
    DbManager.insert(generated);
  }

  void showWarningMessage(BuildContext context) {
    bool? isLoggedInBefore = MyGlobal.prefs?.getBool('isWarningAppeared');
    if (isLoggedInBefore == null || isLoggedInBefore == false) {
      MyWidgets.showAlertDialog(
          context,
          "⚠️ Caution: Imaginify's Results May Vary ⚠️",
          _warningMessage,
          'OK', () async {
        Navigator.of(context).pop();
        await MyGlobal.prefs
            ?.setBool('isWarningAppeared', true);
      }, null, null);
    }
  }
}
