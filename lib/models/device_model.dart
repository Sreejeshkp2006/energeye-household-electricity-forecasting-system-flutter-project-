class DeviceModel {
  final String id; // 🔹 NEW (Firestore doc ID)
  final String name;
  final double watt;
  final double hours;
  final double rate;
  final double dailyUnit;
  final double dailyCost;

  DeviceModel({
    required this.id,
    required this.name,
    required this.watt,
    required this.hours,
    required this.rate,
    required this.dailyUnit,
    required this.dailyCost,
  });

  // 🔹 EXISTING FUNCTION (unchanged logic)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'watt': watt,
      'hours': hours,
      'rate': rate,
      'dailyUnit': dailyUnit,
      'dailyCost': dailyCost,
      'createdAt': DateTime.now(),
    };
  }

  // 🔹 NEW (for Firestore read)
  factory DeviceModel.fromFirestore(String id, Map<String, dynamic> map) {
    return DeviceModel(
      id: id,
      name: map['name'],
      watt: (map['watt'] as num).toDouble(),
      hours: (map['hours'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      dailyUnit: (map['dailyUnit'] as num).toDouble(),
      dailyCost: (map['dailyCost'] as num).toDouble(),
    );
  }
}
