import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isVendor => _currentUser?.userType == 'vendor';
  bool get isCustomer => _currentUser?.userType == 'customer';

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data based on email
      if (email.contains('vendor')) {
        _currentUser = UserModel(
          id: '1',
          name: 'John Vendor',
          email: email,
          phone: '+1234567890',
          userType: 'vendor',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profileImage: 'https://via.placeholder.com/150',
        );
      } else {
        _currentUser = UserModel(
          id: '2',
          name: 'Jane Customer',
          email: email,
          phone: '+1234567890',
          userType: 'customer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profileImage: 'https://via.placeholder.com/150',
        );
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String userType) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: '',
        userType: userType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      setLoading(false);
      return true;
    } catch (e) {
      setError('Registration failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      setLoading(false);
    } catch (e) {
      setError('Logout failed: ${e.toString()}');
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

  // New auth methods for the auth screens
  Future<void> signIn(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock authentication - in real app, validate with backend
      if (email == 'demo@wholesalers.com' && password == 'demo123') {
        _currentUser = UserModel(
          id: 'demo',
          name: 'Demo User',
          email: email,
          phone: '+1234567890',
          userType: 'customer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profileImage: 'https://via.placeholder.com/150',
        );
      } else {
        // For demo purposes, accept any valid email/password
        _currentUser = UserModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'User',
          email: email,
          phone: '',
          userType: 'customer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      setLoading(false);
    } catch (e) {
      setError('Sign in failed: ${e.toString()}');
      setLoading(false);
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password, {bool isVendor = false}) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: '',
        userType: isVendor ? 'vendor' : 'customer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      setLoading(false);
    } catch (e) {
      setError('Sign up failed: ${e.toString()}');
      setLoading(false);
      rethrow;
    }
  }

  Future<void> completeVendorOnboarding(Map<String, dynamic> vendorData) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user to be a verified vendor
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          phone: vendorData['phone'] ?? _currentUser!.phone,
          userType: 'vendor',
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
          profileImage: _currentUser!.profileImage,
        );
      }
      
      setLoading(false);
    } catch (e) {
      setError('Vendor onboarding failed: ${e.toString()}');
      setLoading(false);
      rethrow;
    }
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  // Mock login for demo purposes
  void mockLogin({bool asVendor = false}) {
    if (asVendor) {
      _currentUser = UserModel(
        id: '1',
        name: 'Demo Vendor',
        email: 'vendor@demo.com',
        phone: '+1234567890',
        userType: 'vendor',
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
