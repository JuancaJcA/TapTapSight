import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";
  bool _changeView = true;
  bool _buttonTap = false;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
  }

  Future _speak(String txt) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    GoogleTranslator translator = GoogleTranslator();
    var result = await translator.translate(txt, from: 'en', to: 'es');
    await flutterTts.speak(result.toString());
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: _changeView
          ? Center(
              child: ClipOval(
                child: Material(
                  color: Colors.white, // button color
                  child: InkWell(
                    splashColor: Color(0xFF96939F), // inkwell color
                    highlightColor:Colors.white.withOpacity(.3),
                    borderRadius: BorderRadius.circular(30),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.camera,color: Colors.black54),
                    ),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onSelect(ssd);
                      onChangeView();
                    },
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                Container(
                  width: screen.width,
                  height: screen.height - 200,
                  child: Camera(
                    widget.cameras,
                    _model,
                    setRecognitions,
                  ),
                ),
                // Camera(
                //   widget.cameras,
                //   _model,
                //   setRecognitions,
                // ),
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height - 200,
                    screen.width,
                    _model,
                    _buttonTap),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ClipOval(
                      child: Material(
                        color:Color(0xFF227B81),
                        child: InkWell(
                          splashColor: Color(0xFF154D51),
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.arrow_back_ios_outlined)),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            onChangeView();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ClipOval(
                      child: Material(
                        color: Color(0xFFD9BB6D), // button color
                        child: InkWell(
                          splashColor: Color(0xFFB28D2E),
                          highlightColor:Colors.white.withOpacity(.5),
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.speaker_phone_sharp)),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            onChangeButton();
                            String textSpeech = "";
                            for (var i = 0; i < _recognitions.length; i++) {
                              String txt = "";
                              var detectedTxt =
                                  _recognitions[i]["detectedClass"];
                              var detectedConf =
                                  _recognitions[i]["confidenceInClass"];
                              txt += detectedTxt.toString() +
                                  detectedConf.toString();
                              print(txt);
                              if (detectedConf > 0.50) {
                                textSpeech +=
                                    _recognitions[i]["detectedClass"] + ",";
                              }
                            }
                            _speak(textSpeech);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  loadModel() async {
    String res;
    res = await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
    print(res);
  }

  onSelect(model) {
    setState(
      () {
        _model = model;
      },
    );
    loadModel();
  }

  onChangeView() {
    setState(
      () {
        _changeView = !_changeView;
        print(_changeView);
      },
    );
  }

  onChangeButton() {
    setState(
      () {
        _buttonTap = !_buttonTap;
      },
    );
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(
      () {
        _recognitions = recognitions;
        _imageHeight = imageHeight;
        _imageWidth = imageWidth;
      },
    );
  }
}
