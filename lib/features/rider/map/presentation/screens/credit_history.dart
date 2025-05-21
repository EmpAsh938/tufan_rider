import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/features/rider/map/cubit/rider_payment_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/rider_payment_state.dart';

class CreditHistory extends StatefulWidget {
  const CreditHistory({super.key});

  @override
  State<CreditHistory> createState() => _CreditHistoryState();
}

class _CreditHistoryState extends State<CreditHistory> {
  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'loaded',
      'amount': 500,
      'date': '2023-05-15',
      'time': '10:30 AM',
    },
    {
      'type': 'deducted',
      'amount': 100,
      'date': '2023-05-14',
      'time': '02:15 PM',
    },
    {
      'type': 'loaded',
      'amount': 300,
      'date': '2023-05-10',
      'time': '09:45 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text('Credit Transaction History'),
        ),
        body: BlocBuilder<RiderPaymentCubit, RiderPaymentState>(
          builder: (context, state) {
            if (state is RiderPaymentFetching) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RiderPaymentFetched) {
              final transactions = state.transactions;
              return ListView.builder(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Ensures scrolling works
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                transaction['type'] == 'loaded'
                                    ? 'Credit Loaded'
                                    : 'Credit Deducted',
                                style: AppTypography.labelText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: transaction['type'] == 'loaded'
                                      ? AppColors.primaryGreen
                                      : AppColors.primaryRed,
                                ),
                              ),
                              Text(
                                '${transaction['balance']} NPR',
                                style: AppTypography.labelText.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // '${transaction.date} • ${transaction.time}',
                            '2024-05-14',
                            style: AppTypography.paragraph.copyWith(
                              color: AppColors.primaryBlack.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is RiderPaymentError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTypography.paragraph.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No transactions available.'));
            }
          },
        ),
      ),
    );
  }
}
