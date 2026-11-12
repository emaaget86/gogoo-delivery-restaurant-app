import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor_restaurant/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor_restaurant/theme/light_theme.dart';
import 'package:stackfood_multivendor_restaurant/util/dimensions.dart';
import 'package:stackfood_multivendor_restaurant/util/images.dart';
import 'package:stackfood_multivendor_restaurant/util/styles.dart';

class RestaurantAvailabilityToggle extends StatelessWidget {
  const RestaurantAvailabilityToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        final restaurants = profileController.profileModel?.restaurants;
        if (restaurants == null || restaurants.isEmpty) {
          return const SizedBox();
        }
        final bool isOpen = restaurants.first.active == true;
        final bool loading = authController.restaurantStatusLoading;
        final Color statusColor = isOpen ? primaryTeal : const Color(0xFF9E9E9E);

        return Row(children: [
          Flexible(
            child: Text(
              isOpen ? 'available'.tr : 'unavailable'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: statusColor),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          loading ? const SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal),
          ) : SizedBox(
            width: 46, height: 28,
            child: FittedBox(
              child: CupertinoSwitch(
                value: isOpen,
                activeTrackColor: primaryTeal,
                inactiveTrackColor: const Color(0xFFBDBDBD),
                onChanged: (bool isActive) => confirmRestaurantAvailabilityChange(isActive),
              ),
            ),
          ),
        ]);
      });
    });
  }
}

void confirmRestaurantAvailabilityChange(bool isActive) {
  final profileController = Get.find<ProfileController>();
  if (profileController.modulePermission?.restaurantConfig != true) {
    showCustomSnackBar('you_have_no_permission_to_access_this_feature'.tr);
    return;
  }
  if (Get.find<AuthController>().restaurantStatusLoading) {
    return;
  }
  Get.dialog(ConfirmationDialogWidget(
    icon: Images.warning,
    description: isActive ? 'are_you_sure_to_open_restaurant'.tr : 'are_you_sure_to_close_restaurant'.tr,
    onYesPressed: () {
      Get.back();
      Get.find<AuthController>().toggleRestaurantClosedStatus();
    },
  ));
}
