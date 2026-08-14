import 'package:flutter/material.dart';
import '../core/services/address_service.dart';
import '../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final _addressService = AddressService();

  List<AddressModel> addresses = [];
  bool isLoading = false;
  String? errorMessage;

  AddressModel? get defaultAddress =>
      addresses.where((a) => a.isDefault).cast<AddressModel?>().firstOrNull;

  Future<void> fetchAddresses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      addresses = await _addressService.list();
    } catch (_) {
      errorMessage = "Failed to load addresses";
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addAddress(AddressModel address) async {
    try {
      await _addressService.create(address);
      await fetchAddresses();
      return true;
    } catch (_) {
      errorMessage = "Failed to save address";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(int id, AddressModel address) async {
    try {
      await _addressService.update(id, address);
      await fetchAddresses();
      return true;
    } catch (_) {
      errorMessage = "Failed to update address";
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _addressService.delete(id);
      await fetchAddresses();
    } catch (_) {
      errorMessage = "Failed to delete address";
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(int id) async {
    try {
      await _addressService.setDefault(id);
      await fetchAddresses();
    } catch (_) {
      errorMessage = "Failed to set default address";
      notifyListeners();
    }
  }
}