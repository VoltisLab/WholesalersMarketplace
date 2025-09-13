#!/usr/bin/env python3
"""
Script to create a simple image upload endpoint for the Django backend
This creates a basic file upload endpoint that can be used for profile images
"""

import os
import requests
import json

def create_image_upload_endpoint():
    """Create a simple image upload endpoint"""
    
    # Check if backend is running
    try:
        response = requests.get("http://localhost:8000/")
        print("✅ Backend is running")
    except:
        print("⚠️ Backend is not running, but showing the code you need to add...")
    
    # Create the upload directory if it doesn't exist
    upload_dir = "media/profile_images"
    if not os.path.exists(upload_dir):
        os.makedirs(upload_dir)
        print(f"✅ Created upload directory: {upload_dir}")
    
    print("\n📝 To add image upload functionality to your Django backend, add this code:")
    print("\n" + "="*60)
    print("1. Add to your Django settings.py:")
    print("""
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
""")
    
    print("\n2. Add to your main urls.py:")
    print("""
from django.conf import settings
from django.conf.urls.static import static
from django.urls import path, include

urlpatterns = [
    # ... your existing patterns
    path('api/upload-image/', include('your_app.urls')),  # Add this line
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
""")
    
    print("\n3. Create a new view in your app (e.g., views.py):")
    print("""
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import uuid
import os

@csrf_exempt
def upload_image(request):
    if request.method == 'POST':
        try:
            if 'image' in request.FILES:
                image_file = request.FILES['image']
                
                # Generate unique filename
                file_extension = os.path.splitext(image_file.name)[1]
                unique_filename = f"{uuid.uuid4()}{file_extension}"
                
                # Save the file
                file_path = default_storage.save(f'profile_images/{unique_filename}', image_file)
                
                # Return the URL
                image_url = request.build_absolute_uri(f'/media/{file_path}')
                
                return JsonResponse({
                    'success': True,
                    'image_url': image_url,
                    'message': 'Image uploaded successfully'
                })
            else:
                return JsonResponse({
                    'success': False,
                    'message': 'No image file provided'
                }, status=400)
                
        except Exception as e:
            return JsonResponse({
                'success': False,
                'message': f'Upload failed: {str(e)}'
            }, status=500)
    
    return JsonResponse({
        'success': False,
        'message': 'Only POST method allowed'
    }, status=405)
""")
    
    print("\n4. Add URL pattern in your app's urls.py:")
    print("""
from django.urls import path
from . import views

urlpatterns = [
    path('upload-image/', views.upload_image, name='upload_image'),
]
""")
    
    print("\n5. Add to your User model (models.py):")
    print("""
from django.db import models

class User(AbstractUser):
    # ... your existing fields
    profile_image = models.ImageField(
        upload_to='profile_images/',
        null=True,
        blank=True,
        help_text='Profile image for the user'
    )
""")
    
    print("\n6. Create and run migrations:")
    print("""
python manage.py makemigrations
python manage.py migrate
""")
    
    print("\n" + "="*60)
    print("✅ After implementing these changes, your Flutter app will be able to upload images!")
    print("📁 Images will be stored in: media/profile_images/")
    print("🌐 Images will be accessible at: http://localhost:8000/media/profile_images/")

if __name__ == "__main__":
    create_image_upload_endpoint()
