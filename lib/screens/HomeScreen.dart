import 'dart:convert';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SingleChapterScreen.dart';
import 'VerseScreen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onReadNowPressed;

  const HomeScreen({super.key, required this.onReadNowPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>?> fetchVerseOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String? savedDate = prefs.getString('verse_date');
    int? savedChapter = prefs.getInt('verse_chapter');
    int? savedVerse = prefs.getInt('verse_number');

    print("Lol");

    if (savedDate == today && savedChapter != null && savedVerse != null) {
      final savedVerseData = await _fetchVerse(savedChapter, savedVerse);
      if (savedVerseData != null) return savedVerseData;
    }

    final random = Random();
    for (int i = 0; i < 5; i++) {
      int newChapter = random.nextInt(18) + 1;
      int newVerse = random.nextInt(50) + 1;

      final newVerseData = await _fetchVerse(newChapter, newVerse);
      if (newVerseData != null) {
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

    final url = Uri.parse(
        "https://bhagavad-gita3.p.rapidapi.com/v2/chapters/$chapter/verses/$verse/");
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
          "translation":
              data['translations'] != null && data['translations'].isNotEmpty
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
        scrolledUnderElevation: 0,
        title: Text(
          "Bhagavad Gita",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: CupertinoColors.white,
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                isScrollControlled: true,
                builder: (context) {
                  final chapterController = TextEditingController();
                  final verseController = TextEditingController();

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Search Chapter / Verse",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                        const SizedBox(height: 20),
                        TextField(
                          controller: chapterController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Chapter Number",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: verseController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Verse Number (optional)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            final chapterText = chapterController.text.trim();
                            final verseText = verseController.text.trim();

                            if (chapterText.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Please enter a chapter number")),
                              );
                              return;
                            }

                            final chapter = int.tryParse(chapterText);
                            final verse = int.tryParse(verseText);

                            if (chapter == null ||
                                chapter < 1 ||
                                chapter > 18) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Enter a valid chapter (1–18)")),
                              );
                              return;
                            }

                            Navigator.pop(context); // Close bottom sheet

                            if (verseText.isEmpty) {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => SingleChapterScreen(
                                    chapterId: chapter,
                                  ),
                                ),
                              );
                            } else {
                              if (verse == null || verse < 1 || verse > 78) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Enter a valid verse number")),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => VerseScreen(
                                    chapterId: chapter,
                                    verseId: verse,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE36E00),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          child: Text(
                            "Search",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
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
                      Text(
                        "Experience the Gita",
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Anytime, Anywhere",
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: widget.onReadNowPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE36E00),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        child: Text(
                          "Read Now",
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
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
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFFE36E00),
                              ),
                            ),
                            Text(
                              "Chapter ${data['chapter']}, Verse ${data['verse']}",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF323232),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data['translation'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) => VerseScreen(
                                              chapterId: data['chapter'],
                                              verseId: data['verse'] as int),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "See More",
                                      style: GoogleFonts.inter(
                                          color: Color(0xFFE36E00),
                                          fontWeight: FontWeight.w700),
                                    )),
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Reflection",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFE36E00),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\"You have the right to perform your duty, but not to the fruits of your actions.\" - Bhagavad Gita 2.47",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF323232),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "API Used in this App",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFE36E00),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Base URL: https://bhagavad-gita3.p.rapidapi.com",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "- Get all chapters:\n  /v2/chapters/",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      Text(
                        "- Get specific chapter:\n  /v2/chapters/1/",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      Text(
                        "- Get all verses from a chapter:\n  /v2/chapters/1/verses/",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      Text(
                        "- Get a specific verse:\n  /v2/chapters/1/verses/1/",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Powered by RapidAPI",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
