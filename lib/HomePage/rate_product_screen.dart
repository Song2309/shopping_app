import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class RateProductScreen extends StatefulWidget {
  @override
  _RateProductScreenState createState() => _RateProductScreenState();
}

class _RateProductScreenState extends State<RateProductScreen> {
  double rating = 0;
  TextEditingController commentController = TextEditingController();
  List<File> images = [];
  File? video;
  List<Map<String, dynamic>> reviews = [];

  // Hàm chọn ảnh
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length <= 3) {
      setState(() {
        images = pickedFiles.map((file) => File(file.path!)).toList();
      });
    } else {
      // Giới hạn tối đa 3 ảnh
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You can select up to 3 images.")));
    }
  }

  // Kiểm tra kích thước tệp
  Future<void> checkFileSize(XFile xfile) async {
    // Chuyển XFile thành File
    File file = File(xfile.path);

    // Kiểm tra kích thước tệp
    int fileSize = await file.length(); // Sử dụng length() thay vì lengthSync()

    if (fileSize > 100 * 1024 * 1024) {
      // Nếu tệp lớn hơn 100MB
      print('File size exceeds 100MB');
    }
  }

  // Hàm chọn video
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Chuyển pickedFile thành File và kiểm tra kích thước
      File file = File(pickedFile.path);
      int fileSize = await file.length();  // Dùng length() thay vì lengthSync()

      if (fileSize <= 100 * 1024 * 1024) { // 100MB max
        setState(() {
          video = file;
        });
      } else {
        // Giới hạn video dưới 100MB
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Video size must be under 100MB.")));
      }
    }
  }

  // Hàm gửi đánh giá
  void _submitReview() {
    if (rating == 0 || commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please complete all fields.")));
      return;
    }

    setState(() {
      reviews.add({
        'rating': rating,
        'comment': commentController.text,
        'images': images,
        'video': video,
      });
    });

    // Reset các trường sau khi gửi đánh giá
    setState(() {
      rating = 0;
      commentController.clear();
      images.clear();
      video = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review submitted!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rate Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rating Label
                  Text("Rate the product:"),
                  SizedBox(height: 10), // Khoảng cách giữa label và RatingBar
                  // RatingBar
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40.0,
                    itemBuilder: (context, index) {
                      return Icon(
                        Icons.star,
                        color: index < rating ? Colors.yellow : Colors.grey,
                      );
                    },
                    onRatingUpdate: (ratingValue) {
                      setState(() {
                        rating = ratingValue;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Comment
            Text("Leave a comment (max 200 characters):"),
            TextField(
              controller: commentController,
              maxLength: 200,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write your comment here...",
              ),
            ),
            SizedBox(height: 20),

            // Images Picker
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Pick Images (max 3)"),
                ),
                SizedBox(width: 10),
                Text("${images.length}/3 images selected"),
              ],
            ),
            SizedBox(height: 10),
            // Display selected images
            images.isNotEmpty
                ? SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(images[index], width: 80, height: 80, fit: BoxFit.cover),
                  );
                },
              ),
            )
                : Text("No images selected."),
            SizedBox(height: 20),

            // Video Picker
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: Text("Pick a Video (max 100MB)"),
                ),
                SizedBox(width: 10),
                video != null ? Text("Video selected") : Container(),
              ],
            ),
            SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: _submitReview,
                child: Text("Submit Review"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReviewListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  ReviewListScreen({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submitted Reviews"),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Order #${review['orderNumber']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rating: ${review['rating']} stars"),
                  Text("Comment: ${review['comment'].substring(0, 20)}..."),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
