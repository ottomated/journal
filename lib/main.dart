import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(JournalApp());

class JournalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal',
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.dark,
          accentColor: Colors.deepPurpleAccent,
          textSelectionHandleColor: Colors.black),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color color = Color(0xffffffff);
  double colorBrightness = 1.0;
  SharedPreferences prefs;

  TextEditingController text;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    text = TextEditingController();
    init();
    super.initState();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    var str = prefs.getString(todayKey);
    text.value = TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }

  String get todayKey {
    var now = DateTime.now();
    return "journal-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: TextField(
              controller: text,
              autofocus: true,
              maxLines: 100000,
              cursorColor: color,
              style: TextStyle(
                color: color,
              ),
              onChanged: (val) async {
                await prefs.setString(todayKey, val);
              },
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          Container(
            width: 20.0,
            height: height,
            child: GestureDetector(
              onVerticalDragUpdate: (d) async {
                var difference = d.primaryDelta / 100;
                var b = (await Screen.brightness) - difference;
                b = b.clamp(0.0, 1.0).toDouble();
                Screen.setBrightness(b);
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 20.0,
              height: height,
              child: GestureDetector(
                onVerticalDragUpdate: (d) async {
                  var difference = d.primaryDelta / 100;
                  var b = (colorBrightness) - difference;
                  b = b.clamp(0.0, 1.0).toDouble();
                  colorBrightness = b;
                  setState(() {
                    color = color
                        .withRed((255 * b).toInt())
                        .withBlue((255 * b).toInt())
                        .withGreen((255 * b).toInt());
                  });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () {},
        child: Icon(Icons.collections_bookmark),
        foregroundColor: Colors.black,
      ),
    );
  }
}
