import 'package:flutter/material.dart';
import 'package:invisible_watermark/invisible_watermark.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invisible Watermark Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      home: const HomeContent(),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  final watermark = InvisibleWatermark();
  final picker = ImagePicker();
  File? originalImage;
  File? watermarkedImage;
  File? extractedImage;
  bool isProcessing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (pickedFile == null) return;
    setState(() {
      originalImage = File(pickedFile.path);
      watermarkedImage = null;
      extractedImage = null;
      _tabController.animateTo(0);
    });
  }

  Future<void> addWatermark() async {
    if (originalImage == null) return;
    if (!mounted) return;
    setState(() => isProcessing = true);

    try {
      final imageBytes = await originalImage!.readAsBytes();
      final watermarkedBytes = await watermark.addWatermark(
        imageBytes,
        'Flutter Invisible Watermark Demo',
      );

      final tempFile = File('${originalImage!.path}_watermarked.png');
      await tempFile.writeAsBytes(watermarkedBytes);

      setState(() {
        watermarkedImage = tempFile;
        _tabController.animateTo(1);
      });
    } catch (e) {
      debugPrint('addWatermark error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> extractWatermark() async {
    if (watermarkedImage == null) return;
    if (!mounted) return;
    setState(() => isProcessing = true);

    try {
      final imageBytes = await watermarkedImage!.readAsBytes();
      final extractedBytes = await watermark.extractVisibleWatermark(imageBytes);

      final tempFile = File('${watermarkedImage!.path}_extracted.png');
      await tempFile.writeAsBytes(extractedBytes);

      setState(() {
        extractedImage = tempFile;
        _tabController.animateTo(2);
      });
    } catch (e) {
      debugPrint('extractWatermark error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watermark Demo', style: TextStyle(fontSize: 16)),
        leadingWidth: 0,
        leading: Container(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blue.withOpacity(0.3),
                    disabledForegroundColor: Colors.white38,
                  ),
                  onPressed: pickImage,
                  child: const Text(
                    'Photograph',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blue.withOpacity(0.3),
                    disabledForegroundColor: Colors.white38,
                  ),
                  onPressed: originalImage != null ? addWatermark : null,
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blue.withOpacity(0.3),
                    disabledForegroundColor: Colors.white38,
                  ),
                  onPressed: watermarkedImage != null ? extractWatermark : null,
                  child: const Text(
                    'Extract',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Original'),
                  Tab(text: 'Watermarked'),
                  Tab(text: 'Extracted'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildImageView('Original Image', originalImage),
                    _buildImageView('Watermarked Image', watermarkedImage),
                    _buildImageView('Extracted Watermark', extractedImage),
                  ],
                ),
              ),
            ],
          ),
          if (isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageView(String title, File? image) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (image != null) Image.file(image) else const Text('No image'),
        ],
      ),
    );
  }
}
