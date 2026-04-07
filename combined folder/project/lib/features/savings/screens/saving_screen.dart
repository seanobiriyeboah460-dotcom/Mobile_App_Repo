import 'package:flutter/material.dart';
import '../../auth/models/savings_goal_model.dart';
import '../services/saving_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/screens/add_savings_goal_screen.dart';

class SavingsScreen extends StatefulWidget {
  final String userId;
  const SavingsScreen({super.key, required this.userId});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final SavingsService _savingsService = SavingsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Savings Goals'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<SavingsGoalModel>>(
        stream: _savingsService.getGoals(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading goals',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No savings goals yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to create your first goal',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openAddGoal(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Goal'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 48),
                      backgroundColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            );
          }

          // Summary header
          final totalTarget = goals.fold(0.0, (sum, g) => sum + g.targetAmount);
          final totalSaved = goals.fold(0.0, (sum, g) => sum + g.savedAmount);
          final completed = goals.where((g) => g.isCompleted).length;

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Saved',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(totalSaved),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'of ${CurrencyFormatter.format(totalTarget)}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${goals.length}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Goals',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completed Completed',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Goals List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    return _GoalCard(
                      goal: goals[index],
                      onAddMoney: () => _showAddMoneyDialog(goals[index]),
                      onDelete: () => _deleteGoal(goals[index].id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _openAddGoal,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  void _openAddGoal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSavingsGoalScreen(userId: widget.userId),
      ),
    );
  }

  Future<void> _showAddMoneyDialog(SavingsGoalModel goal) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to "${goal.title}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Amount (GH₵)',
            prefixIcon: Icon(Icons.monetization_on_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim());
              if (amount != null && amount > 0) {
                await _savingsService.addToGoal(
                  goal.id,
                  goal.savedAmount,
                  amount,
                );
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(String goalId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _savingsService.deleteGoal(goalId);
    }
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback onAddMoney;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onAddMoney,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = goal.isCompleted ? AppColors.income : AppColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  goal.isCompleted
                      ? Icons.check_circle_outline
                      : Icons.savings_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      goal.isCompleted
                          ? 'Goal completed! 🎉'
                          : '${goal.daysRemaining} days remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: goal.isCompleted
                            ? AppColors.income
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textLight,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceGrey,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),

          // Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormatter.format(goal.savedAmount)} saved',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                goal.progressPercent,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'of ${CurrencyFormatter.format(goal.targetAmount)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Add Money Button
          if (!goal.isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddMoney,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Money'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
