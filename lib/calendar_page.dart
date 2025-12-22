import 'dart:io';
import 'dart:ui';
import 'package:assignment/widget/mood_summary.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../logic/mood_controller.dart';
import '../data/mood_model.dart';
import 'diary_mood_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MoodController>().loadMoods());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoodController>();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiaryMoodPage()),
          );
          if (mounted) {
            context.read<MoodController>().loadMoods();
          }
        },
        backgroundColor: Colors.indigo[900],
        elevation: 10,
        icon: const Icon(Icons.edit_note, color: Colors.white),
        label: const Text(
          "ADD DIARY",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildAestheticBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "MY JOURNEY",
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildGlassContainer(
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020),
                          lastDay: DateTime.utc(2030),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            leftChevronIcon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.indigo[300], size: 18),
                            rightChevronIcon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.indigo[300], size: 18),
                          ),
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            todayDecoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4338CA)]),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.indigoAccent, blurRadius: 10, offset: Offset(0, 4))],
                            ),
                          ),
                          onDaySelected: (sel, foc) {
                            setState(() {
                              _selectedDay = sel;
                              _focusedDay = foc;
                            });
                            _showEditSheet(sel, controller);
                          },
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              final dateStr = day.toIso8601String().substring(0, 10);
                              final moodIdx = controller.moods.indexWhere((m) => m.date == dateStr);
                              if (moodIdx != -1) {
                                return Positioned(
                                  bottom: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                    ),
                                    child: Text(controller.moods[moodIdx].emoji, style: const TextStyle(fontSize: 10)),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildAnalysisHeader(),
                      MoodSummaryChart(controller: controller),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAestheticBackground() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Stack(
        children: [
          Positioned(top: -30, left: -40, child: CircleAvatar(radius: 100, backgroundColor: Colors.indigo[50]!.withOpacity(0.6))),
          Positioned(bottom: 300, right: -60, child: CircleAvatar(radius: 140, backgroundColor: Colors.blue[50]!.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildAnalysisHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 5),
      child: Row(
        children: [
          Container(width: 5, height: 25, decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 15),
          const Text("Analysis", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  void _showEditSheet(DateTime date, MoodController controller) {
    final dateStr = date.toIso8601String().substring(0, 10);
    final moodIdx = controller.moods.indexWhere((m) => m.date == dateStr);
    if (moodIdx == -1) return;

    final mood = controller.moods[moodIdx];
    final noteCtrl = TextEditingController(text: mood.note);
    // Track the image path locally in the sheet
    String? currentImagePath = mood.imagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 25,
            right: 25,
            top: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Memory",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900])),
              const SizedBox(height: 20),

              // --- IMAGE UPDATE SECTION ---
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    // Update the state inside the bottom sheet
                    setS(() => currentImagePath = pickedFile.path);
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: currentImagePath != null && currentImagePath!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.file(File(currentImagePath!), fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: Colors.indigo[200], size: 40),
                      const Text("Add Photo", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.indigo.withOpacity(0.03),
                  hintText: "Update your thoughts...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // CRITICAL: Update BOTH the note and the imagePath
                  controller.updateMood(mood.copyWith(
                    note: noteCtrl.text,
                    imagePath: currentImagePath,
                  ));
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text("SAVE CHANGES",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                  onPressed: () => _confirmDelete(mood.id!, controller),
                  child: const Text("Delete Entry",
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int id, MoodController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () { controller.deleteMood(id); Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}