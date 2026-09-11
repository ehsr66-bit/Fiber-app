import 'package:flutter/material.dart';

void main() {
  runApp(const FiberApp());
}

class FiberApp extends StatelessWidget {
  const FiberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدیریت فیبر نوری',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: FiberHomeScreen(),
      ),
    );
  }
}

class Cable {
  final String name;
  final int coreCount;
  final String destination;

  Cable({required this.name, required this.coreCount, required this.destination});
}

class Connection {
  final String fromCable;
  final int fromCore;
  final String toCable;
  final int toCore;

  Connection({
    required this.fromCable,
    required this.fromCore,
    required this.toCable,
    required this.toCore,
  });
}

class FiberHomeScreen extends StatefulWidget {
  const FiberHomeScreen({super.key});

  @override
  State<FiberHomeScreen> createState() => _FiberHomeScreenState();
}

class _FiberHomeScreenState extends State<FiberHomeScreen> {
  final List<Cable> cables = [];
  final List<Connection> connections = [];

  // Controllers for adding cable
  final nameController = TextEditingController();
  final destController = TextEditingController();
  int selectedCoreCount = 48;

  // Connection selections
  String? sourceCable;
  int sourceCore = 1;
  String? targetCable;
  int targetCore = 1;

  final List<Color> fiberColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.brown,
    Colors.grey,
    Colors.white,
    Colors.red,
    Colors.black,
    Colors.yellow,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  void _addCable() {
    if (nameController.text.isEmpty) return;
    setState(() {
      cables.add(Cable(
        name: nameController.text,
        coreCount: selectedCoreCount,
        destination: destController.text.isEmpty ? 'نامشخص' : destController.text,
      ));
      nameController.clear();
      destController.clear();
    });
    Navigator.pop(context);
  }

  void _addConnection() {
    if (sourceCable == null || targetCable == null) return;
    if (sourceCable == targetCable && sourceCore == targetCore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نمی‌توان یک کر را به خودش وصل کرد!')),
      );
      return;
    }

    setState(() {
      connections.add(Connection(
        fromCable: sourceCable!,
        fromCore: sourceCore,
        toCable: targetCable!,
        toCore: targetCore,
      ));
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت کربندی فیبر نوری'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // کارت آمار سریع
            Row(
              children: [
                _buildStatCard('تعداد کابل‌ها', cables.length.toString(), Colors.blue),
                const SizedBox(width: 10),
                _buildStatCard('اتصالات (مفصل)', connections.length.toString(), Colors.green),
              ],
            ),
            const SizedBox(height: 20),

            // دکمه‌های عملیاتی
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCableDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('کابل جدید'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: cables.length < 2 ? null : () => _showAddConnectionDialog(),
                    icon: const Icon(Icons.cable),
                    label: const Text('ثبت اتصال (Splice)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // لیست کابل‌ها
            const Text('لیست کابل‌ها و مقصدها:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            cables.isEmpty
                ? const Text('هنوز کابلی تعریف نشده است.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cables.length,
                    itemBuilder: (context, index) {
                      final c = cables[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.settings_input_hdmi, color: Colors.indigo),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('تعداد کر: ${c.coreCount} | مقصد: ${c.destination}'),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 25),

            // لیست اتصالات
            const Text('اتصالات ثبت شده (کربندی):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            connections.isEmpty
                ? const Text('هیچ اتصالی ثبت نشده است.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: connections.length,
                    itemBuilder: (context, index) {
                      final conn = connections[index];
                      Color c1Color = fiberColors[(conn.fromCore - 1) % 12];
                      Color c2Color = fiberColors[(conn.toCore - 1) % 12];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // مبدا
                              Row(
                                children: [
                                  CircleAvatar(backgroundColor: c1Color, radius: 8),
                                  const SizedBox(width: 8),
                                  Text('${conn.fromCable} (کر ${conn.fromCore})'),
                                ],
                              ),
                              const Icon(Icons.swap_horiz, color: Colors.grey),
                              // مقصد
                              Row(
                                children: [
                                  Text('${conn.toCable} (کر ${conn.toCore})'),
                                  const SizedBox(width: 8),
                                  CircleAvatar(backgroundColor: c2Color, radius: 8),
                                ],
                              ),
                            ],
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

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن کابل جدید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'نام کابل (مثلاً Cable-48A)'),
            ),
            TextField(
              controller: destController,
              decoration: const InputDecoration(labelText: 'مقصد (مثلاً رک اتاق ۱۰۲)'),
            ),
            DropdownButtonFormField<int>(
              value: selectedCoreCount,
              decoration: const InputDecoration(labelText: 'تعداد کر'),
              items: [6, 12, 24, 48, 96, 144].map((count) {
                return DropdownMenuItem(value: count, child: Text('$count کر'));
              }).toList(),
              onChanged: (val) => selectedCoreCount = val!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(onPressed: _addCable, child: const Text('ذخیره')),
        ],
      ),
    );
  }

  void _showAddConnectionDialog() {
    sourceCable = cables[0].name;
    targetCable = cables.length > 1 ? cables[1].name : cables[0].name;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final sCableObj = cables.firstWhere((c) => c.name == sourceCable);
          final tCableObj = cables.firstWhere((c) => c.name == targetCable);

          return AlertDialog(
            title: const Text('ثبت اتصال کر به کر'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مبدا
                  DropdownButtonFormField<String>(
                    value: sourceCable,
                    decoration: const InputDecoration(labelText: 'کابل مبدا'),
                    items: cables.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        sourceCable = val;
                        sourceCore = 1;
                      });
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: sourceCore,
                    decoration: const InputDecoration(labelText: 'کر مبدا'),
                    items: List.generate(sCableObj.coreCount, (i) => i + 1)
                        .map((i) => DropdownMenuItem(value: i, child: Text('کر $i'))).toList(),
                    onChanged: (val) => setDialogState(() => sourceCore = val!),
                  ),
                  const Divider(),
                  // مقصد
                  DropdownButtonFormField<String>(
                    value: targetCable,
                    decoration: const InputDecoration(labelText: 'کابل مقصد'),
                    items: cables.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        targetCable = val;
                        targetCore = 1;
                      });
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: targetCore,
                    decoration: const InputDecoration(labelText: 'کر مقصد'),
                    items: List.generate(tCableObj.coreCount, (i) => i + 1)
                        .map((i) => DropdownMenuItem(value: i, child: Text('کر $i'))).toList(),
                    onChanged: (val) => setDialogState(() => targetCore = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
              ElevatedButton(onPressed: _addConnection, child: const Text('ثبت اتصال')),
            ],
          );
        },
      ),
    );
  }
}
