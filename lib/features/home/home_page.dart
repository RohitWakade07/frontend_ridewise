import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../find_ride/book_ride_page.dart';
import '../find_ride/create_ride_page.dart';
import 'ViewProfilePage.dart';


class HomePage extends StatefulWidget {
  final String email;
  final String phone;

  const HomePage({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContent(),
      const BookRidePage(),
      ProfilePage(email: widget.email, phone: widget.phone),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(19.0760, 72.8777),
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          _buildTopSection(),
          _buildBottomActionSheet(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.my_location, color: Colors.black),
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newLatLng(const LatLng(19.0760, 72.8777)),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Column(
        children: [
          _buildLocationField(
            controller: _pickupController,
            hintText: 'Enter pickup location',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 10),
          _buildLocationField(
            controller: _destinationController,
            hintText: 'Where to?',
            icon: Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondaryDark,
        prefixIcon: Icon(icon, color: Colors.white54),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBottomActionSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child: Icon(Icons.horizontal_rule_rounded, 
                  color: Colors.white54),
              ),
              _buildQuickActions(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Recent Rides',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              _buildRecentRides(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.directions_car,
            label: 'Ride',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRidePage()),
            ),
          ),
          _buildActionButton(
            icon: Icons.directions_bike,
            label: 'Bike',
            onPressed: () {},
          ),
          _buildActionButton(
            icon: Icons.delivery_dining,
            label: 'Delivery',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: AppColors.accentGreen),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildRecentRides() {
    // Replace with actual recent rides data
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.white54),
      title: const Text('Churchgate Station → Bandra West',
        style: TextStyle(color: Colors.white)),
      subtitle: const Text('₹245 • 25 Oct 2023',
        style: TextStyle(color: Colors.white54)),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
        onPressed: () {},
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Rides',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: AppColors.accentGreen,
      unselectedItemColor: Colors.white54,
      backgroundColor: AppColors.secondaryDark,
      onTap: _onItemTapped,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); // Empty container since main content is in stack
  }
}