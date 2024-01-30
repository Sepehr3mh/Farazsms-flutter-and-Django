import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _numberController = TextEditingController();
  bool _isButtonVisible = false;
  bool isTapped = false;

  @override
  void initState() {
    super.initState();
    _numberController.addListener(_updateButtonVisibility);
  }

  void _updateButtonVisibility() {
    final text = _numberController.text.replaceAll(' ', '');
    if (text.length == 10) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      _isButtonVisible = text.length == 10;
    });
  }

  // تابع برای تولید عدد شش رقمی تصادفی
  String generateRandomSixDigitNumber() {
    var randomNumber = Random().nextInt(900000) + 100000;
    return randomNumber.toString();
  }

  // تابع برای ارسال درخواست به سرور Django
  Future<void> sendRequest() async {
    var url = Uri.parse(
        ''); // Your server address
    try {
      var response = await http.post(
        url,
        body: json.encode({
          'usernumber': _numberController.text,
          'random_number': generateRandomSixDigitNumber() // استفاده از تابع تولید عدد تصادفی
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Request sent successfully');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Message sent successfully"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 350,
              child: TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number',
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(13),
                  NumberInputFormatter(),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (_isButtonVisible)
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onHighlightChanged: (value) {
                  setState(() {
                    isTapped = value;
                  });
                },
                onTap: () {
                  sendRequest(); // فراخوانی تابع ارسال درخواست
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastLinearToSlowEaseIn,
                  height: isTapped ? 55 : 60,
                  width: MediaQuery.of(context).size.width *
                      (isTapped ? 0.85 : 0.90),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(3, 7),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text
        .replaceAll(' ', '')
        .replaceAllMapped(RegExp(r'(\d{3})(?=\d{4})'), (Match m) => '${m[1]} ');
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
