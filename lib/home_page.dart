import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(email: 'john.doe@example.com'), // Default email
    );
  }
}

// Home Page
class MyHomePage extends StatefulWidget {
  final String email;

  const MyHomePage({super.key, required this.email});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _wheelAnimationController;

  @override
  void initState() {
    super.initState();
    _wheelAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _wheelAnimationController.dispose();
    super.dispose();
  }

  void _navigateToDestinationPage() {
    if (_controller.text.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DestinationPage(location: _controller.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('RideWise'),
        backgroundColor: Colors.black,
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildHeaderWithAnimation(),
            const SizedBox(height: 50),
            _buildLocationInput(),
            const SizedBox(height: 30),
            _buildFindRideButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: const Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProfilePage(email: widget.email),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Previous Rides'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PreviousRidesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Send Parcel'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SendParcelPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'RideWise',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Arial',
              letterSpacing: 2,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _wheelAnimationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _wheelAnimationController.value * 6.28,
              child: child,
            );
          },
          child: const Icon(
            Icons.directions_bike,
            color: Colors.white,
            size: 50,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[800],
          hintText: 'Where do you want to go?',
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.location_on, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFindRideButton() {
    return ElevatedButton(
      onPressed: _navigateToDestinationPage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      child: const Text(
        'Find Ride',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}

// Destination Page
class DestinationPage extends StatelessWidget {
  final String location;

  const DestinationPage({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination'),
      ),
      body: Center(
        child: Text(
          'You are going to $location!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// View Profile Page
class ViewProfilePage extends StatelessWidget {
  final String email;

  const ViewProfilePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Text(
          'Welcome to your profile, $email!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Previous Rides Page
class PreviousRidesPage extends StatelessWidget {
  const PreviousRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Rides'),
      ),
      body: const Center(
        child: Text(
          'This is the Previous Rides page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Send Parcel Page
class SendParcelPage extends StatelessWidget {
  const SendParcelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Parcel'),
      ),
      body: const Center(
        child: Text(
          'This is the Send Parcel page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
