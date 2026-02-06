import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GigListTile extends StatelessWidget {
  const GigListTile({
    super.key,
    required this.title,
    required this.pay,
    required this.hourlyRate,
    required this.distanceMiles,
    required this.deadline,
    required this.onTap,
  });

  final String title;
  final double pay;
  final double hourlyRate;
  final double distanceMiles;
  final DateTime deadline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deadlineLabel = DateFormat('MMM d, h:mm a').format(deadline);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text('Deadline $deadlineLabel • ${distanceMiles.toStringAsFixed(1)} mi'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${pay.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('\$${hourlyRate.toStringAsFixed(2)}/hr'),
          ],
        ),
      ),
    );
  }
}
