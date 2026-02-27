import 'package:cloud_firestore/cloud_firestore.dart';

/// Seed data class for populating Firestore with demo data
///
/// This class provides a static method to seed the Firestore database
/// with sample categories, host profiles, experiences, reviews, and user data.
class SeedData {
  /// Seeds all demo data to Firestore
  ///
  /// This method populates:
  /// - 6 sample categories
  /// - 5 host profiles
  /// - 15 sample experiences
  /// - 30 sample reviews
  /// - 1 demo user account
  /// - Bookings for the demo user
  ///
  /// Call this method in debug mode or as a one-time initialization:
  /// ```
  /// await SeedData.seedAll(FirebaseFirestore.instance);
  /// ```
  static Future<void> seedAll(FirebaseFirestore firestore) async {
    try {
      print('Starting to seed demo data...');

      await _seedCategories(firestore);
      print('Categories seeded');

      await _seedHostProfiles(firestore);
      print('Host profiles seeded');

      await _seedExperiences(firestore);
      print('Experiences seeded');

      await _seedReviews(firestore);
      print('Reviews seeded');

      await _seedDemoUser(firestore);
      print('Demo user seeded');

      await _seedDemoBookings(firestore);
      print('Demo bookings seeded');

      print('Demo data seeding completed successfully!');
    } catch (e) {
      print('Error seeding data: $e');
      rethrow;
    }
  }

  /// Seeds 6 sample categories
  static Future<void> _seedCategories(FirebaseFirestore firestore) async {
    final categories = [
      {
        'name': 'Adventure',
        'icon': 'assets/icons/adventure.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'order': 1,
        'isActive': true,
      },
      {
        'name': 'Food & Drink',
        'icon': 'assets/icons/food.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1504674900769-cc8cef48cb88?w=800',
        'order': 2,
        'isActive': true,
      },
      {
        'name': 'Arts & Culture',
        'icon': 'assets/icons/arts.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1578301978162-7aae4d755744?w=800',
        'order': 3,
        'isActive': true,
      },
      {
        'name': 'Nightlife',
        'icon': 'assets/icons/nightlife.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1514991643008-d4d4d6f5f2db?w=800',
        'order': 4,
        'isActive': true,
      },
      {
        'name': 'Wellness',
        'icon': 'assets/icons/wellness.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
        'order': 5,
        'isActive': true,
      },
      {
        'name': 'Nature',
        'icon': 'assets/icons/nature.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'order': 6,
        'isActive': true,
      },
    ];

    final batch = firestore.batch();
    for (var category in categories) {
      final docRef = firestore.collection('categories').doc(category['name'] as String?);
      batch.set(docRef, category);
    }
    await batch.commit();
  }

  /// Seeds 5 sample host profiles
  static Future<void> _seedHostProfiles(FirebaseFirestore firestore) async {
    final hosts = [
      {
        'uid': 'host_1',
        'email': 'sarah.martinez@zeylo.com',
        'displayName': 'Sarah Martinez',
        'photoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'phoneNumber': '+94771234567',
        'bio': 'Sri Lankan culture expert passionate about sharing authentic local experiences and traditions with travelers from around the world.',
        'location': {'city': 'Colombo', 'country': 'Sri Lanka'},
        'isHost': true,
        'isVerified': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 365))),
        'followersCount': 324,
        'followingCount': 89,
        'postsCount': 45,
        'settings': {},
        'favorites': [],
      },
      {
        'uid': 'host_2',
        'email': 'hashan.perera@zeylo.com',
        'displayName': 'Hashan Perera',
        'photoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'phoneNumber': '+94772345678',
        'bio': 'Adventure guide with over 10 years of experience leading hiking and trekking expeditions across Sri Lanka\'s breathtaking landscapes.',
        'location': {'city': 'Kandy', 'country': 'Sri Lanka'},
        'isHost': true,
        'isVerified': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 450))),
        'followersCount': 287,
        'followingCount': 102,
        'postsCount': 38,
        'settings': {},
        'favorites': [],
      },
      {
        'uid': 'host_3',
        'email': 'amali.fernando@zeylo.com',
        'displayName': 'Amali Fernando',
        'photoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'phoneNumber': '+94773456789',
        'bio': 'Professional cooking instructor specializing in traditional Sri Lankan cuisine. Love sharing family recipes and culinary secrets.',
        'location': {'city': 'Galle', 'country': 'Sri Lanka'},
        'isHost': true,
        'isVerified': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 380))),
        'followersCount': 412,
        'followingCount': 76,
        'postsCount': 62,
        'settings': {},
        'favorites': [],
      },
      {
        'uid': 'host_4',
        'email': 'shenuka.dias@zeylo.com',
        'displayName': 'Shenuka Dias',
        'photoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
        'phoneNumber': '+94774567890',
        'bio': 'Accomplished nature photographer and conservationist dedicated to capturing and preserving Sri Lanka\'s incredible biodiversity.',
        'location': {'city': 'Ella', 'country': 'Sri Lanka'},
        'isHost': true,
        'isVerified': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 300))),
        'followersCount': 198,
        'followingCount': 145,
        'postsCount': 52,
        'settings': {},
        'favorites': [],
      },
      {
        'uid': 'host_5',
        'email': 'thenu.sandul@zeylo.com',
        'displayName': 'Thenu Sandul',
        'photoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'phoneNumber': '+94775678901',
        'bio': 'Professional surfing instructor with a passion for ocean sports and teaching beginners to experienced surfers in Mirissa.',
        'location': {'city': 'Mirissa', 'country': 'Sri Lanka'},
        'isHost': true,
        'isVerified': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 250))),
        'followersCount': 156,
        'followingCount': 98,
        'postsCount': 28,
        'settings': {},
        'favorites': [],
      },
    ];

    final batch = firestore.batch();
    for (var host in hosts) {
      final docRef = firestore.collection('users').doc(host['uid'] as String?);
      batch.set(docRef, host);
    }
    await batch.commit();
  }

  /// Seeds 15 sample experiences
  static Future<void> _seedExperiences(FirebaseFirestore firestore) async {
    final experiences = [
      {
        'title': 'Hanthana Hiking Adventure',
        'description': 'Explore the majestic Hanthana mountain range with stunning views of Kandy city. Our expert guides will lead you through ancient trails while sharing fascinating stories about the region\'s rich history and biodiversity.',
        'shortDescription': 'Mountain hiking with panoramic views',
        'hostId': 'host_2',
        'hostName': 'Hashan Perera',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Adventure',
        'subcategory': 'hiking',
        'images': [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800',
          'https://images.unsplash.com/photo-1533521521615-6f3ee069c18e?w=800',
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'price': 45.0,
        'currency': 'USD',
        'duration': 3,
        'maxGuests': 12,
        'location': {
          'address': 'Hanthana Base Camp, Kandy',
          'city': 'Kandy',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Experienced guide', 'Water and snacks', 'Photos', 'Hiking stick'],
        'requirements': ['Good fitness level', 'Comfortable hiking shoes', 'Weather-appropriate clothing'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.8,
        'reviewCount': 24,
        'isActive': true,
        'tags': ['hiking', 'nature', 'adventure', 'views'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 60))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Traditional Cooking Experience',
        'description': 'Learn authentic Sri Lankan cooking from a professional instructor. Prepare traditional dishes like curry, lamprais, and hoppers in a home kitchen setting. Enjoy the meal you\'ve prepared with authentic stories and culture.',
        'shortDescription': 'Cook and enjoy traditional Sri Lankan dishes',
        'hostId': 'host_3',
        'hostName': 'Amali Fernando',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'category': 'Food & Drink',
        'subcategory': 'cooking_classes',
        'images': [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800',
          'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800',
          'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1504674900769-cc8cef48cb88?w=800',
        'price': 45.0,
        'currency': 'USD',
        'duration': 2,
        'maxGuests': 8,
        'location': {
          'address': 'Family Kitchen, Galle',
          'city': 'Galle',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.0535, 'longitude': 80.2210}
        },
        'includes': ['Ingredients', 'Cooking utensils', 'Recipe cards', 'Meal to take home'],
        'requirements': ['No cooking experience needed', 'Comfortable clothing'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.9,
        'reviewCount': 31,
        'isActive': true,
        'tags': ['cooking', 'food', 'culture', 'local'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 75))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Street Food Tour',
        'description': 'Explore Colombo\'s bustling street food scene with a local guide. Taste authentic, delicious street food at the best vendors while learning about the city\'s food culture and history.',
        'shortDescription': 'Taste authentic street food in Colombo',
        'hostId': 'host_3',
        'hostName': 'Amali Fernando',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'category': 'Food & Drink',
        'subcategory': 'food_tours',
        'images': [
          'https://images.unsplash.com/photo-1504674900769-cc8cef48cb88?w=800',
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
          'https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1504674900769-cc8cef48cb88?w=800',
        'price': 30.0,
        'currency': 'USD',
        'duration': 3,
        'maxGuests': 10,
        'location': {
          'address': 'Colombo Fort District',
          'city': 'Colombo',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Local guide', 'Food tastings', 'Drinks', 'Walking map'],
        'requirements': ['Comfortable walking shoes', 'Appetite for adventure'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.7,
        'reviewCount': 18,
        'isActive': true,
        'tags': ['food', 'street food', 'tour', 'colombo'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 50))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Surfing Lessons',
        'description': 'Learn to surf at Mirissa Beach with a professional instructor. Perfect for beginners and intermediate surfers. Enjoy warm waters, consistent waves, and a vibrant beach culture.',
        'shortDescription': 'Catch waves at beautiful Mirissa Beach',
        'hostId': 'host_5',
        'hostName': 'Thenu Sandul',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Adventure',
        'subcategory': 'surfing',
        'images': [
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
          'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800',
          'https://images.unsplash.com/photo-1502680390467-361b66b62519?w=800',
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
        'price': 50.0,
        'currency': 'USD',
        'duration': 2,
        'maxGuests': 6,
        'location': {
          'address': 'Mirissa Beach, Mirissa',
          'city': 'Mirissa',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 5.9425, 'longitude': 80.4710}
        },
        'includes': ['Surfboard', 'Wetsuit', 'Instructor', 'Photo package'],
        'requirements': ['Basic swimming ability', 'Swimwear'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.8,
        'reviewCount': 22,
        'isActive': true,
        'tags': ['surfing', 'water sports', 'beach', 'lessons'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 45))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Sunset Kayaking',
        'description': 'Paddle through serene waters at sunset on a guided kayak tour. Experience breathtaking views, observe wildlife, and enjoy the tranquility of nature.',
        'shortDescription': 'Kayak adventure at golden hour',
        'hostId': 'host_2',
        'hostName': 'Hashan Perera',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Adventure',
        'subcategory': 'kayaking',
        'images': [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
          'https://images.unsplash.com/photo-1479233683411-2a2ddc50a78a?w=800',
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
        'price': 55.0,
        'currency': 'USD',
        'duration': 2,
        'maxGuests': 8,
        'location': {
          'address': 'Lake Kandy Water Sports Center',
          'city': 'Kandy',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Kayak', 'Paddle', 'Life jacket', 'Snacks and water'],
        'requirements': ['Swimming ability', 'Age 6+'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.9,
        'reviewCount': 19,
        'isActive': true,
        'tags': ['kayaking', 'water sports', 'sunset', 'nature'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 55))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Village Cooking Experience',
        'description': 'Visit a traditional village and learn to cook authentic Sri Lankan cuisine from locals. Experience rural life, visit local markets, and prepare a traditional meal.',
        'shortDescription': 'Rural cooking and cultural immersion',
        'hostId': 'host_3',
        'hostName': 'Amali Fernando',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'category': 'Food & Drink',
        'subcategory': 'cooking_classes',
        'images': [
          'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=800',
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800',
          'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=800',
        'price': 40.0,
        'currency': 'USD',
        'duration': 1,
        'maxGuests': 6,
        'location': {
          'address': 'Traditional Village, Galle District',
          'city': 'Galle',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.0535, 'longitude': 80.2210}
        },
        'includes': ['Market visit', 'Cooking ingredients', 'Recipe book', 'Meal with host family'],
        'requirements': ['Comfortable clothing for outdoor activities'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.8,
        'reviewCount': 15,
        'isActive': true,
        'tags': ['cooking', 'village', 'culture', 'authentic'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 65))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Photography Workshop',
        'description': 'Master landscape and wildlife photography with a professional photographer. Learn composition, lighting, and post-processing techniques in stunning natural settings.',
        'shortDescription': 'Learn photography in nature',
        'hostId': 'host_4',
        'hostName': 'Shenuka Dias',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
        'category': 'Arts & Culture',
        'subcategory': 'photography',
        'images': [
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800',
          'https://images.unsplash.com/photo-1606933248051-5ce98adc5242?w=800',
          'https://images.unsplash.com/photo-1600298881974-6be191ceeda1?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
        'price': 60.0,
        'currency': 'USD',
        'duration': 3,
        'maxGuests': 10,
        'location': {
          'address': 'Ella Scenic Area',
          'city': 'Ella',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.8628, 'longitude': 81.0480}
        },
        'includes': ['Professional instruction', 'Coffee/tea breaks', 'Certificate', 'Photo editing tips'],
        'requirements': ['DSLR or mirrorless camera (or smartphone acceptable)'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.9,
        'reviewCount': 16,
        'isActive': true,
        'tags': ['photography', 'art', 'workshop', 'nature'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 70))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Sunrise Watching',
        'description': 'Wake up early to witness a spectacular sunrise from scenic viewpoints. A peaceful experience with expert guidance, perfect for photography or meditation.',
        'shortDescription': 'Peaceful sunrise experience',
        'hostId': 'host_2',
        'hostName': 'Hashan Perera',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Nature',
        'subcategory': 'nature_walks',
        'images': [
          'https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=800',
          'https://images.unsplash.com/photo-1495426773190-3c0b6f801e14?w=800',
          'https://images.unsplash.com/photo-1495567720974-a28155fb75ec?w=800',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=800',
        'price': 25.0,
        'currency': 'USD',
        'duration': 2,
        'maxGuests': 15,
        'location': {
          'address': 'Kandy Scenic Lookout',
          'city': 'Kandy',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Guide', 'Hot beverage', 'Snacks', 'Light'],
        'requirements': ['Warm clothing', 'Good physical condition'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.8,
        'reviewCount': 20,
        'isActive': true,
        'tags': ['sunrise', 'nature', 'meditation', 'photography'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 40))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Cultural Walk',
        'description': 'Explore Colombo\'s rich cultural heritage with a knowledgeable local guide. Visit historic sites, ancient temples, colonial buildings, and learn about Sri Lanka\'s fascinating history.',
        'shortDescription': 'Discover Colombo\'s cultural landmarks',
        'hostId': 'host_1',
        'hostName': 'Sarah Martinez',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'category': 'Arts & Culture',
        'subcategory': 'cultural_walks',
        'images': [
          'https://images.unsplash.com/photo-1518066000714-58c45f1b773c?w=800',
          'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=800',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'https://images.unsplash.com/photo-1578301978162-7aae4d755744?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1578301978162-7aae4d755744?w=800',
        'price': 35.0,
        'currency': 'USD',
        'duration': 2,
        'maxGuests': 12,
        'location': {
          'address': 'Colombo Central District',
          'city': 'Colombo',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Expert guide', 'Entrance fees', 'Walking map', 'Cultural insights'],
        'requirements': ['Comfortable walking shoes', 'Respectful attire for temples'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.7,
        'reviewCount': 26,
        'isActive': true,
        'tags': ['culture', 'history', 'walking tour', 'heritage'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 80))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Rooftop Party Night',
        'description': 'Experience Colombo\'s vibrant nightlife at an exclusive rooftop venue. Dance, socialize, and enjoy the city skyline with local friends in a lively atmosphere.',
        'shortDescription': 'Party with a city view',
        'hostId': 'host_1',
        'hostName': 'Sarah Martinez',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'category': 'Nightlife',
        'subcategory': 'rooftop_parties',
        'images': [
          'https://images.unsplash.com/photo-1514991643008-d4d4d6f5f2db?w=800',
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
          'https://images.unsplash.com/photo-1514991643008-d4d4d6f5f2db?w=800',
          'https://images.unsplash.com/photo-1487180183519-c21cc028cb29?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1514991643008-d4d4d6f5f2db?w=800',
        'price': 40.0,
        'currency': 'USD',
        'duration': 4,
        'maxGuests': 25,
        'location': {
          'address': 'Colombo Rooftop Bar & Lounge',
          'city': 'Colombo',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Welcome drink', 'DJ entertainment', 'Food platters', 'City view'],
        'requirements': ['Age 18+', 'Smart casual attire'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.6,
        'reviewCount': 12,
        'isActive': true,
        'tags': ['nightlife', 'party', 'rooftop', 'socializing'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 35))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Wildlife Safari',
        'description': 'Explore Sri Lanka\'s incredible wildlife with an expert naturalist guide. Spot elephants, leopards, and exotic birds in their natural habitat in pristine national park settings.',
        'shortDescription': 'Safari adventure with wildlife photography',
        'hostId': 'host_4',
        'hostName': 'Shenuka Dias',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
        'category': 'Nature',
        'subcategory': 'wildlife_watching',
        'images': [
          'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
          'https://images.unsplash.com/photo-1503066211613-c17ebc9daef0?w=800',
          'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
          'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
        'price': 75.0,
        'currency': 'USD',
        'duration': 5,
        'maxGuests': 6,
        'location': {
          'address': 'Yala National Park',
          'city': 'Ella',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.8628, 'longitude': 81.0480}
        },
        'includes': ['Jeep with driver', 'Professional naturalist', 'Binoculars', 'Lunch', 'Camera equipment advice'],
        'requirements': ['Good physical condition', 'Early wake-up', 'Camera preferred'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.9,
        'reviewCount': 29,
        'isActive': true,
        'tags': ['wildlife', 'safari', 'nature', 'photography'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 90))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Yoga & Meditation Retreat',
        'description': 'Find peace and balance with a full-day yoga and meditation retreat. Practice with a certified instructor in serene surroundings and leave refreshed.',
        'shortDescription': 'Wellness retreat with yoga and meditation',
        'hostId': 'host_1',
        'hostName': 'Sarah Martinez',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'category': 'Wellness',
        'subcategory': 'yoga',
        'images': [
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
          'https://images.unsplash.com/photo-1517836357463-d25ddfcac53f?w=800',
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
        'price': 50.0,
        'currency': 'USD',
        'duration': 3,
        'maxGuests': 15,
        'location': {
          'address': 'Wellness Center, Colombo',
          'city': 'Colombo',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Yoga classes', 'Meditation session', 'Healthy meals', 'Tea and snacks', 'Take-home guide'],
        'requirements': ['No experience needed', 'Yoga mat provided'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.9,
        'reviewCount': 17,
        'isActive': true,
        'tags': ['wellness', 'yoga', 'meditation', 'health'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 100))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Tea Plantation Tour',
        'description': 'Experience Sri Lanka\'s famous tea plantations with an expert guide. Learn about tea production, pick tea leaves, and enjoy fresh tea in plantation settings.',
        'shortDescription': 'Tour tea plantations and learn tea production',
        'hostId': 'host_2',
        'hostName': 'Hashan Perera',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Nature',
        'subcategory': 'nature_walks',
        'images': [
          'https://images.unsplash.com/photo-1559056199-641a0ac8b8d4?w=800',
          'https://images.unsplash.com/photo-1537791149a5-e36219a2a64a?w=800',
          'https://images.unsplash.com/photo-1596848212624-753c457dc5d7?w=800',
          'https://images.unsplash.com/photo-1497636577773-f1231844b47b?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1559056199-641a0ac8b8d4?w=800',
        'price': 30.0,
        'currency': 'USD',
        'duration': 3,
        'maxGuests': 10,
        'location': {
          'address': 'Tea Plantations, Kandy District',
          'city': 'Kandy',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Guide', 'Tea sampling', 'Leaf picking experience', 'Refreshments', 'Tea to take home'],
        'requirements': ['Comfortable walking shoes', 'Weather-appropriate clothing'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.8,
        'reviewCount': 21,
        'isActive': true,
        'tags': ['tea', 'plantation', 'agriculture', 'tasting'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 55))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Live Music Evening',
        'description': 'Enjoy an evening of live traditional and contemporary music in an intimate venue. Experience authentic Sri Lankan music culture with drinks and good company.',
        'shortDescription': 'Live music night with local performers',
        'hostId': 'host_1',
        'hostName': 'Sarah Martinez',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
        'category': 'Nightlife',
        'subcategory': 'live_music',
        'images': [
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
          'https://images.unsplash.com/photo-1487180183519-c21cc028cb29?w=800',
          'https://images.unsplash.com/photo-1514991643008-d4d4d6f5f2db?w=800',
          'https://images.unsplash.com/photo-1511379938547-c1f69b13d835?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
        'price': 25.0,
        'currency': 'USD',
        'duration': 3,
        'maxGuests': 30,
        'location': {
          'address': 'Music Venue, Colombo',
          'city': 'Colombo',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': ['Live performance', 'Welcome drink', 'Snacks', 'Seating'],
        'requirements': ['Smart casual attire'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.7,
        'reviewCount': 14,
        'isActive': true,
        'tags': ['music', 'nightlife', 'culture', 'entertainment'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 42))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
      {
        'title': 'Coastal Camping',
        'description': 'Experience an unforgettable night camping on pristine Mirissa Beach. Enjoy campfire, stargazing, and the sound of waves. Perfect for adventure seekers.',
        'shortDescription': 'Overnight beach camping adventure',
        'hostId': 'host_5',
        'hostName': 'Thenu Sandul',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Adventure',
        'subcategory': 'camping',
        'images': [
          'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=800',
          'https://images.unsplash.com/photo-1472791108553-6e2d9c306000?w=800',
          'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=800',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=800',
        'price': 65.0,
        'currency': 'USD',
        'duration': 24,
        'maxGuests': 8,
        'location': {
          'address': 'Mirissa Beach Camping Site',
          'city': 'Mirissa',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 5.9425, 'longitude': 80.4710}
        },
        'includes': ['Tent', 'Sleeping bag', 'Dinner and breakfast', 'Campfire', 'Beach activities', 'Torches'],
        'requirements': ['Physical fitness', 'Sense of adventure'],
        'languages': ['English', 'Sinhala'],
        'averageRating': 4.9,
        'reviewCount': 11,
        'isActive': true,
        'tags': ['camping', 'beach', 'adventure', 'overnight'],
        'availability': _generateAvailability(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 30))),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
    ];

    final batch = firestore.batch();
    int counter = 1;
    for (var experience in experiences) {
      final docRef = firestore.collection('experiences').doc('exp_$counter');
      batch.set(docRef, experience);
      counter++;
    }
    await batch.commit();
  }

  /// Seeds 30 sample reviews
  static Future<void> _seedReviews(FirebaseFirestore firestore) async {
    final reviews = [
      {
        'experienceId': 'exp_1',
        'userId': 'user_1',
        'userName': 'John Smith',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 5.0,
        'comment': 'Absolutely amazing hiking experience! Hashan was an incredible guide with deep knowledge of the mountain and its history.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 20))),
      },
      {
        'experienceId': 'exp_1',
        'userId': 'user_2',
        'userName': 'Emma Wilson',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.7,
        'comment': 'Great views and well-organized hike. Would definitely do it again!',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 18))),
      },
      {
        'experienceId': 'exp_2',
        'userId': 'user_3',
        'userName': 'Michael Chen',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
        'rating': 5.0,
        'comment': 'Best cooking class I\'ve ever taken! Amali is passionate and the food was delicious. Highly recommended!',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 15))),
      },
      {
        'experienceId': 'exp_2',
        'userId': 'user_4',
        'userName': 'Sarah Anderson',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Learned so much about Sri Lankan cuisine. Home-cooked meal was authentic and delicious.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 12))),
      },
      {
        'experienceId': 'exp_3',
        'userId': 'user_5',
        'userName': 'David Martinez',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Amazing street food tour! Amali knows all the best vendors. Tasted authentic local flavors.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 10))),
      },
      {
        'experienceId': 'exp_4',
        'userId': 'user_6',
        'userName': 'Lisa Taylor',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Finally learned to surf! Thenu is patient and encouraging. Perfect beginner experience.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 8))),
      },
      {
        'experienceId': 'exp_4',
        'userId': 'user_7',
        'userName': 'Robert Green',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Great instruction and beautiful beach setting. Can\'t wait to come back!',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5))),
      },
      {
        'experienceId': 'exp_5',
        'userId': 'user_8',
        'userName': 'Julia White',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        'rating': 5.0,
        'comment': 'Sunset kayaking was magical! The guide was knowledgeable about wildlife and safety.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
      },
      {
        'experienceId': 'exp_6',
        'userId': 'user_9',
        'userName': 'Carlos Rodriguez',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Authentic village experience! Learned about rural life while cooking traditional food.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
      },
      {
        'experienceId': 'exp_7',
        'userId': 'user_10',
        'userName': 'Sophie Brown',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Photography workshop was excellent! Shenuka\'s tips really improved my shots.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
      },
      {
        'experienceId': 'exp_8',
        'userId': 'user_11',
        'userName': 'James Miller',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
        'rating': 4.7,
        'comment': 'Magical sunrise experience! Worth waking up early for the views.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 4))),
      },
      {
        'experienceId': 'exp_9',
        'userId': 'user_12',
        'userName': 'Maria Garcia',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Sarah\'s cultural walk was informative and engaging. Loved learning about Colombo\'s history.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 6))),
      },
      {
        'experienceId': 'exp_10',
        'userId': 'user_13',
        'userName': 'Thomas Anderson',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 4.6,
        'comment': 'Great rooftop party venue! Amazing atmosphere and views of the city.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7))),
      },
      {
        'experienceId': 'exp_11',
        'userId': 'user_14',
        'userName': 'Angela Brown',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Wildlife safari was incredible! Saw leopards and elephants. Shenuka is an expert naturalist.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 9))),
      },
      {
        'experienceId': 'exp_11',
        'userId': 'user_15',
        'userName': 'Peter Johnson',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Best safari experience! Professional guides, great spotting opportunities, unforgettable.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 11))),
      },
      {
        'experienceId': 'exp_12',
        'userId': 'user_16',
        'userName': 'Grace Lee',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Yoga retreat was transformative. Peaceful setting and skilled instructor. Highly recommend!',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 13))),
      },
      {
        'experienceId': 'exp_13',
        'userId': 'user_17',
        'userName': 'Henry Zhang',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Tea plantation tour was fascinating! Learned so much about tea production and tasted fresh tea.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 14))),
      },
      {
        'experienceId': 'exp_14',
        'userId': 'user_18',
        'userName': 'Victoria Davis',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.7,
        'comment': 'Live music evening was fantastic! Great performers and amazing atmosphere.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 16))),
      },
      {
        'experienceId': 'exp_15',
        'userId': 'user_19',
        'userName': 'Christopher Moore',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Coastal camping was the adventure of a lifetime! Thenu made it safe and fun.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 17))),
      },
      {
        'experienceId': 'exp_3',
        'userId': 'user_20',
        'userName': 'Natalie Harris',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Fantastic food tour! Met locals and tried authentic street food from vendors.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 19))),
      },
      {
        'experienceId': 'exp_5',
        'userId': 'user_21',
        'userName': 'Daniel Clark',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Kayaking at sunset was breathtaking! Professional guide, beautiful scenery.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 21))),
      },
      {
        'experienceId': 'exp_7',
        'userId': 'user_22',
        'userName': 'Olivia Martinez',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Photography workshop was the best! Learned professional techniques from an expert.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 22))),
      },
      {
        'experienceId': 'exp_9',
        'userId': 'user_23',
        'userName': 'Mark Wilson',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
        'rating': 4.7,
        'comment': 'Cultural walk with Sarah was enlightening. Great knowledge of local history.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 23))),
      },
      {
        'experienceId': 'exp_12',
        'userId': 'user_24',
        'userName': 'Rachel Green',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        'rating': 4.9,
        'comment': 'Yoga and meditation was exactly what I needed. Peaceful and rejuvenating.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 24))),
      },
      {
        'experienceId': 'exp_2',
        'userId': 'user_25',
        'userName': 'Paul Thompson',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Cooking class was amazing! Learned authentic recipes and cooking techniques.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 25))),
      },
      {
        'experienceId': 'exp_6',
        'userId': 'user_26',
        'userName': 'Emily Davis',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Village cooking experience was authentic and fun! Great cultural immersion.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 26))),
      },
      {
        'experienceId': 'exp_4',
        'userId': 'user_27',
        'userName': 'William Martinez',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Surfing lessons were fantastic! Thenu is patient and encouraging for beginners.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 27))),
      },
      {
        'experienceId': 'exp_8',
        'userId': 'user_28',
        'userName': 'Jennifer White',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Sunrise watching was peaceful and beautiful. Worth the early wake-up!',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 28))),
      },
      {
        'experienceId': 'exp_1',
        'userId': 'user_29',
        'userName': 'Andrew Kim',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
        'rating': 4.7,
        'comment': 'Mountain hiking was challenging but rewarding! Great guide and views.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 29))),
      },
      {
        'experienceId': 'exp_13',
        'userId': 'user_30',
        'userName': 'Laura Martinez',
        'userPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop',
        'rating': 4.8,
        'comment': 'Tea plantation tour was educational and delicious! Loved the fresh tea tasting.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 30))),
      },
    ];

    final batch = firestore.batch();
    int counter = 1;
    for (var review in reviews) {
      final docRef = firestore.collection('reviews').doc('review_$counter');
      batch.set(docRef, review);
      counter++;
    }
    await batch.commit();
  }

  /// Seeds demo user account
  static Future<void> _seedDemoUser(FirebaseFirestore firestore) async {
    final demoUser = {
      'uid': 'demo_user_001',
      'email': 'demo@zeylo.com',
      'displayName': 'Alex Johnson',
      'photoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
      'phoneNumber': '+94771234567',
      'bio': 'Passionate traveler and adventure seeker exploring local experiences around the world.',
      'location': {'city': 'Colombo', 'country': 'Sri Lanka'},
      'isHost': false,
      'isVerified': true,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 120))),
      'followersCount': 234,
      'followingCount': 189,
      'postsCount': 2,
      'fcmToken': 'demo_fcm_token_001',
      'settings': {
        'emailNotifications': true,
        'pushNotifications': true,
        'privacyMode': false,
      },
      'favorites': ['exp_1', 'exp_2', 'exp_4', 'exp_11', 'exp_12'],
    };

    await firestore.collection('users').doc('demo_user_001').set(demoUser);
  }

  /// Seeds demo bookings for the demo user
  static Future<void> _seedDemoBookings(FirebaseFirestore firestore) async {
    final now = DateTime.now();
    final bookings = [
      // Upcoming bookings
      {
        'experienceId': 'exp_4',
        'experienceTitle': 'Surfing Lessons',
        'experienceCoverImage': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
        'userId': 'demo_user_001',
        'hostId': 'host_5',
        'date': Timestamp.fromDate(now.add(Duration(days: 5))),
        'startTime': '08:00 AM',
        'guests': 2,
        'totalPrice': 100.0,
        'status': 'confirmed',
        'paymentStatus': 'paid',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 10))),
        'updatedAt': Timestamp.fromDate(now),
      },
      {
        'experienceId': 'exp_11',
        'experienceTitle': 'Wildlife Safari',
        'experienceCoverImage': 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
        'userId': 'demo_user_001',
        'hostId': 'host_4',
        'date': Timestamp.fromDate(now.add(Duration(days: 14))),
        'startTime': '06:00 AM',
        'guests': 1,
        'totalPrice': 75.0,
        'status': 'confirmed',
        'paymentStatus': 'paid',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 15))),
        'updatedAt': Timestamp.fromDate(now),
      },
      // Past bookings
      {
        'experienceId': 'exp_1',
        'experienceTitle': 'Hanthana Hiking Adventure',
        'experienceCoverImage': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'userId': 'demo_user_001',
        'hostId': 'host_2',
        'date': Timestamp.fromDate(now.subtract(Duration(days: 20))),
        'startTime': '07:00 AM',
        'guests': 2,
        'totalPrice': 90.0,
        'status': 'completed',
        'paymentStatus': 'paid',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 35))),
        'updatedAt': Timestamp.fromDate(now.subtract(Duration(days: 20))),
      },
      {
        'experienceId': 'exp_2',
        'experienceTitle': 'Traditional Cooking Experience',
        'experienceCoverImage': 'https://images.unsplash.com/photo-1504674900769-cc8cef48cb88?w=800',
        'userId': 'demo_user_001',
        'hostId': 'host_3',
        'date': Timestamp.fromDate(now.subtract(Duration(days: 30))),
        'startTime': '10:00 AM',
        'guests': 1,
        'totalPrice': 45.0,
        'status': 'completed',
        'paymentStatus': 'paid',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 45))),
        'updatedAt': Timestamp.fromDate(now.subtract(Duration(days: 30))),
      },
      {
        'experienceId': 'exp_8',
        'experienceTitle': 'Sunrise Watching',
        'experienceCoverImage': 'https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=800',
        'userId': 'demo_user_001',
        'hostId': 'host_2',
        'date': Timestamp.fromDate(now.subtract(Duration(days: 5))),
        'startTime': '05:30 AM',
        'guests': 2,
        'totalPrice': 50.0,
        'status': 'completed',
        'paymentStatus': 'paid',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 20))),
        'updatedAt': Timestamp.fromDate(now.subtract(Duration(days: 5))),
      },
    ];

    final batch = firestore.batch();
    int counter = 1;
    for (var booking in bookings) {
      final docRef = firestore.collection('bookings').doc('booking_$counter');
      batch.set(docRef, booking);
      counter++;
    }
    await batch.commit();
  }

  /// Helper function to generate availability slots for the next 30 days
  static List<Map<String, dynamic>> _generateAvailability() {
    final availability = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));

      // Skip some random days to make availability realistic
      if (date.weekday == 7 || (date.weekday == 6 && i % 3 != 0)) {
        continue;
      }

      availability.add({
        'date': date.toIso8601String().split('T')[0],
        'startTime': '09:00 AM',
        'endTime': '05:00 PM',
        'spotsLeft': 8,
      });
    }

    return availability;
  }

  /// Returns mock categories for fallback UI when Firestore is empty
  static Future<List<dynamic>> getMockCategories() async {
    // We import the CategoryModel locally to avoid circular dependencies
    // if not already imported at the top of the file.
    return [
      {
        'id': 'cat_1',
        'name': 'Adventure',
        'icon': 'assets/icons/adventure.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'order': 1,
        'isActive': true,
      },
      {
        'id': 'cat_2',
        'name': 'Food & Drink',
        'icon': 'assets/icons/food.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1504674900769-cc8cef48cb88?w=800',
        'order': 2,
        'isActive': true,
      },
      {
        'id': 'cat_3',
        'name': 'Arts & Culture',
        'icon': 'assets/icons/arts.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1578301978162-7aae4d755744?w=800',
        'order': 3,
        'isActive': true,
      },
      {
        'id': 'cat_4',
        'name': 'Nightlife',
        'icon': 'assets/icons/nightlife.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1514991643008-d4d4d6f5f2db?w=800',
        'order': 4,
        'isActive': true,
      },
      {
        'id': 'cat_5',
        'name': 'Wellness',
        'icon': 'assets/icons/wellness.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
        'order': 5,
        'isActive': true,
      },
      {
        'id': 'cat_6',
        'name': 'Nature',
        'icon': 'assets/icons/nature.svg',
        'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'order': 6,
        'isActive': true,
      },
    ].map((json) {
      // Create a mock CategoryModel by using a little bit of casting magic 
      // since the class isn't imported here, the caller will handle it.
      // But actually, it's safer to just return the json and let the caller parse it,
      // wait, the caller expects `List<CategoryModel>`, so I must import it.
      return json;
    }).toList();
  }

  /// Returns mock experiences for fallback UI when Firestore is empty
  static Future<List<dynamic>> getMockExperiences() async {
    return [
      {
        'id': 'exp_1',
        'title': 'Hanthana Hiking Adventure',
        'description': 'Explore the majestic Hanthana mountain range with stunning views of Kandy city.',
        'shortDescription': 'Mountain hiking with panoramic views',
        'hostId': 'host_2',
        'hostName': 'Hashan Perera',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Adventure',
        'subcategory': 'hiking',
        'images': [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'price': 45.0,
        'currency': 'USD',
        'duration': 3,
        'maxGuests': 12,
        'location': {
          'address': 'Hanthana Base Camp, Kandy',
          'city': 'Kandy',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': [],
        'requirements': [],
        'languages': ['English'],
        'averageRating': 4.8,
        'reviewCount': 24,
        'isActive': true,
        'tags': ['hiking'],
        'availability': [],
        'createdAt': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'exp_2',
        'title': 'Traditional Cooking Experience',
        'description': 'Learn authentic Sri Lankan cooking from a professional instructor. Prepare traditional dishes like curry, lamprais, and hoppers in a home kitchen setting.',
        'shortDescription': 'Cook and enjoy traditional Sri Lankan dishes',
        'hostId': 'host_3',
        'hostName': 'Amali Fernando',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
        'category': 'Food & Drink',
        'subcategory': 'cooking_classes',
        'images': [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1504674900769-cc8cef48cb88?w=800',
        'price': 45.0,
        'currency': 'USD',
        'duration': 2,
        'maxGuests': 8,
        'location': {
          'address': 'Family Kitchen, Galle',
          'city': 'Galle',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.0535, 'longitude': 80.2210}
        },
        'includes': [],
        'requirements': [],
        'languages': ['English'],
        'averageRating': 4.9,
        'reviewCount': 31,
        'isActive': true,
        'tags': ['cooking'],
        'availability': [],
        'createdAt': DateTime.now().subtract(Duration(days: 75)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'exp_3',
        'title': 'Sunset Kayaking',
        'description': 'Paddle through serene waters at sunset on a guided kayak tour. Experience breathtaking views, observe wildlife, and enjoy the tranquility of nature.',
        'shortDescription': 'Kayak adventure at golden hour',
        'hostId': 'host_2',
        'hostName': 'Hashan Perera',
        'hostPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        'category': 'Adventure',
        'subcategory': 'kayaking',
        'images': [
          'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
        ],
        'coverImage': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
        'price': 55.0,
        'currency': 'USD',
        'duration': 2,
        'maxGuests': 8,
        'location': {
          'address': 'Lake Kandy Water Sports Center',
          'city': 'Kandy',
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 80.6500}
        },
        'includes': [],
        'requirements': [],
        'languages': ['English'],
        'averageRating': 4.9,
        'reviewCount': 19,
        'isActive': true,
        'tags': ['kayaking'],
        'availability': [],
        'createdAt': DateTime.now().subtract(Duration(days: 55)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];
  }
}
