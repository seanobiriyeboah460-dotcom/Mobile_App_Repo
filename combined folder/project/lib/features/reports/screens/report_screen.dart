import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/services/transactions_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class ReportsScreen extends StatefulWidget {
  final String userId;
  const ReportsScreen({super.key, required this.userId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TransactionService _transactionService = TransactionService();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(_months[index]),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMonth = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stream for monthly data
            StreamBuilder<List<TransactionModel>>(
              stream: _transactionService.getTransactionsByMonth(
                widget.userId,
                _selectedMonth,
                _selectedYear,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data ?? [];

                double totalIncome = 0;
                double totalExpenses = 0;
                Map<String, double> expenseByCategory = {};

                for (final tx in transactions) {
                  if (tx.isIncome) {
                    totalIncome += tx.amount;
                  } else {
                    totalExpenses += tx.amount;
                    expenseByCategory[tx.category] =
                        (expenseByCategory[tx.category] ?? 0) + tx.amount;
                  }
                }

                final netSavings = totalIncome - totalExpenses;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Income',
                            amount: totalIncome,
                            color: AppColors.income,
                            icon: Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Expenses',
                            amount: totalExpenses,
                            color: AppColors.expense,
                            icon: Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Net Savings Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: netSavings >= 0
                            ? AppColors.income.withOpacity(0.1)
                            : AppColors.expense.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: netSavings >= 0
                              ? AppColors.income
                              : AppColors.expense,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Savings',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(netSavings.abs()),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: netSavings >= 0
                                  ? AppColors.income
                                  : AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (transactions.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            const Icon(
                              Icons.bar_chart_outlined,
                              size: 64,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions for ${_months[_selectedMonth - 1]}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Income vs Expense Bar Chart
                      const Text(
                        'Income vs Expenses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY:
                                (totalIncome > totalExpenses
                                    ? totalIncome
                                    : totalExpenses) *
                                1.2,
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: totalIncome,
                                    color: AppColors.income,
                                    width: 40,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: totalExpenses,
                                    color: AppColors.expense,
                                    width: 40,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text(
                                          'Income',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.income,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      case 1:
                                        return const Text(
                                          'Expenses',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.expense,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      default:
                                        return const Text('');
                                    }
                                  },
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Expense Breakdown
                      if (expenseByCategory.isNotEmpty) ...[
                        const Text(
                          'Expense Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...expenseByCategory.entries.map((entry) {
                          final percent = totalExpenses > 0
                              ? (entry.value / totalExpenses * 100)
                                    .toStringAsFixed(1)
                              : '0';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(entry.value),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.expense,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$percent%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: totalExpenses > 0
                                        ? entry.value / totalExpenses
                                        : 0,
                                    minHeight: 6,
                                    backgroundColor: AppColors.surfaceGrey,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.expense,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      // Recent Transactions
                      const SizedBox(height: 8),
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...transactions.take(5).map((tx) {
                        final isIncome = tx.isIncome;
                        final color = isIncome
                            ? AppColors.income
                            : AppColors.expense;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: color,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tx.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
