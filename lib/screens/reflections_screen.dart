import 'package:flutter/material.dart';
import '../widgets/paper_card.dart';

class ReflectionsScreen extends StatelessWidget {
  const ReflectionsScreen({super.key});

  final List<Map<String, String>> reflections = const [
    {'title': 'Morning Prayer', 'body': 'Lord, give me strength to choose rightly today...'},
    {'title': 'Short Reflection', 'body': 'Whenever temptation comes, remember why you started.'},
    {'title': 'Evening Examen', 'body': 'Review your day with gratitude and resolve.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Reflections'), backgroundColor: Colors.transparent, foregroundColor: const Color(0xFF2B2B2B)),
      body: ListView.builder(
        itemCount: reflections.length,
        itemBuilder: (_, i) {
          final r = reflections[i];
          return PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(r['body']!),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [TextButton(onPressed: () {}, child: const Text('Mark prayed'))],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
