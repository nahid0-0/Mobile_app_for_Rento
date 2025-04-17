import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top curved container
          ClipPath(
            clipper: TopCurveClipper(),
            child: _TopGradientContainer(),
          ),
          // Bottom curved container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: _BottomGradientContainer(),
            ),
          ),
          // Main content
          user == null
              ? const Center(
                  child: Text(
                    'Please log in to view favorites',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'Favorites',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 3,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            // Simulate refresh; replace with actual data refresh if needed
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          color: Colors.teal,
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: firestore.collection('users').doc(user.uid).snapshots(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.hasError) {
                                return const Center(
                                  child: Text(
                                    'Error loading favorites',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final userData = userSnapshot.data;
                              if (userData == null || !userData.exists) {
                                return const Center(
                                  child: Text(
                                    'No favorites found',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              final favorites = List<String>.from(userData.get('favorites') ?? []);

                              if (favorites.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No favorites added yet',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              // Handle Firestore whereIn limit (10 items)
                              if (favorites.length > 10) {
                                return const Center(
                                  child: Text(
                                    'Too many favorites. Please remove some to view.',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }

                              return StreamBuilder<QuerySnapshot>(
                                stream: firestore
                                    .collection('properties')
                                    .where('title', whereIn: favorites)
                                    .snapshots(),
                                builder: (context, propSnapshot) {
                                  if (propSnapshot.hasError) {
                                    return const Center(
                                      child: Text(
                                        'Error loading properties',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  }
                                  if (propSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  final properties = propSnapshot.data?.docs ?? [];

                                  if (properties.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No matching properties found',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                                    itemCount: properties.length,
                                    itemBuilder: (context, index) {
                                      final property =
                                          properties[index].data() as Map<String, dynamic>;
                                      final title = property['title'] as String? ?? 'No Title';
                                      final rent = property['rent']?.toString() ?? 'N/A';
                                      final imageUrl = property['image_url'] as String? ?? '';
                                      final location = property['location'] as String? ?? 'Unknown';
                                      final bed = property['bed']?.toString() ?? 'N/A';
                                      final bath = property['bath']?.toString() ?? 'N/A';
                                      final from = property['from'] as String? ?? 'N/A';

                                      // Log the image URL for debugging
                                      debugPrint('Image URL for $title: $imageUrl');

                                      return AnimatedOpacity(
                                        opacity: 1.0,
                                        duration: Duration(milliseconds: 300 + (index * 100)),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PropertyDetailPage(property: property),
                                              ),
                                            );
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
                                                    _buildPropertyImage(imageUrl, title),
                                                    // Favorite Icon
                                                    Positioned(
                                                      top: 12,
                                                      right: 12,
                                                      child: CircleAvatar(
                                                        radius: 18,
                                                        backgroundColor: Colors.white,
                                                        child: IconButton(
                                                          icon: const Icon(
                                                            Icons.favorite,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                          onPressed: () async {
                                                            _showRemoveConfirmationDialog(
                                                              context,
                                                              firestore,
                                                              user.uid,
                                                              title,
                                                            );
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
                                                        title,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black87,
                                                          fontFamily: 'Poppins',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          _buildIconText(
                                                              Icons.king_bed, '$bed Bed'),
                                                          const SizedBox(width: 16),
                                                          _buildIconText(
                                                              Icons.bathtub, '$bath Bath'),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Available from: $from',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[600],
                                                          fontFamily: 'Roboto',
                                                        ),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            '\$$rent/mo',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.teal[600],
                                                              fontFamily: 'Roboto',
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 12, vertical: 6),
                                                            decoration: BoxDecoration(
                                                              color: Colors.teal[50],
                                                              borderRadius:
                                                                  BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                              'For Rent',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.teal[700],
                                                                fontFamily: 'Roboto',
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
                                                              location,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.grey[600],
                                                                fontFamily: 'Roboto',
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
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyImage(String imageUrl, String title) {
    if (imageUrl.isEmpty || !Uri.parse(imageUrl).isAbsolute) {
      return _placeholderImage();
    }
    return Image.network(
      imageUrl,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
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
        debugPrint('Image load error for $title: $error');
        return _placeholderImage();
      },
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(
        Icons.home,
        color: Colors.teal,
        size: 50,
      ),
    );
  }

  void _showRemoveConfirmationDialog(
      BuildContext context, FirebaseFirestore firestore, String userId, String propertyTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Favorite',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "$propertyTitle" from your favorites?',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await firestore.collection('users').doc(userId).update({
                  'favorites': FieldValue.arrayRemove([propertyTitle]),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Removed from favorites'),
                    backgroundColor: Colors.green.shade400,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error removing favorite: $e'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Gradient container widgets extracted for reusability
class _TopGradientContainer extends StatelessWidget {
  const _TopGradientContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _BottomGradientContainer extends StatelessWidget {
  const _BottomGradientContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade800],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

// Enhanced Property Detail Page
class PropertyDetailPage extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final title = property['title'] as String? ?? 'No Title';
    final rent = property['rent']?.toString() ?? 'N/A';
    final location = property['location'] as String? ?? 'Unknown';
    final bed = property['bed']?.toString() ?? 'N/A';
    final bath = property['bath']?.toString() ?? 'N/A';
    final from = property['from'] as String? ?? 'N/A';
    final imageUrl = property['image_url'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.teal.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.home,
                  size: 100,
                  color: Colors.teal,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: \$$rent/mo',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: $location',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Bedrooms: $bed',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Bathrooms: $bath',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Available from: $from',
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for top curve
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.3, size.height, size.width * 0.6, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.4, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom clipper for bottom curve
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width * 0.3, 0, size.width * 0.5, 30);
    path.quadraticBezierTo(size.width * 0.7, 60, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}