import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/platform_widgets.dart';
import '../widgets/country_code_picker.dart';
import '../data/country_codes.dart';
import '../services/graphql_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  CountryCode _selectedCountry = CountryCodes.countries.first;
  String _selectedGender = 'Prefer not to say';
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 PersonalInfoScreen: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 PersonalInfoScreen: addPostFrameCallback executing');
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    debugPrint('🔄 PersonalInfoScreen: Starting to load user data...');
    setState(() => _isLoading = true);
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view your profile');
      }
      debugPrint('🔄 PersonalInfoScreen: Token obtained, fetching profile data...');

      // Fetch complete profile data from backend
      final profileData = await AuthService.viewMe(token);
      debugPrint('🔄 PersonalInfoScreen: Profile data received: $profileData');
      
      if (profileData != null) {
        // Populate form fields with backend data
        _firstNameController.text = profileData['firstName'] ?? '';
        _lastNameController.text = profileData['lastName'] ?? '';
        _emailController.text = profileData['email'] ?? '';
        
        debugPrint('🔄 PersonalInfoScreen: Basic fields set');
        
        // Handle phone number (remove country code if present)
        final phoneNumber = profileData['phoneNumber'] ?? '';
        if (phoneNumber.isNotEmpty) {
          // Extract country code and number
          if (phoneNumber.startsWith('+')) {
            final parts = phoneNumber.split(' ');
            if (parts.length > 1) {
              final countryCode = parts[0];
              final number = parts[1];
              
              // Find matching country code
              final country = CountryCodes.countries.firstWhere(
                (c) => c.dialCode == countryCode,
                orElse: () => CountryCodes.countries.first,
              );
              _selectedCountry = country;
              _phoneController.text = number;
            } else {
              _phoneController.text = phoneNumber.substring(1); // Remove +
            }
          } else {
            _phoneController.text = phoneNumber;
          }
        }
        
        // Handle gender
        final gender = profileData['gender'] ?? '';
        if (gender.isNotEmpty) {
          switch (gender.toUpperCase()) {
            case 'MALE':
              _selectedGender = 'Male';
              break;
            case 'FEMALE':
              _selectedGender = 'Female';
              break;
            case 'OTHER':
              _selectedGender = 'Other';
              break;
            case 'PREFER_NOT_TO_SAY':
              _selectedGender = 'Prefer not to say';
              break;
            default:
              _selectedGender = 'Prefer not to say';
          }
        }
        
        // Handle date of birth
        final dob = profileData['dob'] ?? '';
        if (dob.isNotEmpty) {
          try {
            _selectedBirthDate = DateTime.parse(dob);
          } catch (e) {
            debugPrint('Error parsing date: $e');
          }
        }
        
        // Handle address information
        _addressController.text = profileData['streetAddress'] ?? '';
        _cityController.text = profileData['city'] ?? '';
        _postalCodeController.text = profileData['postalCode'] ?? '';
        
        debugPrint('✅ PersonalInfoScreen: Profile data loaded successfully');
        debugPrint('✅ PersonalInfoScreen: First name: ${_firstNameController.text}');
        debugPrint('✅ PersonalInfoScreen: Last name: ${_lastNameController.text}');
        debugPrint('✅ PersonalInfoScreen: Phone: ${_phoneController.text}');
        debugPrint('✅ PersonalInfoScreen: Gender: $_selectedGender');
        debugPrint('✅ PersonalInfoScreen: DOB: $_selectedBirthDate');
        debugPrint('✅ PersonalInfoScreen: Address: ${_addressController.text}');
        debugPrint('✅ PersonalInfoScreen: City: ${_cityController.text}');
        debugPrint('✅ PersonalInfoScreen: Postal: ${_postalCodeController.text}');
        
        // Trigger UI update
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error loading profile data: $e');
      // Fallback to basic user data from AuthProvider
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      
      if (user != null) {
        _firstNameController.text = user.name.split(' ').first;
        if (user.name.split(' ').length > 1) {
          _lastNameController.text = user.name.split(' ').skip(1).join(' ');
        }
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePersonalInfo,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? AppColors.textSecondary : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _showChangePhotoOptions,
                            icon: const Icon(Icons.camera_alt, size: 16),
                            label: const Text('Change Photo'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Basic Information
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hint: 'Enter your first name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hint: 'Enter your last name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Phone number with country code
                    PhoneNumberField(
                      phoneController: _phoneController,
                      selectedCountry: _selectedCountry,
                      onCountryChanged: (country) {
                        setState(() => _selectedCountry = country);
                      },
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Gender selection
                    _buildDropdownField(
                      label: 'Gender',
                      value: _selectedGender,
                      items: ['Male', 'Female', 'Other', 'Prefer not to say'],
                      onChanged: (value) {
                        setState(() => _selectedGender = value!);
                      },
                      icon: Icons.person_outline,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Birth date
                    _buildDateField(),
                    
                    const SizedBox(height: 32),
                    
                    // Address Information
                    _buildSectionHeader('Address Information'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      hint: 'Enter your street address',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'Enter your city',
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _postalCodeController,
                            label: 'Postal Code',
                            hint: 'Enter postal code',
                            icon: Icons.markunread_mailbox_outlined,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 100), // Extra space for floating button
                  ],
                ),
              ),
            ),
          ),
          
          // Floating save button
          SafeArea(
            child: Container(
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
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: PlatformWidgets.primaryButton(
                  text: 'Save Changes',
                  onPressed: _isLoading ? null : _savePersonalInfo,
                  isLoading: _isLoading,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
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
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectBirthDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surface,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : 'Select your birth date',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedBirthDate != null 
                        ? AppColors.textPrimary 
                        : AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _showChangePhotoOptions() {
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
              const Text(
                'Change Profile Picture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                  _buildPhotoOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                  _buildPhotoOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfilePhoto();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // Get authentication token
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to update your profile');
      }

      // Prepare profile data
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phoneNumber = _phoneController.text.trim().isNotEmpty 
          ? '${_selectedCountry.dialCode}${_phoneController.text.trim()}'
          : null;
      final gender = _selectedGender != 'Prefer not to say' ? _selectedGender.toUpperCase() : null;
      final dateOfBirth = _selectedBirthDate != null 
          ? _selectedBirthDate!.toIso8601String().split('T')[0]
          : null;

      // Update profile via GraphQL
      final result = await AuthService.updateProfile(
        token: token,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        streetAddress: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      );

      if (result != null) {
        // Update local user data in AuthProvider
        final authProvider = context.read<AuthProvider>();
        await authProvider.loadUserData();

        if (mounted) {
          PlatformWidgets.showSnackBar(
            context,
            message: 'Personal information updated successfully!',
            type: SnackBarType.success,
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to update profile');
      }

    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to update information. Please try again.';
        if (e is AppError) {
          errorMessage = e.userMessage;
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        PlatformWidgets.showSnackBar(
          context,
          message: errorMessage,
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // This would integrate with image_picker package
      // For now, show a message that this feature is being implemented
      PlatformWidgets.showSnackBar(
        context,
        message: 'Camera integration coming soon!',
        type: SnackBarType.info,
      );
    } catch (e) {
      PlatformWidgets.showSnackBar(
        context,
        message: 'Failed to open camera: ${e.toString()}',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // This would integrate with image_picker package
      // For now, show a message that this feature is being implemented
      PlatformWidgets.showSnackBar(
        context,
        message: 'Gallery integration coming soon!',
        type: SnackBarType.info,
      );
    } catch (e) {
      PlatformWidgets.showSnackBar(
        context,
        message: 'Failed to open gallery: ${e.toString()}',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      // This would remove the profile photo via backend
      // For now, show a message that this feature is being implemented
      PlatformWidgets.showSnackBar(
        context,
        message: 'Remove photo feature coming soon!',
        type: SnackBarType.info,
      );
    } catch (e) {
      PlatformWidgets.showSnackBar(
        context,
        message: 'Failed to remove photo: ${e.toString()}',
        type: SnackBarType.error,
      );
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
