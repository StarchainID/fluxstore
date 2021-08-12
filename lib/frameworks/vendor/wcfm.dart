import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product, Store;
import '../../widgets/common/webview.dart';
import '../woocommerce/index.dart';
import 'vendor_mixin.dart';

class WCFMWidget extends WooWidget with VendorMixin {
  @override
  Product updateProductObject(Product product, Map? json) {
    if (json!['store'] != null && json['store']['vendor_id'] != null) {
      product.store = Store.fromWCFMJson(json['store']);
    }
    return product;
  }

  @override
  Widget getAdminVendorScreen(context, dynamic user) {
    var base64Str = EncodeUtils.encodeCookie(user.cookie);
    var vendorURL =
        '${serverConfig['url']}/${kVendorConfig['wcfm']}&cookie=$base64Str';
    return WebView(url: vendorURL, title: S.of(context).vendorAdmin);
  }

  @override
  Widget getDeliveryScreen(context, dynamic user) {
    return Container();
  }
}
