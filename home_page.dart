import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_property_page.dart'; // Import Add Property Page
import 'favorite_page.dart'; // Import Favorite Page
import 'dart:ui';
import 'profile_page.dart';
import 'search_page.dart';
import 'adding_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to store properties
  List<Map<String, dynamic>> _properties = [];

  // Current index for bottom navigation
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch the latest properties on startup
    _fetchProperties();
  }

  // Fetch the latest 5 properties from Firestore
  Future<void> _fetchProperties() async {
    try {
      final querySnapshot = await _firestore
          .collection('properties')
          .orderBy('from', descending: true)
          .limit(5)
          .get();

      setState(() {
        _properties = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id, // add this line
            'title': doc['title'],
            'bed': doc['bed'],
            'bath': doc['bath'],
            'rent': doc['rent'],
            'location': doc['location'],
            'owner': doc['owner'],
            'phone': doc['phone'],
            'lat': doc['lat'],
            'lng': doc['lng'],
            'image_url': doc['image_url'],
            'from': doc['from'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.teal[800]!.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        elevation: 0,
        title: const Text(
          'Rento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        centerTitle: false, // Align title to the left
        actions: [
          // Wider Search Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 140, // Slightly wider for better balance
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.9),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Three Dots (More Options)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: () {
              // Implement more options functionality
            },
            splashRadius: 22,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _properties.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            )
          : RefreshIndicator(
              onRefresh: _fetchProperties,
              color: Colors.teal,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  final property = _properties[index];
                  // final propertyId = property.id;
                  return GestureDetector(
                    onTap: () {
                      // Navigate to Property Details
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: Colors.teal.withOpacity(0.2),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          Stack(
                            children: [
                              property['image_url'] != null &&
                                      property['image_url'].isNotEmpty
                                  ? Image.network(
                                      property['image_url'],
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          height: 220,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.teal,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return _placeholderImage();
                                      },
                                    )
                                  : _placeholderImage(),
                              // Favorite Icon
                              Positioned(
                                top: 12,
                                right: 12,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: Colors.teal[600],
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final title = property['title'] as String?;
                                      if (title != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddingPage(propertyTitle: title),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Cannot favorite: Property title is missing'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.red.shade400,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Property Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildIconText(
                                        Icons.king_bed, '${property['bed']} Bed'),
                                    const SizedBox(width: 16),
                                    _buildIconText(Icons.bathtub,
                                        '${property['bath']} Bath'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Available from: ${property['from']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${property['rent']}/mo',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal[600],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.teal[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'For Rent',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        property['location'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[600],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPropertyPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Implement navigation logic here
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                      MaterialPageRoute(
                      builder: (_) => const HomePage(),
                      ),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                      MaterialPageRoute(
                      builder: (_) => const FavoritesPage(),
                      ),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                      MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                      ),
                  );
                  break;
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.teal[600],
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 0
                        ? Colors.teal[100]
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home,
                    size: _currentIndex == 0 ? 28 : 24,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 1
                        ? Colors.teal[100]
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: _currentIndex == 1 ? 28 : 24,
                  ),
                ),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 2
                        ? Colors.teal[100]
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: _currentIndex == 2 ? 28 : 24,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for placeholder image
  Widget _placeholderImage() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Helper widget for icon + text
  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.teal[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}