import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/page_transitions.dart';
import '../providers/payment_provider.dart';
import 'smart_payment_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    // Load payment methods when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.slideFromRight(const SmartPaymentScreen()),
              );
            },
            tooltip: 'Add Payment Method',
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (paymentProvider.isEmpty) {
            return _buildEmptyState();
          }

          return _buildPaymentMethodsList(paymentProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payment_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No payment methods added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add your cards or payment methods for quick and secure checkout',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransitions.slideFromRight(const SmartPaymentScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your payment information is secure and encrypted',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList(PaymentProvider paymentProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paymentProvider.paymentMethods.length,
      itemBuilder: (context, index) {
        final method = paymentProvider.paymentMethods[index];
        return _buildPaymentMethodCard(method, paymentProvider);
      },
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, PaymentProvider paymentProvider) {
    final isDefault = method['isDefault'] == true;
    final cardLastFour = method['cardLastFour'] ?? '****';
    final cardBrand = method['cardBrand'] ?? 'Card';
    final expiryMonth = method['cardExpMonth'] ?? 0;
    final expiryYear = method['cardExpYear'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCardIcon(cardBrand),
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          '$cardBrand •••• $cardLastFour',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Expires ${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (!isDefault)
              IconButton(
                icon: const Icon(Icons.star_outline),
                onPressed: () => _setAsDefault(method['id'], paymentProvider),
                tooltip: 'Set as Default',
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _showDeleteDialog(method, paymentProvider),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCardIcon(String cardBrand) {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  void _setAsDefault(String paymentMethodId, PaymentProvider paymentProvider) async {
    final success = await paymentProvider.setDefaultPaymentMethod(paymentMethodId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method set as default'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set as default: ${paymentProvider.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteDialog(Map<String, dynamic> method, PaymentProvider paymentProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${method['cardBrand']} •••• ${method['cardLastFour']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePaymentMethod(method['id'], paymentProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePaymentMethod(String paymentMethodId, PaymentProvider paymentProvider) async {
    final success = await paymentProvider.deletePaymentMethod(paymentMethodId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete payment method: ${paymentProvider.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}