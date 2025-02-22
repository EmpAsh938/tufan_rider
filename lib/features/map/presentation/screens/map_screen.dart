import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';

class MapBookingScreen extends StatefulWidget {
  const MapBookingScreen({super.key});

  @override
  State<MapBookingScreen> createState() => _MapBookingScreenState();
}

class _MapBookingScreenState extends State<MapBookingScreen> {
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Placeholder for map section (Insert Map here)
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/map_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.35,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Notch Handle
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SelectableIconsRow(),
                              SizedBox(height: 10),
                              buildLocationField(
                                label: "From",
                                icon: Icons.location_on_outlined,
                                imagePath:
                                    'assets/icons/location_pin_source.png',
                              ),
                              SizedBox(height: 10),
                              buildLocationField(
                                label: "To",
                                icon: Icons.location_on_outlined,
                                imagePath:
                                    'assets/icons/location_pin_destination.png',
                              ),
                              SizedBox(height: 30),
                              InkWell(
                                onTap: () {
                                  // Handle tap event
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryWhite,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.gray),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/carbon_map.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Set on Map',
                                        style: AppTypography.paragraph,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Previous History",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              ...List.generate(
                                4,
                                (index) => ListTile(
                                  leading: Icon(Icons.history,
                                      color: Colors.orangeAccent),
                                  title: Text("Sallaghari, Araniko Highway"),
                                  trailing:
                                      Icon(Icons.arrow_forward_ios, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.all(1), // Adds space around the icon
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite, // Background color
                  borderRadius: BorderRadius.circular(15), // Makes it circular
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlack
                          .withOpacity(0.1), // Optional shadow
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Builder(builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.primaryBlack,
                      size: 30,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }

  Widget buildLocationField(
      {required String label,
      required IconData icon,
      required String imagePath}) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Image.asset(imagePath),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.gray,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: Image.asset(
          'assets/icons/material-symbols_search.png',
        ),
      ),
    );
  }
}

class SelectableIconsRow extends StatefulWidget {
  const SelectableIconsRow({super.key});

  @override
  State<SelectableIconsRow> createState() => _SelectableIconsRowState();
}

class _SelectableIconsRowState extends State<SelectableIconsRow> {
  String selectedIcon = ''; // Keep track of the selected icon

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSelectableIcon(
          imagePath: 'assets/icons/bike.png',
          isSelected: selectedIcon == 'bike',
          onTap: () => setState(() => selectedIcon = 'bike'),
        ),
        const SizedBox(width: 30),
        const SizedBox(
          height: 80,
          child: VerticalDivider(
            thickness: 2,
            width: 2,
            color: AppColors.gray,
          ),
        ),
        const SizedBox(width: 30),
        _buildSelectableIcon(
          imagePath: 'assets/icons/car.png',
          isSelected: selectedIcon == 'car',
          onTap: () => setState(() => selectedIcon = 'car'),
        ),
      ],
    );
  }

  Widget _buildSelectableIcon({
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.neutralColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
