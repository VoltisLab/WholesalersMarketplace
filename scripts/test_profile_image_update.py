#!/usr/bin/env python3
"""
Test script for profile image update functionality
"""

import requests
import json

# Backend URL
BASE_URL = "http://localhost:8000/graphql/"

def test_profile_image_update():
    """Test the profile image update mutation"""
    
    # First, login to get a token
    login_mutation = """
    mutation Login($email: String!, $password: String!) {
        login(email: $email, password: $password) {
            token
            refreshToken
            user {
                id
                email
                accountType
            }
        }
    }
    """
    
    login_variables = {
        "email": "demo@supplier.com",
        "password": "Demo123!"
    }
    
    print("🔄 Logging in...")
    response = requests.post(
        BASE_URL,
        json={
            "query": login_mutation,
            "variables": login_variables
        }
    )
    
    if response.status_code != 200:
        print(f"❌ Login failed: {response.status_code}")
        return
    
    login_data = response.json()
    
    if "errors" in login_data:
        print(f"❌ Login error: {login_data['errors']}")
        return
    
    token = login_data["data"]["login"]["token"]
    print(f"✅ Login successful! Token: {token[:20]}...")
    
    # Test profile image update
    update_mutation = """
    mutation UpdateProfileImage($profileImage: String!) {
        updateProfileImage(profileImage: $profileImage) {
            success
            message
            user {
                id
                firstName
                lastName
                email
                phone
                accountType
                profileImage
            }
        }
    }
    """
    
    update_variables = {
        "profileImage": "https://example.com/test-profile-image.jpg"
    }
    
    print("🔄 Testing profile image update...")
    response = requests.post(
        BASE_URL,
        json={
            "query": update_mutation,
            "variables": update_variables
        },
        headers={
            "Authorization": f"Bearer {token}"
        }
    )
    
    if response.status_code != 200:
        print(f"❌ Profile update failed: {response.status_code}")
        print(f"Response: {response.text}")
        return
    
    update_data = response.json()
    
    if "errors" in update_data:
        print(f"❌ Profile update error: {update_data['errors']}")
        return
    
    result = update_data["data"]["updateProfileImage"]
    print(f"✅ Profile update result: {json.dumps(result, indent=2)}")

if __name__ == "__main__":
    test_profile_image_update()
