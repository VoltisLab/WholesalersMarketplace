#!/usr/bin/env python3
"""
Script to add profile image upload functionality to the Django backend
"""

import requests
import json

# Backend URL
BASE_URL = "http://localhost:8000/graphql/"

def add_profile_image_upload():
    """Add profile image upload mutation to the backend"""
    
    # First, let's check if the backend is running
    try:
        response = requests.get("http://localhost:8000/")
        print("✅ Backend is running")
    except:
        print("❌ Backend is not running. Please start the Django server first.")
        return
    
    # Check current schema
    introspection_query = """
    query IntrospectionQuery {
      __schema {
        mutationType {
          fields {
            name
            description
          }
        }
      }
    }
    """
    
    print("🔄 Checking current GraphQL schema...")
    response = requests.post(
        BASE_URL,
        json={"query": introspection_query}
    )
    
    if response.status_code == 200:
        data = response.json()
        mutations = data.get('data', {}).get('__schema', {}).get('mutationType', {}).get('fields', [])
        mutation_names = [m['name'] for m in mutations]
        
        print(f"📋 Available mutations: {', '.join(mutation_names)}")
        
        if 'updateProfileImage' in mutation_names:
            print("✅ updateProfileImage mutation already exists!")
        else:
            print("❌ updateProfileImage mutation not found. Need to add it to Django backend.")
            print("\n📝 To add profile image upload, you need to:")
            print("1. Add a profileImage field to the User model in Django")
            print("2. Create a mutation resolver for updateProfileImage")
            print("3. Add file upload handling for images")
    else:
        print(f"❌ Failed to connect to GraphQL endpoint: {response.status_code}")

if __name__ == "__main__":
    add_profile_image_upload()
