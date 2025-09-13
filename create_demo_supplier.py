#!/usr/bin/env python3
"""
Create a demo supplier account for testing product creation.
"""

import requests
import json

BACKEND_URL = "https://uat-api.vmodel.app/wms/graphql/"
HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "WholesalersMarketplace/1.0"
}

def create_demo_supplier():
    """Create a demo supplier account"""
    
    print("🚀 Creating Demo Supplier Account")
    print("=" * 40)
    
    # Register supplier
    register_mutation = """
    mutation Register($firstName: String!, $lastName: String!, $password1: String!, $password2: String!, $email: String!, $accountType: String!, $termsAccepted: Boolean!) {
      register(firstName: $firstName, lastName: $lastName, password1: $password1, password2: $password2, email: $email, accountType: $accountType, termsAccepted: $termsAccepted) {
        success
        token
        refreshToken
        errors
      }
    }
    """
    
    register_variables = {
        "firstName": "Demo",
        "lastName": "Supplier",
        "password1": "Demo123!",
        "password2": "Demo123!",
        "email": "demo@supplier.com",
        "accountType": "SUPPLIER",
        "termsAccepted": True
    }
    
    print("📝 Registering demo supplier...")
    register_response = requests.post(BACKEND_URL, headers=HEADERS, json={'query': register_mutation, 'variables': register_variables})
    
    print(f"Status: {register_response.status_code}")
    register_data = register_response.json()
    print(f"Response: {json.dumps(register_data, indent=2)}")
    
    if register_data.get('data', {}).get('register', {}).get('success'):
        token = register_data['data']['register']['token']
        print("✅ Demo supplier account created successfully!")
        print(f"📧 Email: demo@supplier.com")
        print(f"🔑 Password: Demo123!")
        print(f"🎫 Token: {token[:50]}...")
        
        # Test product creation
        print("\n🧪 Testing product creation...")
        product_mutation = """
        mutation CreateProduct($name: String!, $description: String!, $price: Float!, $discountPrice: Float, $imagesUrl: [String!]!, $category: String!, $stockQuantity: Int!) {
          createProduct(name: $name, description: $description, price: $price, discountPrice: $discountPrice, imagesUrl: $imagesUrl, category: $category, stockQuantity: $stockQuantity) {
            success
            message
            product {
              id
              name
              price
              category
            }
          }
        }
        """
        
        product_variables = {
            "name": "Demo Product",
            "description": "A demo product for testing",
            "price": 99.99,
            "discountPrice": 10.0,
            "imagesUrl": ["https://picsum.photos/400/400?random=1"],
            "category": "Electronics",
            "stockQuantity": 100
        }
        
        headers_with_auth = HEADERS.copy()
        headers_with_auth["Authorization"] = f"Bearer {token}"
        
        product_response = requests.post(BACKEND_URL, headers=headers_with_auth, json={'query': product_mutation, 'variables': product_variables})
        
        print(f"Product creation status: {product_response.status_code}")
        product_data = product_response.json()
        print(f"Product creation response: {json.dumps(product_data, indent=2)}")
        
        if product_data.get('data', {}).get('createProduct', {}).get('success'):
            print("✅ Product creation test successful!")
            print("🎉 Demo supplier account is ready for testing!")
        else:
            print("❌ Product creation test failed")
            print("You may need to check the backend configuration")
        
        return True
    else:
        print("❌ Demo supplier account creation failed")
        print(f"Errors: {register_data.get('data', {}).get('register', {}).get('errors')}")
        return False

if __name__ == "__main__":
    success = create_demo_supplier()
    
    if success:
        print("\n" + "="*50)
        print("🎯 DEMO ACCOUNT READY!")
        print("="*50)
        print("📧 Email: demo@supplier.com")
        print("🔑 Password: Demo123!")
        print("👤 Account Type: SUPPLIER")
        print("\nYou can now login with these credentials in the app")
        print("and test product creation functionality!")
    else:
        print("\n❌ Failed to create demo supplier account")

