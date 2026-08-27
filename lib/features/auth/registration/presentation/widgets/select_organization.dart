// import 'package:colloborator_v3/core/constants/app_icons.dart';
// import 'package:colloborator_v3/core/theme/app_theme.dart';
// import 'package:colloborator_v3/core/theme/screen_size.dart';
// import 'package:colloborator_v3/features/auth/registration/domain/entities/organization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gap/gap.dart';

// class DropDown extends StatelessWidget {
//   const DropDown({super.key, required this.items, required this.selectItems, required this.onChanged, this.showSearch, this.color, this.hintText, this.title, this.radius, this.showStar = true, this.titleStyle});

//   final Function onChanged;
//   final List<Organization> items;
//   final Organization? selectItems;
//   final bool? showSearch;
//   final Color? color;
//   final String? hintText;
//   final String? title;
//   final double? radius;
//   final bool showStar;
//   final TextStyle? titleStyle;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Visibility(
//           visible: title != null,
//           child: Row(
//             children: [
//               if(showStar)...[SvgPicture.asset(AppIcons.star, height: ScreenSize.h10, colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),),
//               Gap(ScreenSize.w5)],
//               Text(title ?? "", style: titleStyle ?? AppTheme.data.textTheme.headlineLarge!.copyWith(color: AppTheme.colors.black)),
//             ],
//           ),
//         ),
//         Gap(title != null ? ScreenSize.w5 : 0),
//         DropdownSearch<Universal>(
//           items: items,
//           filterFn: (item, query) {
//             if (query.isEmpty) return true;
//             final title = item.title.toLowerCase();
//             final q = query.toLowerCase();
//             return title.contains(q) || Helper.cyrillicToLatin(title).contains(Helper.cyrillicToLatin(q)) || Helper.latinToCyrillic(title).contains(Helper.latinToCyrillic(q));
//           },
//           onChanged: (Universal? newValue) => newValue != null ? onChanged(newValue) : {},
//           selectedItem: selectItems,
//           dropdownDecoratorProps: DropDownDecoratorProps(
//             textAlign: TextAlign.center,
//             dropdownSearchDecoration: InputDecoration(
//               filled: true,
//               fillColor: color ?? AppTheme.colors.white,
//               contentPadding: EdgeInsets.symmetric(horizontal: ScreenSize.h5),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius ?? ScreenSize.r25), borderSide: BorderSide(color: AppTheme.colors.primary)),
//               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius ?? ScreenSize.r25), borderSide: BorderSide(color: AppTheme.colors.stroke)),
//               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius ?? ScreenSize.r25), borderSide: BorderSide(color: AppTheme.colors.primary)),
//             ),
//           ),
//           popupProps: PopupProps.menu(
//             showSearchBox: showSearch ?? false,
//             menuProps: MenuProps(backgroundColor: Colors.transparent),
//             searchFieldProps: TextFieldProps(
//               cursorColor: AppTheme.colors.primary,
//               style: AppTheme.data.textTheme.headlineSmall!.copyWith(color: AppTheme.colors.black),
//               decoration: InputDecoration(
//                 contentPadding: EdgeInsets.only(left: ScreenSize.h6),
//                 hintText: hintText ?? "",
//                 hintStyle: AppTheme.data.textTheme.headlineSmall,
//                 suffixIcon: Padding(padding: EdgeInsets.all(ScreenSize.h10), child: SvgPicture.asset(AppIcons.search)),
//                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius ?? ScreenSize.r25), borderSide: BorderSide(color: AppTheme.colors.stroke)),
//                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius ?? ScreenSize.r25), borderSide: BorderSide(color: AppTheme.colors.stroke)),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//               ),
//             ),
//             containerBuilder: (context, popupWidget) => Container(
//               height: ScreenSize.h200 + ScreenSize.h50,
//               width: double.infinity,
//               margin: EdgeInsets.only(top: ScreenSize.h5),
//               padding: EdgeInsets.only(top: ScreenSize.h10),
//               decoration: BoxDecoration(
//                 color: AppTheme.colors.white,
//                 border: Border.all(color: AppTheme.colors.primary),
//                 borderRadius: BorderRadius.circular(radius ?? ScreenSize.r20),
//                 boxShadow: ContainerShadow.universaShadow(),
//               ),
//               child: popupWidget,
//             ),
//             itemBuilder: (context, item, isSelected) => Container(
//               height: ScreenSize.h40,
//               width: double.infinity,
//               padding: EdgeInsets.only(left: ScreenSize.h5),
//               margin: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h3),
//               alignment: Alignment.centerLeft,
//               decoration: BoxDecoration(
//                 color: item.id == selectItems.id ? AppTheme.colors.primary.withValues(alpha: .18) : null,
//                 borderRadius: BorderRadius.circular(radius ?? ScreenSize.r10),
//                 border: Border.all(color: AppTheme.colors.lineColor),
//               ),
//               child: Text(item.title, maxLines: 1, style: AppTheme.data.textTheme.headlineSmall!.copyWith(color: AppTheme.colors.black)),
//             ),
//           ),
//           dropdownBuilder: (context, selectedItem) => Container(
//             height: ScreenSize.h30,
//             width: double.maxFinite,
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.only(left: ScreenSize.w5, top: ScreenSize.h2),
//             child: Text(
//               selectedItem != null ? selectedItem.id != 0 ? selectedItem.title : hintText ?? "-" : hintText ?? "-",
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: selectedItem != null ? selectedItem.id != 0 ? AppTheme.data.textTheme.titleSmall!.copyWith(color: AppTheme.colors.black) : AppTheme.data.textTheme.titleSmall!.copyWith(color: AppTheme.colors.grey) : AppTheme.data.textTheme.titleSmall!.copyWith(color: AppTheme.colors.grey),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }