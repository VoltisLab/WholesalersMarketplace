import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../widgets/modal_dropdown.dart';
import '../services/graphql_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';
import '../services/product_service.dart';
import '../services/aws_s3_service.dart';
import '../providers/enhanced_product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _brandController = TextEditingController();
  final _customTagsController = TextEditingController();
  final _customProcessingDaysController = TextEditingController();
  final _deliveryTimeController = TextEditingController();

  String _selectedCategory = '';
  String _selectedCondition = 'NEW';
  String _selectedSize = '';
  String _selectedBrand = '';
  List<String> _selectedTags = [];
  List<File> _selectedImages = [];
  bool _isVintage = false;
  bool _isSustainable = false;
  bool _isHandmade = false;
  bool _isNegotiable = true;
  bool _isShippingIncluded = false;
  String _shippingMethod = 'STANDARD';
  int _processingTime = 1;
  bool _useCustomProcessingDays = false;
  String _generatedSku = '';
  
  // Upload progress tracking
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  int _currentImageIndex = 0;
  int _totalImages = 0;

  List<Map<String, dynamic>> _categories = [];
  final Map<String, int> _categoryNameToId = {};

  final List<String> _conditions = [
    'NEW',
    'LIKE_NEW',
    'GOOD',
    'FAIR',
    'POOR',
  ];

  final List<String> _sizes = [
    'XS', 'S', 'M', 'L', 'XL', 'XXL',
    'UK 4', 'UK 6', 'UK 8', 'UK 10', 'UK 12', 'UK 14', 'UK 16',
    'US 0', 'US 2', 'US 4', 'US 6', 'US 8', 'US 10', 'US 12', 'US 14',
    'EU 32', 'EU 34', 'EU 36', 'EU 38', 'EU 40', 'EU 42', 'EU 44', 'EU 46',
    'One Size', 'Custom'
  ];

  final List<String> _popularTags = [
    'Vintage', 'Y2K', 'Cottagecore', 'Dark Academia', 'Streetwear',
    'Minimalist', 'Boho', 'Grunge', 'Preppy', 'Gothic', 'Kawaii',
    'Sustainable', 'Handmade', 'Designer', 'Luxury', 'Affordable'
  ];

  final List<String> _brands = [
    'Nike', 'Adidas', 'Zara', 'H&M', 'Uniqlo', 'Gap', 'Levi\'s', 'Tommy Hilfiger',
    'Calvin Klein', 'Ralph Lauren', 'Gucci', 'Prada', 'Chanel', 'Louis Vuitton',
    'Versace', 'Armani', 'Burberry', 'Hermès', 'Dior', 'Balenciaga', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _generateSku();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _brandController.dispose();
    _customTagsController.dispose();
    _customProcessingDaysController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fillMockData,
            icon: const Icon(
              Icons.auto_fix_high,
              color: AppColors.primary,
              size: 20,
            ),
            tooltip: 'Fill Mock Data',
          ),
          TextButton(
            onPressed: _saveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildPricingSection(),
              const SizedBox(height: 24),
              _buildDetailsSection(),
              const SizedBox(height: 24),
              _buildShippingSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildSpecialFeaturesSection(),
              const SizedBox(height: 40),
              _buildPublishButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add up to 10 photos. First photo will be your cover image.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        _selectedImages.isEmpty
            ? _buildAddImageButton()
            : _buildImageGrid(),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Add Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select from gallery',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length + (_selectedImages.length < 10 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return _buildAddMoreButton();
        }
        return _buildImageItem(_selectedImages[index], index);
      },
    );
  }

  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Cover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _titleController,
          label: 'Product Title',
          hint: 'e.g., Vintage 90s Denim Jacket',
          maxLines: 1,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a product title';
            }
            if (value.length < 10) {
              return 'Title must be at least 10 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Tell buyers about your item...',
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            if (value.length < 20) {
              return 'Description must be at least 20 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModalDropdown(
          label: 'Category',
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          items: _categories.map((cat) => cat['name'] as String).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value ?? ''),
          icon: Icons.category_outlined,
          hint: 'Select category',
          validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModalDropdown(
                label: 'Condition',
                value: _selectedCondition,
                items: _conditions,
                onChanged: (value) => setState(() => _selectedCondition = value ?? 'NEW'),
                icon: Icons.verified_outlined,
                hint: 'Select condition',
                itemSubtitles: {
                  'New': 'Brand new item that has never been used',
                  'Like New': 'Gently used with minimal signs of wear',
                  'Used/2nd hand': 'Previously owned item in good working condition',
                  'Good': 'Used with some signs of wear but still functional',
                  'Fair': 'Well-used with visible wear but works properly',
                  'Poor': 'Heavily used with significant wear or damage',
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ModalDropdown(
                label: 'Size',
                value: _selectedSize.isEmpty ? null : _selectedSize,
                items: _sizes,
                onChanged: (value) => setState(() => _selectedSize = value ?? ''),
                icon: Icons.straighten_outlined,
                hint: 'Select size',
                validator: (value) => value == null || value.isEmpty ? 'Please select a size' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModalDropdown(
                label: 'Brand',
                value: _selectedBrand.isEmpty ? null : _selectedBrand,
                items: _brands,
                onChanged: (value) => setState(() => _selectedBrand = value ?? ''),
                icon: Icons.branding_watermark_outlined,
                hint: 'Select brand',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: TextEditingController(text: _generatedSku),
                label: 'SKU (Auto-generated)',
                hint: 'Auto-generated',
                enabled: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Selling Price',
                hint: '0.00',
                keyboardType: TextInputType.number,
                prefix: Container(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: const Text(
                    '£',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _originalPriceController,
                label: 'Original Price (Optional)',
                hint: '0.00',
                keyboardType: TextInputType.number,
                prefix: Container(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: const Text(
                    '£',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _quantityController,
          label: 'Quantity Available',
          hint: '1',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter quantity';
            }
            if (int.tryParse(value) == null || int.parse(value) < 1) {
              return 'Please enter a valid quantity';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: const Text(
                  'Price Negotiable',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Allow buyers to make offers',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isNegotiable,
                onChanged: (value) => setState(() => _isNegotiable = value),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (Optional)',
                hint: 'e.g., 500g',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _dimensionsController,
                label: 'Dimensions (Optional)',
                hint: 'L x W x H cm',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShippingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text(
            'Shipping Included',
            style: TextStyle(fontSize: 14),
          ),
          subtitle: const Text(
            'Include shipping cost in price',
            style: TextStyle(fontSize: 12),
          ),
          value: _isShippingIncluded,
          onChanged: (value) => setState(() => _isShippingIncluded = value),
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
        const SizedBox(height: 16),
        ModalDropdown(
          label: 'Shipping Method',
          value: _shippingMethod,
          items: ['STANDARD', 'EXPRESS', 'NEXT_DAY', 'COLLECTION_ONLY'],
          onChanged: (value) => setState(() => _shippingMethod = value ?? 'STANDARD'),
          icon: Icons.local_shipping_outlined,
          hint: 'Select shipping method',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModalDropdown(
                label: 'Processing Time',
                value: _useCustomProcessingDays ? 'Custom' : _processingTime.toString(),
                items: ['1', '2', '3', '5', '7', '14', 'Custom'],
                onChanged: (value) {
                  if (value == 'Custom') {
                    setState(() => _useCustomProcessingDays = true);
                  } else {
                    setState(() {
                      _useCustomProcessingDays = false;
                      _processingTime = int.parse(value ?? '1');
                    });
                  }
                },
                icon: Icons.schedule_outlined,
                hint: 'Select processing time',
              ),
            ),
            if (_useCustomProcessingDays) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _customProcessingDaysController,
                  label: 'Custom Days',
                  hint: 'e.g., 10',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _deliveryTimeController,
          label: 'Estimated Delivery Time',
          hint: 'e.g., 3-5 business days',
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add tags to help buyers find your item',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else if (_selectedTags.length < 5) {
                    _selectedTags.add(tag);
                  }
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _customTagsController,
          label: 'Add Custom Tags',
          hint: 'Enter custom tags separated by commas',
          onSubmitted: _addCustomTags,
        ),
        if (_selectedTags.length >= 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Maximum 5 tags selected',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecialFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text(
            'Vintage Item',
            style: TextStyle(fontSize: 14),
          ),
          subtitle: const Text(
            'Item is from a previous era',
            style: TextStyle(fontSize: 12),
          ),
          value: _isVintage,
          onChanged: (value) => setState(() => _isVintage = value),
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text(
            'Sustainable',
            style: TextStyle(fontSize: 14),
          ),
          subtitle: const Text(
            'Eco-friendly or sustainable item',
            style: TextStyle(fontSize: 12),
          ),
          value: _isSustainable,
          onChanged: (value) => setState(() => _isSustainable = value),
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text(
            'Handmade',
            style: TextStyle(fontSize: 14),
          ),
          subtitle: const Text(
            'Item is handmade or custom',
            style: TextStyle(fontSize: 12),
          ),
          value: _isHandmade,
          onChanged: (value) => setState(() => _isHandmade = value),
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _publishProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Publish Product',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? prefix,
    String? Function(String?)? validator,
    bool enabled = true,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
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
          enabled: enabled,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefix: prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }


  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        for (XFile image in images) {
          if (_selectedImages.length < 10) {
            _selectedImages.add(File(image.path));
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _fillMockData() {
    setState(() {
      // Basic product information
      _titleController.text = 'Premium Cotton T-Shirt - Summer Collection';
      _descriptionController.text = 'High-quality 100% organic cotton t-shirt perfect for summer. Soft, breathable, and comfortable. Available in multiple colors and sizes. Perfect for casual wear or layering. Machine washable and colorfast.';
      _priceController.text = '29.99';
      _originalPriceController.text = '39.99';
      _quantityController.text = '100';
      _weightController.text = '0.2';
      _dimensionsController.text = 'Length: 70cm, Chest: 50cm, Sleeve: 20cm';
      _brandController.text = 'EcoWear';
      _deliveryTimeController.text = '3 Business days';
      
      // Product attributes
      _selectedCategory = 'Women > Clothing > Tops > T-Shirts';
      _selectedCondition = 'NEW';
      _selectedSize = 'M';
      _selectedBrand = 'EcoWear';
      
      // Tags
      _selectedTags = ['Sustainable', 'Affordable', 'Cottagecore'];
      _customTagsController.text = 'organic, cotton, summer, casual';
      
      // Special features
      _isVintage = false;
      _isSustainable = true;
      _isHandmade = false;
      _isNegotiable = true;
      _isShippingIncluded = false;
      _shippingMethod = 'STANDARD';
      _processingTime = 1;
      _useCustomProcessingDays = false;
      
      // Generate SKU
      _generatedSku = 'EW-COTTON-TS-M-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎯 Mock data filled! Ready for testing.'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSimpleProgressDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              _uploadProgress == 0.0 
                ? 'Preparing upload...'
                : 'Uploading ${_totalImages} image${_totalImages > 1 ? 's' : ''}...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _uploadProgress == 0.0 
                ? 'Initializing...'
                : '${(_uploadProgress * 100).toInt()}% complete',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_uploadProgress > 0.0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: AppColors.textSecondary.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _publishProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one photo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Initialize upload progress
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentImageIndex = 0;
      _totalImages = _selectedImages.length;
    });

    // Show simple, stable progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSimpleProgressDialog(),
    );

    try {
      // Get authentication token
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to create products');
      }

      // Upload images first
      final List<Map<String, String>> imageUrls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final imageFile = _selectedImages[i];
        
        // Update current image index and show initial progress
        setState(() {
          _currentImageIndex = i;
          _uploadProgress = i / _selectedImages.length; // Show progress for completed images
        });
        
        try {
          // Upload to AWS S3 with progress callback
          final imageUrl = await AwsS3Service.uploadImage(
            imageFile, 
            folder: 'products',
            onProgress: (progress) {
              // Calculate overall progress: (completed images + current image progress) / total images
              final overallProgress = (i + progress) / _selectedImages.length;
              // Update more frequently for better user feedback (every 5%)
              if ((overallProgress - _uploadProgress).abs() > 0.05 || overallProgress >= 1.0) {
                if (mounted) {
                  setState(() {
                    _uploadProgress = overallProgress;
                  });
                }
              }
            },
          );
          
          if (imageUrl != null) {
            imageUrls.add({
              'url': imageUrl,
              'thumbnail': imageUrl // S3 URLs can be used directly
            });
            debugPrint('✅ Image uploaded to S3: $imageUrl');
          } else {
            debugPrint('❌ Failed to upload image: ${imageFile.path}');
            // Continue with other images
          }
        } catch (e) {
          debugPrint('❌ Error uploading image: $e');
          // Continue with other images
        }
      }
      
      // Set progress to 100% when all images are uploaded
      setState(() {
        _uploadProgress = 1.0;
      });
      
      // Check if at least one image was uploaded successfully
      if (imageUrls.isEmpty) {
        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
            _currentImageIndex = 0;
            _totalImages = 0;
          });
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload images. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Prepare product data
      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'sellingPrice': double.parse(_priceController.text),
        'originalPrice': _originalPriceController.text.isNotEmpty 
            ? double.parse(_originalPriceController.text) 
            : null,
        'imagesUrl': imageUrls,
        'category': _selectedCategory,
        'quantityAvailable': int.parse(_quantityController.text),
        'selectedTags': _selectedTags,
        'weight': _weightController.text.isNotEmpty ? _weightController.text : null,
        'dimensions': _dimensionsController.text.isNotEmpty ? _dimensionsController.text : null,
        'brand': _brandController.text.isNotEmpty ? _brandController.text : null,
        'condition': _selectedCondition,
        'isVintage': _isVintage,
        'isSustainable': _isSustainable,
        'isHandmade': _isHandmade,
        'isNegotiable': _isNegotiable,
        'isShippingIncluded': _isShippingIncluded,
        'shippingMethod': _shippingMethod,
        'processingTime': _useCustomProcessingDays 
            ? int.parse(_customProcessingDaysController.text)
            : _processingTime,
        'deliveryTime': _deliveryTimeController.text.isNotEmpty 
            ? _deliveryTimeController.text 
            : null,
        'materials': _selectedTags.where((tag) => 
            ['Cotton', 'Leather', 'Silk', 'Wool', 'Denim', 'Linen'].contains(tag)
        ).toList(),
        'careInstructions': _isVintage ? 'Handle with care. Vintage item.' : null,
      };

      // Map category name to ID (you may want to fetch this from backend)
      int categoryId = _mapCategoryToId(_selectedCategory);
      
      // Create product via GraphQL
      final result = await ProductService.createProduct(
        token: token,
        name: productData['title'] as String,
        description: productData['description'] as String,
        price: productData['sellingPrice'] as double,
        category: categoryId,
        size: _selectedSize.isNotEmpty ? _mapSizeToId(_selectedSize) : null,
        imagesUrl: imageUrls,
        discount: 0.00,
        condition: _mapConditionToEnum(_selectedCondition),
        style: _mapStyleToEnum('casual'), // Default style - you may want to add style selection
        color: ['Black'], // Default color as array - you may want to add color selection
        brand: null, // No brands in database, use customBrand instead
        materials: null, // Materials not implemented in backend yet
        customBrand: _selectedBrand.isNotEmpty ? _selectedBrand : null,
        isFeatured: false,
      );

      if (result != null) {
        // Refresh product list in provider
        final productProvider = context.read<EnhancedProductProvider>();
        await productProvider.loadProducts();

        // Close loading dialog and reset upload state
        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
            _currentImageIndex = 0;
            _totalImages = 0;
          });
          Navigator.pop(context); // Close loading dialog
          Navigator.pop(context); // Close add product screen
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product published successfully! 🎉'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Failed to create product');
      }

    } catch (e) {
      // Close loading dialog and reset upload state
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _currentImageIndex = 0;
          _totalImages = 0;
        });
        Navigator.pop(context); // Close loading dialog
        
        String errorMessage = 'Failed to create product';
        if (e is AppError) {
          errorMessage = e.userMessage;
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _generateSku() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = (timestamp.length > 6) ? timestamp.substring(timestamp.length - 6) : timestamp;
    setState(() {
      _generatedSku = 'SKU-$random';
    });
  }

  Future<void> _loadCategories() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql('''
            query GetCategories {
              categories {
                id
                name
              }
            }
          '''),
        ),
      );

      if (result.hasException) {
        debugPrint('❌ Error loading categories: ${result.exception}');
        return;
      }

      final categories = result.data?['categories'] as List? ?? [];
      setState(() {
        _categories = categories.cast<Map<String, dynamic>>();
        // Create mapping for easy lookup
        for (final category in _categories) {
          _categoryNameToId[category['name']] = int.parse(category['id'].toString());
        }
      });

      debugPrint('✅ Loaded ${_categories.length} categories');
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
    }
  }

  void _addCustomTags(String value) {
    if (value.trim().isNotEmpty) {
      final tags = value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
      setState(() {
        for (String tag in tags) {
          if (!_selectedTags.contains(tag) && _selectedTags.length < 5) {
            _selectedTags.add(tag);
          }
        }
      });
      _customTagsController.clear();
    }
  }

  String _mapConditionToEnum(String condition) {
    // Map frontend condition values to backend enum values
    switch (condition.toUpperCase()) {
      case 'NEW':
        return 'BRAND_NEW_WITH_TAGS';
      case 'LIKE_NEW':
        return 'EXCELLENT_CONDITION';
      case 'GOOD':
        return 'GOOD_CONDITION';
      case 'FAIR':
      case 'POOR':
        return 'HEAVILY_USED';
      default:
        return 'BRAND_NEW_WITH_TAGS';
    }
  }

  String _mapStyleToEnum(String style) {
    switch (style.toLowerCase()) {
      case 'casual':
        return 'CASUAL';
      case 'formal':
        return 'FORMAL_WEAR';
      case 'party':
        return 'PARTY_OUTFIT';
      case 'work':
        return 'WORKWEAR';
      case 'workout':
        return 'WORKOUT';
      case 'vintage':
        return 'VINTAGE';
      case 'minimalist':
        return 'MINIMALIST';
      case 'boho':
        return 'BOHO';
      case 'grunge':
        return 'GRUNGE';
      case 'streetwear':
        return 'STREETWEAR';
      case 'preppy':
        return 'PREPPY';
      case 'cottagecore':
        return 'COTTAGECORE';
      case 'y2k':
        return 'Y2K';
      default:
        return 'CASUAL';
    }
  }

  int _mapCategoryToId(String categoryName) {
    // Use the actual category ID from the API
    final categoryId = _categoryNameToId[categoryName];
    if (categoryId != null) {
      return categoryId;
    }
    
    // Fallback mapping for common categories
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return 673;
      case 'fashion':
        return 675;
      case 'men':
        return 1;
      case 'women':
        return 179;
      case 'boys':
        return 434;
      case 'girls':
        return 539;
      case 'toddlers':
        return 672;
      default:
        return 674; // Default to General category
    }
  }

  String _mapShippingMethodToEnum(String shippingMethod) {
    // Shipping method values are already in the correct enum format
    return shippingMethod;
  }

  int? _mapSizeToId(String sizeName) {
    // Map common size names to backend IDs
    switch (sizeName.toUpperCase()) {
      case 'XS': return 2;  // ID: 2
      case 'S': return 3;   // ID: 3
      case 'M': return 4;   // ID: 4
      case 'L': return 5;   // ID: 5
      case 'XL': return 6;  // ID: 6
      case 'XXL': return 7; // ID: 7 (2XL)
      case 'XXXL': return 8; // ID: 8 (3XL)
      case 'UK 4': return 34; // ID: 34
      case 'UK 6': return 35; // ID: 35
      case 'UK 8': return 36; // ID: 36
      case 'UK 10': return 37; // ID: 37
      case 'UK 12': return 38; // ID: 38
      case 'UK 14': return 39; // ID: 39
      case 'UK 16': return 40; // ID: 40
      case 'US 0': return 91; // ID: 91 (15)
      case 'US 2': return 92; // ID: 92 (16)
      case 'US 4': return 93; // ID: 93 (17)
      case 'US 6': return 94; // ID: 94 (18)
      case 'US 8': return 95; // ID: 95 (19)
      case 'US 10': return 96; // ID: 96 (20)
      case 'US 12': return 97; // ID: 97 (21)
      case 'US 14': return 98; // ID: 98 (22)
      default: return null; // Unknown size
    }
  }

}
