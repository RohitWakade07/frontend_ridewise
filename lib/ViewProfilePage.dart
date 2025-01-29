import 'package:flutter/material.dart';

class ViewProfilePage extends StatefulWidget {
  final String email;

  const ViewProfilePage({super.key, required this.email});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  String userName = '';
  String profilePicture = 'assets/profile.jpg';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Fetch data from Firebase based on the email
    // Example code if using Firestore:
    // final userDoc = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(widget.email)
    //     .get();
    // setState(() {
    //   userName = userDoc['name'] ?? 'No Name';
    //   profilePicture = userDoc['profilePicture'] ?? 'assets/profile.jpg';
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(profilePicture), // Profile image
            ),
            const SizedBox(height: 20),
            Text(
              userName.isNotEmpty ? 'Name: $userName' : 'Fetching name...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${widget.email}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
