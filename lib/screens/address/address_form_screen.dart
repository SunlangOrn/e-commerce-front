import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../widgets/primary_button.dart';
import 'address_map_picker_screen.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? existing;
  const AddressFormScreen({super.key, this.existing});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressLineCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _provinceCtrl;
  late final TextEditingController _postalCtrl;

  double? _latitude;
  double? _longitude;
  bool _isDefault = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.fullName ?? "");
    _phoneCtrl = TextEditingController(text: e?.phone ?? "");
    _addressLineCtrl = TextEditingController(text: e?.addressLine ?? "");
    _cityCtrl = TextEditingController(text: e?.city ?? "Phnom Penh");
    _provinceCtrl = TextEditingController(text: e?.province ?? "");
    _postalCtrl = TextEditingController(text: e?.postalCode ?? "");
    _latitude = e?.latitude;
    _longitude = e?.longitude;
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressLineCtrl.dispose();
    _cityCtrl.dispose();
    _provinceCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    LatLng? initialPos;
    if (_latitude != null && _longitude != null) {
      initialPos = LatLng(_latitude!, _longitude!);
    }

    // Expect PickedLocation response matching AddressMapPickerScreen
    final PickedLocation? result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressMapPickerScreen(initialLatLng: initialPos),
      ),
    );

    if (result != null) {
      setState(() {
        _addressLineCtrl.text = result.addressLine;
        if (result.city.isNotEmpty) {
          _cityCtrl.text = result.city;
        }
        _latitude = result.latLng.latitude;
        _longitude = result.latLng.longitude;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final address = AddressModel(
      id: widget.existing?.id ?? 0,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine: _addressLineCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      province: _provinceCtrl.text.trim().isEmpty ? null : _provinceCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim().isEmpty ? null : _postalCtrl.text.trim(),
      isDefault: _isDefault,
      latitude: _latitude,
      longitude: _longitude,
    );

    final provider = context.read<AddressProvider>();
    final ok = widget.existing != null
        ? await provider.updateAddress(widget.existing!.id, address)
        : await provider.addAddress(address);

    setState(() => _saving = false);
    if (ok && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? "Failed to save")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? "Add Address" : "Edit Address"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: _pickOnMap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFF3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: (_latitude != null && _longitude != null)
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(_latitude!, _longitude!),
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.mystore.ecommerce',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_latitude!, _longitude!),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Chip(
                          label: const Text("Change"),
                          backgroundColor:
                          Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                )
                    : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 32),
                      SizedBox(height: 8),
                      Text("Tap to pick location on map"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Full name"),
              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone number"),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressLineCtrl,
              decoration: const InputDecoration(labelText: "Address line"),
              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(labelText: "City"),
                    validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _provinceCtrl,
                    decoration: const InputDecoration(labelText: "Province"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _postalCtrl,
              decoration: const InputDecoration(labelText: "Postal code"),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Set as default address"),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: "Save Address",
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}