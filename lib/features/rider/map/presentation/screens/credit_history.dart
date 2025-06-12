import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/rider_payment_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/rider_payment_state.dart';

class CreditHistory extends StatefulWidget {
  const CreditHistory({super.key});

  @override
  State<CreditHistory> createState() => _CreditHistoryState();
}

class _CreditHistoryState extends State<CreditHistory> {
  @override
  void initState() {
    super.initState();
    final riderResponse = context.read<CreateRiderCubit>().riderResponse;
    if (riderResponse != null) {
      context
          .read<RiderPaymentCubit>()
          .getTransactionHistory(riderResponse.id.toString(), 'token');
    }
  }

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
              if (transactions.isEmpty) {
                return const Center(
                  child: Text('No transactions available.'),
                );
              }
              return ListView.builder(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Ensures scrolling works
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final dateTimeList = transaction['dateTime'];
                  final dateTime = DateTime(
                    dateTimeList[0],
                    dateTimeList[1],
                    dateTimeList[2],
                    dateTimeList[3],
                    dateTimeList[4],
                    dateTimeList[5],
                    (dateTimeList.length > 6) ? (dateTimeList[6] ~/ 1000) : 0,
                  );

                  final formattedDate =
                      DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

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
                                transaction['type'] == 'CREDIT'
                                    ? 'Credit Loaded'
                                    : 'Credit Deducted',
                                style: AppTypography.labelText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: transaction['type'] == 'CREDIT'
                                      ? AppColors.primaryGreen
                                      : AppColors.primaryRed,
                                ),
                              ),
                              Text(
                                '${transaction['amount']} NPR',
                                style: AppTypography.labelText.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formattedDate,
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
