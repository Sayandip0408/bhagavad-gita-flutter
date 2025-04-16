import 'dart:convert';
import 'package:bhagavad_gita/screens/VerseScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class SingleChapterScreen extends StatefulWidget {
  final int chapterId;

  const SingleChapterScreen({super.key, required this.chapterId});

  @override
  State<SingleChapterScreen> createState() => _SingleChapterScreenState();
}

class _SingleChapterScreenState extends State<SingleChapterScreen> {
  Map<String, dynamic>? chapterData;
  List<dynamic>? versesData;
  bool isLoading = true;
  int currentPage = 0;
  final int versesPerPage = 5;


  @override
  void initState() {
    super.initState();
    fetchChapterDetails();
  }

  String cleanVerseText(String rawText) {
    final document = parse(rawText);
    return document.body?.text ?? rawText;
  }

  Future<void> fetchChapterDetails() async {
    final chapterUrl = Uri.parse(
        "https://bhagavad-gita3.p.rapidapi.com/v2/chapters/${widget.chapterId}/");
    final versesUrl = Uri.parse(
        "https://bhagavad-gita3.p.rapidapi.com/v2/chapters/${widget.chapterId}/verses/");

    final headers = {
      'x-rapidapi-key': 'ab3f75ae48msh7e33c4ccfdceca9p134952jsn5a740b661b0b',
      'x-rapidapi-host': 'bhagavad-gita3.p.rapidapi.com',
    };

    try {
      final chapterResponse = await http.get(chapterUrl, headers: headers);
      final versesResponse = await http.get(versesUrl, headers: headers);

      if (chapterResponse.statusCode == 200 &&
          versesResponse.statusCode == 200) {
        final chapterJson = json.decode(chapterResponse.body);
        final versesJson = json.decode(utf8.decode(versesResponse.bodyBytes));

        setState(() {
          chapterData = chapterJson;
          versesData = versesJson;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            children: [
              Icon(CupertinoIcons.back, size: 24, color: Color(0xFFE36E00)),

              SizedBox(width: 4),
              Text(
                'BG Chapter ${widget.chapterId}',
                style: TextStyle(
                  color: Color(0xFFE36E00),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : (chapterData == null || versesData == null)
              ? Center(child: Text('Failed to load data'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        chapterData!['name_translated'] ?? 'No Name',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE36E00),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        chapterData!['chapter_summary'] ??
                            'No summary available',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.secondaryLabel,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 25),
                      Image.asset(
                        "images/flute.png",
                        height: 100,
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.list_bullet_below_rectangle,
                            color: Color(0xFFE36E00),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Total Verses: ${chapterData!['verses_count'] ?? 0}",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFFE36E00),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      Column(
                        children: [
                          // Pagination Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (currentPage > 0)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.left_chevron, size: 16, color: Colors.red,),
                                      Text("Previous", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),),
                                    ],
                                  ),
                                ),
                              Text("|", style: TextStyle(decoration: TextDecoration.none, fontSize: 10, color: Colors.black87,),),
                              if ((currentPage + 1) * versesPerPage < versesData!.length)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text("Next", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),),
                                      Icon(CupertinoIcons.right_chevron, size: 16, color: Colors.green,),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          ...versesData!
                              .skip(currentPage * versesPerPage)
                              .take(versesPerPage)
                              .map((verse) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 1,
                                color: Colors.white,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "VERSE: ${verse['verse_number']}",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: CupertinoColors.activeBlue,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        verse['translations'] != null &&
                                            verse['translations'].isNotEmpty
                                            ? cleanVerseText(
                                            verse['translations'].firstWhere(
                                                  (t) => t['language'] == 'english',
                                              orElse: () => {'description': ''},
                                            )['description'] ??
                                                '')
                                            : 'No translation available',
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: CupertinoColors.secondaryLabel,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (_) => VerseScreen(
                                                    chapterId: widget.chapterId,
                                                    verseId: verse['verse_number'] as int
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Read Now",
                                                  style: TextStyle(color: Color(0xFFE36E00)),
                                                ),
                                                SizedBox(width: 5),
                                                Icon(
                                                  CupertinoIcons.right_chevron,
                                                  size: 15,
                                                  color: Color(0xFFE36E00),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          // Pagination Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (currentPage > 0)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.left_chevron, size: 16, color: Colors.red,),
                                      Text("Previous", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),),
                                    ],
                                  ),
                                ),
                              Text("|", style: TextStyle(decoration: TextDecoration.none, fontSize: 10, color: Colors.black87,),),
                              if ((currentPage + 1) * versesPerPage < versesData!.length)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text("Next", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),),
                                      Icon(CupertinoIcons.right_chevron, size: 16, color: Colors.green,),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      )


                    ],
                  ),
                ),
    );
  }
}
