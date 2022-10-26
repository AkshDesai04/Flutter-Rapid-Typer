import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() => runApp(const RapidTyper());

class RapidTyper extends StatelessWidget {
  const RapidTyper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const MyKeyExample(),
      ),
    );
  }
}

class MyKeyExample extends StatefulWidget {
  const MyKeyExample({super.key});

  @override
  State<MyKeyExample> createState() => _MyKeyExampleState();
}

class _MyKeyExampleState extends State<MyKeyExample> {
  Stopwatch stopwatch = Stopwatch();
  String testtext = "two women were fighting over a child";
  String statusText = "Incomplete";
  // The node used to request the keyboard focus.
  final FocusNode _focusNode = FocusNode();
  // The message to display.
  String _message = "", temp = "";
  var char_history = [];
  int IDO = 0;
  final int mi = -1;

  // Focus nodes need to be disposed.
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String getChar(String data) {
    print("Raw data: $data");

    data = data.toLowerCase();

    if (data.indexOf("key ") == 0) data = data[4];
    if (data.indexOf("digit ") == 0) data = data[6];
    if (data.indexOf("numpad ") == 0) data = data[7];
    if (data == 'space') data = ' ';
    if (data == 'comma') data = ',';
    if (data == 'period') data = '.';
    if (data == 'slash') data = '/';
    if (data == 'backslash') data = '\\';
    if (data.indexOf("al") == 0) data = ""; //alt
    if (data.indexOf("sh") == 0) data = ""; //shift
    if (data.indexOf("co") == 0) data = ""; //control
    if (data.indexOf("me") == 0) data = ""; //meta
    if (data.indexOf("en") == 0) data = "\n"; //enter
    if (data.indexOf("ta") == 0) data = ""; //tab

    IDO = char_history.indexOf(data);
    print("outside index = $IDO");

    if (IDO < 0) {
      char_history.add(data);
      if (data == "backspace") {
        //backspace
        _message = _message.substring(0, _message.length - 1);
        return "";
      }
      return data;
    }
    char_history.remove(data);
    if (data == "backspace") return "";
    return "";
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    setState(() {
      if (!kReleaseMode) {
        // As the name implies, the debugName will only print useful
        // information in debug mode.
        temp = getChar('${event.logicalKey.debugName}');
        _message = '$_message' + temp;
        if (_message.toLowerCase() == testtext.toLowerCase()) {
          stopwatch.stop();
          statusText =
              "Done" + (stopwatch.elapsedMilliseconds / 1000).toString();
          print("main:$testtext");
          print("curr:$_message");
        } else
          statusText = "Incomplete";
      }
    });
    return event.logicalKey == LogicalKeyboardKey.keyQ
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double min_hw = min(height, width);
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(min_hw * 0.25),
        child: DefaultTextStyle(
          style: textTheme.headline4!,
          child: Focus(
            focusNode: _focusNode,
            onKey: _handleKeyEvent,
            child: AnimatedBuilder(
              animation: _focusNode,
              builder: (BuildContext context, Widget? child) {
                if (!_focusNode.hasFocus) {
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(_focusNode);
                      //stopwatch start
                      stopwatch.start();
                    },
                    child: const Text(
                      "Let's Get Started\nClick Here",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(testtext)),
                    Text(
                      _message,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      statusText,
                    ),
                  ],
                );
                // return RichText(
                //   text: TextSpan(
                //     children: textspans,
                //   ),
                // );
              },
            ),
          ),
        ),
      ),
    );
  }
}
