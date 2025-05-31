import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';

class CustomRating extends StatefulWidget {
  final String riderId;
  final double size;

  const CustomRating({
    super.key,
    required this.riderId,
    this.size = 16, // optional: allow customizing the star size
  });

  @override
  State<CustomRating> createState() => _CustomRatingState();
}

class _CustomRatingState extends State<CustomRating> {
  double _rating = 0.0;

  Future<void> fetchRating() async {
    final rating =
        await context.read<CreateRiderCubit>().averageRating(widget.riderId);

    setState(() {
      _rating = rating;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRating();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: widget.size,
          ignoreGestures: true, // makes it read-only
          itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: AppColors.primaryColor,
          ),
          onRatingUpdate: (rating) {},
        ),
        const SizedBox(width: 4),
        Text(
          _rating.toStringAsFixed(1),
          style: AppTypography.labelText.copyWith(
            color: AppColors.primaryBlack.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
