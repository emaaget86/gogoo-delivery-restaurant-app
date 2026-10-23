import 'package:stackfood_multivendor_restaurant/util/dimensions.dart';
import 'package:stackfood_multivendor_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subTitle;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? menuWidget;
  final double? elevation;
  final Widget? titleSuffix;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final SystemUiOverlayStyle? systemOverlayStyle;
  const CustomAppBarWidget({super.key, required this.title, this.onBackPressed, this.isBackButtonExist = true, this.menuWidget, this.subTitle, this.elevation, this.titleSuffix, this.backgroundColor, this.foregroundColor, this.systemOverlayStyle});

  @override
  Widget build(BuildContext context) {
    final Color barColor = backgroundColor ?? Theme.of(context).cardColor;
    final Color contentColor = foregroundColor ?? Theme.of(context).textTheme.bodyLarge!.color!;

    return AppBar(
      systemOverlayStyle: systemOverlayStyle,
      iconTheme: IconThemeData(color: contentColor),
      actionsIconTheme: IconThemeData(color: contentColor),
      title: Column(
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(
              title!, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: contentColor),
            )),
            titleSuffix != null ? Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              child: titleSuffix!,
            ) : const SizedBox(),
          ]),
          subTitle != null ? Text(subTitle!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)) : const SizedBox(),
        ],
      ),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: contentColor,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : const SizedBox(),
      backgroundColor: barColor,
      surfaceTintColor: barColor,
      shadowColor: Theme.of(context).hintColor.withValues(alpha: 0.5),
      elevation: elevation ?? 2,
      scrolledUnderElevation: elevation ?? 2,
      actions: menuWidget != null ? [menuWidget!, const SizedBox(width: 10)] : null,
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? 70 : 50);
}