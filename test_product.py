#!/usr/bin/env python3
import requests
import json

BACKEND_URL = "https://uat-api.vmodel.app/wms/graphql/"
HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "WholesalersMarketplace/1.0"
}

# Register a supplier first
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
    "email": "testsupplier4@example.com",
    "accountType": "SUPPLIER",
    "termsAccepted": True
}

print("1. Registering supplier...")
register_response = requests.post(BACKEND_URL, headers=HEADERS, json={'query': register_mutation, 'variables': register_variables})
print(f"Status: {register_response.status_code}")
register_data = register_response.json()
print(f"Response: {json.dumps(register_data, indent=2)}")

if register_data.get('data', {}).get('register', {}).get('success'):
    token = register_data['data']['register']['token']
    print(f"\n2. Got token: {token[:50]}...")
    
    # Test product creation with minimal fields
    product_mutation = """
    mutation CreateProduct($name: String!, $description: String!, $price: Float!, $imagesUrl: [String!]!, $category: Int!) {
      createProduct(name: $name, description: $description, price: $price, imagesUrl: $imagesUrl, category: $category) {
        success
        message
        product {
          id
          name
          price
        }
      }
    }
    """
    
    product_variables = {
        "name": "Test Product",
        "description": "A test product description",
        "price": 99.99,
        "imagesUrl": ["https://picsum.photos/400/400?random=1"],
        "category": 1
    }
    
    headers_with_auth = HEADERS.copy()
    headers_with_auth["Authorization"] = f"Bearer {token}"
    
    print("\n3. Creating product...")
    product_response = requests.post(BACKEND_URL, headers=headers_with_auth, json={'query': product_mutation, 'variables': product_variables})
    print(f"Status: {product_response.status_code}")
    print(f"Response: {product_response.text}")
else:
    print("Registration failed")

