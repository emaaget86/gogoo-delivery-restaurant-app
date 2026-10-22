import 'package:flutter/material.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor_restaurant/util/dimensions.dart';
import 'package:stackfood_multivendor_restaurant/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String imageData;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  const BottomNavItemWidget({super.key, required this.imageData, required this.label, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isSelected ? Theme.of(context).primaryColor : Colors.grey;

    return Expanded(
      child: CustomInkWellWidget(
        onTap: onTap,
        radius: Dimensions.radiusDefault,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageData, color: itemColor, height: 22, width: 22),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: itemColor),
            ),
          ],
        ),
      ),
    );
  }
}