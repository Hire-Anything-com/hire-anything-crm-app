import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppIcons {
  AppIcons._();

  static Widget icon(IconData data, {Color? color, double size = 24.0}) {
    return HugeIcon(icon: data, color: color ?? Colors.black, size: size);
  }

  // Navigation
  static const home = HugeIcons.strokeRoundedHome01;
  static const search = HugeIcons.strokeRoundedSearch01;
  static const settings = HugeIcons.strokeRoundedSettings01;
  static const notification = HugeIcons.strokeRoundedNotification02;
  static const profile = HugeIcons.strokeRoundedUser;

  // Actions
  static const add = HugeIcons.strokeRoundedAdd01;
  static const edit = HugeIcons.strokeRoundedEdit01;
  static const delete = HugeIcons.strokeRoundedDelete02;
  static const close = HugeIcons.strokeRoundedCancel01;
  static const back = HugeIcons.strokeRoundedArrowLeft01;
  static const forward = HugeIcons.strokeRoundedArrowRight01;
  static const filter = HugeIcons.strokeRoundedFilter;
  static const sort = HugeIcons.strokeRoundedSorting01;

  // Booking
  static const calendar = HugeIcons.strokeRoundedCalendar01;
  static const clock = HugeIcons.strokeRoundedClock01;
  static const location = HugeIcons.strokeRoundedLocation01;
  static const bookmark = HugeIcons.strokeRoundedBookmark01;

  // Communication
  static const chat = HugeIcons.strokeRoundedMessage01;
  static const call = HugeIcons.strokeRoundedCall;
  static const mail = HugeIcons.strokeRoundedMail01;

  // Auth
  static const lock = HugeIcons.strokeRoundedLockPassword;
  static const eyeOpen = HugeIcons.strokeRoundedView;
  static const eyeClosed = HugeIcons.strokeRoundedViewOff;

  // Dashboard
  static const task = HugeIcons.strokeRoundedTask01;
  static const leave = HugeIcons.strokeRoundedCalendar02;
  static const history = HugeIcons.strokeRoundedClock02;

  // Misc
  static const star = HugeIcons.strokeRoundedStar;
  static const heart = HugeIcons.strokeRoundedFavourite;
  static const share = HugeIcons.strokeRoundedShare01;
  static const camera = HugeIcons.strokeRoundedCamera01;
  static const image = HugeIcons.strokeRoundedImage01;
}
