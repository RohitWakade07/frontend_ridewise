import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../payments/payments_page.dart';


class RideConfirmedPage extends StatelessWidget {
  final Map<String, dynamic> rideData;

  const RideConfirmedPage({super.key, required this.rideData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Ride Confirmed'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Column(
        children: [
          const LinearProgressIndicator(value: 0.3),
          const Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(19.0760, 72.8777),
                zoom: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage('https://example.com/driver.jpg')),
                  title: const Text('Driver Name',
                    style: TextStyle(color: Colors.white)),
                  subtitle: RatingStars(
                    value: 4.5,
                    starBuilder: (index, color) => Icon(
                      Icons.star,
                      color: color,
                    ),
                  ),
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.car_rental, color: Colors.white),
                  title: const Text('Vehicle Details',
                    style: TextStyle(color: Colors.white)),
                  subtitle: Text('MH01 AB 1234 • Sedan',
                    style: TextStyle(color: Colors.grey[400])),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaymentPage())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Proceed to Payment',
                    style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}