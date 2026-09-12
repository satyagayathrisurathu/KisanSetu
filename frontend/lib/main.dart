import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiBaseUrl = 'http://127.0.0.1:8000';

void main() {
  runApp(const KisanSetuApp());
}

class KisanSetuApp extends StatelessWidget {
  const KisanSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KisanSetu',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F8F4),
        fontFamily: 'Arial',
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int selectedIndex = 0;

  void openTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpenTab: openTab),
      const PlansPage(),
      const WorkersPage(),
      const MorePage(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: openTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Workers',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final void Function(int) onOpenTab;

  const HomePage({
    super.key,
    required this.onOpenTab,
  });

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'KisanSetu',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No new notifications.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF66BB6A),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart farming starts here',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Plan crops, manage workers, track costs and make better farming decisions.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Farm overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                OverviewCard(
                  title: 'Farm area',
                  value: '5 Acres',
                  icon: Icons.landscape,
                  color: const Color(0xFF558B2F),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your farm area is 5 acres.'),
                      ),
                    );
                  },
                ),
                OverviewCard(
                  title: 'Active crops',
                  value: '3',
                  icon: Icons.grass,
                  color: const Color(0xFF00897B),
                  onTap: () {
                    onOpenTab(1);
                  },
                ),
                OverviewCard(
                  title: 'Workers',
                  value: '8',
                  icon: Icons.groups,
                  color: const Color(0xFF1565C0),
                  onTap: () {
                    onOpenTab(2);
                  },
                ),
                OverviewCard(
                  title: 'Pending tasks',
                  value: '4',
                  icon: Icons.task_alt,
                  color: const Color(0xFFEF6C00),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You have 4 pending tasks.'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ActionTile(
              icon: Icons.add_circle_outline,
              title: 'Create farm plan',
              subtitle: 'Add crop activities and important dates',
              onTap: () {
                openPage(context, const FarmPlanPage());
              },
            ),
            ActionTile(
              icon: Icons.cloud_outlined,
              title: 'Check weather',
              subtitle: 'View weather information for your location',
              onTap: () {
                openPage(context, const WeatherPage());
              },
            ),
            ActionTile(
              icon: Icons.groups_outlined,
              title: 'Manage workers',
              subtitle: 'Add workers and assign farm activities',
              onTap: () {
                onOpenTab(2);
              },
            ),
            ActionTile(
              icon: Icons.camera_alt_outlined,
              title: 'Crop disease detection',
              subtitle: 'Upload a crop image for AI analysis',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'AI crop disease detection will be added next.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            icon,
            color: const Color(0xFF2E7D32),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

class FarmPlanPage extends StatefulWidget {
  const FarmPlanPage({super.key});

  @override
  State<FarmPlanPage> createState() => _FarmPlanPageState();
}

class _FarmPlanPageState extends State<FarmPlanPage> {
  final cropController = TextEditingController();
  final areaController = TextEditingController();
  final activityController = TextEditingController();
  final sowingController = TextEditingController();
  final harvestController = TextEditingController();
  final notesController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    cropController.dispose();
    areaController.dispose();
    activityController.dispose();
    sowingController.dispose();
    harvestController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> saveFarmPlan() async {
    if (cropController.text.trim().isEmpty ||
        areaController.text.trim().isEmpty ||
        activityController.text.trim().isEmpty ||
        sowingController.text.trim().isEmpty ||
        harvestController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/farm-plans'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'crop_name': cropController.text.trim(),
          'farm_area': areaController.text.trim(),
          'activity': activityController.text.trim(),
          'sowing_date': sowingController.text.trim(),
          'harvest_date': harvestController.text.trim(),
          'notes': notesController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm plan saved successfully.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not save plan: ${response.body}',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backend is not running. Start FastAPI and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Farm Plan'),
        backgroundColor: Colors.green.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: cropController,
              decoration: const InputDecoration(
                labelText: 'Crop name',
                hintText: 'Example: Rice',
                prefixIcon: Icon(Icons.grass),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(
                labelText: 'Farm area',
                hintText: 'Example: 2 acres',
                prefixIcon: Icon(Icons.landscape),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: activityController,
              decoration: const InputDecoration(
                labelText: 'Farm activity',
                hintText: 'Example: Seed sowing',
                prefixIcon: Icon(Icons.agriculture),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: sowingController,
              decoration: const InputDecoration(
                labelText: 'Sowing date',
                hintText: 'Example: 2026-09-15',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: harvestController,
              decoration: const InputDecoration(
                labelText: 'Expected harvest date',
                hintText: 'Example: 2027-01-15',
                prefixIcon: Icon(Icons.event_available),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional information',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: isSaving ? null : saveFarmPlan,
                icon: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isSaving ? 'Saving...' : 'Save farm plan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  List<dynamic> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/farm-plans'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          plans = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadPlans,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'My Farm Plans',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your saved crop activities and farming schedules.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (plans.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No farm plans yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Create your first farm plan from the Home page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...plans.map(
                (plan) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.grass,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      plan['crop_name'] ?? 'Unknown crop',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${plan['activity']}\n'
                      'Area: ${plan['farm_area']}\n'
                      'Sowing: ${plan['sowing_date']}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final searchController = TextEditingController();

  final List<Map<String, String>> workers = [
    {
      'name': 'Ramesh',
      'role': 'Field worker',
      'language': 'Telugu',
      'phone': '9876543210',
      'status': 'Available',
    },
    {
      'name': 'Suresh',
      'role': 'Tractor operator',
      'language': 'Hindi',
      'phone': '9876543211',
      'status': 'Busy',
    },
    {
      'name': 'Lakshmi',
      'role': 'Harvest worker',
      'language': 'Telugu',
      'phone': '9876543212',
      'status': 'Available',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredWorkers {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return workers;
    }

    return workers.where((worker) {
      return worker['name']!.toLowerCase().contains(query) ||
          worker['role']!.toLowerCase().contains(query) ||
          worker['language']!.toLowerCase().contains(query) ||
          worker['phone']!.contains(query);
    }).toList();
  }

  Future<void> showAddWorkerDialog() async {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final languageController = TextEditingController();
    final phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Register worker manually'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Worker name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Work role',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: languageController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred language',
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    roleController.text.trim().isEmpty ||
                    languageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all worker details.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  workers.add({
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'role': roleController.text.trim(),
                    'language': languageController.text.trim(),
                    'status': 'Available',
                  });
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Worker registered successfully.'),
                  ),
                );
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    roleController.dispose();
    languageController.dispose();
    phoneController.dispose();
  }

  Future<void> showVoiceRegistrationDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();
    final languageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Voice registration'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.mic,
                        size: 48,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Voice prototype',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'For now, enter the details after speaking with the worker.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Worker name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Work role',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: languageController,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    roleController.text.trim().isEmpty ||
                    languageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all worker details.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  workers.add({
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'role': roleController.text.trim(),
                    'language': languageController.text.trim(),
                    'status': 'Available',
                  });
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Voice registration prototype completed.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Save worker'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    roleController.dispose();
    languageController.dispose();
  }

  void showWorkerOptions(Map<String, String> worker) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.call),
                title: Text('Call ${worker['name']}'),
                subtitle: Text(worker['phone']!),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Calling ${worker['name']} at ${worker['phone']}',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Send message'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Messaging ${worker['name']} will be added next.',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.task_alt),
                title: const Text('Assign task'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Task assignment for ${worker['name']} will be added next.',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove worker'),
                onTap: () {
                  setState(() {
                    workers.remove(worker);
                  });

                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Worker removed.'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleWorkers = filteredWorkers;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workers',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Coordinate your farm team easily.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'manual') {
                      showAddWorkerDialog();
                    } else {
                      showVoiceRegistrationDialog();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'manual',
                      child: Row(
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(width: 10),
                          Text('Manual registration'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'voice',
                      child: Row(
                        children: [
                          Icon(Icons.mic),
                          SizedBox(width: 10),
                          Text('Voice registration'),
                        ],
                      ),
                    ),
                  ],
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search name, role or phone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: visibleWorkers.isEmpty
                ? const Center(
                    child: Text('No workers found.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: visibleWorkers.length,
                    itemBuilder: (context, index) {
                      final worker = visibleWorkers[index];
                      final isAvailable =
                          worker['status'] == 'Available';

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              worker['name']![0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            worker['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(worker['role']!),
                                Text('Phone: ${worker['phone']}'),
                                Text(
                                  'Language: ${worker['language']}',
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    worker['status']!,
                                    style: TextStyle(
                                      color: isAvailable
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              showWorkerOptions(worker);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: Colors.green.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF64B5F6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Hyderabad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '29°C',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Partly cloudy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: WeatherInfoCard(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '68%',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: WeatherInfoCard(
                    icon: Icons.air,
                    title: 'Wind',
                    value: '12 km/h',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: WeatherInfoCard(
                    icon: Icons.umbrella,
                    title: 'Rain chance',
                    value: '30%',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: WeatherInfoCard(
                    icon: Icons.thermostat,
                    title: 'Feels like',
                    value: '31°C',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Farm suggestion: Check the soil moisture before irrigation. Avoid spraying pesticides if rain is expected.',
                      style: TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'These are sample weather values. Live weather integration will use the backend API.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const WeatherInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'More',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ActionTile(
            icon: Icons.account_circle_outlined,
            title: 'Profile',
            subtitle: 'Manage your farmer profile',
            onTap: () {},
          ),
          ActionTile(
            icon: Icons.attach_money,
            title: 'Cost tracking',
            subtitle: 'Track farm expenses and income',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Cost tracking will be added next.',
                  ),
                ),
              );
            },
          ),
          ActionTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Manage application settings',
            onTap: () {},
          ),
          ActionTile(
            icon: Icons.info_outline,
            title: 'About KisanSetu',
            subtitle: 'Learn about this smart farming platform',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'KisanSetu',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.agriculture),
                children: const [
                  Text(
                    'KisanSetu is a smart farming assistant for crop planning, worker management and farm decisions.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
