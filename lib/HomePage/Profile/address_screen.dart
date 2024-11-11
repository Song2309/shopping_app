import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool isLoading = true;
  bool isEditable = false;  // Biến kiểm tra chế độ chỉnh sửa
  String name = '';
  String email = '';
  String address = '';
  String city = '';
  String state = '';
  String postalCode = '';
  String country = '';

  // Controllers để chỉnh sửa thông tin
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load user profile from API based on the logged-in user's email
  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null && email.isNotEmpty) {
      try {
        final userData = await fetchUserData();
        final user = userData.firstWhere((user) => user['email'] == email, orElse: () => {});

        if (user.isNotEmpty) {
          setState(() {
            name = user['firstName'] ?? 'No name';
            this.email = user['email'] ?? 'No email';
            address = user['address']['address'] ?? 'No address';
            city = user['address']['city'] ?? 'No city';
            state = user['address']['state'] ?? 'No state';
            postalCode = user['address']['postalCode'] ?? 'No postal code';
            country = user['address']['country'] ?? 'No country';

            // Gán giá trị ban đầu vào các controller
            addressController.text = address;
            cityController.text = city;
            stateController.text = state;
            postalCodeController.text = postalCode;
            countryController.text = country;

            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('User not found');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching user data: $e");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('No email found in SharedPreferences');
    }
  }

  // Fetch user data from the API
  Future<List<Map<String, dynamic>>> fetchUserData() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/users'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['users']);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Hàm lưu các thông tin đã chỉnh sửa vào SharedPreferences
  Future<void> _saveUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', addressController.text);
    await prefs.setString('city', cityController.text);
    await prefs.setString('state', stateController.text);
    await prefs.setString('postalCode', postalCodeController.text);
    await prefs.setString('country', countryController.text);

    setState(() {
      address = addressController.text;
      city = cityController.text;
      state = stateController.text;
      postalCode = postalCodeController.text;
      country = countryController.text;
      isEditable = false;  // Đóng chế độ chỉnh sửa sau khi lưu
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address Information'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            // TextField cho các trường thông tin
            TextField(
              controller: addressController,
              readOnly: !isEditable, // Chỉ cho phép chỉnh sửa khi isEditable là true
              decoration: InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: cityController,
              readOnly: !isEditable,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: stateController,
              readOnly: !isEditable,
              decoration: InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: postalCodeController,
              readOnly: !isEditable,
              decoration: InputDecoration(
                labelText: 'Postal Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: countryController,
              readOnly: !isEditable,
              decoration: InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Nút Adjust: Mở chế độ chỉnh sửa
            if (!isEditable)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditable = true; // Chuyển sang chế độ chỉnh sửa
                  });
                },
                child: Text('Adjust'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            // Nút Save: Lưu các thay đổi
            if (isEditable)
              ElevatedButton(
                onPressed: _saveUserProfile,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
