import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/product_model.dart';
import '../services/duplicate_product_service.dart';
import '../services/error_service.dart';

class DuplicateProductDialog extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onSuccess;

  const DuplicateProductDialog({
    super.key,
    required this.product,
    this.onSuccess,
  });

  @override
  State<DuplicateProductDialog> createState() => _DuplicateProductDialogState();
}

class _DuplicateProductDialogState extends State<DuplicateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _customBrandController = TextEditingController();
  final _conditionController = TextEditingController();
  final _styleController = TextEditingController();
  final _colorController = TextEditingController();
  final _hashtagsController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = '${widget.product.name} (Copy)';
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();
    _discountPriceController.text = widget.product.discountPrice?.toString() ?? '0.00';
    _customBrandController.text = widget.product.specifications['Brand'] ?? '';
    
    // Initialize additional fields from product specifications
    _conditionController.text = widget.product.specifications['Condition'] ?? '';
    _styleController.text = widget.product.specifications['Style'] ?? '';
    _colorController.text = widget.product.specifications['Color'] ?? '';
    _hashtagsController.text = widget.product.specifications['Hashtags'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _customBrandController.dispose();
    _conditionController.dispose();
    _styleController.dispose();
    _colorController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }

  Future<void> _duplicateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Parse colors from comma-separated string
      List<String>? colors;
      if (_colorController.text.trim().isNotEmpty) {
        colors = _colorController.text.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
      }
      
      // Parse hashtags from comma-separated string
      List<String>? hashtags;
      if (_hashtagsController.text.trim().isNotEmpty) {
        hashtags = _hashtagsController.text.split(',').map((h) => h.trim()).where((h) => h.isNotEmpty).toList();
      }

      final result = await DuplicateProductService.duplicateProduct(
        productId: int.parse(widget.product.id),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text),
        discountPrice: double.tryParse(_discountPriceController.text),
        condition: _conditionController.text.trim().isNotEmpty ? _conditionController.text.trim() : null,
        style: _styleController.text.trim().isNotEmpty ? _styleController.text.trim() : null,
        color: colors,
        customBrand: _customBrandController.text.trim().isNotEmpty 
            ? _customBrandController.text.trim() 
            : null,
      );

      if (result != null && result['success'] == true) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Product duplicated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        
        widget.onSuccess?.call();
        Navigator.of(context).pop();
      } else {
        throw Exception(result?['message'] ?? 'Failed to duplicate product');
      }
    } catch (e) {
      setState(() {
        _error = e is AppError ? e.userMessage : e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.copy_all,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Duplicate Product',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Create a copy of "${widget.product.name}" with your modifications.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: AppColors.error, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Product Name',
                        hint: 'Enter product name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter product description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Price',
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Price is required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _discountPriceController,
                              label: 'Discount Price',
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (double.tryParse(value) == null) {
                                    return 'Enter a valid price';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _customBrandController,
                        label: 'Custom Brand (Optional)',
                        hint: 'Enter custom brand name',
                      ),
                      const SizedBox(height: 16),
                      
                      // Additional product metadata fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _conditionController,
                              label: 'Condition',
                              hint: 'e.g., New, Used, Like New',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _styleController,
                              label: 'Style',
                              hint: 'e.g., Casual, Formal, Sporty',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _colorController,
                        label: 'Colors (comma-separated)',
                        hint: 'e.g., Red, Blue, Green',
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _hashtagsController,
                        label: 'Hashtags (comma-separated)',
                        hint: 'e.g., #summer, #cotton, #organic',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _duplicateProduct,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Duplicate Product'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
