// File: lib/supported_side_plank_pose_widget.dart

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

class SupportedSidePlankPoseWidget extends StatefulWidget {
  const SupportedSidePlankPoseWidget({super.key});

  static String routeName = 'SupportedSidePlankPose';
  static String routePath = '/supportedSidePlankPose';

  @override
  State<SupportedSidePlankPoseWidget> createState() => _SupportedSidePlankPoseWidgetState();
}

class _SupportedSidePlankPoseWidgetState extends State<SupportedSidePlankPoseWidget> {
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

    // Initialize WebViewController with Supported Side Plank Pose video
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
      ..loadRequest(Uri.parse('https://www.youtube.com/embed/kiVFaQAyZAE?si=SgksS4Hofd2f4wW2')); // Supported Side Plank Pose Video
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
            'Supported Side Plank Pose', // Title for Supported Side Plank Pose
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
                            // First page: Image of the pose (Supported Side Plank Pose image)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://www.yogapedia.com/wp-content/uploads/2023/11/c7d47200-0951-4236-841a-9645c0dbaf24-1.png', // Supported Side Plank Pose Image
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.network(
                                        'https://placehold.co/400x300/91EEA5/FFFFFF?text=Supported+Side+Plank+Pose', // Placeholder for Supported Side Plank Pose
                                        fit: BoxFit.contain,
                                      ),
                                ),
                              ),
                            ),
                            // Second page: YouTube video embed (Supported Side Plank Pose video)
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
              // Description and Instructions Section (Supported Side Plank Pose Content)
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
                        'Supported side plank pose, or salamba vasisthasana in Sanskrit, is a modified version of side plank pose. With the top leg bent and foot flat on the floor, the pose is more accessible to those who find it difficult to balance with the feet stacked. This variation still strengthens the legs, core and arms.',
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
                        '1. Begin in plank pose.\n2. Bend the left knee and place the foot on the floor about halfway up the body.\n3. Inhale and reach the left arm to the sky, opening the chest to the side.\n4. Breathe while holding the pose. Change sides.',
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
                        '• Avoid if there is ankle, wrist or shoulder injury.',
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