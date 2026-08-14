import 'package:flutter/material.dart';
import '../models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    this.selected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          address.latitude != null ? Icons.location_on : Icons.location_off,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(address.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (address.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text("Default",
                    style: TextStyle(fontSize: 11, color: Colors.green)),
              ),
          ],
        ),
        subtitle: Text(
          "${address.phone}\n${address.addressLine}, ${address.city}",
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") onEdit?.call();
            if (value == "delete") onDelete?.call();
            if (value == "default") onSetDefault?.call();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            if (!address.isDefault)
              const PopupMenuItem(value: "default", child: Text("Set as default")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        ),
      ),
    );
  }
}

extension on MaterialColor {
  withValues({required double alpha}) {}
}