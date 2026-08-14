import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PickedLocation {
  final LatLng latLng;
  final String addressLine;
  final String city;

  PickedLocation({
    required this.latLng,
    required this.addressLine,
    required this.city,
  });
}

class AddressMapPickerScreen extends StatefulWidget {
  final LatLng? initialLatLng;

  const AddressMapPickerScreen({super.key, this.initialLatLng});

  @override
  State<AddressMapPickerScreen> createState() => _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<AddressMapPickerScreen> {
  static const _defaultCenter = LatLng(11.5564, 104.9282); // Phnom Penh fallback

  final MapController _mapController = MapController();
  late LatLng _pickedLatLng;
  String _resolvedAddress = "";
  bool _resolving = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _pickedLatLng = widget.initialLatLng ?? _defaultCenter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLatLng != null) {
        _reverseGeocode(_pickedLatLng);
      } else {
        _goToCurrentLocation();
      }
    });
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location services disabled");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _pickedLatLng = latLng);

      _mapController.move(latLng, 16.0);
      await _reverseGeocode(latLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't get current location: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _resolving = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final line = [p.street, p.subLocality]
            .where((s) => s != null && s.isNotEmpty)
            .join(", ");
        setState(() {
          _resolvedAddress = line.isNotEmpty ? line : "Selected location";
        });
      }
    } catch (_) {
      setState(() => _resolvedAddress = "Selected location");
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<String> _cityFor(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality?.isNotEmpty == true
            ? placemarks.first.locality!
            : (placemarks.first.administrativeArea ?? "Phnom Penh");
      }
    } catch (_) {}
    return "Phnom Penh";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick delivery location")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // OpenStreetMap Widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLatLng,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (position.center != null) {
                  _pickedLatLng = position.center!;
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _reverseGeocode(_pickedLatLng);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mystore.ecommerce',
              ),
            ],
          ),

          // Fixed Center Pin
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.location_pin, size: 44, color: Colors.red),
          ),

          // Current Location FAB
          Positioned(
            right: 16,
            bottom: 160,
            child: FloatingActionButton(
              heroTag: "locate",
              onPressed: _locating ? null : _goToCurrentLocation,
              child: _locating
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Address Card & Action Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resolving ? "Locating..." : _resolvedAddress,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resolving
                            ? null
                            : () async {
                          final city = await _cityFor(_pickedLatLng);
                          if (context.mounted) {
                            Navigator.pop(
                              context,
                              PickedLocation(
                                latLng: _pickedLatLng,
                                addressLine: _resolvedAddress,
                                city: city,
                              ),
                            );
                          }
                        },
                        child: const Text("Use this location"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}