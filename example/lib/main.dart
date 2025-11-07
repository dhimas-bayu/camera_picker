import 'package:camera_picker_example/src/barcode_scanner_page.dart';
import 'package:camera_picker_example/src/record_video_page.dart';
import 'package:camera_picker_example/src/take_image_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  final ValueNotifier<int> _pageNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageNotifier.value);
  }

  @override
  void dispose() {
    _pageNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera picker app'), centerTitle: true),
      body: _buildBody(),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _pageNotifier,
        builder: (context, value, child) {
          return NavigationBar(
            selectedIndex: value,
            onDestinationSelected: (index) async {
              _pageNotifier.value = index;
              _pageController.animateToPage(
                index,
                duration: Durations.medium4,
                curve: Curves.easeIn,
              );
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.qr_code_outlined),
                label: "Scan QR-Code",
              ),
              NavigationDestination(
                icon: Icon(Icons.video_camera_back_rounded),
                label: "Record Video",
              ),
              NavigationDestination(
                icon: Icon(Icons.camera_alt),
                label: "Capture Image",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        BarcodeScannerPage(),
        RecordVideoPage(),
        TakeImagePage(),
      ],
    );
  }
}

Map<int, String> get tabIndicator => {
  0: "Scan Barcode",
  1: "Record Video",
  2: "Capture Image",
};
