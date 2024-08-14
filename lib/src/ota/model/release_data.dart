class ReleaseData {
  final int version;
  final Map<String, dynamic> data;

  ReleaseData({required this.version, required this.data});

  ReleaseData.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        data = json['data'];

  Map<String, dynamic> toJson() => {'version': version, 'data': data};
}
