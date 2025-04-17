import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  AddPropertyPageState createState() => AddPropertyPageState();
}

class AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  // Define controllers for each field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bedController = TextEditingController();
  final TextEditingController _bathController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _availableFromController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variable to hold the selected date
  DateTime? _availableFrom;

  // Show date picker and update _availableFrom and _availableFromController
  Future<void> _selectAvailableFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _availableFrom) {
      setState(() {
        _availableFrom = pickedDate;
        _availableFromController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Add property data to Firestore
  Future<void> addProperty() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('properties').add({
          'id': _firestore.collection('properties').doc(),
          'title': _titleController.text,
          'bed': int.parse(_bedController.text),
          'bath': int.parse(_bathController.text),
          'rent': _rentController.text,
          'location': _locationController.text,
          'from': _availableFromController.text,
          'owner': _ownerController.text,
          'phone': _phoneController.text,
          'lat': 23.8125, // Static placeholder
          'lng': 90.4203, // Static placeholder
          'image_url': _imageUrlController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Property added successfully'),
            backgroundColor: Colors.teal[600],
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding property: $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal[600],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Property',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Property Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _titleController,
                  label: 'Property Title',
                  inputType: TextInputType.text,
                  icon: Icons.home,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _bedController,
                        label: 'Beds',
                        inputType: TextInputType.number,
                        icon: Icons.king_bed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _bathController,
                        label: 'Baths',
                        inputType: TextInputType.number,
                        icon: Icons.bathtub,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _rentController,
                  label: 'Rent (per month)',
                  inputType: TextInputType.number,
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _locationController,
                  label: 'Location',
                  inputType: TextInputType.text,
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _ownerController,
                  label: 'Owner Name',
                  inputType: TextInputType.text,
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  inputType: TextInputType.phone,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _availableFromController,
                  label: 'Available From',
                  inputType: TextInputType.datetime,
                  icon: Icons.calendar_today,
                  isReadOnly: true,
                  onTap: () => _selectAvailableFromDate(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'Property Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide a valid image URL for the property',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextFormField(
                  controller: _imageUrlController,
                  label: 'Image URL',
                  inputType: TextInputType.url,
                  icon: Icons.image,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: addProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 5,
                    shadowColor: Colors.teal.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Save Property',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text form fields with styling
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required TextInputType inputType,
    required IconData icon,
    bool isReadOnly = false,
    Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      readOnly: isReadOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal[600]),
        prefixIcon: Icon(icon, color: Colors.teal[600]),
        filled: true,
        fillColor: Colors.teal[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[600]!, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}