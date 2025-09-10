import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/platform_widgets.dart';
import '../widgets/country_code_picker.dart';
import '../data/country_codes.dart';
import 'phone_verification_screen.dart';

class EditPhoneScreen extends StatefulWidget {
  final String? currentPhone;
  final CountryCode? currentCountryCode;

  const EditPhoneScreen({
    super.key,
    this.currentPhone,
    this.currentCountryCode,
  });

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late CountryCode _selectedCountry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.currentCountryCode ?? CountryCodes.countries.first;
    _phoneController.text = widget.currentPhone ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updatePhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // Navigate to phone verification
      final verificationResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneVerificationScreen(
            phoneNumber: _phoneController.text,
            countryCode: _selectedCountry,
            isFromProfile: true,
            onVerificationComplete: () {
              // Phone verification completed
              // In a real app, you would update the user's phone number here
              PlatformWidgets.showSnackBar(
                context,
                message: 'Phone number updated successfully!',
                type: SnackBarType.success,
              );
            },
          ),
        ),
      );

      if (verificationResult == true) {
        // Return the updated phone info to the previous screen
        Navigator.pop(context, {
          'phone': _phoneController.text,
          'countryCode': _selectedCountry,
        });
      }
    } catch (e) {
      PlatformWidgets.showSnackBar(
        context,
        message: 'Failed to update phone number. Please try again.',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PlatformWidgets.appBar(
        title: 'Edit Phone Number',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Phone Number',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'We\'ll send a verification code to your new number',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Current phone number (if exists)
                if (widget.currentPhone != null) ...[
                  const Text(
                    'Current Phone Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.divider.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.currentCountryCode?.flag ?? '🇺🇸',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.currentCountryCode?.dialCode ?? '+1'} ${widget.currentPhone}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // New phone number field
                PhoneNumberField(
                  phoneController: _phoneController,
                  selectedCountry: _selectedCountry,
                  onCountryChanged: (country) {
                    setState(() => _selectedCountry = country);
                  },
                  label: widget.currentPhone != null ? 'New Phone Number' : 'Phone Number',
                  hint: 'Enter your phone number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 6) {
                      return 'Please enter a valid phone number';
                    }
                    // Check if it's the same as current number
                    if (widget.currentPhone != null && 
                        value == widget.currentPhone && 
                        _selectedCountry.code == widget.currentCountryCode?.code) {
                      return 'Please enter a different phone number';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                // Security note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Your phone number is used for account security and important notifications.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Update button
                PlatformWidgets.primaryButton(
                  text: widget.currentPhone != null 
                      ? 'Update Phone Number' 
                      : 'Add Phone Number',
                  onPressed: _isLoading ? null : _updatePhoneNumber,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
