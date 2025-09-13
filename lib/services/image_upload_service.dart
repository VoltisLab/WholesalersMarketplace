import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImageUploadService {
  static const String _baseUrl = 'http://localhost:8000';
  
  /// Upload an image file to the server
  /// Returns the URL of the uploaded image if successful, null otherwise
  static Future<String?> uploadImage(File imageFile) async {
    try {
      print('🔄 Attempting to upload image to server: $_baseUrl/api/upload-image/');
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/upload-image/'),
      );
      
      // Add the image file
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: path.basename(imageFile.path),
      );
      
      request.files.add(multipartFile);
      
      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('✅ Image uploaded successfully to server: ${responseData['image_url']}');
          return responseData['image_url'];
        } else {
          print('❌ Server upload failed: ${responseData['message']}');
          return null;
        }
      } else {
        print('❌ Server upload failed with status ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image to server: $e');
      return null;
    }
  }
  
  /// Upload image and get a temporary URL for testing
  /// This creates a mock upload that returns a local file path
  static Future<String?> uploadImageMock(File imageFile) async {
    try {
      print('⚠️ Performing mock image upload (local storage)');
      
      // For now, return the local file path as a mock URL
      // In a real implementation, this would upload to a cloud service
      await Future.delayed(const Duration(seconds: 1)); // Simulate upload time
      
      // Return the local file path for now
      print('✅ Mock upload successful: ${imageFile.path}');
      return imageFile.path;
    } catch (e) {
      print('❌ Mock image upload error: $e');
      return null;
    }
  }
  
  /// Upload to a cloud service (AWS S3, Cloudinary, etc.)
  /// This is a placeholder for future implementation
  static Future<String?> uploadToCloud(File imageFile) async {
    try {
      // TODO: Implement actual cloud upload
      // This would typically involve:
      // 1. Resize/compress the image
      // 2. Generate a unique filename
      // 3. Upload to cloud storage (S3, Cloudinary, etc.)
      // 4. Return the public URL
      
      print('📝 Cloud upload not implemented yet');
      return null;
    } catch (e) {
      print('❌ Cloud upload error: $e');
      return null;
    }
  }
}
