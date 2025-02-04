
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Support Center'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('How to cancel a ride?',
                      style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    title: Text('Payment issues',
                      style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    title: Text('Safety concerns',
                      style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Describe your issue',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.accentGreen),
                  onPressed: _submitSupportRequest,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _submitSupportRequest() async {
    if (_messageController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('supportTickets').add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'message': _messageController.text,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }
}