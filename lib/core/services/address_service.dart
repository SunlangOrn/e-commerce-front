import '../constants/api_constants.dart';
import '../../models/address_model.dart';
import 'api_client.dart';

class AddressService {
  final _dio = ApiClient.instance.dio;

  Future<List<AddressModel>> list() async {
    final res = await _dio.get(ApiConstants.addresses);
    // Backend returns a Spring Page — items are under data.content
    final data = res.data["data"];
    final content = (data is Map && data["content"] != null)
        ? data["content"] as List<dynamic>
        : (data as List<dynamic>);
    return content.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> getById(int id) async {
    final res = await _dio.get(ApiConstants.addressById(id));
    return AddressModel.fromJson(res.data["data"]);
  }

  Future<AddressModel> create(AddressModel address) async {
    final res = await _dio.post(ApiConstants.addresses, data: address.toRequestJson());
    return AddressModel.fromJson(res.data["data"]);
  }

  Future<AddressModel> update(int id, AddressModel address) async {
    final res = await _dio.put(ApiConstants.addressById(id), data: address.toRequestJson());
    return AddressModel.fromJson(res.data["data"]);
  }

  Future<void> delete(int id) async {
    await _dio.delete(ApiConstants.addressById(id));
  }

  Future<AddressModel> setDefault(int id) async {
    final res = await _dio.patch(ApiConstants.addressSetDefault(id));
    return AddressModel.fromJson(res.data["data"]);
  }
}