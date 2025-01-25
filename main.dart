import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool hasData = prefs.getString('username') != null;
  runApp(MyApp(initialPage: hasData ? HomePage() : LoginPage()));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  MyApp({required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifestyle360',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightGreen,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.teal.shade900),
        ),
      ),
      home: initialPage,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _healthInfoController = TextEditingController();
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _welcomeMessage();
  }

  Future<void> _welcomeMessage() async {
    await flutterTts.speak(
      "Welcome to Lifestyle360. Please log in and provide your details.",
    );
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('gender', _genderController.text);
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('occupation', _occupationController.text);
    await prefs.setString('hobbies', _hobbiesController.text);
    await prefs.setString('healthInfo', _healthInfoController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lifestyle360 - Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter Your Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ..._buildTextFields(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    'Save and Continue',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTextFields() {
    return [
      _buildTextField(_usernameController, 'Username'),
      _buildTextField(_ageController, 'Age', TextInputType.number),
      _buildTextField(_genderController, 'Gender'),
      _buildTextField(_weightController, 'Body Weight', TextInputType.number),
      _buildTextField(_occupationController, 'Occupation'),
      _buildTextField(_hobbiesController, 'Hobbies'),
      _buildTextField(_healthInfoController, 'Health Information'),
    ];
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String activity = "Loading...";
  late FlutterTts flutterTts;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? "";
      final age = prefs.getString('age') ?? "";
      final gender = prefs.getString('gender') ?? "";
      final weight = prefs.getString('weight') ?? "";
      final occupation = prefs.getString('occupation') ?? "";
      final hobbies = prefs.getString('hobbies') ?? "";
      final healthInfo = prefs.getString('healthInfo') ?? "";

      final timeNow = DateFormat('h:mm a').format(DateTime.now());

      final response = await http.post(
        Uri.parse(
            'https://ccfa4c30-1823-4031-bab9-90f88b5302e8-00-341f3sxlc30fy.pike.replit.dev/data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'age': age,
          'gender': gender,
          'weight': weight,
          'occupation': occupation,
          'hobbies': hobbies,
          'healthInfo': healthInfo,
          'time': timeNow,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          activity = data[0]['description'];
        });
      } else {
        setState(() {
          activity = "Failed to load data!";
        });
      }
    } catch (e) {
      setState(() {
        activity = "Error: ${e.toString()}";
      });
    }
  }

  void _toggleSpeech() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(activity);
      setState(() {
        isSpeaking = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lifestyle360 - Home'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSpeech,
        backgroundColor: Colors.teal,
        child: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Text(
              activity,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
