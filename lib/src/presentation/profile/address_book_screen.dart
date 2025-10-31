import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user.dart';
import '../../core/services/shipping_events.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final _api = ApiService();
  final _auth = AuthService();
  User? _user;
  bool _loading = true;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = await _auth.getCurrentUser();
    if (current == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    setState(() { _user = current; });
    final data = await _api.getUserProfile(userId: current.userId);
    if (data != null) {
      final list = (data['addresses'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
      setState(() { _addresses = list; });
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _setDefault(int id) async {
    if (_user == null) return;
    final ok = await _api.setDefaultAddress(userId: _user!.userId, addressId: id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Đã đặt địa chỉ mặc định' : 'Cập nhật thất bại'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
    if (ok) {
      _load();
      // thông báo trang thanh toán tính lại phí ship
      try { ShippingEvents.refresh(); } catch (_) {}
    }
  }

  Future<void> _showEditAddressDialog(Map<String, dynamic> address) async {
    print('🔧 _showEditAddressDialog called for address: ${address['ho_ten']}');
    final dynamic rawId = address['id'];
    final int addressId = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) ?? 0 : (rawId as num).toInt());
    
    if (addressId <= 0) {
      print('❌ Invalid address ID: $addressId');
      return;
    }

    final nameCtrl = TextEditingController(text: address['ho_ten']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: address['dien_thoai']?.toString() ?? '');
    final addressCtrl = TextEditingController(text: address['dia_chi']?.toString() ?? '');
    
    // State cho dropdown
    int? selectedProvinceId;
    int? selectedDistrictId;
    int? selectedWardId;
    String? selectedProvinceName;
    String? selectedDistrictName;
    String? selectedWardName;
    
    // Load dữ liệu dropdown
    final provinces = await _api.getProvinces() ?? [];
    final provinceName = address['ten_tinh']?.toString() ?? '';
    final districtName = address['ten_huyen']?.toString() ?? '';
    final wardName = address['ten_xa']?.toString() ?? '';
    
    // Tìm ID từ tên
    selectedProvinceName = provinceName;
    final province = provinces.firstWhere((p) => p['name'] == provinceName, orElse: () => {});
    selectedProvinceId = province['id'];
    
    if (selectedProvinceId != null) {
      final districts = await _api.getDistricts(provinceId: selectedProvinceId) ?? [];
      selectedDistrictName = districtName;
      final district = districts.firstWhere((d) => d['name'] == districtName, orElse: () => {});
      selectedDistrictId = district['id'];
      
      if (selectedDistrictId != null) {
        final wards = await _api.getWards(provinceId: selectedProvinceId, districtId: selectedDistrictId) ?? [];
        selectedWardName = wardName;
        final ward = wards.firstWhere((w) => w['name'] == wardName, orElse: () => {});
        selectedWardId = ward['id'];
      }
    }

    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSB) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sửa địa chỉ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _field('Họ và tên', nameCtrl),
                  const SizedBox(height: 8),
                  _field('Điện thoại', phoneCtrl, keyboard: TextInputType.phone),
                  const SizedBox(height: 8),
                  _field('Địa chỉ chi tiết', addressCtrl, maxLines: 2),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Map<String, dynamic>>?>(
                    future: _api.getProvinces(),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? [];
                      return DropdownButtonFormField<int>(
                        initialValue: selectedProvinceId,
                        decoration: _dd('Tỉnh/Thành phố'),
                        items: items.map((p) => DropdownMenuItem<int>(value: p['id'] as int, child: Text(p['name'] as String))).toList(),
                        onChanged: (v) async {
                          setSB(() {
                            selectedProvinceId = v;
                            selectedProvinceName = items.firstWhere((e)=>e['id']==v)['name'];
                            selectedDistrictId = null;
                            selectedDistrictName = null;
                            selectedWardId = null;
                            selectedWardName = null;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (selectedProvinceId != null)
                    FutureBuilder<List<Map<String, dynamic>>?>(
                      future: _api.getDistricts(provinceId: selectedProvinceId!),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          initialValue: selectedDistrictId,
                          decoration: _dd('Quận/Huyện'),
                          items: items.map((d) => DropdownMenuItem<int>(value: d['id'] as int, child: Text(d['name'] as String))).toList(),
                          onChanged: (v) async {
                            setSB(() {
                              selectedDistrictId = v;
                              selectedDistrictName = items.firstWhere((e)=>e['id']==v)['name'];
                              selectedWardId = null;
                              selectedWardName = null;
                            });
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  if (selectedDistrictId != null)
                    FutureBuilder<List<Map<String, dynamic>>?>(
                      future: _api.getWards(provinceId: selectedProvinceId!, districtId: selectedDistrictId!),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          initialValue: selectedWardId,
                          decoration: _dd('Phường/Xã'),
                          items: items.map((w) => DropdownMenuItem<int>(value: w['id'] as int, child: Text(w['name'] as String))).toList(),
                          onChanged: (v) {
                            setSB(() {
                              selectedWardId = v;
                              selectedWardName = items.firstWhere((e)=>e['id']==v)['name'];
                            });
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_user == null) return;
                          if (selectedProvinceId == null || selectedDistrictId == null || selectedWardId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn đủ Tỉnh/TP - Quận/Huyện - Phường/Xã')));
                            return;
                          }
                          final ok = await _api.updateAddress(
                            userId: _user!.userId,
                            addressId: addressId,
                            hoTen: nameCtrl.text.trim(),
                            dienThoai: phoneCtrl.text.trim(),
                            diaChi: addressCtrl.text.trim(),
                            tenTinh: selectedProvinceName ?? '',
                            tenHuyen: selectedDistrictName ?? '',
                            tenXa: selectedWardName ?? '',
                            tinh: selectedProvinceId ?? 0,
                            huyen: selectedDistrictId ?? 0,
                            xa: selectedWardId ?? 0,
                          );
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Đã cập nhật địa chỉ' : 'Cập nhật địa chỉ thất bại'),
                            backgroundColor: ok ? Colors.green : Colors.red,
                          ));
                          if (ok) {
                            _load();
                            try { ShippingEvents.refresh(); } catch (_) {}
                          }
                        },
                        child: const Text('Lưu'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(Map<String, dynamic> address) async {
    print('🗑️ _showDeleteConfirmDialog called for address: ${address['ho_ten']}');
    final dynamic rawId = address['id'];
    final int addressId = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) ?? 0 : (rawId as num).toInt());
    
    if (addressId <= 0) {
      print('❌ Invalid address ID: $addressId');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon hoặc tiêu đề
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 24,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              // Tiêu đề
              const Text(
                'Xác nhận xóa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Nội dung
              Text(
                'Bạn có chắc muốn xóa địa chỉ "${address['ho_ten']?.toString() ?? ''}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Nút hành động
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.black.withOpacity(0.2)),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.black,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && _user != null) {
      final ok = await _api.deleteAddress(
        userId: _user!.userId,
        addressId: addressId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Đã xóa địa chỉ' : 'Xóa địa chỉ thất bại'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
      if (ok) {
        _load();
        try { ShippingEvents.refresh(); } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ địa chỉ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final a = _addresses[index];
                final isDefault = (a['active']?.toString() ?? '0') == '1';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header với tên và nút mặc định
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a['ho_ten']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a['dien_thoai']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'Mặc định',
                                  style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                                ),
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  final dynamic rawId = a['id'];
                                  final int id = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) ?? 0 : (rawId as num).toInt());
                                  if (id > 0) _setDefault(id);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Đặt mặc định',
                                  style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Địa chỉ chi tiết
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a['dia_chi']?.toString() ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${a['ten_xa'] ?? ''}, ${a['ten_huyen'] ?? ''}, ${a['ten_tinh'] ?? ''}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Nút hành động
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async => await _showEditAddressDialog(a),
                              icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                              label: const Text('Sửa', style: TextStyle(color: Colors.blue, fontSize: 14)),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: isDefault ? null : () async => await _showDeleteConfirmDialog(a),
                              icon: Icon(Icons.delete, size: 16, color: isDefault ? Colors.grey : Colors.red),
                              label: Text(
                                'Xóa', 
                                style: TextStyle(
                                  color: isDefault ? Colors.grey : Colors.red, 
                                  fontSize: 14
                                )
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemCount: _addresses.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAddressDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool setDefault = false;
    int? selectedProvinceId;
    int? selectedDistrictId;
    int? selectedWardId;
    String? selectedProvinceName;
    String? selectedDistrictName;
    String? selectedWardName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSB) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Thêm địa chỉ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _field('Họ và tên', nameCtrl),
                    const SizedBox(height: 8),
                    _field('Điện thoại', phoneCtrl, keyboard: TextInputType.phone),
                    const SizedBox(height: 8),
                    _field('Địa chỉ (số nhà, đường)', addressCtrl, maxLines: 2),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Map<String, dynamic>>?>(
                      future: _api.getProvinces(limit: 200),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          initialValue: selectedProvinceId,
                          decoration: _dd('Tỉnh/Thành phố'),
                          items: items
                              .map((p) => DropdownMenuItem<int>(value: p['id'] as int, child: Text(p['name'] as String)))
                              .toList(),
                          onChanged: (v) {
                            setSB(() {
                              selectedProvinceId = v;
                              selectedDistrictId = null;
                              selectedWardId = null;
                              selectedProvinceName = items.firstWhere((e) => e['id'] == v)['name'];
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    if (selectedProvinceId != null)
                      FutureBuilder<List<Map<String, dynamic>>?>(
                        future: _api.getDistricts(provinceId: selectedProvinceId!),
                        builder: (context, snapshot) {
                          final items = snapshot.data ?? [];
                          return DropdownButtonFormField<int>(
                            initialValue: selectedDistrictId,
                            decoration: _dd('Quận/Huyện'),
                            items: items
                                .map((d) => DropdownMenuItem<int>(value: d['id'] as int, child: Text(d['name'] as String)))
                                .toList(),
                            onChanged: (v) {
                              setSB(() {
                                selectedDistrictId = v;
                                selectedWardId = null;
                                selectedDistrictName = items.firstWhere((e) => e['id'] == v)['name'];
                              });
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 8),
                    if (selectedProvinceId != null && selectedDistrictId != null)
                      FutureBuilder<List<Map<String, dynamic>>?>(
                        future: _api.getWards(provinceId: selectedProvinceId!, districtId: selectedDistrictId!),
                        builder: (context, snapshot) {
                          final items = snapshot.data ?? [];
                          return DropdownButtonFormField<int>(
                            initialValue: selectedWardId,
                            decoration: _dd('Phường/Xã'),
                            items: items
                                .map((w) => DropdownMenuItem<int>(value: w['id'] as int, child: Text(w['name'] as String)))
                                .toList(),
                            onChanged: (v) {
                              setSB(() {
                                selectedWardId = v;
                                selectedWardName = items.firstWhere((e) => e['id'] == v)['name'];
                              });
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: setDefault,
                          onChanged: (v) {
                            setSB(() {
                              setDefault = v ?? false;
                            });
                          },
                        ),
                        const Text('Đặt làm mặc định'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (_user == null) return;
                            if (selectedProvinceId == null || selectedDistrictId == null || selectedWardId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng chọn đủ Tỉnh/TP - Quận/Huyện - Phường/Xã')),
                              );
                              return;
                            }
                            final ok = await _api.addAddress(
                              userId: _user!.userId,
                              hoTen: nameCtrl.text.trim(),
                              dienThoai: phoneCtrl.text.trim(),
                              diaChi: addressCtrl.text.trim(),
                              tenXa: selectedWardName ?? '',
                              tenHuyen: selectedDistrictName ?? '',
                              tenTinh: selectedProvinceName ?? '',
                              tinh: selectedProvinceId ?? 0,
                              huyen: selectedDistrictId ?? 0,
                              xa: selectedWardId ?? 0,
                              isDefault: setDefault,
                            );
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? 'Đã thêm địa chỉ' : 'Thêm địa chỉ thất bại'),
                                backgroundColor: ok ? Colors.green : Colors.red,
                              ),
                            );
                            if (ok) {
                              _load();
                              try {
                                ShippingEvents.refresh();
                              } catch (_) {}
                            }
                          },
                          child: const Text('Lưu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _field(String label, TextEditingController c, {TextInputType? keyboard, int maxLines = 1}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1890FF)),
        ),
      ),
    );
  }

  InputDecoration _dd(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1890FF)),
      ),
    );
  }
}


