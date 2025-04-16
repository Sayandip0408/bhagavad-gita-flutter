import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        scrolledUnderElevation: 0,
        title: Text(
          "Developer Info",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.info_circle_fill),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  "images/developer.jpg",
                  height: 90,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "SayanDip Adhikary",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "adhikarysayandip@gmail.com",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'adhikarysayandip@gmail.com',
                    query: Uri.encodeFull(
                        'subject=Hello from Bhagavad Gita App&body=I would like to...'),
                  );
                  await launchUrl(emailLaunchUri,
                      mode: LaunchMode.externalApplication);
                },
                splashColor: Color(0xFFBD5D02),
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Color(0xFFE36E00),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        Icon(
                          FluentIcons.mail_12_filled,
                          color: CupertinoColors.white,
                        ),
                        Text(
                          "Send Mail",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Know More",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFf3f3f3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      children: [
                        _buildListTile(
                          context,
                          icon: CupertinoIcons.person_crop_circle,
                          title: 'Visit Portfolio',
                          url: 'https://sayandip-adhikary.vercel.app/',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Divider(height: 1),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.code,
                          title: 'View Projects on GitHub',
                          url: 'https://github.com/Sayandip0408',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Divider(height: 1),
                        ),
                        _buildListTile(
                          context,
                          icon: CupertinoIcons.photo_camera_solid,
                          title: 'Photography Page',
                          url: 'https://shutter-island.netlify.app',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Divider(height: 1),
                        ),
                        _buildListTile(
                          context,
                          icon: CupertinoIcons.briefcase_fill,
                          title: 'LinkedIn Profile',
                          url:
                              'https://www.linkedin.com/in/sayandip-adhikary-7359a8199/',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Divider(height: 1),
                        ),
                        _buildListTile(
                          context,
                          icon: CupertinoIcons.star_fill,
                          title: 'Rate this App',
                          url:
                              'https://play.google.com/store/apps/details?id=your.app.id',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Divider(height: 1),
                        ),
                        _buildListTile(
                          context,
                          icon: CupertinoIcons.share,
                          title: 'Share with Friends',
                          url: 'whatsapp-share',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon, required String title, required String url}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.deepOrange,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF0A0A0A),
        ),
      ),
      trailing: Icon(
        CupertinoIcons.arrow_right,
        size: 16,
      ),
      onTap: () async {
        if (url == 'whatsapp-share') {
          final appUrl =
              'https://github.com/Sayandip0408/bhagavad-gita-flutter';
          final message = Uri.encodeComponent(
              "Hey! I found this amazing Bhagavad Gita app 📖✨. Check it out:\n$appUrl");
          final whatsappUrl = Uri.parse("https://wa.me/?text=$message");

          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        } else {
          final Uri uri = Uri.parse(url);
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
  }
}
