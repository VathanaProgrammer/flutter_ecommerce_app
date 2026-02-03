# Flutter E-Commerce App

A modern, feature-rich Flutter e-commerce application integrated with Laravel 11 backend API.

## 🚀 New Features Added

### Advanced Shopping Features
- ✅ **Advanced Search** - Multi-criteria product search with filters and sorting
- ✅ **Coupon System** - Apply discount coupons at checkout
- ✅ **Address Management** - Manage multiple shipping addresses
- ✅ **Notifications** - Real-time user notifications
- ✅ **Product Reviews** - Rate and review products with images
- ✅ **Product Comparison** - Compare up to 4 products side-by-side
- ✅ **Enhanced Cart** - Improved cart management with session support

### Existing Features
- User Authentication (Login/Signup)
- Product Browsing (Featured, Recommended, Categories)
- Shopping Cart
- Favorites/Wishlist
- Order Management
- User Profile Management
- Multiple Payment Methods (ABA, ACLEDA, Cash)
- Google Maps Integration
- Location-based Services

## 📦 New Dependencies

No additional dependencies required! All new features work with existing packages:
- `http` - API communication
- `provider` - State management
- `shared_preferences` - Local storage
- `flutter_map` & `latlong2` - Maps
- `geolocator` & `geocoding` - Location services

## 🗂️ New Files Structure

```
lib/
├── models/
│   ├── coupon.dart              # NEW
│   ├── address.dart             # NEW
│   ├── notification.dart        # NEW
│   └── review.dart              # NEW
├── services/
│   ├── coupon_service.dart      # NEW
│   ├── address_service.dart     # NEW
│   ├── notification_service.dart # NEW
│   ├── search_service.dart      # NEW
│   └── review_service.dart      # NEW
└── screens/
    ├── search/
    │   └── search_screen.dart   # NEW
    └── notifications/
        └── notification_screen.dart # NEW
```

## 🔧 API Integration

### Base URL
```dart
static const String baseUrl = 'https://learner-teach.online/api';
```

### New API Endpoints

#### Search & Filters
```dart
GET /search                      // Advanced product search
GET /search/suggestions          // Search autocomplete
GET /search/filters              // Available filters
```

#### Coupons
```dart
GET /coupons                     // List active coupons
POST /coupons/validate           // Validate coupon code
```

#### Addresses
```dart
GET /addresses                   // List user addresses
POST /addresses                  // Create address
PUT /addresses/{id}              // Update address
DELETE /addresses/{id}           // Delete address
POST /addresses/{id}/set-default // Set default address
```

#### Notifications
```dart
GET /notifications               // Get notifications
GET /notifications/unread-count  // Unread count
POST /notifications/{id}/read    // Mark as read
POST /notifications/read-all     // Mark all as read
DELETE /notifications/{id}       // Delete notification
DELETE /notifications            // Clear all
```

#### Reviews
```dart
GET /products/{id}/reviews       // Product reviews
POST /reviews                    // Create review
PUT /reviews/{id}                // Update review
DELETE /reviews/{id}             // Delete review
POST /reviews/{id}/vote-helpful  // Vote helpful
```

## 🎨 New Screens

### 1. Search Screen
**Location:** `lib/screens/search/search_screen.dart`

**Features:**
- Real-time search suggestions
- Advanced filters (category, price, rating, stock)
- Multiple sorting options
- Pagination support
- Filter chips and bottom sheet

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SearchScreen()),
);
```

### 2. Notification Screen
**Location:** `lib/screens/notifications/notification_screen.dart`

**Features:**
- Unread count badge
- Mark as read/unread
- Swipe to delete
- Clear all notifications
- Different notification types (order, promotion, system)
- Time ago formatting

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NotificationScreen()),
);
```

## 💡 Usage Examples

### Using Coupon Service
```dart
import 'package:ecommersflutter_new/services/coupon_service.dart';

// Get active coupons
final coupons = await CouponService.getActiveCoupons();

// Validate coupon
final result = await CouponService.validateCoupon(
  code: 'SAVE10',
  subtotal: 100.0,
);

if (result?['error'] == null) {
  final discount = result!['discount_amount'];
  final finalAmount = result['final_amount'];
  print('Discount: \$$discount, Final: \$$finalAmount');
}
```

### Using Address Service
```dart
import 'package:ecommersflutter_new/services/address_service.dart';

// Get addresses
final addresses = await AddressService.getAddresses();

// Create new address
final newAddress = await AddressService.createAddress({
  'recipient_name': 'John Doe',
  'phone': '123456789',
  'address_line1': '123 Main St',
  'city': 'Phnom Penh',
  'postal_code': '12000',
  'country': 'Cambodia',
  'is_default': true,
});

// Set default
await AddressService.setDefaultAddress(addressId);
```

### Using Search Service
```dart
import 'package:ecommersflutter_new/services/search_service.dart';

// Advanced search
final result = await SearchService.searchProducts(
  query: 'phone',
  categoryId: 1,
  minPrice: 100,
  maxPrice: 500,
  minRating: 4,
  inStock: true,
  sortBy: 'price_low',
  page: 1,
);

final products = result['products'] as List<Product>;
final totalPages = result['last_page'] as int;
```

### Using Notification Service
```dart
import 'package:ecommersflutter_new/services/notification_service.dart';

// Get notifications
final notifications = await NotificationService.getNotifications();

// Get unread count
final count = await NotificationService.getUnreadCount();

// Mark as read
await NotificationService.markAsRead(notificationId);

// Mark all as read
await NotificationService.markAllAsRead();
```

### Using Review Service
```dart
import 'package:ecommersflutter_new/services/review_service.dart';

// Get product reviews
final reviews = await ReviewService.getProductReviews(productId);

// Create review
final review = await ReviewService.createReview(
  productId: 1,
  rating: 5,
  title: 'Great product!',
  comment: 'Highly recommended',
  images: ['image1.jpg', 'image2.jpg'],
);

// Vote helpful
await ReviewService.voteHelpful(reviewId, true);
```

## 🔐 Authentication

All authenticated endpoints require the user token:

```dart
final user = await Api.getCurrentUser();
if (user != null && user.token != null) {
  // Make authenticated request
  headers: {
    'Authorization': 'Bearer ${user.token}',
  }
}
```

## 🎯 Integration Steps

1. **Update your existing screens** to use the new services
2. **Add navigation** to SearchScreen and NotificationScreen
3. **Integrate coupons** in your checkout flow
4. **Add address selection** in checkout
5. **Show notification badge** in app bar
6. **Add review section** in product details

### Example: Add Search Icon to Home
```dart
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
    ),
    // Notification icon with badge
    Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),
  ],
)
```

## 🚀 Running the App

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build for production
flutter build apk --release
flutter build ios --release
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔄 State Management

The app uses **Provider** for state management. New providers can be added for:
- Notification state
- Address management
- Search filters
- Review management

## 🎨 UI/UX Highlights

- **Material Design 3** components
- **Responsive layouts** for all screen sizes
- **Smooth animations** and transitions
- **Pull-to-refresh** on list screens
- **Swipe gestures** for actions
- **Bottom sheets** for filters
- **Snackbars** for feedback
- **Loading indicators** for async operations

## 📝 Notes

- All new services handle errors gracefully
- Network errors are caught and logged
- User authentication is checked before API calls
- Session management for guest users
- Proper null safety throughout

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Developer

Built with ❤️ using Flutter & Laravel
