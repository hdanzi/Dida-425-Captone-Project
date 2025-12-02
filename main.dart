// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


void main() {
 runApp(const MyApp());
}


/* --------------------------------------------------------------------------
 Models
 -------------------------------------------------------------------------- */
class Reminder {
 final String title;
 final TimeOfDay time;
 final bool isSuggested;
 final String id;


 Reminder({
    required this.title,
    required this.time,
    this.isSuggested = false,
 }) : id = UniqueKey().toString();


 @override
 bool operator ==(final Object other) =>
     identical(this, other) ||
     other is Reminder && runtimeType == other.runtimeType && id == other.id;


 @override
 int get hashCode => id.hashCode;
}


/* --------------------------------------------------------------------------
 App State (Provider)
 -------------------------------------------------------------------------- */
class MyAppState extends ChangeNotifier {
 final List<Reminder> _reminders = [
  Reminder(
    title: "Take a 5-minute deep breathing break",
    time: const TimeOfDay(hour: 10, minute: 0),
    isSuggested: true,
  ),
  Reminder(
    title: "Drink a glass of water",
    time: const TimeOfDay(hour: 14, minute: 30),
    isSuggested: true,
  ),
  Reminder(
    title: "Write down 3 things you're grateful for",
    time: const TimeOfDay(hour: 20, minute: 0),
    isSuggested: true,
  ),
 ];


 List<Reminder> get reminders => _reminders;


 void addReminder(final String title, final TimeOfDay time) {
  _reminders.add(Reminder(title: title, time: time));
  _reminders.sort((final a, final b) =>
       (a.time.hour * 60 + a.time.minute) - (b.time.hour * 60 + b.time.minute));
  notifyListeners();
 }


 void removeReminder(final Reminder reminder) {
  _reminders.remove(reminder);
  notifyListeners();
 }
}


/* --------------------------------------------------------------------------
 MyApp
 -------------------------------------------------------------------------- */
class MyApp extends StatelessWidget {
 const MyApp({super.key});


 @override
 Widget build(final BuildContext context) {
  return ChangeNotifierProvider(
   create: (_) => MyAppState(),
   child: MaterialApp(
    title: 'StudyBreak',
    theme: ThemeData(
     colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 26, 92, 28)),
     useMaterial3: true,
    ),
    home: const MyHomePage(),
   ),
  );
 }
}


/* --------------------------------------------------------------------------
 MyHomePage (Simplified - No NavigationRail)
 -------------------------------------------------------------------------- */
class MyHomePage extends StatefulWidget {
 const MyHomePage({super.key});


 @override
 State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
 int selectedIndex = 0;


 // Function to navigate between pages (passed to MainNavigationPage and sub-pages)
 void onNavigateToSection(final int index) {
  setState(() {
   selectedIndex = index;
  });
 }


 @override
 Widget build(final BuildContext context) {
  Widget page;
  // The onNavigateToSection is passed to sub-pages so they can set selectedIndex = 0 (Home)
  // when the user presses a back button.
  switch (selectedIndex) {
   case 0:
    page = MainNavigationPage(onNavigate: onNavigateToSection);
   case 1:
    page = BrainGamesPage(onBack: () => onNavigateToSection(0));
   case 2:
    page = BreathingExercisesPage(onBack: () => onNavigateToSection(0));
   case 3:
    page = MoodTrackingPage(onBack: () => onNavigateToSection(0));
   case 4:
    page = RemindersAlarmsPage(onBack: () => onNavigateToSection(0));
   case 5:
    page = ExtraHelpPage(onBack: () => onNavigateToSection(0));
   default:
    page = const Center(child: Text("Page not found"));
  }


  // No LayoutBuilder or Row needed. The body is just the selected 'page' widget.
  return Scaffold(
   body: page,
  );
 }
}


/* --------------------------------------------------------------------------
 Main navigation grid (Home content)
 -------------------------------------------------------------------------- */
class MainNavigationPage extends StatelessWidget {
 final ValueChanged<int> onNavigate;
 const MainNavigationPage({required this.onNavigate, super.key});


 @override
 Widget build(final BuildContext context) {
  // Simple grid of navigation cards (index mapping matches NavigationRail)
  return Scaffold(
   appBar: AppBar(title: const Text('Welcome to StudyBreak! 🧘‍♀️')),
   body: GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    padding: const EdgeInsets.all(20),
    children: [
     NavigationCard(title: 'Brain Games', icon: Icons.psychology, onTap: () => onNavigate(1)),
     NavigationCard(title: 'Breathing Exercises', icon: Icons.self_improvement, onTap: () => onNavigate(2)),
     NavigationCard(title: 'Mood Tracking', icon: Icons.mood, onTap: () => onNavigate(3)),
     NavigationCard(title: 'Reminders & Alarms', icon: Icons.access_alarm, onTap: () => onNavigate(4)),
     NavigationCard(title: 'Extra Help', icon: Icons.thumb_up, onTap: () => onNavigate(5)),
    ],
   ),
  );
 }
}


class NavigationCard extends StatelessWidget {
 final String title;
 final IconData icon;
 final VoidCallback onTap;
 const NavigationCard({required this.title, required this.icon, required this.onTap, super.key});


 @override
 Widget build(final BuildContext context) {
  return Card(
   elevation: 4,
   child: InkWell(
    onTap: onTap,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
     Icon(icon, size: 50, color: Theme.of(context).colorScheme.primary),
     const SizedBox(height: 10),
     Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
   ),
  );
 }
}


/* --------------------------------------------------------------------------
 BrainGamesPage (opens SelfCareAdventure.html from assets)
 -------------------------------------------------------------------------- */
class BrainGamesPage extends StatelessWidget {
 // Added callback to go back to Home view
 final VoidCallback onBack;
 const BrainGamesPage({required this.onBack, super.key});


 void _openTwine() {
  launchUrl(
   Uri.parse('assets/Self Care Adventure.html'),
   webOnlyWindowName: '_blank',
  );
 }


 @override
 Widget build(final BuildContext context) {
  return Scaffold(
   // Added a leading IconButton to go back to the home index
   appBar: AppBar(
    title: const Text('Brain Games'),
    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
   ),
   body: Center(
    child: TextButton(
     onPressed: _openTwine,
     child: const Text('Open Self-Care Adventure', style: TextStyle(fontSize: 18)),
    ),
   ),
  );
 }
}


/* --------------------------------------------------------------------------
 BreathingExercisesPage (opens BreathingExercises.html)
 -------------------------------------------------------------------------- */
class BreathingExercisesPage extends StatelessWidget {
 // Added callback to go back to Home view
 final VoidCallback onBack;
 const BreathingExercisesPage({required this.onBack, super.key});


 void _openBreathing() {
  launchUrl(
   Uri.parse('assets/Breathing Exercises.html'),
   webOnlyWindowName: '_blank',
  );
 }


 @override
 Widget build(final BuildContext context) {
  return Scaffold(
   // Added a leading IconButton to go back to the home index
   appBar: AppBar(
    title: const Text('Breathing Exercises'),
    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
   ),
   body: Center(
    child: TextButton(
     onPressed: _openBreathing,
     child: const Text('Open Breathing Exercises', style: TextStyle(fontSize: 18)),
    ),
   ),
  );
 }
}


/* --------------------------------------------------------------------------
 MoodTrackingPage (saves 4 moods to SharedPreferences)
 -------------------------------------------------------------------------- */
class MoodTrackingPage extends StatefulWidget {
 // Added callback to go back to Home view
 final VoidCallback onBack;
 const MoodTrackingPage({required this.onBack, super.key});


 @override
 State<MoodTrackingPage> createState() => _MoodTrackingPageState();
}


class _MoodTrackingPageState extends State<MoodTrackingPage> {
 double _happiness = 50;
 double _sadness = 50;
 double _stress = 50;
 double _energy = 70;


 List<Map<String, dynamic>> _moodHistory = [];


 @override
 void initState() {
  super.initState();
  _loadMoodHistory();
 }


 Future<void> _loadMoodHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString("moodHistory");
  if (jsonString != null) {
   setState(() {
    _moodHistory = List<Map<String, dynamic>>.from(json.decode(jsonString));
   });
  }
 }


 Future<void> _saveMoodEntry() async {
  final prefs = await SharedPreferences.getInstance();
  final entry = {
   "happiness": _happiness.round(),
   "sadness": _sadness.round(),
   "stress": _stress.round(),
   "energy": _energy.round(),
   "timestamp": DateTime.now().toIso8601String(),
  };
  _moodHistory.add(entry);
  await prefs.setString("moodHistory", json.encode(_moodHistory));
  setState(() {});
 }


 @override
 Widget build(final BuildContext context) {
  return Scaffold(
   // Added a leading IconButton to go back to the home index
   appBar: AppBar(
    title: const Text('Mood Tracking'),
    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
   ),
   body: SingleChildScrollView(
    child: Center(
     child: Column(
      children: [
       const SizedBox(height: 20),


       // Happiness
       const Text('Rate your Happiness:', style: TextStyle(fontSize: 18)),
       Slider(
        value: _happiness,
        max: 100,
        divisions: 10,
        label: _happiness.round().toString(),
        onChanged: (final value) => setState(() => _happiness = value),
       ),
       const SizedBox(height: 20),


       // Sadness
       const Text('Rate your Sadness:', style: TextStyle(fontSize: 18)),
       Slider(
        value: _sadness,
        max: 100,
        divisions: 10,
        label: _sadness.round().toString(),
        onChanged: (final value) => setState(() => _sadness = value),
       ),
       const SizedBox(height: 20),


       // Stress
       const Text('Rate your Stress Level:', style: TextStyle(fontSize: 18)),
       Slider(
        value: _stress,
        max: 100,
        divisions: 10,
        label: _stress.round().toString(),
        onChanged: (final value) => setState(() => _stress = value),
       ),
       const SizedBox(height: 20),


       // Energy
       const Text('Rate your Energy:', style: TextStyle(fontSize: 18)),
       Slider(
        value: _energy,
        max: 100,
        divisions: 10,
        label: _energy.round().toString(),
        onChanged: (final value) => setState(() => _energy = value),
       ),
       const SizedBox(height: 20),


       ElevatedButton(onPressed: _saveMoodEntry, child: const Text('Save Mood Entry')),
       const SizedBox(height: 30),


       const Text('Mood History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
       const SizedBox(height: 10),


       // History cards
       ..._moodHistory.reversed.map((final entry) {
        final date = DateTime.parse(entry["timestamp"]);
        final formatted = "${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
        return Card(
         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
         child: ListTile(
          title: Text(
           // FIX: Replaced illegal spaces with standard spaces
           "😊 ${entry["happiness"]} | 😢 ${entry["sadness"]} | 😟 ${entry["stress"]} | ⚡ ${entry["energy"]}",
          ),
          subtitle: Text(formatted),
         ),
        );
       }),
      ],
     ),
    ),
   ),
  );
 }
}


/* --------------------------------------------------------------------------
 Reminders & Alarms Page
 -------------------------------------------------------------------------- */
class RemindersAlarmsPage extends StatefulWidget {
 // Added callback to go back to Home view
 final VoidCallback onBack;
 const RemindersAlarmsPage({required this.onBack, super.key});


 @override
 State<RemindersAlarmsPage> createState() => _RemindersAlarmsPageState();
}


class _RemindersAlarmsPageState extends State<RemindersAlarmsPage> {
 void _showAddSelectionMenu(final BuildContext context, final MyAppState appState) {
  showModalBottomSheet(
   context: context,
   builder: (final BuildContext sheetContext) {
    return Column(
     mainAxisSize: MainAxisSize.min,
     children: <Widget>[
      ListTile(
       leading: const Icon(Icons.alarm_on),
       title: const Text('Add Wake-Up Alarm'),
       onTap: () {
        Navigator.pop(sheetContext);
        _showAddWakeUpAlarmDialog(context, appState);
       },
      ),
      ListTile(
       leading: const Icon(Icons.note_add),
       title: const Text('Add General Reminder'),
       onTap: () {
        Navigator.pop(sheetContext);
        _showAddGeneralReminderDialog(context, appState);
       },
      ),
     ],
    );
   },
  );
 }


 Future<void> _showAddGeneralReminderDialog(final BuildContext context, final MyAppState appState) async {
  TimeOfDay? selectedTime;
  final TextEditingController titleController = TextEditingController();


  return showDialog<void>(
   context: context,
   builder: (final BuildContext dialogContext) {
    return AlertDialog(
     title: const Text('Add General Reminder'),
     content: SingleChildScrollView(
      child: ListBody(
       children: <Widget>[
        TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Reminder Title', hintText: 'e.g., Check calendar, Meditate')),
        const SizedBox(height: 20),
        StatefulBuilder(builder: (final context, final setDialogState) {
         return ElevatedButton.icon(
          onPressed: () async {
           final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
           if (picked != null) {
            setDialogState(() {
             selectedTime = picked;
            });
           }
          },
          icon: const Icon(Icons.access_time),
          label: Text(selectedTime == null ? 'Select Time' : 'Time: ${selectedTime!.format(context)}'),
         );
        }),
       ],
      ),
     ),
     actions: <Widget>[
      TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(dialogContext).pop()),
      TextButton(
       child: const Text('Add Reminder'),
       onPressed: () {
        if (titleController.text.isNotEmpty && selectedTime != null) {
         appState.addReminder(titleController.text, selectedTime!);
         Navigator.of(dialogContext).pop();
        }
       },
      ),
     ],
    );
   },
  );
 }


 Future<void> _showAddWakeUpAlarmDialog(final BuildContext context, final MyAppState appState) async {
  TimeOfDay? selectedTime;
  final TextEditingController titleController = TextEditingController(text: 'Wake-Up Alarm');


  return showDialog<void>(
   context: context,
   builder: (final BuildContext dialogContext) {
    return AlertDialog(
     title: const Text('Add New Wake-Up Alarm'),
     content: SingleChildScrollView(
      child: ListBody(
       children: <Widget>[
        TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Alarm Title', hintText: 'e.g., Early Class, Gym Session')),
        const SizedBox(height: 20),
        StatefulBuilder(builder: (final context, final setDialogState) {
         return ElevatedButton.icon(
          onPressed: () async {
           final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
           if (picked != null) {
            setDialogState(() {
             selectedTime = picked;
            });
           }
          },
          icon: const Icon(Icons.access_time),
          label: Text(selectedTime == null ? 'Select Time' : 'Time: ${selectedTime!.format(context)}'),
         );
        }),
       ],
      ),
     ),
     actions: <Widget>[
      TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(dialogContext).pop()),
      TextButton(
       child: const Text('Add Alarm'),
       onPressed: () {
        if (titleController.text.isNotEmpty && selectedTime != null) {
         appState.addReminder(titleController.text, selectedTime!);
         Navigator.of(dialogContext).pop();
        }
       },
      ),
     ],
    );
   },
  );
 }


 @override
 Widget build(final BuildContext context) {
  final appState = context.watch<MyAppState>();
  final reminders = appState.reminders;


  return Scaffold(
   // Added a leading IconButton to go back to the home index
   appBar: AppBar(
    title: const Text('⏰ Reminders & Alarms'),
    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
   ),
   body: ListView(
    children: [
     Padding(padding: const EdgeInsets.all(16.0), child: Text('Suggested Mental Health Reminders', style: Theme.of(context).textTheme.titleLarge)),
     ...reminders.where((final r) => r.isSuggested).map((final reminder) => _ReminderListTile(reminder: reminder, appState: appState)),
     const Divider(),
     Padding(padding: const EdgeInsets.all(16.0), child: Text('Your Custom Alarms & Reminders', style: Theme.of(context).textTheme.titleLarge)),
     reminders.where((final r) => !r.isSuggested).isEmpty
         ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Tap the plus button to add an alarm or reminder!'))
         : Column(children: reminders.where((final r) => !r.isSuggested).map((final reminder) => _ReminderListTile(reminder: reminder, appState: appState)).toList()),
    ],
   ),
   floatingActionButton: FloatingActionButton(onPressed: () => _showAddSelectionMenu(context, appState), child: const Icon(Icons.add)),
  );
 }
}


class _ReminderListTile extends StatelessWidget {
 final Reminder reminder;
 final MyAppState appState;


 const _ReminderListTile({
    required this.reminder,
    required this.appState,
 });


 @override
 Widget build(final BuildContext context) {
  return ListTile(
   leading: Icon(
    reminder.isSuggested ? Icons.lightbulb_outline : Icons.alarm,
    color: reminder.isSuggested
        ? Theme.of(context).colorScheme.primary
        : null,
   ),
   title: Text(
    reminder.title,
    style: TextStyle(
     fontWeight:
         reminder.isSuggested ? FontWeight.bold : FontWeight.normal,
    ),
   ),
   subtitle: Text(reminder.time.format(context)),
   trailing: reminder.isSuggested
       ? null
       : IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => appState.removeReminder(reminder),
       ),
  );
 }
}

/* --------------------------------------------------------------------------
 ExtraHelpPage (external resources)
 -------------------------------------------------------------------------- */
class ExtraHelpPage extends StatelessWidget {
 // Added callback to go back to Home view
 final VoidCallback onBack;
 const ExtraHelpPage({required this.onBack, super.key});


 Future<void> _launchURL(final String url) async {
  final Uri uri = Uri.parse(url);


  if (!await launchUrl(
   uri,
   webOnlyWindowName: '_blank',
  )) {
   throw Exception('Could not launch $url');
  }
 }


 @override
 Widget build(final BuildContext context) {
  return Scaffold(
   // Added a leading IconButton to go back to the home index
   appBar: AppBar(
    title: const Text('Extra Help'),
    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
   ),
   body: Center(
    child: Padding(
     padding: const EdgeInsets.all(20),
     child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
       //
       const Text(
        "You are not alone. No matter how overwhelming things may feel, "
        "there is always help available and always a path forward. "
        "You deserve support, and reaching out is a strong and brave step. "
        "Keep going! You’ve got this!",
        style: TextStyle(
         fontSize: 18,
         height: 1.4,
        ),
        textAlign: TextAlign.center,
       ),


       const SizedBox(height: 40),


       ElevatedButton(
        onPressed: () => _launchURL('https://sprc.org/'),
        child: const Text('Open Suicide Prevention Resource Center'),
       ),
       const SizedBox(height: 20),


       ElevatedButton(
        onPressed: () => _launchURL('https://988lifeline.org/'),
        child: const Text('Open 988 Suicide & Crisis Lifeline'),
       ),
       const SizedBox(height: 20),


       ElevatedButton(
        onPressed: () => _launchURL('https://www.nami.org/Home'),
        child: const Text('Open NAMI Website'),
       ),
      ],
     ),
    ),
   ),
  );
 }
}