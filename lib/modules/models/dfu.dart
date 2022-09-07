class DFU {
  String? name;
  String? id;
  int? rssi;
  DFU({this.name, this.id, required this.rssi});
  @override
  String toString() {
    return '{name: ${name}, id: ${id}, rssi: ${rssi}}';
  }
}
