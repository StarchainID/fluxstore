import '../common/config.dart';
import '../common/constants.dart';
import '../frameworks/vendor/index.dart';
import '../frameworks/vendor/services/vendor_service_mixin.dart';
import '../frameworks/woocommerce/services/woo_mixin.dart';
import '../frameworks/wordpress/services/wordpress_mixin.dart';
import '../modules/advertisement/services/ads_service_mixin.dart';
import '../modules/firebase/firebase_notification_service.dart';
import '../modules/firebase/firebase_service.dart';
import '../modules/onesignal/one_signal_notification_service.dart';
import 'notification/notification_service.dart';
import 'notification/notification_service_impl.dart';
import 'service_config.dart';

class Services
    with
        ConfigMixin,
        WooMixin,
        VendorMixin,
        ServiceVendorMixin,
        WordPressMixin,
        AdsServiceMixin {
  static final Services _instance = Services._internal();

  factory Services() => _instance;

  Services._internal();

  /// using BaseFirebaseServices when disable the Firebase
  // final firebase = BaseFirebaseServices();
  final firebase = FirebaseServices();

  /// Get notification Service
  static NotificationService getNotificationService() {
    NotificationService notificationService = NotificationServiceImpl();
    if (isIos || isAndroid) {
      if (kOneSignalKey['enable'] ?? false) {
        notificationService =
            OneSignalNotificationService(appID: kOneSignalKey['appID']);
      } else {
        notificationService = FirebaseNotificationService();
      }
    }
    return notificationService;
  }
}
