import 'package:flutter/material.dart';
import '../models/device_model.dart';

class DeviceTile extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onDelete;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.teal.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// DEVICE DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.history_toggle_off_rounded, size: 12, color: Colors.teal.shade200),
                    const SizedBox(width: 4),
                    Text(
                      "${device.quantity} × ${device.hours}h • ${device.dailyUnit.toStringAsFixed(1)} units",
                      style: TextStyle(
                        color: Colors.blueGrey.shade300,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// COST AND DELETE ACTION
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "₹${device.dailyCost.toStringAsFixed(1)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onDelete,
                child: Text(
                  "Remove",
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
