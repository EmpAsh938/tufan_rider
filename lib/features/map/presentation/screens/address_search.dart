import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';

class AddressSearch extends StatelessWidget {
  const AddressSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: Text(
          "Choose your route",
          style: AppTypography.headline.copyWith(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // From Field
            TextField(
              decoration: InputDecoration(
                labelText: "From",
                prefixIcon: const Icon(Icons.my_location),
                hintText: "Enter starting location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // handle "from" input change
              },
            ),

            const SizedBox(height: 16),

            // To Field
            TextField(
              decoration: InputDecoration(
                labelText: "To",
                prefixIcon: const Icon(Icons.location_on_outlined),
                hintText: "Enter destination",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // handle "to" input change
              },
            ),

            const SizedBox(height: 24),

            // Placeholder for autocomplete results
            Expanded(
              child: ListView.separated(
                itemCount: 5, // mock data
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.place),
                    title: Text("Suggested Place #${index + 1}"),
                    subtitle: const Text("Place address here"),
                    onTap: () {
                      // handle suggestion tap
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
