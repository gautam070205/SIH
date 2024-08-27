import 'dart:async';

import 'package:attendance/Screens/drawerScreens/home.dart';
import 'package:attendance/Screens/registerScreens/login.dart';
import 'package:attendance/common/appstyle.dart';
import 'package:attendance/constants.dart';
import 'package:attendance/provider/userProvider.dart';
// import 'package:attendance/route/route.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  bool isInsideGeofence = false;
  double? latitude = 0.0;
  double? longitude = 0.0;
  final double latitude1 = 30.3502;
  final double longitude1 = 76.3602;
  final double distance1 = 200.0;
  int _selectedIndex = 0;
  StreamSubscription<Position>? positionStream;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // ref.read(authPageProvider.notifier).signUp(
      //     "gautam", "medapp772@gmail.com", "1234qwer@G", "tedx", "1234qwer@G");
      // ref
      //     .read(authPageProvider.notifier)
      //     .verifyPin("378760", "medapp772@gmail.com");
      ref
          .read(authPageProvider.notifier)
          .signIn("medapp772@gmail.com", "1234qwer@G");
      ref.read(authPageProvider.notifier).getUserInfo();
    });
  }

  Future<void> _checkPermissionAndStartGeofencing() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }
    }

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      _showLocationServiceDialog();
      return;
    }

    _getInitialPosition();
    _startGeofenceMonitoring();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Needed'),
          content: const Text(
              'This app needs location permissions to function. Please enable location services and permissions.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content:
              const Text('Please enable location services to use this app.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getInitialPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      // Optionally, show an error message to the user
    }
  }

  void _startGeofenceMonitoring() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 100,
      ),
    ).listen((Position position) {
      _checkGeofence(position);
      _updateUserLocation(position);
    });
  }

  Future<void> _refreshLocation() async {
    await _getInitialPosition();
    setState(() {}); // Trigger a rebuild to reflect any changes
  }

  void _checkGeofence(Position position) {
    final double testDistance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude1,
      longitude1,
    );

    final bool testInsideGeofence = testDistance <= distance1;

    if (testInsideGeofence != isInsideGeofence) {
      setState(() {
        isInsideGeofence = testInsideGeofence;
      });

      if (testInsideGeofence) {
        _handleCheckIn();
      } else {
        _handleCheckOut();
        _showWarningDialog();
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on selected index if needed
  }

  void _updateUserLocation(Position position) {
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  void _handleCheckIn() {
    print('Inside');
  }

  void _handleCheckOut() {
    print('Outside');
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissal by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Geofence Alert'),
          content: const Text('You are outside the geofence!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userName = ref.read(authPageProvider).user.name;
    final String companyName = ref.read(authPageProvider).user.companyName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondary,
        title: const Center(
          child: Text(
            "Attendity",
            style: TextStyle(color: Color.fromARGB(255, 225, 225, 225)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: kSecondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    userName,
                    style: appStyle(24, Colors.white, FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    companyName,
                    style: appStyle(18, Colors.white, FontWeight.w400),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Get.to(() => const AttandenceDetails());
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Add your navigation code here
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_applications_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Add your navigation code here
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () async {
                // Perform logout
                await ref.read(authPageProvider.notifier).logout();

                // Navigate to the login page using GetX
                Get.to(() => LoginPage());
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLocation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Welcome to Attendity!',
                      style: appStyle(25, kDark, FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome $userName',
                    style: appStyle(25, kTertiary, FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isInsideGeofence
                        ? 'You are currently inside of $companyName'
                        : 'You are currently outside of $companyName',
                    style: appStyle(16, kPrimary, FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude1, longitude1),
                      zoom: 15.0,
                    ),
                    markers: {
                      if (latitude != null && longitude != null)
                        Marker(
                          markerId: const MarkerId('user_location'),
                          position: LatLng(latitude!, longitude!),
                          infoWindow: const InfoWindow(title: 'Your Location'),
                        ),
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId('geofence'),
                        center: LatLng(latitude1, longitude1),
                        radius: distance1,
                        fillColor: Colors.blue.withOpacity(0.3),
                        strokeColor: Colors.blue,
                        strokeWidth: 2,
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Aligns content to the start of the column
                  children: [
                    Center(
                      child: Text(
                        "Details",
                        style: appStyle(20, kDark, FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Working Hours: xyz ",
                      style: appStyle(15, kDark, FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Working Hours Left: xyz",
                      style: appStyle(15, kDark, FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total Work done:xyz ",
                      style: appStyle(15, kDark, FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        selectedItemColor: kSecondary, // Color for the selected icon
        unselectedItemColor: kDark, // Color for the unselected icons
        backgroundColor: kGray, // Background color of the BottomNavigationBar
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
