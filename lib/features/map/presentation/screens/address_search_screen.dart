import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/core/constants/api_constants.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
import 'package:tufan_rider/gen/assets.gen.dart';
import 'package:http/http.dart' as http;

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({
    super.key,
  });

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final FocusNode fromFocusNode = FocusNode();
  final FocusNode toFocusNode = FocusNode();

  bool isFromFocused = false;
  bool isToFocused = false;

  List<Map<String, dynamic>> fromSuggestions = [];
  List<Map<String, dynamic>> toSuggestions = [];

  bool isSearchingFrom = false;

  Timer? _debounce;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  void fetchAddress() {
    final addressCubit = locator.get<AddressCubit>();
    final source = addressCubit.source;
    final destination = addressCubit.destination;

    setState(() {
      if (source != null) fromController.text = source!.name ?? '';
      if (destination != null) toController.text = destination!.name ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> fetchGooglePlaces(String input) async {
    if (input.isEmpty) return [];

    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String url =
        '$baseUrl?input=$input&key=${ApiConstants.mapAPI}&components=country:np';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List<dynamic>;
      return predictions.map((p) {
        return {
          'description': p['description'],
          'place_id': p['place_id'],
        };
      }).toList();
    } else {
      debugPrint('Failed to fetch places: ${response.body}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
    final String url = '$baseUrl?place_id=$placeId&key=${ApiConstants.mapAPI}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['result'];
      final location = result['geometry']['location'];
      return {
        'lat': location['lat'],
        'lng': location['lng'],
        'address': result['formatted_address'],
        'name': result['name'],
      };
    } else {
      debugPrint('Failed to fetch place details: ${response.body}');
      return null;
    }
  }

  void _onSearchChanged({required bool isFrom, required String query}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await fetchGooglePlaces(query);
      setState(() {
        if (isFrom) {
          fromSuggestions = results;
        } else {
          toSuggestions = results;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    fetchAddress();

    fromFocusNode.addListener(() {
      setState(() => isFromFocused = fromFocusNode.hasFocus);
    });
    toFocusNode.addListener(() {
      setState(() => isToFocused = toFocusNode.hasFocus);
    });

    // 2️⃣ Then schedule a post‐frame callback to grab the Navigator arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        setState(() {
          // Update your focus flags from the passed args
          isFromFocused = args['isFromFocused'] ?? isFromFocused;
          isToFocused = args['isToFocused'] ?? isToFocused;
        });

        // 3️⃣ Optionally request focus based on those flags
        if (isFromFocused) {
          FocusScope.of(context).requestFocus(fromFocusNode);
        } else if (isToFocused) {
          FocusScope.of(context).requestFocus(toFocusNode);
        }
      }
    });
  }

  @override
  void dispose() {
    fromFocusNode.dispose();
    toFocusNode.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define an InputDecorationTheme that applies an OutlineInputBorder
    // with your primaryColor when focused, black when not.
    final customInputTheme = InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
      isDense: true,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixStyle: const TextStyle(fontSize: 16, color: Colors.black),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlack, width: 2),
      ),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: customInputTheme,
      ),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              "Choose your route",
              style: AppTypography.headline.copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.done),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // From Field
                TextField(
                  focusNode: fromFocusNode,
                  controller: fromController,
                  decoration: const InputDecoration(
                    labelText: "From",
                    prefixIcon: Icon(Icons.my_location),
                    hintText: "Enter starting location",
                  ),
                  onChanged: (value) {
                    _onSearchChanged(isFrom: true, query: value);
                  },
                ),

                const SizedBox(height: 16),

                // To Field
                TextField(
                  focusNode: toFocusNode,
                  controller: toController,
                  decoration: const InputDecoration(
                    labelText: "To",
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: "Enter destination",
                  ),
                  onChanged: (value) {
                    _onSearchChanged(isFrom: false, query: value);
                  },
                ),

                const SizedBox(height: 16),

                // "Set on Map" button
                GestureDetector(
                  onTap: () => Navigator.pop(context, {
                    'isFromFocused': isFromFocused,
                    'isToFocused': isToFocused
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Assets.icons.carbonMap.path,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        Text('Set on Map', style: AppTypography.paragraph),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Autocomplete results
                Expanded(
                  child: ListView.separated(
                    itemCount: isFromFocused
                        ? fromSuggestions.length
                        : toSuggestions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final suggestion = isFromFocused
                          ? fromSuggestions[index]
                          : toSuggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.place),
                        title: Text(suggestion['description'] ?? ''),
                        onTap: () async {
                          final details =
                              await fetchPlaceDetails(suggestion['place_id']!);

                          if (details != null) {
                            final cubit = locator.get<AddressCubit>();

                            if (isFromFocused) {
                              fromController.text = details['address'] ?? '';
                              cubit.setSource(RideLocation(
                                  lat: details['lat'],
                                  lng: details['lng'],
                                  name: suggestion[
                                      'description'])); // Save source with lat, lng, address

                              setState(() => fromSuggestions = []);
                            } else {
                              toController.text =
                                  suggestion['description'] ?? '';
                              cubit.setDestination(RideLocation(
                                  lat: details['lat'],
                                  lng: details['lng'],
                                  name: suggestion[
                                      'description'])); // Save source with lat, lng, address

                              setState(() => toSuggestions = []);

                              if (fromController.text.isNotEmpty &&
                                  toController.text.isNotEmpty) {
                                Navigator.pop(context);
                              }
                            }
                          }
                        },
                      );
                    },
                  ),
                ),

                CustomButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
