import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DashboardSimplified extends StatelessWidget {
  const DashboardSimplified({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        height: 80,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShadCard(
              title: Text("Devices offline", style: TextStyle(fontSize: 10)),
              child: Text("0"),
            ),
            ShadCard(
              title: Text("Devices offline", style: TextStyle(fontSize: 10)),
              child: Text("0"),
            ),
            ShadCard(
              title: Text("Devices offline", style: TextStyle(fontSize: 10)),
              child: Text("0"),
            ),
          ],
        ),
      ),
    );
  }
}
