#!/usr/bin/env python3
"""
Script to convert an existing user account to a supplier account.
This will update the account type in the backend.
"""

import requests
import json

BACKEND_URL = "https://uat-api.vmodel.app/wms/graphql/"
HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "WholesalersMarketplace/1.0"
}

def UpdateUserType(email, password):
    """Convert an existing user account to supplier"""
    
    # First, login to get the token
    print(f"🔑 Logging in as {email}...")
    login_mutation = """
    mutation Login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        token
        refreshToken
        user {
          id
          email
          firstName
          lastName
          accountType
        }
      }
    }
    """
    
    login_variables = {
        "email": email,
        "password": password
    }
    
    login_response = requests.post(BACKEND_URL, headers=HEADERS, json={'query': login_mutation, 'variables': login_variables})
    
    if login_response.status_code != 200:
        print(f"❌ Login failed with status {login_response.status_code}")
        print(f"Response: {login_response.text}")
        return False
    
    login_data = login_response.json()
    print(f"Login response: {json.dumps(login_data, indent=2)}")
    
    if not login_data.get('data', {}).get('login', {}).get('token'):
        print("❌ Login failed - no token received")
        return False
    
    token = login_data['data']['login']['token']
    current_account_type = login_data['data']['login']['user'].get('accountType', 'UNKNOWN')
    
    print(f"✅ Login successful!")
    print(f"Current account type: {current_account_type}")
    
    if current_account_type == 'SUPPLIER':
        print("✅ Account is already a supplier!")
        return True
    
    # Try to update account type using updateUser mutation
    print("🔄 Attempting to update account type to SUPPLIER...")
    
    update_mutation = """
    mutation UpdateUser($accountType: String!) {
      updateUser(accountType: $accountType) {
        success
        message
        user {
          id
          email
          firstName
          lastName
          accountType
        }
      }
    }
    """
    
    update_variables = {
        "accountType": "SUPPLIER"
    }
    
    headers_with_auth = HEADERS.copy()
    headers_with_auth["Authorization"] = f"Bearer {token}"
    
    update_response = requests.post(BACKEND_URL, headers=headers_with_auth, json={'query': update_mutation, 'variables': update_variables})
    
    print(f"Update status: {update_response.status_code}")
    print(f"Update response: {update_response.text}")
    
    if update_response.status_code == 200:
        update_data = update_response.json()
        if update_data.get('data', {}).get('updateUser', {}).get('success'):
            print("✅ Account successfully converted to supplier!")
            return True
        else:
            print("❌ Account type update failed")
            print(f"Error: {update_data}")
    else:
        print("❌ Update request failed")
    
    return False

def main():
    print("🚀 UpdateUserType - Convert Account to Supplier")
    print("=" * 50)
    
    # Get user credentials
    email = input("Enter your email: ").strip()
    password = input("Enter your password: ").strip()
    
    if not email or not password:
        print("❌ Email and password are required")
        return
    
    success = UpdateUserType(email, password)
    
    if success:
        print("\n🎉 Success! Your account is now a supplier account.")
        print("You can now create products in the app.")
    else:
        print("\n❌ Failed to convert account to supplier.")
        print("You may need to contact support or create a new supplier account.")

if __name__ == "__main__":
    main()
