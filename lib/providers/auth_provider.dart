import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/graphql_service.dart';
import '../services/token_service.dart';
import '../services/image_upload_service.dart';
import '../services/error_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _lastErrorCode;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastErrorCode => _lastErrorCode;
  bool get isLoggedIn => _currentUser != null;
  bool get isSupplier => _currentUser?.userType == 'supplier';
  bool get isCustomer => _currentUser?.userType == 'customer';

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error, {String? errorCode}) {
    _error = error;
    _lastErrorCode = errorCode;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result != null && result['token'] != null) {
        // Save tokens
        await TokenService.saveTokens(
          token: result['token'],
          refreshToken: result['refreshToken'] ?? '',
        );

        // Get user details
        final userData = await AuthService.viewMe(result['token']);
        
        if (userData != null) {
          _currentUser = UserModel(
            id: userData['id']?.toString() ?? '',
            name: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
            email: userData['email'] ?? email,
            phone: '', // Will be updated from profile
            userType: result['user']?['accountType']?.toLowerCase() ?? 'customer',
            accountType: result['user']?['accountType'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            profileImage: null,
          );

          await TokenService.saveUserData(userData);
          setLoading(false);
          notifyListeners(); // Ensure UI updates after login
          return true;
        }
      }
      
      setError('Invalid login credentials');
      setLoading(false);
      return false;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage, errorCode: e.trackingCode);
      } else {
        final error = createError(ErrorCode.unknown, details: e.toString());
        setError(error.userMessage, errorCode: error.trackingCode);
      }
      setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String userType, {String? phone, bool termsAccepted = false}) async {
    setLoading(true);
    setError(null);

    try {
      final nameParts = name.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      final result = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: password,
        accountType: userType,
        termsAccepted: termsAccepted,
      );

      if (result != null && result['success'] == true && result['token'] != null) {
        // Save tokens
        await TokenService.saveTokens(
          token: result['token'],
          refreshToken: result['refreshToken'] ?? '',
        );

        // Get user details
        final userData = await AuthService.viewMe(result['token']);
        
        if (userData != null) {
          _currentUser = UserModel(
            id: userData['id']?.toString() ?? '',
            name: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
            email: userData['email'] ?? email,
            phone: phone ?? '',
            userType: userType.toLowerCase(),
            accountType: userData['accountType'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            profileImage: null,
          );

          await TokenService.saveUserData(userData);
          setLoading(false);
          notifyListeners(); // Ensure UI updates after registration
          return true;
        }
      }
      
      final errors = result?['errors'] as List?;
      final errorDetails = errors?.join(', ') ?? 'Registration failed';
      final error = createError(ErrorCode.authInvalidCredentials, details: errorDetails);
      setError(error.userMessage, errorCode: error.trackingCode);
      setLoading(false);
      return false;
      
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage, errorCode: e.trackingCode);
      } else {
        final error = createError(ErrorCode.unknown, details: e.toString());
        setError(error.userMessage, errorCode: error.trackingCode);
      }
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    setLoading(true);
    
    try {
      // Get refresh token for API logout
      final refreshToken = await TokenService.getRefreshToken();
      
      if (refreshToken != null) {
        // Call API logout
        try {
          await AuthService.logout(refreshToken);
          debugPrint('✅ Server-side logout successful');
        } catch (e) {
          // API logout failed, but continue with local cleanup
          debugPrint('⚠️ API logout failed, continuing with local cleanup: $e');
        }
      }
      
      // Clear tokens and user data locally
      await TokenService.clearTokens();
      _currentUser = null;
      _error = null;
      _lastErrorCode = null;
      
      setLoading(false);
    } catch (e) {
      final error = createError(ErrorCode.unknown, details: 'Logout failed: ${e.toString()}');
      setError(error.userMessage, errorCode: error.trackingCode);
      setLoading(false);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = updatedUser;
      setLoading(false);
    } catch (e) {
      setError('Profile update failed: ${e.toString()}');
      setLoading(false);
    }
  }

  Future<void> updateProfileImage(String? imagePath) async {
    if (_currentUser != null) {
      // Update local state immediately for UI responsiveness
      final updatedUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        userType: _currentUser!.userType,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
        profileImage: imagePath,
        isActive: _currentUser!.isActive,
        defaultAddress: _currentUser!.defaultAddress,
      );
      
      _currentUser = updatedUser;
      notifyListeners();
      
      // Save to local storage
      await TokenService.saveUserData({
        'id': _currentUser!.id,
        'firstName': _currentUser!.name.split(' ').first,
        'lastName': _currentUser!.name.split(' ').skip(1).join(' '),
        'email': _currentUser!.email,
        'phone': _currentUser!.phone,
        'accountType': _currentUser!.userType.toUpperCase(),
        'profileImage': imagePath,
      });
    }
  }

  Future<bool> saveProfileImageToBackend(String? imagePath) async {
    if (_currentUser == null || imagePath == null) return false;
    
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        setError('No authentication token found');
        setLoading(false);
        return false;
      }

      // Upload image to server
      String? uploadedImageUrl;
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          // Try to upload to server first
          uploadedImageUrl = await ImageUploadService.uploadImage(imageFile);
          
          // If server upload fails, use mock upload for now
          if (uploadedImageUrl == null) {
            print('⚠️ Server upload failed, using mock upload');
            uploadedImageUrl = await ImageUploadService.uploadImageMock(imageFile);
          }
        }
      }
      
      // Update the user model with the uploaded image URL
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        userType: _currentUser!.userType,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
        profileImage: uploadedImageUrl ?? imagePath, // Use uploaded URL or fallback to local path
        isActive: _currentUser!.isActive,
        defaultAddress: _currentUser!.defaultAddress,
      );
      
      // Save updated user data to local storage
      await TokenService.saveUserData({
        'id': _currentUser!.id,
        'firstName': _currentUser!.name.split(' ').first,
        'lastName': _currentUser!.name.split(' ').skip(1).join(' '),
        'email': _currentUser!.email,
        'phone': _currentUser!.phone,
        'accountType': _currentUser!.userType.toUpperCase(),
        'profileImage': _currentUser!.profileImage,
      });
      
      notifyListeners();
      setLoading(false);
      return true;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage, errorCode: e.trackingCode);
      } else {
        setError('Profile image update failed: ${e.toString()}');
      }
      setLoading(false);
      return false;
    }
  }

  // New auth methods for the auth screens
  Future<void> signIn(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      debugPrint('🔄 Attempting login for: $email');
      // Use real backend authentication
      final result = await AuthService.login(
        email: email,
        password: password,
      );
      
      debugPrint('🔍 Login result: $result');

      if (result != null && result['token'] != null) {
        // Save tokens
        await TokenService.saveTokens(
          token: result['token'],
          refreshToken: result['refreshToken'],
        );

        // Get user profile
        final userResult = await AuthService.viewMe(result['token']);
        if (userResult != null) {
          // Convert GraphQL response to UserModel format
          _currentUser = UserModel(
            id: userResult['id']?.toString() ?? 'unknown',
            name: '${userResult['firstName'] ?? ''} ${userResult['lastName'] ?? ''}'.trim(),
            email: userResult['email'] ?? email,
            phone: userResult['phoneNumber'] ?? '',
            userType: userResult['accountType']?.toLowerCase() ?? 'customer',
            accountType: userResult['accountType'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } else {
          // Fallback if profile fetch fails
          _currentUser = UserModel(
            id: result['user']?['id'] ?? 'unknown',
            name: result['user']?['name'] ?? 'User',
            email: email,
            phone: result['user']?['phone'] ?? '',
            userType: result['user']?['userType'] ?? 'customer',
            accountType: result['user']?['accountType'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            profileImage: result['user']?['profileImage'],
          );
        }
        
        notifyListeners();
      } else {
        throw Exception('Login failed: Invalid response from server');
      }
      
      setLoading(false);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      if (e is AppError) {
        setError(e.userMessage, errorCode: e.errorCode.code);
      } else {
        setError('Sign in failed: ${e.toString()}');
      }
      setLoading(false);
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password, {bool isSupplier = false}) async {
    setLoading(true);
    setError(null);

    try {
      final success = await register(
        name, 
        email, 
        password, 
        isSupplier ? 'supplier' : 'customer',
        termsAccepted: true,
      );
      
      if (!success) {
        throw createError(ErrorCode.authInvalidCredentials, details: 'Registration failed during signup');
      }
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage, errorCode: e.trackingCode);
      } else {
        final error = createError(ErrorCode.unknown, details: e.toString());
        setError(error.userMessage, errorCode: error.trackingCode);
      }
      setLoading(false);
      rethrow;
    }
  }

  Future<void> completeSupplierOnboarding(Map<String, dynamic> supplierData) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user to be a verified supplier
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          phone: supplierData['phone'] ?? _currentUser!.phone,
          userType: 'supplier',
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
          profileImage: _currentUser!.profileImage,
        );
      }
      
      setLoading(false);
    } catch (e) {
      setError('Supplier onboarding failed: ${e.toString()}');
      setLoading(false);
      rethrow;
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      final userData = await AuthService.viewMe(token);
      
      if (userData != null) {
        _currentUser = UserModel(
          id: userData['id']?.toString() ?? '',
          name: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          userType: userData['accountType']?.toLowerCase() ?? 'customer',
          accountType: userData['accountType'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profileImage: userData['profileImage'],
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }

  Future<void> loadUserData() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final userData = await AuthService.viewMe(token);
      if (userData != null) {
        _currentUser = UserModel(
          id: userData['id']?.toString() ?? '',
          name: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          userType: userData['accountType']?.toLowerCase() ?? 'customer',
          accountType: userData['accountType'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profileImage: userData['profileImage'],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  // Debug method to clear all stored tokens
  Future<void> clearAllTokens() async {
    await TokenService.clearTokens();
    _currentUser = null;
    _error = null;
    _lastErrorCode = null;
    notifyListeners();
    debugPrint('✅ All tokens cleared');
  }

  // Mock login for demo purposes
  void mockLogin({bool asSupplier = false}) {
    if (asSupplier) {
      _currentUser = UserModel(
        id: '1',
        name: 'Demo Supplier',
        email: 'supplier@demo.com',
        phone: '+1234567890',
        userType: 'supplier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        profileImage: 'https://via.placeholder.com/150',
      );
    } else {
      _currentUser = UserModel(
        id: '2',
        name: 'Demo Customer',
        email: 'customer@demo.com',
        phone: '+1234567890',
        userType: 'customer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        profileImage: 'https://via.placeholder.com/150',
      );
    }
    notifyListeners();
  }
}
