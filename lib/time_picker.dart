import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimePicker extends StatefulWidget {
  final double deviceWidth;
  final double deviceHeight;


  const TimePicker({super.key,
    required this.deviceWidth,
    required this.deviceHeight});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  bool isMinuteFocused = false;
  bool isHourFocused = false;
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double inputWidth = widget.deviceWidth * 0.25;
    double inputHeight = widget.deviceHeight * 0.09;
    double containerHeight = widget.deviceHeight * 0.12;
    double containerWidth = widget.deviceWidth * 0.35;
    double gapWidth = widget.deviceWidth * 0.05;
    double gapHeight = widget.deviceHeight * 0.07;
    return MaterialApp(
      home: AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'ENTER TIME',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              int result = 0;
              debugPrint("Result: $result");
              Navigator.of(context).pop(result);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blue
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              int result = 0;
              try {
                if (hourController.text.isEmpty && minuteController.text.isEmpty){
                  result = 0;
                } else if (hourController.text.isEmpty){
                  result = int.parse(minuteController.text) * 60;
                } else if (minuteController.text.isEmpty){
                  result = int.parse(hourController.text) * 3600;
                } else {
                  result = (int.parse(hourController.text) * 3600) + int.parse(minuteController.text) * 60;
                }
                debugPrint("Result: $result");
              } catch (e) {
                debugPrint("Error: $e");
              }
              Navigator.of(context).pop(result);
            },
            child: const Text(
              'Set',
              style: TextStyle(
                color: Colors.blue
              ),
            ),
          ),
        ],
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: containerHeight,
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: isHourFocused ? Colors.blue.withOpacity(0.5) : Colors.black.withOpacity(0.4),
                            width: 1.5,
                          ),
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      height: inputHeight,
                      width: inputWidth,
                      child: Focus(
                        autofocus: false,
                        onFocusChange: (hasFocus) {
                          setState(() {
                            isHourFocused = hasFocus;
                          });
                        },
                        child: TextFormField(
                          controller: hourController,
                          decoration: const InputDecoration(
                              border: InputBorder.none
                          ),
                          showCursor: false,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 60),
                        ),
                      )
                  ),
                  const Text(
                    'Hour',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: containerHeight,
              width: gapWidth,
              child: const Text(
                ':',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
            ),
            SizedBox(
              height: containerHeight,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isMinuteFocused ? Colors.blue.withOpacity(0.5) : Colors.black.withOpacity(0.4),
                        width: 1.5,
                      ),
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: inputHeight,
                    width: inputWidth,
                    child: Focus(
                      autofocus: false,
                      onFocusChange: (hasFocus) {
                        setState(() {
                          isMinuteFocused = hasFocus;
                        });
                      },
                      child: TextFormField(
                        controller: minuteController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        showCursor: false,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const Text(
                    'Minute',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
