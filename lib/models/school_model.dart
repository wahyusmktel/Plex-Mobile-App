class SchoolModel {
  final String id;
  final String namaSekolah;
  final String npsn;
  final String jenjang;
  final String? alamat;
  final String? desaKelurahan;
  final String? kecamatan;
  final String? kabupatenKota;
  final String? provinsi;
  final String statusSekolah; // Negeri/Swasta
  final String status; // pending/approved/rejected
  final bool isActive;
  final DateTime? createdAt;
  final List<SchoolAdminModel>? admins;

  SchoolModel({
    required this.id,
    required this.namaSekolah,
    required this.npsn,
    required this.jenjang,
    this.alamat,
    this.desaKelurahan,
    this.kecamatan,
    this.kabupatenKota,
    this.provinsi,
    required this.statusSekolah,
    required this.status,
    required this.isActive,
    this.createdAt,
    this.admins,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id']?.toString() ?? '',
      namaSekolah: json['nama_sekolah']?.toString() ?? '',
      npsn: json['npsn']?.toString() ?? '',
      jenjang: json['jenjang']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
      desaKelurahan: json['desa_kelurahan']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      kabupatenKota: json['kabupaten_kota']?.toString(),
      provinsi: json['provinsi']?.toString(),
      statusSekolah: json['status_sekolah']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      admins: json['users'] != null
          ? (json['users'] as List)
                .map((u) => SchoolAdminModel.fromJson(u))
                .toList()
          : null,
    );
  }
}

class SchoolAdminModel {
  final String id;
  final String name;
  final String? email;
  final String username;

  SchoolAdminModel({
    required this.id,
    required this.name,
    this.email,
    required this.username,
  });

  factory SchoolAdminModel.fromJson(Map<String, dynamic> json) {
    return SchoolAdminModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      username: json['username']?.toString() ?? '',
    );
  }
}
