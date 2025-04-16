import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'SingleChapterScreen.dart';
import 'VerseScreen.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  List<dynamic> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    final url = Uri.parse("https://bhagavad-gita3.p.rapidapi.com/v2/chapters/");
    final response = await http.get(url, headers: {
      'x-rapidapi-key': 'ab3f75ae48msh7e33c4ccfdceca9p134952jsn5a740b661b0b',
      'x-rapidapi-host': 'bhagavad-gita3.p.rapidapi.com'
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        chapters = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        scrolledUnderElevation: 0,
        title: Text(
          "Chapters",
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
                        Text("Search Chapter / Verse", style: GoogleFonts.inter(
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
                                SnackBar(content: Text("Please enter a chapter number")),
                              );
                              return;
                            }

                            final chapter = int.tryParse(chapterText);
                            final verse = int.tryParse(verseText);

                            if (chapter == null || chapter < 1 || chapter > 18) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Enter a valid chapter (1–18)")),
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
                                  SnackBar(content: Text("Enter a valid verse number")),
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
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
      body: SafeArea(
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return CupertinoListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${chapter['chapter_number'] ?? ''}. ${chapter['name_translated'] ?? 'No name'}",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE36E00)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          chapter['chapter_summary'] ?? 'No summary available',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.list_bullet_below_rectangle,
                              color: CupertinoColors.secondaryLabel,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${chapter['verses_count'] ?? 0} verses",
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.secondaryLabel),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => SingleChapterScreen(
                            chapterId: chapter['chapter_number'],
                          ),
                        ),
                      );
                    },

                  );
                },
              ),
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CupertinoListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  SizedBox(height: 4),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
