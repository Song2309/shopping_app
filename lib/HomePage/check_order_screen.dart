import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckOrderScreen extends StatefulWidget {
  @override
  _CheckOrderScreenState createState() => _CheckOrderScreenState();
}

class _CheckOrderScreenState extends State<CheckOrderScreen> {
  int _currentStep = 0; // Trạng thái của bước hiện tại

  // Example data that would be passed from MyOrderScreen (in real use, you might pass this data via constructor or state management)
  final Map<String, dynamic> order = {
    'orderNumber': 'ORD12345',
    'date': '2024-10-10',
    'status': 'Pending',
    'trackingNumber': 'TRACK1234',
    'quantity': 2,
    'totalPrice': 100.0,
    'productTitle': 'Wireless Mouse',
    'price': 50.0,
    'voucher': 'DISCOUNT10',
  };

  // Hàm để di chuyển đến bước kế tiếp
  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Hàm để quay lại bước trước
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Hàm tạo Text với nội dung tùy chỉnh
  Widget _buildText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // Hàm tạo Stepper
  Widget _buildStepper() {
    return Stepper(
      currentStep: _currentStep, // Cập nhật bước hiện tại
      onStepTapped: (step) {
        setState(() {
          _currentStep = step; // Chuyển đến bước được chọn
        });
      },
      onStepContinue: _nextStep, // Di chuyển đến bước tiếp theo khi nhấn Continue
      onStepCancel: _previousStep, // Quay lại bước trước khi nhấn Cancel
      steps: [
        Step(
          title: Text(
            'Sender is preparing to ship your order',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          content: Row(
            children: [
              Spacer(),
              Text('Date: 2024-10-10'),
            ],
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: Text(
            'Sender has shipped your parcel',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          content: Row(
            children: [
              Spacer(),
              Text('Date: 2024-10-10'),
            ],
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: Text(
            'Parcel is in transit',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          content: Row(
            children: [
              Spacer(),
              Text('Date: 2024-10-11'),
            ],
          ),
          isActive: _currentStep >= 2,
        ),
        Step(
          title: Text(
            'Parcel has arrived at local hub',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          content: Row(
            children: [
              Spacer(),
              Text('Date: 2024-10-11'),
            ],
          ),
          isActive: _currentStep >= 3,
        ),
        Step(
          title: Text(
            'Parcel is out for delivery',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          content: Row(
            children: [
              Spacer(),
              Text('Date: 2024-10-12'),
            ],
          ),
          isActive: _currentStep >= 4,
        ),
        Step(
          title: Text(
            'Parcel delivered successfully',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          content: Row(
            children: [
              Spacer(),
              Text('Date: 2024-10-13'),
            ],
          ),
          isActive: _currentStep >= 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Check'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sử dụng _buildText để hiển thị 2 dòng văn bản
            _buildText('Date: 13-10-2024'),
            SizedBox(height: 20),
            _buildText('TrackingNumber: TRACK1234'),
            SizedBox(height: 30),
            // Stepper được gọi thông qua _buildStepper
            _buildStepper(),
          ],
        ),
      ),
    );
  }
}
