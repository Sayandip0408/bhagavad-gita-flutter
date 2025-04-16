// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class VerseScreen extends StatelessWidget {
//   final int chapterId;
//   final int verseId;
//
//   const VerseScreen({super.key, required this.chapterId, required this.verseId});
//
//   @override
//   Widget build(BuildContext context) {
//     print("verse id is: $verseId");
//     return CupertinoPageScaffold(
//       backgroundColor: CupertinoColors.white,
//       navigationBar: CupertinoNavigationBar(
//         leading: GestureDetector(
//           onTap: () => Navigator.of(context).pop(),
//           child: Row(
//             children: [
//               Icon(CupertinoIcons.back, size: 24, color: Color(0xFFE36E00)),
//               SizedBox(width: 4),
//               Text(
//                 'BG $chapterId.$verseId',
//                 style: TextStyle(
//                   color: Color(0xFFE36E00),
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       child: Text("Hello"),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class VerseScreen extends StatefulWidget {
  final int chapterId;
  final int verseId;

  const VerseScreen(
      {super.key, required this.chapterId, required this.verseId});

  @override
  State<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  bool isLoading = true;
  String error = '';
  Map<String, dynamic>? verseData;

  @override
  void initState() {
    super.initState();
    fetchVerse();
  }

  Future<void> fetchVerse() async {
    final url =
        'https://bhagavad-gita3.p.rapidapi.com/v2/chapters/${widget.chapterId}/verses/${widget.verseId}/';

    const headers = {
      'X-RapidAPI-Key': 'ab3f75ae48msh7e33c4ccfdceca9p134952jsn5a740b661b0b',
      'X-RapidAPI-Host': 'bhagavad-gita3.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          verseData = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch verse. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            children: [
              const Icon(CupertinoIcons.back,
                  size: 24, color: Color(0xFFE36E00)),
              const SizedBox(width: 4),
              Text(
                'BG ${widget.chapterId}.${widget.verseId}',
                style: const TextStyle(
                  color: Color(0xFFE36E00),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : error.isNotEmpty
                  ? Center(child: Text(error))
                  : verseData == null
                      ? const Center(child: Text('No data found'))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Sanskrit:',
                              //   style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, decoration: TextDecoration.none, color: Color(0xFFE36E00)),
                              // ),
                              Text(
                                verseData!['text'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20,
                                    decoration: TextDecoration.none,
                                    color: Color(0xFFE36E00)),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Translations:',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
                                    color: Color(0xFFE36E00)),
                              ),
                              ...List<Widget>.from(
                                (verseData!['translations'] as List).map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item['author_name']}:',
                                          style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              decoration: TextDecoration.none,
                                              color: Color(0xFF353026)),
                                        ),
                                        Text(
                                          '${item['description']}',
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              decoration: TextDecoration.none,
                                              color: CupertinoColors
                                                  .secondaryLabel),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Commentary:',
                                style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                    color: Color(0xFFE36E00)),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                (verseData!['commentaries'] as List).isNotEmpty
                                    ? verseData!['commentaries'][0]
                                        ['description']
                                    : 'No commentary available.',
                                style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.none,
                                    color: CupertinoColors.secondaryLabel),
                              ),
                              SizedBox(height: 25,),
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Jai Shri Krishna',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }
}
