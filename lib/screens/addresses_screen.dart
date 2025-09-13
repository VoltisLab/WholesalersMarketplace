import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/country_code_picker.dart';
import '../widgets/address_autocomplete_field.dart';
import '../data/country_codes.dart';
import '../services/address_service.dart';
import '../services/token_service.dart';
import '../providers/auth_provider.dart';

enum AddressType { home, work, other }

class AddressModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String streetAddress;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String addressType;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? instructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.addressType,
    this.isDefault = false,
    this.latitude,
    this.longitude,
    this.instructions,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      addressType: json['addressType'] ?? 'home',
      isDefault: json['isDefault'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      instructions: json['instructions'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'addressType': addressType,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'instructions': instructions,
    };
  }

  String get fullAddress {
    return '$streetAddress, $city, $state $postalCode, $country';
  }
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Please log in to view addresses';
          _isLoading = false;
        });
        return;
      }

      final addressesData = await AddressService.getMyAddresses(token);
      final addresses = addressesData.map((json) => AddressModel.fromJson(json)).toList();
      
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load addresses: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Delivery Addresses',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _addNewAddress,
            tooltip: 'Add Address',
          ),
        ],
      ),
      body: _isLoading 
          ? _buildLoadingState() 
          : _error != null 
              ? _buildErrorState() 
              : _addresses.isEmpty 
                  ? _buildEmptyState() 
                  : _buildAddressList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAddress,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Address'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading addresses...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAddresses,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.location_on_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No addresses saved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your delivery addresses for faster checkout',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _addNewAddress,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add First Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return _buildAddressCard(address);
      },
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAddressOptions(address);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: address.isDefault ? AppColors.primary : AppColors.divider.withOpacity(0.3),
            width: address.isDefault ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getAddressTypeColor(address.addressType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAddressTypeIcon(address.addressType),
                          size: 14,
                          color: _getAddressTypeColor(address.addressType),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getAddressTypeLabel(address.addressType),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getAddressTypeColor(address.addressType),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editAddress(address);
                          break;
                        case 'delete':
                          _deleteAddress(address);
                          break;
                        case 'default':
                          _setAsDefault(address);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (!address.isDefault)
                        const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                address.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address.phoneNumber,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address.streetAddress,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${address.city}, ${address.state} ${address.postalCode}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                address.country,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAddressTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return AppColors.primary;
      case 'work':
        return Colors.orange;
      case 'other':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getAddressTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.business;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  String _getAddressTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      case 'other':
        return 'Other';
      default:
        return type.toUpperCase();
    }
  }

  void _addNewAddress() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadAddresses(); // Reload addresses from backend
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _editAddress(AddressModel address) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(address: address),
      ),
    ).then((result) {
      if (result == true) {
        _loadAddresses(); // Reload addresses from backend
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _deleteAddress(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete this address?\n\n${address.name}\n${address.streetAddress}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final token = await TokenService.getToken();
                if (token == null) {
                  throw Exception('Please log in to delete addresses');
                }
                
                await AddressService.deleteAddress(
                  token: token,
                  addressId: address.id,
                );
                
                _loadAddresses(); // Reload addresses from backend
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Address deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete address: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(AddressModel address) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to update addresses');
      }
      
      await AddressService.updateAddress(
        token: token,
        addressId: address.id,
        isDefault: true,
      );
      
      _loadAddresses(); // Reload addresses from backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default address updated'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update default address: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddressOptions(AddressModel address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                address.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Edit Address',
                onTap: () {
                  Navigator.pop(context);
                  _editAddress(address);
                },
              ),
              if (!address.isDefault)
                _buildOptionTile(
                  icon: Icons.star,
                  title: 'Set as Default',
                  onTap: () {
                    Navigator.pop(context);
                    _setAsDefault(address);
                  },
                ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Delete Address',
                onTap: () {
                  Navigator.pop(context);
                  _deleteAddress(address);
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isDestructive ? AppColors.error : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAddressScreen extends StatefulWidget {
  final AddressModel? address;
  
  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  CountryCode _selectedCountry = CountryCodes.countries.first;
  String _selectedType = 'home';
  bool _setAsDefault = false;
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _loadAddressData();
    }
  }

  void _loadAddressData() {
    final address = widget.address!;
    _nameController.text = address.name;
    _phoneController.text = address.phoneNumber;
    _addressController.text = address.streetAddress;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    _instructionsController.text = address.instructions ?? '';
    _selectedType = address.addressType;
    _setAsDefault = address.isDefault;
    _latitude = address.latitude;
    _longitude = address.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.address != null ? 'Edit Address' : 'Add Address',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAddressTypeSelector(),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter recipient name',
                      icon: Icons.person_outline,
                      validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    PhoneNumberField(
                      phoneController: _phoneController,
                      selectedCountry: _selectedCountry,
                      onCountryChanged: (country) {
                        setState(() => _selectedCountry = country);
                      },
                      label: 'Phone Number',
                      hint: 'Enter phone number',
                    ),
                    const SizedBox(height: 16),
                    AddressFormField(
                      label: 'Street Address',
                      hint: 'Search for an address',
                      controller: _addressController,
                      validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
                      onAddressSelected: (addressDetails) {
                        if (addressDetails != null) {
                          setState(() {
                            _addressController.text = addressDetails.fullStreetAddress;
                            _cityController.text = addressDetails.locality ?? '';
                            _stateController.text = addressDetails.administrativeAreaLevel1 ?? '';
                            _postalCodeController.text = addressDetails.postalCode ?? '';
                            _latitude = addressDetails.latitude;
                            _longitude = addressDetails.longitude;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'Enter city',
                            icon: Icons.location_city_outlined,
                            validator: (value) => value?.isEmpty ?? true ? 'City is required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'State/Province',
                            hint: 'Enter state',
                            icon: Icons.map_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      hint: 'Enter postal code',
                      icon: Icons.markunread_mailbox_outlined,
                      validator: (value) => value?.isEmpty ?? true ? 'Postal code is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _instructionsController,
                      label: 'Delivery Instructions (Optional)',
                      hint: 'e.g., Leave at front door, Ring doorbell, etc.',
                      icon: Icons.note_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile(
                      title: const Text('Set as default address'),
                      subtitle: const Text('Use this address for all future orders'),
                      value: _setAsDefault,
                      onChanged: (value) {
                        setState(() {
                          _setAsDefault = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.address != null ? 'Update Address' : 'Save Address',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['home', 'work', 'other'].map((type) {
            final isSelected = _selectedType == type;
            return Expanded(
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedType = type;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? _getAddressTypeColor(type).withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? _getAddressTypeColor(type)
                          : AppColors.divider.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getAddressTypeIcon(type),
                        color: isSelected 
                            ? _getAddressTypeColor(type)
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getAddressTypeLabel(type),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected 
                              ? _getAddressTypeColor(type)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to save addresses');
      }

      if (widget.address != null) {
        // Update existing address
        await AddressService.updateAddress(
          token: token,
          addressId: widget.address!.id,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          streetAddress: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _selectedCountry.name,
          postalCode: _postalCodeController.text,
          addressType: _selectedType,
          isDefault: _setAsDefault,
          latitude: _latitude,
          longitude: _longitude,
          instructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
        );
      } else {
        // Create new address
        await AddressService.createAddress(
          token: token,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          streetAddress: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _selectedCountry.name,
          postalCode: _postalCodeController.text,
          addressType: _selectedType,
          isDefault: _setAsDefault,
          latitude: _latitude,
          longitude: _longitude,
          instructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
        );
      }

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getAddressTypeColor(String type) {
    switch (type) {
      case 'home':
        return AppColors.primary;
      case 'work':
        return AppColors.secondary;
      case 'other':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getAddressTypeIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      case 'other':
        return Icons.location_on_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  String _getAddressTypeLabel(String type) {
    switch (type) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      case 'other':
        return 'Other';
      default:
        return 'Other';
    }
  }

}