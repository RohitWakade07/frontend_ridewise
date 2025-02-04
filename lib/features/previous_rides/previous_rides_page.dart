import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';

class PreviousRidesPage extends StatelessWidget {
  const PreviousRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('passengers', arrayContains: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading history',
                style: TextStyle(color: AppColors.errorRed),
              ),
            );
          }

          final rides = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              final pickup = ride['pickup'] as GeoPoint;
              final destination = ride['destination'] as GeoPoint;
              final date = (ride['date'] as Timestamp).toDate();
              final isCompleted = date.isBefore(DateTime.now());

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
                        'Status: ${isCompleted ? 'Completed' : 'Upcoming'}',
                        style: TextStyle(
                          color: isCompleted 
                              ? AppColors.accentGreen 
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.errorRed),
                    onPressed: () => _cancelRide(context, ride.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancelRide(BuildContext context, String rideId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .update({
            'passengers': FieldValue.arrayRemove([user?.email]),
            'isBooked': false,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride cancelled successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel ride'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}