// File: lib/hare_pose_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart'; // For displaying web content (e.g., YouTube)
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
as smooth_page_indicator; // For the page indicator dots

// Define custom colors directly, consistent with other improved pose pages
const Color primaryBackgroundColor = Color(0xFFF1F4F8); // A light background color
const Color primaryColor = Color(0xFF91EEA5); // Default app green
const Color accentColor = Color(0xFFC0F7C9); // Lighter green for inactive dots and some accents
const Color headlineTextColor = Colors.white; // For app bar title and major headings
const Color bodyTextColor = Color(0xFF333333); // For general body text
const Color secondaryTextColor = Color(0xFF57636C); // For less prominent text

class HarePoseWidget extends StatefulWidget { // Changed class name
  const HarePoseWidget({super.key});

  static String routeName = 'HarePose'; // Changed route name
  static String routePath = '/harePose'; // Changed route path

  @override
  State<HarePoseWidget> createState() => _HarePoseWidgetState(); // Changed state class name
}

class _HarePoseWidgetState extends State<HarePoseWidget> { // Changed state class name
  // PageController for the PageView
  late PageController _pageViewController;
  // WebViewController for the WebView
  late final WebViewController _webViewController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize PageController
    _pageViewController = PageController(initialPage: 0);

    // Initialize WebViewController with Hare Pose video
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/embed/')) {
              return NavigationDecision.navigate;
            }
            debugPrint('Blocking navigation to ${request.url}');
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.youtube.com/embed/y3eLdcW6L1E?si=UYRNELtwyXemwTkc')); // Hare Pose Video
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: primaryBackgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor, // Using primaryColor (#91EEA5)
          automaticallyImplyLeading: false,
          title: Text(
            'Hare Pose', // Title for Hare Pose
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.bold,
              color: headlineTextColor,
              fontSize: 24,
              letterSpacing: 0.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: headlineTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 4,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PageView Section (Image and Video)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        PageView(
                          controller: _pageViewController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            // First page: Image of the pose (Hare Pose image)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://www.yogapedia.com/wp-content/uploads/2023/11/37ab0721-b9e7-428c-bd32-293dff3280d5-1.png', // Hare Pose Image
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.network(
                                        'https://placehold.co/400x300/91EEA5/FFFFFF?text=Hare+Pose', // Placeholder for Hare Pose
                                        fit: BoxFit.contain,
                                      ),
                                ),
                              ),
                            ),
                            // Second page: YouTube video embed (Hare Pose video)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: WebViewWidget(controller: _webViewController),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Page Indicator
                        Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                            child: smooth_page_indicator.SmoothPageIndicator(
                              controller: _pageViewController,
                              count: 2,
                              axisDirection: Axis.horizontal,
                              onDotClicked: (i) async {
                                await _pageViewController.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              effect: const smooth_page_indicator.ExpandingDotsEffect(
                                spacing: 8,
                                radius: 8,
                                dotWidth: 10,
                                dotHeight: 10,
                                dotColor: accentColor,
                                activeDotColor: primaryColor,
                                paintStyle: PaintingStyle.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Description and Instructions Section (Hare Pose Content)
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 22,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hare pose, or shashankasana in Sanskrit, is a dynamic pose that can relieve backache by strengthening and stretching the back. From thunderbolt pose, the practitioner reaches their arms up before folding forward. The movement is repeated for up to several minutes.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          color: bodyTextColor,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Instructions:',
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 22,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Begin in the thunderbolt pose.\n2. Inhale and reach the arms up.\n3. Exhale and bend forward from the hips, bringing the forehead and arms to the floor.\n4. Pause, then inhale and reach up.\n5. Repeat this movement slowly and in tune with the breath.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          color: bodyTextColor,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cautions:',
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 22,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Avoid if there is high blood pressure or slipped disc.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          color: bodyTextColor,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}