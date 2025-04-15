import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<Map<String, dynamic>?> fetchVerseOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Retrieve saved date and IDs from SharedPreferences
    String? savedDate = prefs.getString('verse_date');
    int? savedChapter = prefs.getInt('verse_chapter');
    int? savedVerse = prefs.getInt('verse_number');

    print("Lol");

    // If saved date is today and we have valid saved chapter and verse
    if (savedDate == today && savedChapter != null && savedVerse != null) {
      final savedVerseData = await _fetchVerse(savedChapter, savedVerse);
      if (savedVerseData != null) return savedVerseData;
    }

    // If no valid saved date or IDs, try generating new ones (up to 5 attempts)
    final random = Random();
    for (int i = 0; i < 5; i++) {
      int newChapter = random.nextInt(18) + 1;
      int newVerse = random.nextInt(50) + 1;

      final newVerseData = await _fetchVerse(newChapter, newVerse);
      if (newVerseData != null) {
        // Save new date and IDs in SharedPreferences
        await prefs.setString('verse_date', today);
        await prefs.setInt('verse_chapter', newChapter);
        await prefs.setInt('verse_number', newVerse);
        return newVerseData;
      }
    }

    return null; // If all attempts fail
  }

  Future<Map<String, dynamic>?> _fetchVerse(int chapter, int verse) async {
    print("IDs");
    print({chapter, verse});
    const headers = {
      "X-RapidAPI-Key": "ab3f75ae48msh7e33c4ccfdceca9p134952jsn5a740b661b0b",
      "X-RapidAPI-Host": "bhagavad-gita3.p.rapidapi.com"
    };

    final url = Uri.parse("https://bhagavad-gita3.p.rapidapi.com/v2/chapters/$chapter/verses/$verse/");
    final response = await http.get(url, headers: headers);

    print('Requesting chapter $chapter, verse $verse');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['text'] != null) {
        return {
          "chapter": chapter,
          "verse": verse,
          "text": data['text'],
          "transliteration": data['transliteration'],
          "translation": data['translations'] != null && data['translations'].isNotEmpty
              ? data['translations'][0]['description']
              : 'Translation not available'
        };
      }
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        title: Text(
          "Bhagavad Gita",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    "images/bg.png",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Experience the Gita",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        "Anytime, Anywhere",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE36E00),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        child: const Text(
                          "Read Now",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            FutureBuilder<Map<String, dynamic>?>(
              future: fetchVerseOfTheDay(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                          color: Colors.white,
                          child: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verse of the day -",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFFE36E00),
                              ),
                            ),
                            Text(
                              "Chapter ${data['chapter']}, Verse ${data['verse']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF323232),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data['translation'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: (){},
                                    child: Text("See More", style: TextStyle(color: Color(0xFFE36E00)),)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No verse found. Try again later."),
                  );
                }
              },
            ),


          ],
        ),
      ),

    );
  }
}
