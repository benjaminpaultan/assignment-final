import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../logic/mood_controller.dart';
import '../data/mood_model.dart';

class DiaryDetailPage extends StatefulWidget {
  final String selectedEmoji;

  const DiaryDetailPage({super.key, required this.selectedEmoji});

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  final TextEditingController _noteController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.withOpacity(0.1), Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Hero(
                    tag: 'mood-emoji',
                    child: Text(widget.selectedEmoji, style: const TextStyle(fontSize: 100)),
                  ),
                  const Text(
                    "TELL ME MORE...",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Colors.indigo
                    ),
                  ),
                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_enhance_rounded, size: 40, color: Colors.indigo.withOpacity(0.5)),
                          const SizedBox(height: 10),
                          Text("Capture a Memory", style: TextStyle(color: Colors.indigo.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: TextField(
                          controller: _noteController,
                          maxLines: 6,
                          style: const TextStyle(fontSize: 18),
                          decoration: const InputDecoration(
                            hintText: "How was your day, truly?",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final entry = MoodEntry(
                          date: DateTime.now().toIso8601String().substring(0, 10),
                          emoji: widget.selectedEmoji,
                          note: _noteController.text,
                          imagePath: _selectedImage?.path ?? "",
                        );
                        await context.read<MoodController>().addMood(entry);
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text(
                          "SAVE ENTRY",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}