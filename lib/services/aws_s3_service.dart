import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AwsS3Service {
  static String _region = 'eu-north-1'; // Made this mutable to try different regions
  static const String _service = 's3';
  static const String _algorithm = 'AWS4-HMAC-SHA256';
  
  // AWS credentials - using placeholder values for development
  static const String _accessKeyId = 'placeholder_access_key';
  static const String _secretAccessKey = 'placeholder_secret_key';
  static const String _bucketName = 'whosaleb2b';
  
  // Common AWS regions to try
  static const List<String> _commonRegions = [
    'us-east-1',
    'us-west-2', 
    'eu-west-1',
    'eu-north-1',
    'ap-southeast-1',
    'ap-southeast-2',
  ];
  
  /// Upload an image file to AWS S3
  /// Returns the URL of the uploaded image if successful, null otherwise
  static Future<String?> uploadImage(File imageFile, {String? folder, Function(double)? onProgress}) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final filename = '${folder ?? 'products'}/${timestamp}_${DateTime.now().microsecondsSinceEpoch}.$extension';
      
      // Read file bytes
      final fileBytes = await imageFile.readAsBytes();
      
      // Create signed URL for PUT request
      final signedUrl = _createSignedUrl('PUT', filename, fileBytes.length);
      
      print('🔄 Uploading to S3: $filename');
      print('🔄 Using signed URL: $signedUrl');
      
      // Upload file using Dio with proper redirect handling
      final dio = Dio();
      dio.options.followRedirects = false; // Handle redirects manually
      dio.options.maxRedirects = 0;
      
      final response = await dio.put(
        signedUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': _getContentType(extension),
            'Content-Length': fileBytes.length.toString(),
          },
          validateStatus: (status) {
            // Accept all status codes to handle redirects manually
            return true;
          },
        ),
        onSendProgress: onProgress != null ? (sent, total) {
          if (total > 0) {
            onProgress(sent / total);
          }
        } : null,
      );
      
      // Handle redirects manually
      if (response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location']?.first;
        if (redirectUrl != null) {
          print('🔄 Following redirect to: $redirectUrl');
          final redirectResponse = await dio.put(
            redirectUrl,
            data: fileBytes,
            options: Options(
              headers: {
                'Content-Type': _getContentType(extension),
                'Content-Length': fileBytes.length.toString(),
              },
            ),
            onSendProgress: onProgress != null ? (sent, total) {
              if (total > 0) {
                onProgress(sent / total);
              }
            } : null,
          );
          
          if (redirectResponse.statusCode == 200 || redirectResponse.statusCode == 204) {
            final imageUrl = 'https://$_bucketName.s3.$_region.amazonaws.com/$filename';
            print('✅ Image uploaded successfully to S3: $imageUrl');
            return imageUrl;
          } else {
            print('❌ S3 upload failed after redirect with status ${redirectResponse.statusCode}');
            print('Response headers: ${redirectResponse.headers}');
            return null;
          }
        }
      }
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Return the public URL
        final imageUrl = 'https://$_bucketName.s3.$_region.amazonaws.com/$filename';
        print('✅ Image uploaded successfully to S3: $imageUrl');
        return imageUrl;
      } else {
        print('❌ S3 upload failed with status ${response.statusCode}');
        print('Response headers: ${response.headers}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading to S3: $e');
      return null;
    }
  }
  
  /// Create a signed URL for S3 PUT request
  static String _createSignedUrl(String method, String key, int contentLength) {
    final now = DateTime.now().toUtc();
    // Fix: Use proper date format yyyyMMdd for credentials
    final date = '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    // Fix: Use proper ISO8601 format with 'Z' suffix
    final datetime = '${now.toIso8601String().substring(0, 19).replaceAll(':', '').replaceAll('-', '')}Z';
    
    // Create credential string
    final credential = '$_accessKeyId/$date/$_region/$_service/aws4_request';
    
    // Create canonical request - For path-style URLs, include bucket name in URI
    final canonicalUri = '/$_bucketName/$key';
    
    // Build query parameters first to include in canonical request
    final queryParams = {
      'X-Amz-Algorithm': _algorithm,
      'X-Amz-Credential': credential,
      'X-Amz-Date': datetime,
      'X-Amz-Expires': '3600',
      'X-Amz-SignedHeaders': 'host',
    };
    
    final canonicalQueryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final canonicalHeaders = 'host:s3.$_region.amazonaws.com\n';
    final signedHeaders = 'host';
    final payloadHash = 'UNSIGNED-PAYLOAD'; // Use UNSIGNED-PAYLOAD for presigned URLs
    
    final canonicalRequest = '$method\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash';
    
    // Create string to sign
    final stringToSign = '$_algorithm\n$datetime\n$date/$_region/$_service/aws4_request\n${sha256.convert(utf8.encode(canonicalRequest)).toString()}';
    
    // Calculate signature
    final signature = _calculateSignature(_secretAccessKey, date, _region, _service, stringToSign);
    
    // Add signature to query parameters
    queryParams['X-Amz-Signature'] = signature;

    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    // Use path-style URL instead of virtual-hosted-style to avoid redirect issues
    // Note: canonicalUri already includes the bucket name, so we don't add it again
    return 'https://s3.$_region.amazonaws.com$canonicalUri?$queryString';
  }
  
  /// Calculate AWS signature
  static String _calculateSignature(String secretKey, String date, String region, String service, String stringToSign) {
    final kDate = Hmac(sha256, utf8.encode('AWS4$secretKey')).convert(utf8.encode(date));
    final kRegion = Hmac(sha256, kDate.bytes).convert(utf8.encode(region));
    final kService = Hmac(sha256, kRegion.bytes).convert(utf8.encode(service));
    final kSigning = Hmac(sha256, kService.bytes).convert(utf8.encode('aws4_request'));
    final signature = Hmac(sha256, kSigning.bytes).convert(utf8.encode(stringToSign));
    return signature.toString();
  }
  
  /// Get content type based on file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
  
  /// Test S3 connection and bucket access
  static Future<bool> testConnection() async {
    print('🔄 Testing S3 connection...');
    
    // We know the bucket is in eu-north-1 from the redirect responses
    _region = 'eu-north-1';
    print('🔄 Testing in region: $_region');
    
    try {
      // Create a simple test file to upload
      final testContent = 'S3 connection test - ${DateTime.now().toIso8601String()}';
      final testFilename = 'connection-test-${DateTime.now().millisecondsSinceEpoch}.txt';
      
      // Create signed URL for PUT request
      final signedUrl = _createSignedUrl('PUT', testFilename, testContent.length);
      print('🔄 Testing with signed URL: $signedUrl');
      
      final dio = Dio();
      dio.options.followRedirects = false;
      dio.options.maxRedirects = 0;
      
      final response = await dio.put(
        signedUrl,
        data: testContent,
        options: Options(
          headers: {
            'Content-Type': 'text/plain',
            'Content-Length': testContent.length.toString(),
          },
          validateStatus: (status) => true, // Accept all status codes
        ),
      );
      
      // Handle redirects if needed
      if (response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location']?.first;
        if (redirectUrl != null) {
          print('🔄 Following redirect to: $redirectUrl');
          final redirectResponse = await dio.put(
            redirectUrl,
            data: testContent,
            options: Options(
              headers: {
                'Content-Type': 'text/plain',
                'Content-Length': testContent.length.toString(),
              },
            ),
          );
          
          if (redirectResponse.statusCode == 200 || redirectResponse.statusCode == 204) {
            print('✅ S3 connection successful after redirect');
            // Clean up test file
            await _deleteTestFile(testFilename);
            return true;
          }
        }
      }
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ S3 connection successful');
        // Clean up test file
        await _deleteTestFile(testFilename);
        return true;
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        if (response.data != null) {
          print('Response: ${response.data}');
        }
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }
  
  /// Delete test file after connection test
  static Future<void> _deleteTestFile(String filename) async {
    try {
      await deleteImage('https://$_bucketName.s3.$_region.amazonaws.com/$filename');
      print('🧹 Cleaned up test file: $filename');
    } catch (e) {
      print('⚠️ Could not clean up test file: $e');
    }
  }

  /// Delete an image from S3
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract key from URL
      final uri = Uri.parse(imageUrl);
      final key = uri.path.substring(1); // Remove leading slash
      
      final signedUrl = _createSignedUrl('DELETE', key, 0);
      
      final dio = Dio();
      final response = await dio.delete(signedUrl);
      
      return response.statusCode == 204;
    } catch (e) {
      print('❌ Error deleting from S3: $e');
      return false;
    }
  }
}
