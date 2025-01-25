import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ZFA Timer",
      debugShowCheckedModeBanner: false,
      home: const TimerSeriesScreen(),
      color: Colors.indigo,
      theme: ThemeData(primaryColor: Colors.indigo),
    );
  }
}

class TimerSeriesScreen extends StatefulWidget {
  const TimerSeriesScreen({super.key});

  @override
  _TimerSeriesScreenState createState() => _TimerSeriesScreenState();
}

class _TimerSeriesScreenState extends State<TimerSeriesScreen> {
  Map<String, int> timerData = {}; // Stores label and duration
  List<String> labels = [];
  int currentTimerIndex = 0;
  bool isRunning = false;
  Duration? remainingDuration;

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  void startTimers() {
    if (timerData.isEmpty || currentTimerIndex >= labels.length) return;

    setState(() {
      isRunning = true;
      remainingDuration =
          Duration(seconds: timerData[labels[currentTimerIndex]]!);
    });
  }

  void onTimerComplete() {
    FlutterRingtonePlayer().playNotification(
      looping: false,
      volume: 40,
      asAlarm: true,
    );

    if (currentTimerIndex + 1 < labels.length) {
      setState(() {
        currentTimerIndex++;
        remainingDuration =
            Duration(seconds: timerData[labels[currentTimerIndex]]!);
      });
    } else {
      setState(() {
        isRunning = false;
        currentTimerIndex = 0;
        remainingDuration = null;
      });
      _onAllTimersComplete();
    }
  }

  void _onAllTimersComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("All Timers Completed"),
        content: const Text("You have completed all the timers."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void addTimer(String label, int duration) {
    setState(() {
      timerData[label] = duration;
      labels.add(label);
    });
    _labelController.clear();
    _durationController.clear();
  }

  void resetTimers() {
    setState(() {
      isRunning = false;
      currentTimerIndex = 0;
      remainingDuration = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          labels.isNotEmpty
              ? "Current Timer: ${labels[currentTimerIndex]}"
              : "Set Timer",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              width: double.infinity,
              child:
                  (isRunning && remainingDuration != null && labels.isNotEmpty)
                      ? SlideCountdown(
                          duration: remainingDuration!,
                          key: ValueKey(currentTimerIndex),
                          onDone: onTimerComplete,
                          style: GoogleFonts.poppins(
                              fontSize: 40, color: Colors.white),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          separatorType: SeparatorType.title,
                        )
                      : Container(
                          child: Text(
                            labels.isEmpty
                                ? "No Timers Set"
                                : "Press Play to begin",
                            style: GoogleFonts.poppins(
                                fontSize: 30, color: Colors.white),
                          ),
                        ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start Button
                IconButton.filled(
                  onPressed: !isRunning ? startTimers : null,
                  icon: const Icon(Icons.play_arrow),
                  tooltip: "Start",
                ),
                // Reset Button
                IconButton.filled(
                  onPressed: resetTimers,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Reset",
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 9,
                  child: TextField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      labelText: "Label",
                      labelStyle: GoogleFonts.poppins(),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _durationController,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        labelText: "In Sec",
                        labelStyle: GoogleFonts.poppins(),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () {
                    final label = _labelController.text.trim();
                    final duration =
                        int.tryParse(_durationController.text.trim());
                    if (label.isNotEmpty && duration != null && duration > 0) {
                      addTimer(label, duration);
                    }
                  },
                  color: Colors.indigo,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(height: 10);
                },
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final label = labels[index];
                  final duration = timerData[label]!;
                  return ListTile(
                    dense: true,
                    leading: Text(
                      (index + 1).toString(),
                      style: GoogleFonts.poppins(),
                    ),
                    title: Text(
                      label,
                      style: GoogleFonts.poppins(),
                    ),
                    trailing: Text(
                      "$duration seconds",
                      style: GoogleFonts.poppins(),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Made with ",
                  style: GoogleFonts.poppins(),
                ),
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.red,
                ),
                Text(
                  " for Zuhair",
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
