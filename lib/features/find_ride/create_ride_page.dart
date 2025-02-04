import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../core/theme/app_colors.dart';

// ================== Create Ride Page ==================
class CreateRidePage extends StatefulWidget {
  const CreateRidePage({super.key});

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  late GoogleMapController _mapController;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  double _fareEstimate = 0.0;
  String _selectedRideType = 'Standard';
  final List<Map<String, dynamic>> _rideTypes = [
    {
      'name': 'Standard',
      'icon': Icons.directions_car,
      'pricePerKm': 12.0,
      'eta': '5 min',
      'seats': 4
    },
    {
      'name': 'Premium',
      'icon': Icons.airline_seat_recline_extra,
      'pricePerKm': 18.0,
      'eta': '7 min',
      'seats': 4
    },
    {
      'name': 'XL',
      'icon': Icons.airport_shuttle,
      'pricePerKm': 25.0,
      'eta': '10 min',
      'seats': 6
    },
  ];

  void _calculateFare(double distance) {
    final selectedType = _rideTypes
        .firstWhere((type) => type['name'] == _selectedRideType);
    setState(() => _fareEstimate = distance * selectedType['pricePerKm']);
  }

  Future<void> _confirmRide() async {
    if (_pickupLocation == null || _destinationLocation == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final rideData = {
      'userId': user?.uid,
      'pickup': GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
      'destination':
          GeoPoint(_destinationLocation!.latitude, _destinationLocation!.longitude),
      'fare': _fareEstimate,
      'rideType': _selectedRideType,
      'status': 'searching',
      'createdAt': FieldValue.serverTimestamp(),
      'driverId': null,
      'estimatedArrival': DateTime.now().add(const Duration(minutes: 5)),
    };

    final docRef = await FirebaseFirestore.instance
        .collection('rides')
        .add(rideData);
        
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RideConfirmedPage(
          rideId: docRef.id,
          rideData: rideData,
          pickup: _pickupLocation,
        ),
      ),
    );
  }

  Widget _buildLocationCard(String title, IconData icon) {
    return Card(
      color: AppColors.secondaryDark,
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentGreen),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.edit, color: Colors.white54),
      ),
    );
  }

  Widget _buildRideTypeSelector() {
    return Column(
      children: _rideTypes.map((type) => RadioListTile(
        title: Row(
          children: [
            Icon(type['icon'], color: AppColors.accentGreen),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type['name'], 
                  style: const TextStyle(color: Colors.white)),
                Text("₹${type['pricePerKm']}/km • ${type['seats']} seats",
                  style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ],
        ),
        value: type['name'],
        groupValue: _selectedRideType,
        onChanged: (value) => setState(() => _selectedRideType = value!),
        activeColor: AppColors.accentGreen,
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('New Ride'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(19.0760, 72.8777),
                zoom: 12,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                if (_pickupLocation != null)
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: _pickupLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                if (_destinationLocation != null)
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: _destinationLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildLocationCard('Pickup Location', Icons.location_on),
                const SizedBox(height: 10),
                _buildLocationCard('Destination', Icons.flag),
                const Divider(color: Colors.white24),
                _buildRideTypeSelector(),
                const Divider(color: Colors.white24),
                ListTile(
                  title: const Text('Estimated Fare',
                      style: TextStyle(color: Colors.white)),
                  trailing: Text('₹${_fareEstimate.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: _confirmRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Confirm Ride',
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

// ================== Ride Confirmed Page ==================
class RideConfirmedPage extends StatelessWidget {
  final String rideId;
  final Map<String, dynamic> rideData;
  final LatLng? pickup;

  const RideConfirmedPage({
    super.key,
    required this.rideId,
    required this.rideData,
    this.pickup,
  });

  void _cancelRide(BuildContext context) async {
    await FirebaseFirestore.instance.collection('rides').doc(rideId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final GeoPoint pickupGeo = rideData['pickup'] as GeoPoint;
    final GeoPoint destinationGeo = rideData['destination'] as GeoPoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Confirmed'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(pickupGeo.latitude, pickupGeo.longitude),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: LatLng(pickupGeo.latitude, pickupGeo.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position:
                        LatLng(destinationGeo.latitude, destinationGeo.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                },
              ),
            ),
            const SizedBox(height: 20),
            // Ride Details
            Text('Fare: ₹${rideData['fare'].toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Ride Type: ${rideData['rideType']}',
                style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 20),
            // Driver Info
            const Text('Your Driver',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
              ),
              title: const Text('John Driver',
                  style: TextStyle(color: Colors.white)),
              subtitle: RatingStars(
                value: 4.5,
                starBuilder: (index, color) => Icon(
                  Icons.star,
                  color: color,
                ),
                starCount: 5,
                starSize: 20,
                valueLabelColor: const Color(0xff9b9b9b),
                valueLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 12.0),
                starSpacing: 2,
                maxValue: 5,
                starOffColor: const Color(0xffe7e8ea),
                starColor: AppColors.accentGreen,
              ),
            ),
            const Spacer(),
            // Cancel Button
            ElevatedButton(
              onPressed: () => _cancelRide(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Cancel Ride',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}