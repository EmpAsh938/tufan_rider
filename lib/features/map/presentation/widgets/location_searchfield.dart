import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tufan_rider/core/constants/api_constants.dart';

class Place {
  final String description;
  final String placeId;

  Place({required this.description, required this.placeId});
}

class LocationSearchField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String imagePath;
  final TextEditingController controller;

  const LocationSearchField({
    required this.label,
    required this.icon,
    required this.imagePath,
    required this.controller,
    super.key,
  });

  Future<List<Place>> getGooglePlaceSuggestions(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${ApiConstants.mapAPI}&components=country:np';

    final response = await http.get(Uri.parse(url));

    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return (data['predictions'] as List)
            .map((p) => Place(
                  description: p['description'],
                  placeId: p['place_id'],
                ))
            .toList();
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Place>(
      suggestionsCallback: (search) async {
        if (search.trim().isEmpty) {
          return []; // 🚫 Don't show anything on empty input
        }

        return await getGooglePlaceSuggestions(search);
      },
      builder: (context, textController, focusNode) {
        textController.addListener(() {
          if (textController.text != controller.text) {
            controller.text = textController.text;
            controller.selection = textController.selection;
          }
        });
        return TextField(
          controller: textController, // Bind to your main controller
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(imagePath, width: 20),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      itemBuilder: (context, place) {
        return ListTile(
          leading: Icon(Icons.location_on),
          title: Text(place.description),
        );
      },
      onSelected: (place) {
        controller.text = place.description;
        // Optional: Fetch place details here if you need LatLng
      },
    );
  }
}
