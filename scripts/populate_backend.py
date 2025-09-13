#!/usr/bin/env python3
"""
Script to populate the backend with 100 suppliers and 20 products each.
This will create 2000 products total across 100 suppliers.
"""

import requests
import json
import random
import time
from faker import Faker

# Initialize Faker for generating realistic data
fake = Faker()

# Backend configuration
BACKEND_URL = "https://uat-api.vmodel.app/wms/graphql/"
HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "WholesalersMarketplace/1.0"
}

# Product categories and sample data
CATEGORIES = [
    "Electronics", "Clothing", "Home & Garden", "Sports", "Beauty", 
    "Books", "Toys", "Automotive", "Health", "Office Supplies"
]

PRODUCT_TYPES = {
    "Electronics": ["Smartphone", "Laptop", "Headphones", "Camera", "Tablet", "Smartwatch", "Speaker", "Charger", "Cable", "Adapter"],
    "Clothing": ["T-Shirt", "Jeans", "Dress", "Jacket", "Sweater", "Shoes", "Hat", "Scarf", "Belt", "Socks"],
    "Home & Garden": ["Lamp", "Chair", "Table", "Plant", "Tool", "Decor", "Kitchen", "Bathroom", "Bedroom", "Living Room"],
    "Sports": ["Ball", "Racket", "Shoes", "Equipment", "Gear", "Apparel", "Accessories", "Training", "Outdoor", "Fitness"],
    "Beauty": ["Skincare", "Makeup", "Hair", "Fragrance", "Tools", "Bath", "Body", "Face", "Lips", "Eyes"],
    "Books": ["Fiction", "Non-Fiction", "Textbook", "Comic", "Magazine", "Journal", "Guide", "Manual", "Reference", "Children"],
    "Toys": ["Action Figure", "Doll", "Game", "Puzzle", "Educational", "Outdoor", "Electronic", "Building", "Art", "Music"],
    "Automotive": ["Part", "Accessory", "Tool", "Maintenance", "Interior", "Exterior", "Engine", "Electrical", "Safety", "Performance"],
    "Health": ["Supplement", "Equipment", "Monitor", "Therapy", "Fitness", "Medical", "Wellness", "Nutrition", "Care", "Treatment"],
    "Office Supplies": ["Pen", "Paper", "Folder", "Binder", "Desk", "Chair", "Computer", "Printer", "Storage", "Organization"]
}

def make_graphql_request(query, variables=None):
    """Make a GraphQL request to the backend"""
    payload = {
        "query": query,
        "variables": variables or {}
    }
    
    try:
        response = requests.post(BACKEND_URL, headers=HEADERS, json=payload, timeout=30)
        if response.status_code != 200:
            print(f"❌ Request failed with status {response.status_code}: {response.text}")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return None

def register_supplier(first_name, last_name, email, password):
    """Register a new supplier"""
    mutation = """
    mutation Register($firstName: String!, $lastName: String!, $password1: String!, $password2: String!, $email: String!, $accountType: String!, $termsAccepted: Boolean!) {
      register(
        firstName: $firstName,
        lastName: $lastName,
        password1: $password1,
        password2: $password2,
        email: $email,
        accountType: $accountType,
        termsAccepted: $termsAccepted
      ) {
        success
        token
        refreshToken
        errors
      }
    }
    """
    
    variables = {
        "firstName": first_name,
        "lastName": last_name,
        "password1": password,
        "password2": password,
        "email": email,
        "accountType": "SUPPLIER",
        "termsAccepted": True
    }
    
    return make_graphql_request(mutation, variables)

def login_supplier(email, password):
    """Login as a supplier to get authentication token"""
    mutation = """
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
    
    variables = {
        "email": email,
        "password": password
    }
    
    return make_graphql_request(mutation, variables)

def create_product(token, name, description, price, discount_price, images_url, category, stock_quantity):
    """Create a product for a supplier"""
    mutation = """
    mutation CreateProduct(
      $name: String!,
      $description: String!,
      $price: Float!,
      $discountPrice: Float,
      $imagesUrl: [String!]!,
      $category: String!,
      $subcategory: String,
      $stockQuantity: Int!,
      $tags: [String!],
      $specifications: String,
      $dimensions: String,
      $weight: Float,
      $materials: [String!],
      $careInstructions: String
    ) {
      createProduct(
        name: $name,
        description: $description,
        price: $price,
        discountPrice: $discountPrice,
        imagesUrl: $imagesUrl,
        category: $category,
        subcategory: $subcategory,
        stockQuantity: $stockQuantity,
        tags: $tags,
        specifications: $specifications,
        dimensions: $dimensions,
        weight: $weight,
        materials: $materials,
        careInstructions: $careInstructions
      ) {
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
    
    variables = {
        "name": name,
        "description": description,
        "price": price,
        "discountPrice": discount_price,
        "imagesUrl": images_url,
        "category": category,
        "subcategory": None,
        "stockQuantity": stock_quantity,
        "tags": None,
        "specifications": None,
        "dimensions": None,
        "weight": None,
        "materials": None,
        "careInstructions": None
    }
    
    # Add authorization header
    headers = HEADERS.copy()
    headers["Authorization"] = f"Bearer {token}"
    
    payload = {
        "query": mutation,
        "variables": variables
    }
    
    try:
        response = requests.post(BACKEND_URL, headers=headers, json=payload, timeout=30)
        if response.status_code != 200:
            print(f"❌ Product creation failed with status {response.status_code}: {response.text}")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"❌ Product creation failed: {e}")
        return None

def generate_supplier_data():
    """Generate realistic supplier data"""
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = fake.email()
    password = fake.password(length=12, special_chars=True, digits=True, upper_case=True, lower_case=True)
    
    return {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "password": password
    }

def generate_product_data(supplier_name, category):
    """Generate realistic product data"""
    product_type = random.choice(PRODUCT_TYPES[category])
    brand = fake.company()
    model = fake.bothify(text='??-####', letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    
    name = f"{brand} {product_type} {model}"
    description = fake.paragraph(nb_sentences=3)
    
    # Generate realistic pricing
    base_price = round(random.uniform(10, 500), 2)
    discount_price = round(base_price * random.uniform(0.1, 0.3), 2) if random.random() < 0.3 else None
    
    # Generate product images (using placeholder service)
    images = [
        f"https://picsum.photos/400/400?random={random.randint(1, 1000)}",
        f"https://picsum.photos/400/400?random={random.randint(1, 1000)}",
        f"https://picsum.photos/400/400?random={random.randint(1, 1000)}"
    ]
    
    stock_quantity = random.randint(10, 1000)
    
    return {
        "name": name,
        "description": description,
        "price": base_price,
        "discount_price": discount_price,
        "images": images,
        "category": category,
        "stock_quantity": stock_quantity
    }

def main():
    """Main function to populate the backend"""
    print("🚀 Starting backend population...")
    print("📊 Target: 100 suppliers with 20 products each (2000 total products)")
    print("=" * 60)
    
    successful_suppliers = 0
    successful_products = 0
    failed_suppliers = 0
    failed_products = 0
    
    for supplier_num in range(1, 2):  # Test with 1 supplier first
        print(f"\n🔄 Processing Supplier {supplier_num}/1...")
        
        # Generate supplier data
        supplier_data = generate_supplier_data()
        print(f"   📝 Name: {supplier_data['first_name']} {supplier_data['last_name']}")
        print(f"   📧 Email: {supplier_data['email']}")
        
        # Register supplier
        print("   🔐 Registering supplier...")
        register_result = register_supplier(
            supplier_data['first_name'],
            supplier_data['last_name'],
            supplier_data['email'],
            supplier_data['password']
        )
        
        if not register_result or not register_result.get('data', {}).get('register', {}).get('success'):
            print(f"   ❌ Failed to register supplier: {supplier_data['email']}")
            if register_result and register_result.get('data', {}).get('register', {}).get('errors'):
                print(f"   📝 Errors: {register_result['data']['register']['errors']}")
            failed_suppliers += 1
            continue
        
        # Login to get token
        print("   🔑 Logging in...")
        login_result = login_supplier(supplier_data['email'], supplier_data['password'])
        
        if not login_result or not login_result.get('data', {}).get('login', {}).get('token'):
            print(f"   ❌ Failed to login supplier: {supplier_data['email']}")
            failed_suppliers += 1
            continue
        
        token = login_result['data']['login']['token']
        supplier_name = f"{supplier_data['first_name']} {supplier_data['last_name']}"
        successful_suppliers += 1
        
        print(f"   ✅ Supplier registered and logged in successfully")
        
        # Create 20 products for this supplier
        print("   📦 Creating products...")
        supplier_products = 0
        
        for product_num in range(1, 2):  # Test with 1 product first
            category = random.choice(CATEGORIES)
            product_data = generate_product_data(supplier_name, category)
            
            product_result = create_product(
                token,
                product_data['name'],
                product_data['description'],
                product_data['price'],
                product_data['discount_price'],
                product_data['images'],
                product_data['category'],
                product_data['stock_quantity']
            )
            
            if product_result and product_result.get('data', {}).get('createProduct', {}).get('success'):
                supplier_products += 1
                successful_products += 1
            else:
                failed_products += 1
            
            # Small delay to avoid overwhelming the server
            time.sleep(0.1)
        
        print(f"   ✅ Created {supplier_products}/20 products for {supplier_name}")
        
        # Progress update
        if supplier_num % 10 == 0:
            print(f"\n📊 Progress Update:")
            print(f"   ✅ Successful Suppliers: {successful_suppliers}")
            print(f"   ❌ Failed Suppliers: {failed_suppliers}")
            print(f"   ✅ Successful Products: {successful_products}")
            print(f"   ❌ Failed Products: {failed_products}")
            print("=" * 60)
        
        # Delay between suppliers
        time.sleep(1)
    
    # Final summary
    print(f"\n🎉 Backend Population Complete!")
    print("=" * 60)
    print(f"📊 Final Results:")
    print(f"   ✅ Successful Suppliers: {successful_suppliers}/100")
    print(f"   ❌ Failed Suppliers: {failed_suppliers}/100")
    print(f"   ✅ Successful Products: {successful_products}/2000")
    print(f"   ❌ Failed Products: {failed_products}/2000")
    print(f"   📈 Success Rate: {(successful_suppliers/100)*100:.1f}% suppliers, {(successful_products/2000)*100:.1f}% products")
    
    if successful_suppliers > 0:
        print(f"\n🎯 Average products per supplier: {successful_products/successful_suppliers:.1f}")
    
    print("\n✨ Backend is now populated with realistic supplier and product data!")

if __name__ == "__main__":
    main()
