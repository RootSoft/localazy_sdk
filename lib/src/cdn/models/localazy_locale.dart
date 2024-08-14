class LocalazyLocale {
  final String language;
  final String region;
  final String name;
  final String localizedName;
  final String uri;
  final String timestamp;

  LocalazyLocale(
    this.language,
    this.region,
    this.name,
    this.localizedName,
    this.uri,
    this.timestamp,
  );

  factory LocalazyLocale.fromJSON(Map<String, dynamic> data) {
    return LocalazyLocale(
      data['language'],
      data['region'],
      data['name'],
      data['localizedName'],
      data['uri'],
      data['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'region': region,
      'name': name,
      'localizedName': localizedName,
      'uri': uri,
      'timestamp': timestamp,
    };
  }
}
