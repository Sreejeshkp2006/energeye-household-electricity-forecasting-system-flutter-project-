import 'dart:math';

class EnergyTip {
  final String title;
  final String description;
  final String category;

  EnergyTip({
    required this.title,
    required this.description,
    required this.category,
  });
}

class EnergyTipsService {
  static final List<EnergyTip> _tips = [
    EnergyTip(
      title: "Use LED Bulbs",
      description: "Switch to LED bulbs which use 75% less energy and last 25 times longer than incandescent lighting.",
      category: "Lighting",
    ),
    EnergyTip(
      title: "Unplug Idle Electronics",
      description: "Devices like chargers and TVs use 'vampire power' even when off. Unplug them when not in use.",
      category: "Appliances",
    ),
    EnergyTip(
      title: "Clean Fridge Coils",
      description: "Dusty coils make your fridge work harder. Clean them twice a year to improve efficiency.",
      category: "Appliances",
    ),
    EnergyTip(
      title: "Use Natural Light",
      description: "Open curtains during the day to use sunlight instead of electric lights.",
      category: "Lighting",
    ),
    EnergyTip(
      title: "Shorten Showers",
      description: "Reducing shower time by just 2 minutes can save a significant amount of water heating energy.",
      category: "Water Heating",
    ),
    EnergyTip(
      title: "Air Dry Dishes",
      description: "Disable the heat-dry setting on your dishwasher and let dishes air dry to save energy.",
      category: "Appliances",
    ),
  ];

  // Cache for random instance to avoid recreation
  static final Random _random = Random();

  static List<EnergyTip> getAllTips() => List.unmodifiable(_tips);

  static EnergyTip getRandomTip() {
    // Use random index instead of shuffle() to avoid list manipulation overhead
    final randomIndex = _random.nextInt(_tips.length);
    return _tips[randomIndex];
  }
}
