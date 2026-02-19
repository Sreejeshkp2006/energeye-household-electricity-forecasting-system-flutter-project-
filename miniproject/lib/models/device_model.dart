class DeviceModel {
  final String id;
  final String name;
  final double watt;
  final double hours;
  final double rate;
  final int quantity;
  final double dailyUnit;
  final double dailyCost;
  final int month; // 🔥 NEW

  DeviceModel({
    required this.id,
    required this.name,
    required this.watt,
    required this.hours,
    required this.rate,
    required this.quantity,
    required this.dailyUnit,
    required this.dailyCost,
    required this.month, // 🔥 ADD HERE
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'watt': watt,
      'hours': hours,
      'rate': rate,
      'quantity': quantity,
      'dailyUnit': dailyUnit,
      'dailyCost': dailyCost,
      'month': month, // 🔥 SAVE MONTH
      'createdAt': DateTime.now(),
    };
  }

  factory DeviceModel.fromFirestore(
    String id,
    Map<String, dynamic> map,
  ) {
    return DeviceModel(
      id: id,
      name: map['name'] ?? '',
      watt: map['watt'] != null ? (map['watt'] as num).toDouble() : 0.0,
      hours: map['hours'] != null ? (map['hours'] as num).toDouble() : 0.0,
      rate: map['rate'] != null ? (map['rate'] as num).toDouble() : 0.0,
      quantity: map['quantity'] != null ? (map['quantity'] as num).toInt() : 1,
      dailyUnit:
          map['dailyUnit'] != null ? (map['dailyUnit'] as num).toDouble() : 0.0,
      dailyCost:
          map['dailyCost'] != null ? (map['dailyCost'] as num).toDouble() : 0.0,
      month: map['month'] != null
          ? (map['month'] as num).toInt()
          : 1, // 🔥 SAFE DEFAULT
    );
  }
}
