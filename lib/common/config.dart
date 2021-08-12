import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../common/tools.dart';
import '../generated/l10n.dart';
import '../services/services.dart';
import 'config/configuration_utils.dart';
import 'config/models/index.dart';

part 'config/advertise.dart';
part 'config/blogs.dart';
part 'config/configurations.dart';
part 'config/data_mapping.dart';
part 'config/default_env.dart';
part 'config/dynamic_link.dart';
part 'config/general.dart';
part 'config/languages.dart';
part 'config/loading.dart';
part 'config/onboarding.dart';
part 'config/payments.dart';
part 'config/products.dart';
part 'config/smartchat.dart';
part 'config/vendor.dart';

// Map get serverConfig => Configurations.serverConfig;

// export 'config/index.dart';

const serverConfig = {
  'type': 'wcfm',
  'url': 'https://woocommerce.zeffry.dev',
  'consumerKey': 'ck_f1ff7591d809d6dd00daf28a5021e74eb15097d4',
  'consumerSecret': 'cs_5ffbdc716896b616929a1c9686c54be7993f42db',
  'blog': 'https://woocommerce.zeffry.dev',

  /// remove to use as native screen
  'forgetPassword': 'https://woocommerce.zeffry.dev/wp-login.php?action=lostpassword'
};
