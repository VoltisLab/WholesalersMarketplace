# Wholesalers Marketplace

A comprehensive B2B wholesalers marketplace built with Flutter, designed for connecting wholesale suppliers with retailers and businesses.

## 🚀 Features

### Authentication & Onboarding
- **User Authentication** - Sign in/Sign up with email and password
- **Demo Account** - Quick access with pre-filled credentials (`demo@wholesalers.com` / `demo123`)
- **Vendor Onboarding** - Complete 4-step setup process for suppliers:
  1. Welcome & overview
  2. Business information
  3. Location details  
  4. Product categories selection

### Marketplace Features
- **Product Catalog** - Browse products with advanced filtering and search
- **Vendor Profiles** - Detailed supplier information with ratings and reviews
- **Shopping Cart** - Add/remove products with quantity management
- **Featured Collections** - Gallery-style showcase of top vendors with product previews
- **Categories** - Organized product browsing by category and subcategory

### User Experience
- **Animated Splash Screen** - Custom Lottie animation with smart navigation
- **Responsive Design** - Optimized for various screen sizes
- **Modern UI** - Clean, professional interface with Material Design 3
- **Dark Theme Support** - Consistent theming throughout the app

## 🛠 Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **UI Components**: Material Design 3
- **Animations**: Lottie
- **Image Caching**: CachedNetworkImage
- **Navigation**: Named routes with custom transitions

## 📱 Screenshots

*Screenshots will be added soon*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/VoltisLab/WholesalersMarketplace.git
cd WholesalersMarketplace
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building APK
```bash
flutter build apk --release
```

## 🏗 Project Structure

```
lib/
├── constants/          # App constants (colors, themes, etc.)
├── models/            # Data models
├── providers/         # State management (Provider)
├── screens/           # UI screens
│   ├── auth/         # Authentication screens
│   └── ...
├── widgets/          # Reusable UI components
└── utils/            # Utility functions
```

## 🎯 Key Features Implemented

### Authentication System
- Complete sign-in/sign-up flow
- Demo account for quick testing
- Secure user session management

### Vendor Management
- Multi-step onboarding process
- Business profile creation
- Category selection and management

### Product Showcase
- Gallery-style featured vendors
- Product grid with image previews
- Interactive vendor cards

### Enhanced UX
- Custom splash screen with Lottie animation
- Smooth page transitions
- Loading states and error handling

## 🔧 Configuration

### Demo Account
- Email: `demo@wholesalers.com`
- Password: `demo123`

### Customization
- Update `lib/constants/app_colors.dart` for color scheme
- Modify `lib/constants/app_constants.dart` for spacing and sizing
- Replace assets in `assets/` folder for branding

## 📄 License

This project is proprietary software developed by VoltisLab.

## 🤝 Contributing

This is a private project. For contributions, please contact the VoltisLab team.

## 📞 Support

For support and inquiries, please contact VoltisLab.

---

**Developed with ❤️ by VoltisLab**