import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/address_card.dart';
import 'address_form_screen.dart';

/// If [selectMode] is true, tapping a card pops the screen with the chosen
/// address (used from checkout). Otherwise it's a plain management screen.
class AddressListScreen extends StatefulWidget {
  final bool selectMode;
  const AddressListScreen({super.key, this.selectMode = false});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  Future<void> _confirmDelete(BuildContext context, int addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<AddressProvider>();

      // Executed directly without assigning to a variable to prevent 'void' type errors
      await provider.deleteAddress(addressId);

      if (provider.errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? "Select Address" : "My Addresses"),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => provider.fetchAddresses(),
        child: provider.addresses.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(child: Text("No addresses yet")),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: provider.addresses.length,
          itemBuilder: (context, index) {
            final address = provider.addresses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AddressCard(
                address: address,
                onTap: widget.selectMode
                    ? () => Navigator.pop(context, address)
                    : null,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddressFormScreen(existing: address),
                  ),
                ),
                onDelete: () => _confirmDelete(context, address.id),
                onSetDefault: () => provider.setDefaultAddress(address.id),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddressFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text("Add Address"),
      ),
    );
  }
}