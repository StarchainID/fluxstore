import '../../common/constants.dart';
import '../entities/delivery_user.dart';
import '../serializers/product.dart';

class ProductItem {
  String? id;
  String? productId;
  String? name;
  int? quantity;
  String? total;
  String? featuredImage;
  String? addonsOptions;
  List<String?> attributes = [];
  DeliveryUser? deliveryUser;

  ProductItem.fromJson(Map<String, dynamic> parsedJson) {
    try {
      productId = parsedJson['product_id'].toString();
      name = parsedJson['name'];
      quantity = int.parse("${parsedJson["quantity"]}");
      total = parsedJson['total'];
      featuredImage = parsedJson['featured_image'];
      if (parsedJson['featured_image'] != null) {
        featuredImage = parsedJson['featured_image'];
      }
      if (parsedJson['product_data'] != null) {
        if (parsedJson['product_data']['images'] != null &&
            parsedJson['product_data']['images'].isNotEmpty) {
          featuredImage = parsedJson['product_data']['images'][0]['src'];
        }
      }

      featuredImage ??= kDefaultImage;

      final metaData = parsedJson['meta_data'];
      if (metaData is List) {
        addonsOptions = metaData.map((e) => e['value']).join(', ');
      }

      /// For FluxStore Manager
      if (parsedJson['meta'] != null) {
        addonsOptions = parsedJson['meta'].map((e) => e['value']).join(', ');
        parsedJson['meta'].forEach((attr) {
          if (attr['key'] == 'attribute_pa_color') {
            attributes.add(attr['value']);
          }
        });
      }
      id = parsedJson['id'].toString();
      if (parsedJson['delivery_user'] != null) {
        deliveryUser = DeliveryUser.fromJson(parsedJson['delivery_user']);
      }
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  ProductItem.fromOpencartJson(Map<String, dynamic> parsedJson) {
    try {
      productId = parsedJson['product_id'].toString();
      name = parsedJson['name'];
      quantity = int.parse("${parsedJson["quantity"]}");
      total = parsedJson['total'];
      if (parsedJson['product_data'] != null) {
        if (parsedJson['product_data']['images'] != null &&
            parsedJson['product_data']['images'].isNotEmpty) {
          featuredImage = parsedJson['product_data']['images'][0];
        }
      }
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'total': total,
      'featuredImage': featuredImage
    };
  }

  ProductItem.fromLocalJson(Map<String, dynamic> parsedJson) {
    productId = "${parsedJson["product_id"]}";
    name = parsedJson['name'];
    quantity = parsedJson['quantity'];
    total = parsedJson['total'].toString();
    featuredImage = parsedJson['featuredImage'];
  }

  ProductItem.fromMagentoJson(Map<String, dynamic> parsedJson) {
    try {
      productId = "${parsedJson["product_id"]}";
      name = parsedJson['name'];
      quantity = parsedJson['qty_ordered'];
      total = parsedJson['base_row_total'].toString();
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  ProductItem.fromShopifyJson(Map<String, dynamic> parsedJson) {
    try {
      productId = parsedJson['title'];
      name = parsedJson['title'];
      quantity = parsedJson['quantity'];
      total = '';
      featuredImage = ((parsedJson['variant'] ?? {})['image'] ?? {})['src'];
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  ProductItem.fromPrestaJson(Map<String, dynamic> parsedJson) {
    try {
      productId = parsedJson['product_id'];
      name = parsedJson['product_name'];
      quantity = int.parse(parsedJson['product_quantity']);
      total = parsedJson['product_price'];
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  ProductItem.fromStrapiJson(SerializerProduct model, apiLink) {
    try {
      // var model = SerializerProduct.fromJson(parsedJson);
      productId = model.id.toString();
      name = model.title;
      total = model.price.toString();

      var imageList = [];
      if (model.images != null) {
        for (var item in model.images!) {
          imageList.add(apiLink(item.url));
        }
      }
      featuredImage =
          imageList.isNotEmpty ? imageList[0] : apiLink(model.thumbnail!.url);
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }
}
