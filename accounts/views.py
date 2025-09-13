from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import uuid
import os

# Create your views here.

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