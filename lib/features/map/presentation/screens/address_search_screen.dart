import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final FocusNode fromFocusNode = FocusNode();
  final FocusNode toFocusNode = FocusNode();

  bool isFromFocused = false;
  bool isToFocused = false;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  @override
  void initState() {
    super.initState();

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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Choose your route",
            style: AppTypography.headline.copyWith(fontSize: 18),
          ),
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
                onChanged: (value) {},
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
                onChanged: (value) {},
              ),

              const SizedBox(height: 16),

              // "Set on Map" button
              GestureDetector(
                onTap: () => Navigator.pop(context, {
                  'isFromFocused': isFromFocused,
                  'isToFocused': isToFocused
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  itemCount: 5,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.place),
                      title: Text("Suggested Place #${index + 1}"),
                      subtitle: const Text("Place address here"),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
