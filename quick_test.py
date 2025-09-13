#!/usr/bin/env python3
import requests
import json
import time

BACKEND_URL = "https://uat-api.vmodel.app/wms/graphql/"
HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "WholesalersMarketplace/1.0"
}

def test_supplier_and_product():
    print("🚀 Quick test: 1 supplier + 1 product")
    
    # 1. Register supplier
    print("1. Registering supplier...")
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
        "firstName": "Test",
        "lastName": "Supplier",
        "password1": "Password123!",
        "password2": "Password123!",
        "email": f"testsupplier{int(time.time())}@example.com",
        "accountType": "SUPPLIER",
        "termsAccepted": True
    }
    
    register_response = requests.post(BACKEND_URL, headers=HEADERS, json={'query': register_mutation, 'variables': register_variables})
    print(f"   Status: {register_response.status_code}")
    
    if register_response.status_code == 200:
        register_data = register_response.json()
        print(f"   Response: {json.dumps(register_data, indent=2)}")
        
        if register_data.get('data', {}).get('register', {}).get('success'):
            token = register_data['data']['register']['token']
            print(f"   ✅ Supplier registered successfully!")
            print(f"   Token: {token[:50]}...")
            
            # 2. Create product
            print("\n2. Creating product...")
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
                "name": "Test Product",
                "description": "A test product description",
                "price": 99.99,
                "discountPrice": 10.0,
                "imagesUrl": ["https://picsum.photos/400/400?random=1"],
                "category": "Electronics",
                "stockQuantity": 100
            }
            
            headers_with_auth = HEADERS.copy()
            headers_with_auth["Authorization"] = f"Bearer {token}"
            
            product_response = requests.post(BACKEND_URL, headers=headers_with_auth, json={'query': product_mutation, 'variables': product_variables})
            print(f"   Status: {product_response.status_code}")
            print(f"   Response: {product_response.text}")
            
            if product_response.status_code == 200:
                product_data = product_response.json()
                if product_data.get('data', {}).get('createProduct', {}).get('success'):
                    print("   ✅ Product created successfully!")
                    return True
                else:
                    print("   ❌ Product creation failed")
                    print(f"   Error: {product_data}")
            else:
                print("   ❌ Product creation request failed")
        else:
            print("   ❌ Supplier registration failed")
            print(f"   Errors: {register_data.get('data', {}).get('register', {}).get('errors')}")
    else:
        print("   ❌ Registration request failed")
    
    return False

if __name__ == "__main__":
    success = test_supplier_and_product()
    if success:
        print("\n🎉 Test successful! The backend population should work.")
    else:
        print("\n❌ Test failed. Need to debug the issue.")

