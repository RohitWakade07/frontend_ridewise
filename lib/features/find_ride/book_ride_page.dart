import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';

class BookRidePage extends StatelessWidget {
  const BookRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Available Rides'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('isBooked', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading rides',
                style: TextStyle(color: AppColors.errorRed),
              ),
            );
          }

          final rides = snapshot.data!.docs;

          if (rides.isEmpty) {
            return const Center(
              child: Text(
                'No available rides',
                style: TextStyle(color: AppColors.primaryWhite),
              ),
            );
          }

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return RideItem(ride: ride);
            },
          );
        },
      ),
    );
  }
}

class RideItem extends StatelessWidget {
  final QueryDocumentSnapshot ride;

  const RideItem({super.key, required this.ride});

  Future<void> _bookRide(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(ride.id)
          .update({
            'passengers': FieldValue.arrayUnion([user?.email]),
            'isBooked': true,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride booked successfully!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to book ride'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = ride['pickup'] as GeoPoint;
    final destination = ride['destination'] as GeoPoint;
    final date = (ride['date'] as Timestamp).toDate();

    return Card(
      color: AppColors.secondaryDark,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          '${pickup.latitude.toStringAsFixed(3)}, ${pickup.longitude.toStringAsFixed(3)} → '
          '${destination.latitude.toStringAsFixed(3)}, ${destination.longitude.toStringAsFixed(3)}',
          style: const TextStyle(color: AppColors.primaryWhite),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: AppColors.hintGrey),
            ),
            Text(
              'Driver: ${ride['createdBy']}',
              style: const TextStyle(color: AppColors.hintGrey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.book_online, color: AppColors.accentGreen),
          onPressed: () => _bookRide(context),
        ),
      ),
    );
  }
}