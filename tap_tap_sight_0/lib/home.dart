import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: _changeView
          ? Center(
              child: ClipOval(
                child: Material(
                  color: Colors.amberAccent, // button color
                  child: InkWell(
                    splashColor: Colors.redAccent, // inkwell color
                    child: SizedBox(
                        width: 50, height: 50, child: Icon(Icons.camera)),
                    onTap: () {
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
                    _model),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Material(
                        color: Colors.redAccent, // button color
                        child: InkWell(
                          splashColor: Colors.amberAccent, // inkwell color
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.arrow_back_ios_outlined)),
                          onTap: () {
                            onChangeView();
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
