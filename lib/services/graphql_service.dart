import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'error_service.dart';
import 'token_service.dart';

class GraphQLService {
  static const String _endpoint = 'http://127.0.0.1:8000/graphql/';
  
  static GraphQLClient get client {
    final HttpLink httpLink = HttpLink(
      _endpoint,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WholesalersMarketplace/1.0',
      },
    );
    
    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  static GraphQLClient getAuthenticatedClient(String token) {
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );
    
    final HttpLink httpLink = HttpLink(_endpoint);
    
    final Link link = authLink.concat(httpLink);
    
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
}

class GraphQLQueries {
  static const String register = '''
    mutation Register(\$firstName: String!, \$lastName: String!, \$password1: String!, \$password2: String!, \$email: String!, \$accountType: String!, \$termsAccepted: Boolean!) {
      register(
        firstName: \$firstName,
        lastName: \$lastName,
        password1: \$password1,
        password2: \$password2,
        email: \$email,
        accountType: \$accountType,
        termsAccepted: \$termsAccepted
      ) {
        token
        refreshToken
        success
        errors
      }
    }
  ''';

  static const String login = '''
    mutation Login(\$email: String!, \$password: String!) {
      login(
        email: \$email,
        password: \$password
      ) {
        token
        refreshToken
        user {
          accountType
        }
      }
    }
  ''';

  static const String viewMe = '''
    query ViewMe {
      viewMe {
        id
        email
        firstName
        lastName
        phoneNumber
        dob
        gender
        streetAddress
        city
        postalCode
        accountType
      }
    }
  ''';

  static const String logout = '''
    mutation Logout(\$refreshToken: String!) {
      logout(refreshToken: \$refreshToken) {
        __typename
        message
      }
    }
  ''';

  static const String resetPassword = '''
    mutation ResetPassword(\$currentPassword: String!, \$newPassword: String!) {
      resetPassword(
        currentPassword: \$currentPassword,
        newPassword: \$newPassword
      ) {
        success
        message
      }
    }
  ''';

  // Two-Factor Authentication
  static const String is2FAEnabled = '''
    query Is2FAEnabled {
      is2FAEnabled {
        enabled
      }
    }
  ''';

  static const String enable2FA = '''
    mutation Enable2FA {
      enable2FA {
        success
        qrCodeUrl
        backupCode
        backupCodes
      }
    }
  ''';

  static const String disable2FA = '''
    mutation Disable2FA(\$password: String!) {
      disable2FA(password: \$password) {
        success
        message
      }
    }
  ''';

  static const String verify2FA = '''
    mutation Verify2FA(\$code: String!) {
      verify2FA(code: \$code) {
        success
        message
      }
    }
  ''';

  // Active Sessions
  static const String getActiveSessions = '''
    query GetActiveSessions {
      getActiveSessions {
        sessions {
          id
          deviceName
          deviceType
          location
          ipAddress
          lastActive
          userAgent
        }
        currentSessionId
      }
    }
  ''';

  static const String terminateSession = '''
    mutation TerminateSession(\$sessionId: String!) {
      terminateSession(sessionId: \$sessionId) {
        success
        message
      }
    }
  ''';

  static const String terminateAllOtherSessions = '''
    mutation TerminateAllOtherSessions {
      terminateAllOtherSessions {
        success
        message
      }
    }
  ''';

  // Address Management Queries
  static const String myAddresses = '''
    query MyAddresses {
      myAddresses {
        id
        name
        phoneNumber
        streetAddress
        city
        state
        country
        postalCode
        addressType
        isDefault
        latitude
        longitude
        instructions
        createdAt
        updatedAt
      }
    }
  ''';

  static const String createAddress = '''
    mutation CreateAddress(
      \$name: String!,
      \$phoneNumber: String!,
      \$streetAddress: String!,
      \$city: String!,
      \$state: String,
      \$country: String,
      \$postalCode: String!,
      \$addressType: String,
      \$isDefault: Boolean,
      \$latitude: Float,
      \$longitude: Float,
      \$instructions: String
    ) {
      createAddress(
        name: \$name,
        phoneNumber: \$phoneNumber,
        streetAddress: \$streetAddress,
        city: \$city,
        state: \$state,
        country: \$country,
        postalCode: \$postalCode,
        addressType: \$addressType,
        isDefault: \$isDefault,
        latitude: \$latitude,
        longitude: \$longitude,
        instructions: \$instructions
      ) {
        address {
          id
          name
          phoneNumber
          streetAddress
          city
          state
          country
          postalCode
          addressType
          isDefault
          latitude
          longitude
          instructions
        }
        success
        message
      }
    }
  ''';

  static const String updateAddress = '''
    mutation UpdateAddress(
      \$addressId: ID!,
      \$name: String,
      \$phoneNumber: String,
      \$streetAddress: String,
      \$city: String,
      \$state: String,
      \$country: String,
      \$postalCode: String,
      \$addressType: String,
      \$isDefault: Boolean,
      \$latitude: Float,
      \$longitude: Float,
      \$instructions: String
    ) {
      updateAddress(
        addressId: \$addressId,
        name: \$name,
        phoneNumber: \$phoneNumber,
        streetAddress: \$streetAddress,
        city: \$city,
        state: \$state,
        country: \$country,
        postalCode: \$postalCode,
        addressType: \$addressType,
        isDefault: \$isDefault,
        latitude: \$latitude,
        longitude: \$longitude,
        instructions: \$instructions
      ) {
        address {
          id
          name
          phoneNumber
          streetAddress
          city
          state
          country
          postalCode
          addressType
          isDefault
          latitude
          longitude
          instructions
        }
        success
        message
      }
    }
  ''';

  static const String deleteAddress = '''
    mutation DeleteAddress(\$addressId: ID!) {
      deleteAddress(addressId: \$addressId) {
        success
        message
      }
    }
  ''';

  // Payment Methods Queries
  static const String myPaymentMethods = '''
    query MyPaymentMethods {
      myPaymentMethods {
        id
        paymentType
        isDefault
        cardLastFour
        cardBrand
        cardExpMonth
        cardExpYear
        isActive
        createdAt
        updatedAt
      }
    }
  ''';

  // Notification Preferences
  static const String myNotificationPreferences = '''
    query MyNotificationPreferences {
      myNotificationPreferences {
        id
        pushNotifications
        pushOrders
        pushPromotions
        pushMessages
        pushReviews
        emailNotifications
        emailOrders
        emailPromotions
        emailMessages
        emailReviews
        emailNewsletter
        smsNotifications
        smsOrders
        smsPromotions
        createdAt
        updatedAt
      }
    }
  ''';

  static const String updateNotificationPreferences = '''
    mutation UpdateNotificationPreferences(
      \$pushNotifications: Boolean,
      \$pushOrders: Boolean,
      \$pushPromotions: Boolean,
      \$pushMessages: Boolean,
      \$pushReviews: Boolean,
      \$emailNotifications: Boolean,
      \$emailOrders: Boolean,
      \$emailPromotions: Boolean,
      \$emailMessages: Boolean,
      \$emailReviews: Boolean,
      \$emailNewsletter: Boolean,
      \$smsNotifications: Boolean,
      \$smsOrders: Boolean,
      \$smsPromotions: Boolean
    ) {
      updateNotificationPreferences(
        pushNotifications: \$pushNotifications,
        pushOrders: \$pushOrders,
        pushPromotions: \$pushPromotions,
        pushMessages: \$pushMessages,
        pushReviews: \$pushReviews,
        emailNotifications: \$emailNotifications,
        emailOrders: \$emailOrders,
        emailPromotions: \$emailPromotions,
        emailMessages: \$emailMessages,
        emailReviews: \$emailReviews,
        emailNewsletter: \$emailNewsletter,
        smsNotifications: \$smsNotifications,
        smsOrders: \$smsOrders,
        smsPromotions: \$smsPromotions
      ) {
        preferences {
          id
          pushNotifications
          pushOrders
          pushPromotions
          pushMessages
          pushReviews
          emailNotifications
          emailOrders
          emailPromotions
          emailMessages
          emailReviews
          emailNewsletter
          smsNotifications
          smsOrders
          smsPromotions
        }
        success
        message
      }
    }
  ''';

  // Support System
  static const String createSupportTicket = '''
    mutation CreateSupportTicket(
      \$ticketType: String!,
      \$priority: String,
      \$subject: String!,
      \$description: String!,
      \$orderId: ID,
      \$productId: ID,
      \$attachments: [String]
    ) {
      createSupportTicket(
        ticketType: \$ticketType,
        priority: \$priority,
        subject: \$subject,
        description: \$description,
        orderId: \$orderId,
        productId: \$productId,
        attachments: \$attachments
      ) {
        ticket {
          id
          ticketNumber
          ticketType
          priority
          status
          subject
          description
          createdAt
          updatedAt
        }
        success
        message
      }
    }
  ''';

  static const String createFeedback = '''
    mutation CreateFeedback(
      \$feedbackType: String!,
      \$title: String!,
      \$message: String!,
      \$overallRating: Int,
      \$easeOfUseRating: Int,
      \$featuresRating: Int,
      \$performanceRating: Int,
      \$isAnonymous: Boolean,
      \$deviceInfo: JSONString,
      \$appVersion: String
    ) {
      createFeedback(
        feedbackType: \$feedbackType,
        title: \$title,
        message: \$message,
        overallRating: \$overallRating,
        easeOfUseRating: \$easeOfUseRating,
        featuresRating: \$featuresRating,
        performanceRating: \$performanceRating,
        isAnonymous: \$isAnonymous,
        deviceInfo: \$deviceInfo,
        appVersion: \$appVersion
      ) {
        feedback {
          id
          feedbackType
          title
          message
          overallRating
          easeOfUseRating
          featuresRating
          performanceRating
          isAnonymous
          createdAt
        }
        success
        message
      }
    }
  ''';

  static const String createBugReport = '''
    mutation CreateBugReport(
      \$bugType: String!,
      \$severity: String!,
      \$frequency: String!,
      \$title: String!,
      \$description: String!,
      \$stepsToReproduce: String,
      \$expectedBehavior: String,
      \$actualBehavior: String,
      \$deviceInfo: JSONString,
      \$appVersion: String,
      \$osVersion: String,
      \$browserInfo: String,
      \$screenshots: [String],
      \$logFiles: [String]
    ) {
      createBugReport(
        bugType: \$bugType,
        severity: \$severity,
        frequency: \$frequency,
        title: \$title,
        description: \$description,
        stepsToReproduce: \$stepsToReproduce,
        expectedBehavior: \$expectedBehavior,
        actualBehavior: \$actualBehavior,
        deviceInfo: \$deviceInfo,
        appVersion: \$appVersion,
        osVersion: \$osVersion,
        browserInfo: \$browserInfo,
        screenshots: \$screenshots,
        logFiles: \$logFiles
      ) {
        bugReport {
          id
          bugType
          severity
          frequency
          title
          description
          status
          createdAt
        }
        success
        message
      }
    }
  ''';

  // Order Management
  static const String myOrders = '''
    query MyOrders(\$status: String) {
      myOrders(status: \$status) {
        id
        orderNumber
        status
        paymentStatus
        subtotal
        taxAmount
        shippingCost
        totalAmount
        shippingAddress
        billingAddress
        paymentMethod
        trackingNumber
        notes
        createdAt
        updatedAt
        items {
          id
          productName
          quantity
          unitPrice
          totalPrice
          productImage
        }
      }
    }
  ''';

  static const String createOrder = '''
    mutation CreateOrder(
      \$orderData: OrderInput!,
      \$items: [OrderItemInput!]!
    ) {
      createOrder(orderData: \$orderData, items: \$items) {
        order {
          id
          orderNumber
          status
          paymentStatus
          subtotal
          taxAmount
          shippingCost
          totalAmount
          shippingAddress
          billingAddress
          paymentMethod
          notes
          createdAt
        }
        success
        message
      }
    }
  ''';

  // Cart Management
  static const String myCart = '''
    query MyCart {
      myCart {
        id
        totalItems
        totalAmount
        items {
          id
          product {
            id
            name
            price
            imagesUrl
          }
          quantity
          totalPrice
        }
      }
    }
  ''';

  static const String addToCart = '''
    mutation AddToCart(\$productId: ID!, \$quantity: Int) {
      addToCart(productId: \$productId, quantity: \$quantity) {
        cartItem {
          id
          product {
            id
            name
            price
            imagesUrl
          }
          quantity
          totalPrice
        }
        success
        message
      }
    }
  ''';

  static const String updateCartItem = '''
    mutation UpdateCartItem(\$cartItemId: ID!, \$quantity: Int!) {
      updateCartItem(cartItemId: \$cartItemId, quantity: \$quantity) {
        cartItem {
          id
          product {
            id
            name
            price
            imagesUrl
          }
          quantity
          totalPrice
        }
        success
        message
      }
    }
  ''';

  static const String removeFromCart = '''
    mutation RemoveFromCart(\$cartItemId: ID!) {
      removeFromCart(cartItemId: \$cartItemId) {
        success
        message
      }
    }
  ''';

  // Wishlist Management
  static const String myWishlist = '''
    query MyWishlist {
      myWishlist {
        id
        product {
          id
          name
          price
          imagesUrl
          seller {
            id
            firstName
            lastName
          }
        }
        createdAt
      }
    }
  ''';

  static const String addToWishlist = '''
    mutation AddToWishlist(\$productId: ID!) {
      addToWishlist(productId: \$productId) {
        wishlistItem {
          id
          product {
            id
            name
            price
            imagesUrl
          }
        }
        success
        message
      }
    }
  ''';

  static const String removeFromWishlist = '''
    mutation RemoveFromWishlist(\$productId: ID!) {
      removeFromWishlist(productId: \$productId) {
        success
        message
      }
    }
  ''';

  // Product Management Queries
  static const String allProducts = '''
    query AllProducts(\$first: Int, \$after: String, \$category: String, \$search: String, \$minPrice: Float, \$maxPrice: Float, \$sortBy: String) {
      allProducts(
        first: \$first,
        after: \$after,
        category: \$category,
        search: \$search,
        minPrice: \$minPrice,
        maxPrice: \$maxPrice,
        sortBy: \$sortBy
      ) {
        edges {
          node {
            id
            name
            description
            price
            discountPrice
            imagesUrl
            category
            subcategory
            stockQuantity
            rating
            reviewCount
            tags
            isFeatured
            isActive
            createdAt
            updatedAt
            vendor {
              id
              firstName
              lastName
              businessName
              rating
              reviewCount
              isVerified
            }
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  static const String productById = '''
    query ProductById(\$id: ID!) {
      productById(id: \$id) {
        id
        name
        description
        price
        discountPrice
        imagesUrl
        category
        subcategory
        stockQuantity
        rating
        reviewCount
        tags
        isFeatured
        isActive
        createdAt
        updatedAt
        vendor {
          id
          firstName
          lastName
          businessName
          rating
          reviewCount
          isVerified
          email
          phone
        }
        specifications
        dimensions
        weight
        materials
        careInstructions
      }
    }
  ''';

  static const String featuredProducts = '''
    query FeaturedProducts(\$limit: Int) {
      featuredProducts(limit: \$limit) {
        id
        name
        description
        price
        discountPrice
        imagesUrl
        category
        subcategory
        stockQuantity
        rating
        reviewCount
        tags
        isFeatured
        vendor {
          id
          businessName
          rating
          isVerified
        }
      }
    }
  ''';

  static const String productCategories = '''
    query ProductCategories {
      productCategories {
        id
        name
        description
        imageUrl
        parentCategory
        isActive
        productCount
      }
    }
  ''';

  static const String createProduct = '''
    mutation CreateProduct(
      \$name: String!,
      \$description: String!,
      \$price: Float!,
      \$discount: Float,
      \$imagesUrl: [String!],
      \$category: Int,
      \$brand: Int,
      \$customBrand: String,
      \$size: Int,
      \$materials: Int,
      \$color: String,
      \$condition: ConditionEnum,
      \$style: StyleEnum,
      \$isFeatured: Boolean
    ) {
      createProduct(
        name: \$name,
        description: \$description,
        price: \$price,
        discount: \$discount,
        imagesUrl: \$imagesUrl,
        category: \$category,
        brand: \$brand,
        customBrand: \$customBrand,
        size: \$size,
        materials: \$materials,
        color: \$color,
        condition: \$condition,
        style: \$style,
        isFeatured: \$isFeatured
      ) {
        success
        message
        product {
          id
          name
          description
          price
          discount
          imagesUrl
          category {
            id
            name
          }
          brand {
            id
            name
          }
          size {
            id
            name
          }
          materials {
            id
            name
          }
          color
          condition
          style
          isFeatured
          createdAt
        }
      }
    }
  ''';

  static const String updateProduct = '''
    mutation UpdateProduct(
      \$productId: ID!,
      \$name: String,
      \$description: String,
      \$price: Float,
      \$discountPrice: Float,
      \$imagesUrl: [String!],
      \$category: String,
      \$subcategory: String,
      \$stockQuantity: Int,
      \$tags: [String!],
      \$specifications: JSONString,
      \$dimensions: JSONString,
      \$weight: Float,
      \$materials: [String!],
      \$careInstructions: String,
      \$isActive: Boolean
    ) {
      updateProduct(
        productId: \$productId,
        name: \$name,
        description: \$description,
        price: \$price,
        discountPrice: \$discountPrice,
        imagesUrl: \$imagesUrl,
        category: \$category,
        subcategory: \$subcategory,
        stockQuantity: \$stockQuantity,
        tags: \$tags,
        specifications: \$specifications,
        dimensions: \$dimensions,
        weight: \$weight,
        materials: \$materials,
        careInstructions: \$careInstructions,
        isActive: \$isActive
      ) {
        product {
          id
          name
          description
          price
          discountPrice
          imagesUrl
          category
          subcategory
          stockQuantity
          tags
          isActive
          updatedAt
        }
        success
        message
      }
    }
  ''';

  static const String deleteProduct = '''
    mutation DeleteProduct(\$productId: ID!) {
      deleteProduct(productId: \$productId) {
        success
        message
      }
    }
  ''';

  // Vendor Management Queries
  static const String allVendors = '''
    query AllVendors(\$first: Int, \$after: String, \$search: String, \$category: String, \$isVerified: Boolean) {
      allVendors(
        first: \$first,
        after: \$after,
        search: \$search,
        category: \$category,
        isVerified: \$isVerified
      ) {
        edges {
          node {
            id
            businessName
            description
            email
            phone
            address
            rating
            reviewCount
            isVerified
            categories
            createdAt
            logo
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  static const String vendorById = '''
    query VendorById(\$id: ID!) {
      vendorById(id: \$id) {
        id
        businessName
        description
        email
        phone
        address
        rating
        reviewCount
        isVerified
        categories
        createdAt
        logo
        products {
          id
          name
          price
          imagesUrl
          rating
          reviewCount
        }
      }
    }
  ''';

  // Search and Filter Queries
  static const String searchProducts = '''
    query SearchProducts(
      \$query: String!,
      \$category: String,
      \$minPrice: Float,
      \$maxPrice: Float,
      \$sortBy: String,
      \$first: Int,
      \$after: String
    ) {
      searchProducts(
        query: \$query,
        category: \$category,
        minPrice: \$minPrice,
        maxPrice: \$maxPrice,
        sortBy: \$sortBy,
        first: \$first,
        after: \$after
      ) {
        edges {
          node {
            id
            name
            description
            price
            discountPrice
            imagesUrl
            category
            subcategory
            stockQuantity
            rating
            reviewCount
            tags
            vendor {
              id
              businessName
              rating
              isVerified
            }
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
        totalCount
      }
    }
  ''';

  // Vendor Analytics Queries
  static const String vendorAnalytics = '''
    query VendorAnalytics(\$timeRange: String, \$vendorId: ID) {
      vendorAnalytics(timeRange: \$timeRange, vendorId: \$vendorId) {
        totalRevenue
        totalOrders
        totalProducts
        averageOrderValue
        conversionRate
        topProducts {
          id
          name
          sales
          revenue
        }
        recentOrders {
          id
          orderNumber
          totalAmount
          status
          createdAt
        }
        salesChart {
          date
          revenue
          orders
        }
        customerMetrics {
          totalCustomers
          newCustomers
          returningCustomers
          customerRetentionRate
        }
      }
    }
  ''';

  static const String vendorOrders = '''
    query VendorOrders(\$status: String, \$first: Int, \$after: String) {
      vendorOrders(status: \$status, first: \$first, after: \$after) {
        edges {
          node {
            id
            orderNumber
            customer {
              id
              firstName
              lastName
              email
            }
            totalAmount
            status
            paymentStatus
            createdAt
            items {
              id
              productName
              quantity
              unitPrice
              totalPrice
            }
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  static const String vendorProducts = '''
    query VendorProducts(\$first: Int, \$after: String, \$status: String) {
      vendorProducts(first: \$first, after: \$after, status: \$status) {
        edges {
          node {
            id
            name
            price
            stockQuantity
            sales
            views
            rating
            reviewCount
            isActive
            createdAt
            updatedAt
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  // Notification Queries
  static const String myNotifications = '''
    query MyNotifications(\$first: Int, \$after: String, \$type: String) {
      myNotifications(first: \$first, after: \$after, type: \$type) {
        edges {
          node {
            id
            title
            message
            type
            isRead
            data
            createdAt
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  static const String markNotificationRead = '''
    mutation MarkNotificationRead(\$notificationId: ID!) {
      markNotificationRead(notificationId: \$notificationId) {
        success
        message
      }
    }
  ''';

  static const String markAllNotificationsRead = '''
    mutation MarkAllNotificationsRead {
      markAllNotificationsRead {
        success
        message
      }
    }
  ''';

  // Messaging Queries
  static const String myConversations = '''
    query MyConversations(\$first: Int, \$after: String) {
      myConversations(first: \$first, after: \$after) {
        edges {
          node {
            id
            participants {
              id
              firstName
              lastName
              businessName
              avatar
            }
            lastMessage {
              id
              content
              sender {
                id
                firstName
                lastName
              }
              createdAt
            }
            unreadCount
            updatedAt
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  static const String conversationMessages = '''
    query ConversationMessages(\$conversationId: ID!, \$first: Int, \$after: String) {
      conversationMessages(conversationId: \$conversationId, first: \$first, after: \$after) {
        edges {
          node {
            id
            content
            sender {
              id
              firstName
              lastName
              businessName
              avatar
            }
            createdAt
            isRead
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  static const String sendMessage = '''
    mutation SendMessage(\$conversationId: ID!, \$content: String!) {
      sendMessage(conversationId: \$conversationId, content: \$content) {
        message {
          id
          content
          sender {
            id
            firstName
            lastName
          }
          createdAt
        }
        success
        message
      }
    }
  ''';

  static const String createConversation = '''
    mutation CreateConversation(\$participantId: ID!) {
      createConversation(participantId: \$participantId) {
        conversation {
          id
          participants {
            id
            firstName
            lastName
            businessName
          }
        }
        success
        message
      }
    }
  ''';

  // Analytics Queries
  static const String customerAnalytics = '''
    query CustomerAnalytics(\$timeRange: String, \$vendorId: ID) {
      customerAnalytics(timeRange: \$timeRange, vendorId: \$vendorId) {
        totalCustomers
        newCustomers
        returningCustomers
        customerRetentionRate
        averageOrderValue
        topCustomers {
          id
          name
          totalSpent
          orderCount
          lastOrder
          loyaltyTier
        }
        customerGrowth {
          date
          newCustomers
          totalCustomers
        }
        customerSegments {
          segment
          count
          percentage
          averageValue
        }
      }
    }
  ''';

  static const String salesAnalytics = '''
    query SalesAnalytics(\$timeRange: String, \$vendorId: ID) {
      salesAnalytics(timeRange: \$timeRange, vendorId: \$vendorId) {
        totalRevenue
        totalOrders
        averageOrderValue
        conversionRate
        salesGrowth
        revenueGrowth
        topProducts {
          id
          name
          sales
          revenue
          growth
        }
        salesChart {
          date
          revenue
          orders
          customers
        }
        salesByCategory {
          category
          revenue
          orders
          percentage
        }
        salesByRegion {
          region
          revenue
          orders
          percentage
        }
      }
    }
  ''';

  static const String productAnalytics = '''
    query ProductAnalytics(\$timeRange: String, \$vendorId: ID) {
      productAnalytics(timeRange: \$timeRange, vendorId: \$vendorId) {
        totalProducts
        activeProducts
        outOfStockProducts
        lowStockProducts
        topPerformingProducts {
          id
          name
          views
          sales
          revenue
          conversionRate
        }
        productViews {
          date
          views
          uniqueViews
        }
        inventoryAlerts {
          id
          name
          currentStock
          threshold
          status
        }
      }
    }
  ''';

  // Inventory Management Queries
  static const String inventoryItems = '''
    query InventoryItems(\$first: Int, \$after: String, \$filter: String, \$sortBy: String) {
      inventoryItems(first: \$first, after: \$after, filter: \$filter, sortBy: \$sortBy) {
        edges {
          node {
            id
            name
            category
            price
            stockQuantity
            lowStockThreshold
            imageUrl
            lastUpdated
            isActive
            sales
            views
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
      }
    }
  ''';

  static const String updateInventoryItem = '''
    mutation UpdateInventoryItem(
      \$itemId: ID!,
      \$stockQuantity: Int,
      \$lowStockThreshold: Int,
      \$price: Float,
      \$isActive: Boolean
    ) {
      updateInventoryItem(
        itemId: \$itemId,
        stockQuantity: \$stockQuantity,
        lowStockThreshold: \$lowStockThreshold,
        price: \$price,
        isActive: \$isActive
      ) {
        item {
          id
          name
          stockQuantity
          lowStockThreshold
          price
          isActive
          lastUpdated
        }
        success
        message
      }
    }
  ''';

  // Payment Methods Queries
  static const String addPaymentMethod = '''
    mutation AddPaymentMethod(
      \$paymentType: String!,
      \$cardNumber: String!,
      \$expiryMonth: Int!,
      \$expiryYear: Int!,
      \$cvv: String!,
      \$cardHolderName: String!,
      \$isDefault: Boolean
    ) {
      addPaymentMethod(
        paymentType: \$paymentType,
        cardNumber: \$cardNumber,
        expiryMonth: \$expiryMonth,
        expiryYear: \$expiryYear,
        cvv: \$cvv,
        cardHolderName: \$cardHolderName,
        isDefault: \$isDefault
      ) {
        paymentMethod {
          id
          paymentType
          cardLastFour
          cardBrand
          isDefault
        }
        success
        message
      }
    }
  ''';

  static const String updatePaymentMethod = '''
    mutation UpdatePaymentMethod(
      \$paymentMethodId: ID!,
      \$isDefault: Boolean,
      \$isActive: Boolean
    ) {
      updatePaymentMethod(
        paymentMethodId: \$paymentMethodId,
        isDefault: \$isDefault,
        isActive: \$isActive
      ) {
        paymentMethod {
          id
          isDefault
          isActive
        }
        success
        message
      }
    }
  ''';

  static const String deletePaymentMethod = '''
    mutation DeletePaymentMethod(\$paymentMethodId: ID!) {
      deletePaymentMethod(paymentMethodId: \$paymentMethodId) {
        success
        message
      }
    }
  ''';

  // Order Management - Missing Definitions
  static const String cancelOrder = '''
    mutation CancelOrder(\$orderId: ID!, \$reason: String) {
      cancelOrder(orderId: \$orderId, reason: \$reason) {
        success
        message
        order {
          id
          status
          updatedAt
        }
      }
    }
  ''';

  static const String updateOrderStatus = '''
    mutation UpdateOrderStatus(\$orderId: ID!, \$status: String!, \$notes: String) {
      updateOrderStatus(orderId: \$orderId, status: \$status, notes: \$notes) {
        success
        message
        order {
          id
          status
          updatedAt
        }
      }
    }
  ''';

  static const String trackOrder = '''
    query TrackOrder(\$orderId: ID!) {
      trackOrder(orderId: \$orderId) {
        id
        orderNumber
        status
        statusHistory {
          status
          timestamp
          notes
        }
        trackingNumber
        estimatedDelivery
        currentLocation
        deliveryAddress
        createdAt
        updatedAt
      }
    }
  ''';

  // Cart Management - Missing Definition
  static const String clearCart = '''
    mutation ClearCart {
      clearCart {
        success
        message
        cart {
          id
          totalItems
          totalAmount
        }
      }
    }
  ''';

  // User Profile Mutations - Currently not available in backend
  // These will be implemented when backend supports profile updates
  static const String updateProfile = '''
    mutation UpdateProfile(
      \$firstName: String,
      \$lastName: String,
      \$phoneNumber: String,
      \$dateOfBirth: DateTime,
      \$gender: GenderEnum,
      \$streetAddress: String,
      \$city: String,
      \$postalCode: String
    ) {
      updateUser(
        firstName: \$firstName,
        lastName: \$lastName,
        phoneNumber: \$phoneNumber,
        dob: \$dateOfBirth,
        gender: \$gender,
        streetAddress: \$streetAddress,
        city: \$city,
        postalCode: \$postalCode
      ) {
        user {
          id
          firstName
          lastName
          phoneNumber
          dob
          gender
        }
        success
        message
      }
    }
  ''';

  static const String updateProfileImage = '''
    mutation UpdateProfileImage(\$imageUrl: String!) {
      updateUser(profilePicture: {url: \$imageUrl}) {
        user {
          id
          profilePicture {
            url
          }
        }
        success
        message
      }
    }
  ''';
}

class AuthService {
  static final GraphQLClient _client = GraphQLService.client;

  static Future<Map<String, dynamic>?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String accountType,
    required bool termsAccepted,
  }) async {
    try {
      debugPrint('🔄 Starting registration for: $email');
      
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.register),
          variables: {
            'firstName': firstName,
            'lastName': lastName,
            'password1': password,
            'password2': confirmPassword,
            'email': email,
            'accountType': accountType.toUpperCase(),
            'termsAccepted': termsAccepted,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Parse GraphQL errors
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          
          // Check for duplicate email errors
          if (errorMessage.toLowerCase().contains('email') && 
              (errorMessage.toLowerCase().contains('exist') ||
               errorMessage.toLowerCase().contains('already') ||
               errorMessage.toLowerCase().contains('taken') ||
               errorMessage.toLowerCase().contains('duplicate'))) {
            throw createError(ErrorCode.authEmailAlreadyExists, details: 'Email: $email');
          } else if (errorMessage.toLowerCase().contains('password')) {
            throw createError(ErrorCode.authWeakPassword, details: errorMessage);
          } else {
            throw createError(ErrorCode.graphqlMutationError, details: errorMessage);
          }
        }
        
        // Network errors
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Registration endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final registerData = result.data?['register'];
      
      if (registerData?['success'] != true) {
        final errors = registerData?['errors'] as List?;
        final errorDetails = errors?.join(', ') ?? 'Registration failed';
        throw createError(ErrorCode.authInvalidCredentials, details: errorDetails);
      }

      debugPrint('✅ Registration successful for: $email');
      return registerData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Registration exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔄 Starting login for: $email');
      
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.login),
          variables: {
            'email': email,
            'password': password,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Parse GraphQL errors
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          
          // For login, we want to show the same message for both user not found and wrong password
          // This prevents user enumeration attacks
          if (errorMessage.toLowerCase().contains('invalid') || 
              errorMessage.toLowerCase().contains('incorrect') ||
              errorMessage.toLowerCase().contains('not found') ||
              errorMessage.toLowerCase().contains('wrong') ||
              errorMessage.toLowerCase().contains('bad') ||
              errorMessage.toLowerCase().contains('valid credentials')) {
            throw createError(ErrorCode.authInvalidCredentials, 
              details: 'Login failed for: $email');
          } else {
            throw createError(ErrorCode.graphqlMutationError, 
              details: errorMessage);
          }
        }
        
        // Network errors
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Login endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final loginData = result.data?['login'];
      
      if (loginData?['token'] == null) {
        throw createError(ErrorCode.authInvalidCredentials, 
          details: 'No token received for: $email');
      }

      debugPrint('✅ Login successful for: $email');
      return loginData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Login exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> viewMe(String token) async {
    try {
      debugPrint('🔄 Fetching user profile with token: ${token.substring(0, 10)}...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.viewMe),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Parse GraphQL errors
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          
          if (errorMessage.toLowerCase().contains('unauthorized') || 
              errorMessage.toLowerCase().contains('token')) {
            throw createError(ErrorCode.authTokenInvalid, 
              details: 'Token validation failed');
          } else {
            throw createError(ErrorCode.graphqlQueryError, 
              details: errorMessage);
          }
        }
        
        // Network errors
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'ViewMe endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final userData = result.data?['viewMe'];
      
      if (userData == null) {
        throw createError(ErrorCode.authUserNotFound, 
          details: 'User profile not found');
      }

      debugPrint('✅ User profile fetched successfully');
      return userData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'ViewMe exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> updateProfile({
    required String token,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? bio,
    String? streetAddress,
    String? city,
    String? postalCode,
  }) async {
    try {
      debugPrint('🔄 Updating user profile...');
      
      final authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      // Convert gender string to enum value
      String? genderEnum;
      if (gender != null) {
        switch (gender.toLowerCase()) {
          case 'male':
            genderEnum = 'MALE';
            break;
          case 'female':
            genderEnum = 'FEMALE';
            break;
          case 'other':
            genderEnum = 'OTHER';
            break;
          case 'prefer not to say':
            genderEnum = 'PREFER_NOT_TO_SAY';
            break;
          default:
            genderEnum = 'OTHER';
        }
      }
      
      // Convert date string to DateTime format (ISO 8601)
      String? dateTimeString;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        try {
          // Parse the date string (assuming format like "17/1/1990")
          final parts = dateOfBirth.split('/');
          if (parts.length == 3) {
            final day = parts[0].padLeft(2, '0');
            final month = parts[1].padLeft(2, '0');
            final year = parts[2];
            dateTimeString = '$year-$month-${day}T00:00:00Z';
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing date: $e');
        }
      }
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateProfile),
          variables: {
            if (firstName != null) 'firstName': firstName,
            if (lastName != null) 'lastName': lastName,
            if (phoneNumber != null) 'phoneNumber': phoneNumber,
            if (dateTimeString != null) 'dateOfBirth': dateTimeString,
            if (genderEnum != null) 'gender': genderEnum,
            if (streetAddress != null) 'streetAddress': streetAddress,
            if (city != null) 'city': city,
            if (postalCode != null) 'postalCode': postalCode,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          throw createError(ErrorCode.graphqlMutationError, details: errorMessage);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Update profile endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updateUser'];
      if (updateData?['success'] == true) {
        debugPrint('✅ Profile updated successfully');
        return updateData;
      }
      
      throw createError(ErrorCode.graphqlMutationError, 
        details: updateData?['message'] ?? 'Failed to update profile');
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update profile exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> updateProfileImage({
    required String token,
    required String imageUrl,
  }) async {
    try {
      debugPrint('🔄 Updating profile image...');
      
      final authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateProfileImage),
          variables: {
            'imageUrl': imageUrl,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          throw createError(ErrorCode.graphqlMutationError, details: errorMessage);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Update profile image endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updateUser'];
      if (updateData?['success'] == true) {
        debugPrint('✅ Profile image updated successfully');
        return updateData;
      }
      
      throw createError(ErrorCode.graphqlMutationError, 
        details: updateData?['message'] ?? 'Failed to update profile image');
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update profile image exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> logout(String refreshToken) async {
    try {
      debugPrint('🔄 Starting logout with refreshToken...');
      
      // Get current access token for authentication
      final accessToken = await TokenService.getToken();
      final authenticatedClient = accessToken != null 
          ? GraphQLService.getAuthenticatedClient(accessToken)
          : _client;
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.logout),
          variables: {
            'refreshToken': refreshToken,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          throw createError(ErrorCode.graphqlMutationError, details: errorMessage);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Logout endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final logoutData = result.data?['logout'];
      debugPrint('✅ Logout successful: ${logoutData?['message'] ?? 'Session invalidated'}');
      return logoutData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Logout exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> resetPassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔄 Starting password reset...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.resetPassword),
          variables: {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          
          if (errorMessage.contains('current password') || errorMessage.contains('incorrect')) {
            throw createError(ErrorCode.authInvalidCredentials, details: 'Current password is incorrect');
          }
          
          throw createError(ErrorCode.graphqlMutationError, details: errorMessage);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Reset password endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final resetData = result.data?['resetPassword'];
      final success = resetData?['success'] ?? false;
      
      if (success) {
        debugPrint('✅ Password reset successful');
        return true;
      } else {
        final message = resetData?['message'] ?? 'Password reset failed';
        throw createError(ErrorCode.graphqlMutationError, details: message);
      }
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Reset password exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  // Two-Factor Authentication Methods
  static Future<bool> is2FAEnabled({required String token}) async {
    try {
      debugPrint('🔄 Checking 2FA status...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.is2FAEnabled),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: '2FA status endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final data = result.data?['is2FAEnabled'];
      final enabled = data?['enabled'] ?? false;
      
      debugPrint('✅ 2FA status checked: $enabled');
      return enabled;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: '2FA status check exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>> enable2FA({required String token}) async {
    try {
      debugPrint('🔄 Enabling 2FA...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.enable2FA),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlMutationError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Enable 2FA endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final data = result.data?['enable2FA'];
      final success = data?['success'] ?? false;
      
      if (success) {
        debugPrint('✅ 2FA enabled successfully');
        return {
          'success': true,
          'qrCodeUrl': data?['qrCodeUrl'],
          'backupCode': data?['backupCode'],
          'backupCodes': data?['backupCodes'],
        };
      } else {
        throw createError(ErrorCode.graphqlMutationError, details: 'Failed to enable 2FA');
      }
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Enable 2FA exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> disable2FA({required String token, required String password}) async {
    try {
      debugPrint('🔄 Disabling 2FA...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.disable2FA),
          variables: {
            'password': password,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlMutationError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Disable 2FA endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final data = result.data?['disable2FA'];
      final success = data?['success'] ?? false;
      
      if (success) {
        debugPrint('✅ 2FA disabled successfully');
        return true;
      } else {
        final message = data?['message'] ?? 'Failed to disable 2FA';
        throw createError(ErrorCode.graphqlMutationError, details: message);
      }
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Disable 2FA exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  // Active Sessions Methods
  static Future<Map<String, dynamic>> getActiveSessions({required String token}) async {
    try {
      debugPrint('🔄 Fetching active sessions...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.getActiveSessions),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Active sessions endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final data = result.data?['getActiveSessions'];
      
      debugPrint('✅ Active sessions fetched successfully');
      return {
        'sessions': data?['sessions'] ?? [],
        'currentSessionId': data?['currentSessionId'],
      };
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get active sessions exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> terminateSession({required String token, required String sessionId}) async {
    try {
      debugPrint('🔄 Terminating session: $sessionId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.terminateSession),
          variables: {
            'sessionId': sessionId,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlMutationError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Terminate session endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final data = result.data?['terminateSession'];
      final success = data?['success'] ?? false;
      
      if (success) {
        debugPrint('✅ Session terminated successfully');
        return true;
      } else {
        final message = data?['message'] ?? 'Failed to terminate session';
        throw createError(ErrorCode.graphqlMutationError, details: message);
      }
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Terminate session exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> terminateAllOtherSessions({required String token}) async {
    try {
      debugPrint('🔄 Terminating all other sessions...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.terminateAllOtherSessions),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlMutationError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Terminate all sessions endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final data = result.data?['terminateAllOtherSessions'];
      final success = data?['success'] ?? false;
      
      if (success) {
        debugPrint('✅ All other sessions terminated successfully');
        return true;
      } else {
        final message = data?['message'] ?? 'Failed to terminate all other sessions';
        throw createError(ErrorCode.graphqlMutationError, details: message);
      }
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Terminate all other sessions exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
