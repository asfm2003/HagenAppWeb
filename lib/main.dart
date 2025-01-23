import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

const kGradientStartColor = Color(0xFFC21E1E);
const kGradientMiddleColor = Color(0xFF450000);
const kGradientEndColor = Color(0xFF000000);

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures async operations are complete before app launch
  await AppData.initialize(); // Fetch all contacts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

// Gradient Background Utility
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            kGradientStartColor,
            kGradientMiddleColor,
            kGradientEndColor,
            Colors.white
          ],
          stops: [0.0, 0.5, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  String _targetLanguage = 'de'; // Default to German

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      TranslationPage(targetLanguage: _targetLanguage),
      const ProfilePage(),
      const SettingsPage(),
      const ContactPage(),
    ];
  }

  void _updateLanguage(String newLanguage) {
    setState(() {
      _targetLanguage = newLanguage;
      _pages[1] = TranslationPage(targetLanguage: _targetLanguage);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.translate), label: "Translate"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
            BottomNavigationBarItem(
                icon: Icon(Icons.contact_page), label: "Contact"),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF603032),
          unselectedItemColor: const Color(0xFF3a3939),
          backgroundColor: const Color(0xFFfcf7f8), // Changed color to black
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top gradient background
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Information",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30, // Increased font size for a heading effect
                    fontWeight: FontWeight.bold, // Bold text for emphasis
                  ),
                ),
              ),
            ),
          ),
          // Bottom section with rounded corners
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Party Info Card
                    _buildInfoCard(
                      "Today: Party in FH2",
                      '../assets/party_placeholder.jpeg',
                    ),
                    const SizedBox(height: 10),
                    // Other Info Card
                    _buildInfoCard(
                      "Other info",
                      '../assets/party_placeholder.jpeg',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _NavigationButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key, required this.targetLanguage});

  final String targetLanguage;

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _inputController = TextEditingController();
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();
  String? _translatedText;
  List<String>? _recommendations;
  Timer? _debounce;

  final String _sourceLanguage = 'en';
  late String _targetLanguage;

  @override
  void initState() {
    super.initState();
    _targetLanguage = widget.targetLanguage;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _translateText(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final translation = await translator.translate(text,
            from: _sourceLanguage, to: _targetLanguage);
        setState(() {
          _translatedText = translation.text;
        });
      } catch (e) {
        setState(() {
          _translatedText = "Error during translation: $e";
        });
      }
    });
  }

  Future<void> _fetchRecommendations(String prompt) async {
    try {
      final responses = await fetchChatGPTResponses(prompt);
      setState(() {
        _recommendations = responses;
      });
    } catch (e) {
      setState(() {
        _recommendations = ['Error fetching recommendations: $e'];
      });
    }
  }

  Future<void> _playVoice(String text) async {
    await flutterTts.setLanguage(_targetLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return splitBackgroundWithOverlay(
      context: context,
      centerDown: MediaQuery.of(context).size.height * 0.0001,
      middleSectionMaxHeight: 0.105,
      extraPlaceholder: MediaQuery.of(context).size.height * 0.03,
      topChild: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Translator",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      middleChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _inputController,
                onChanged: (text) => _translateText(text),
                decoration: InputDecoration(
                  labelText: 'Enter text to translate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomChild: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16, width: double.infinity),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFfef7ff),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Color(0xFF635d65)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _translatedText ?? 'Translation will appear here',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => _playVoice(_translatedText ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchRecommendations(_translatedText ?? ''),
                child: const Text('Get Recommendations'),
              ),
              if (_recommendations != null)
                ..._recommendations!.asMap().entries.map(
                      (entry) => Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFfef7ff),
                          border: Border.all(color: const Color(0xFF635d65)),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _playVoice(entry.value),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

Widget splitBackgroundWithOverlay({
  required BuildContext context,
  required Widget topChild,
  required Widget middleChild,
  required Widget bottomChild,
  middleSectionMaxHeight = 0.1,
  dynamic extraPlaceholder = 0.0,
  centerDown = 0.0,
}) {
  return Stack(
    children: [
      // Top and Bottom Backgrounds
      Column(
        children: [
          // Top Part
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFb42120), Colors.black],
              ),
            ),
            child: topChild, // Content in the top section
          ),
          // Break
          Container(
            color: const Color(0xFFdbd5d5),
            height: MediaQuery.of(context).size.height *
                    middleSectionMaxHeight /
                    2 +
                extraPlaceholder,
          ),
          // Bottom Part
          Expanded(
            child: Container(
              color: Color(0xFFdbd5d5),
              child: bottomChild, // Content in the bottom section
            ),
          ),
        ],
      ),
      // Middle Section
      Align(
        alignment: Alignment(0.0, centerDown - 0.4),
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * middleSectionMaxHeight,
            minHeight: MediaQuery.of(context).size.height * 0.07,
          ),
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
            color: const Color(0xFFf8f4f4),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: middleChild, // Middle section content
        ),
      ),
    ],
  );
}

// ChatGPT API Integration
Future<List<String>> fetchChatGPTResponses(String prompt) async {
  final apiKey =
      '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'; // Replace with your actual API key
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant.'},
        {
          'role': 'user',
          'content':
              'I want you to give me a response recommendation for the following question in its language. Im a tourist and i want to respond to that question. Give me only the answer without comment. Always give me only one answer but if i ask the same question change your answer $prompt'
        },
      ],
      'max_tokens': 150,
      'n': 3,
      'temperature': 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(
        data['choices'].map((choice) => choice['message']['content'].trim()));
  } else {
    throw Exception('Failed to fetch response from API');
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> countries = [
    "USA",
    "Germany",
    "Turkey",
    "France",
    "Spain"
  ];
  final List<String> genders = [
    "Male",
    "Female",
    "Non-binary",
    "Transgender",
    "Prefer not to say"
  ];
  final List<String> languages = [
    "English",
    "German",
    "Turkish",
    "Spanish",
    "French"
  ];

  File? _profileImage;
  int _selectedAge = 20;
  String _selectedGender = "Prefer not to say";
  String _selectedCountry = "USA";
  String _selectedLanguage = "English";
  String _studentName = "Student Name";

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('name') ?? "Student Name";
      _selectedAge = prefs.getInt('age') ?? 20;
      _selectedGender = prefs.getString('gender') ?? "Prefer not to say";
      _selectedCountry = prefs.getString('country') ?? "USA";
      _selectedLanguage = prefs.getString('language') ?? "English";
    });
  }

  Future<void> _saveProfileData() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _studentName);
    await prefs.setInt('age', _selectedAge);
    await prefs.setString('gender', _selectedGender);
    await prefs.setString('country', _selectedCountry);
    await prefs.setString('language', _selectedLanguage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _editName() async {
    _nameController.text = _studentName;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: "Enter your name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _studentName = _nameController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return splitBackgroundWithOverlay(
      middleSectionMaxHeight: 0.2,
      context: context,
      topChild: const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Profile",
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      middleChild: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade500,
              backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Text(
                  _studentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: _editName,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomChild: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              crossAxisCount: 2, // Two items per row
              crossAxisSpacing: 16, // Horizontal spacing
              mainAxisSpacing: 16, // Vertical spacing
              shrinkWrap: true, // Allow the GridView to adapt its height
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio:
                  2, // Adjust aspect ratio for better sizing (e.g., 2.5:1 for width to height)
              children: [
                _buildGridContainer(
                  height: 150,
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAgePicker(),
                  ),
                ),
                _buildGridContainer(
                  height: 150,
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDropdownField(
                        "Gender", genders, _selectedGender, (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    }),
                  ),
                ),
                _buildGridContainer(
                  height: 150,
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDropdownField(
                        "Country", countries, _selectedCountry, (value) {
                      setState(() {
                        _selectedCountry = value!;
                      });
                    }),
                  ),
                ),
                _buildGridContainer(
                  height: 150,
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDropdownField(
                        "Language", languages, _selectedLanguage, (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    }),
                  ),
                ),
              ],
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  onPressed: _saveProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf8f4f4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save",
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContainer(
      {required Widget child, required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildDropdownField(String label, List<String> options,
      String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAgePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Age",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<int>(
          value: _selectedAge,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: List.generate(
            100,
            (index) => DropdownMenuItem(
              value: index + 1,
              child: Text("${index + 1}"),
            ),
          ).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAge = value!;
            });
          },
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isHelpExpanded = false;

  void _toggleHelpSection() {
    setState(() {
      _isHelpExpanded = !_isHelpExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return splitBackgroundWithOverlay(
      context: context,
      topChild: const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Settings",
            style: TextStyle(
              color: Color(0xFFf8f4f4),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      middleChild: Container(
        alignment: Alignment.center,
        child: const Text(
          "Account Settings",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      bottomChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionButton('Language', () {
              // TODO: Implement Account Settings
            }),
            _buildSectionButton('Help', _toggleHelpSection),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Contact: tensorenes@gmail.com',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
              crossFadeState: _isHelpExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Map<String, String> _emergencyContacts;
  late Map<String, String> _everydayContacts;
  late Map<String, String> _universityContacts;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    _emergencyContacts = AppData.emergencyContacts;
    _everydayContacts = AppData.everydayContacts;
    _universityContacts = AppData.universityContacts;
  }

  @override
  Widget build(BuildContext context) {
    return splitBackgroundWithOverlay(
      context: context,
      topChild: const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Contacts",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      middleChild: Container(
        alignment: Alignment.center,
        child: const Text(
          "Important contacts categorized for easy access.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      bottomChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Emergency Contacts', _emergencyContacts),
              const SizedBox(height: 20),
              _buildSection('Everyday Contacts', _everydayContacts),
              const SizedBox(height: 20),
              _buildSection('University Contacts', _universityContacts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Map<String, String> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...contacts.entries.map(
          (entry) => Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              title: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                entry.value,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () {
                  // TODO: Implement call functionality
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppData {
  static Map<String, String> emergencyContacts = {};
  static Map<String, String> everydayContacts = {};
  static Map<String, String> universityContacts = {};

  static const String fallbackContactMessage =
      "Fetching failed. Please contact tensorenes@gmail.com.";

  /// Initialize all contacts at app startup
  static Future<void> initialize() async {
    try {
      emergencyContacts = await fetchEmergencyContactsAsync();
      everydayContacts = await fetchEverydayContactsAsync();
      universityContacts = await fetchUniversityContactsAsync();
    } catch (e) {
      print("Error fetching contacts: $e");
      // Provide fallback data
      emergencyContacts = _fallbackEmergencyContacts();
      everydayContacts = _fallbackEverydayContacts();
      universityContacts = _fallbackUniversityContacts();
    }
  }

  static Future<Map<String, String>> fetchEmergencyContactsAsync() async {
    return {
      'Hospital': '+1 800 123 456',
      'Fire Brigade': '+1 800 789 101',
      'Police': '+1 800 911 000',
    };
  }

  static Future<Map<String, String>> fetchEverydayContactsAsync() async {
    return {
      "Doctor's Office": '+1 800 654 321',
      "Dentist": '+1 800 987 654',
    };
  }

  static Future<Map<String, String>> fetchUniversityContactsAsync() async {
    const fallbackContacts = {
      'Mag. Christina Huber-Beran': '+43 5 0804 21530',
      'Barbara Gotschi': '+43 5 0804 21533',
      'Fallback Note':
          'Please contact tensorenes@gmail.com for more assistance.'
    };

    try {
      final dio = Dio();
      final response = await dio.get(
          'https://fh-ooe.at/international/international-office-hagenberg');

      if (response.statusCode == 200) {
        final document = parse(response.data);
        final contacts = <String, String>{};

        final nameElements = document.querySelectorAll('h3.c-headline');
        for (var nameElement in nameElements) {
          final name = nameElement.text.trim();
          final phoneElement =
              nameElement.parent?.querySelector('a[href^="tel:"]');
          final phone =
              phoneElement?.attributes['href']?.replaceFirst('tel:', '').trim();

          if (name.isNotEmpty && phone != null) {
            contacts[name] = phone;
          }
        }

        return contacts.isNotEmpty ? contacts : fallbackContacts;
      } else {
        return fallbackContacts;
      }
    } catch (e) {
      print("Error fetching university contacts: $e");
      return fallbackContacts;
    }
  }

  static Map<String, String> _fallbackEmergencyContacts() {
    return {
      'Hospital': fallbackContactMessage,
      'Fire Brigade': fallbackContactMessage,
      'Police': fallbackContactMessage,
    };
  }

  static Map<String, String> _fallbackEverydayContacts() {
    return {
      "Doctor's Office": fallbackContactMessage,
      "Dentist": fallbackContactMessage,
    };
  }

  static Map<String, String> _fallbackUniversityContacts() {
    return {
      'International Office': fallbackContactMessage,
    };
  }
}
