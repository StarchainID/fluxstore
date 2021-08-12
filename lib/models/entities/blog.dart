import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';

import '../../common/constants.dart';
import '../../services/index.dart';
import '../serializers/blog.dart';

class Blog {
  final dynamic id;
  final String? title;
  final String? subTitle;
  final String? date;
  final String? content;
  final String? author;
  final String? imageFeature;
  final int? categoryId;
  final String? excerpt;
  final String? slug;
  final String? authorImage;

  const Blog({
    this.id,
    this.title,
    this.subTitle,
    this.date,
    this.content,
    this.author,
    this.imageFeature,
    this.categoryId,
    this.excerpt,
    this.slug,
    this.authorImage,
  });

  const Blog.empty(this.id)
      : title = '',
        subTitle = '',
        date = '',
        author = '',
        content = '',
        imageFeature = '',
        categoryId = 0,
        excerpt = '',
        slug = '',
        authorImage = '';

  factory Blog.fromJson(Map<String, dynamic>? json) {
    switch (Config().type) {
      case ConfigType.woo:
      case ConfigType.opencart:
      case ConfigType.magento:
      case ConfigType.dokan:
      case ConfigType.presta:
      case ConfigType.wcfm:
      case ConfigType.wordpress:
        return Blog._fromWooJson(json!);
      case ConfigType.shopify:
        return Blog._fromShopifyJson(json!);
      case ConfigType.strapi:
        return Blog._fromStrapiJson(json!);
      case ConfigType.mylisting:
      case ConfigType.listeo:
      case ConfigType.listpro:
        return Blog._fromListingJson(json!);
      default:
        return const Blog.empty(0);
    }
  }

  Blog._fromShopifyJson(Map<String, dynamic> json)
      : id = json['id'],
        author = json['authorV2']['name'],
        title = json['title'],
        subTitle = null,
        content = json['contentHtml'],
        imageFeature = json['image']['transformedSrc'],
        date = json['publishedAt'],
        categoryId = 0,
        excerpt = '',
        slug = '',
        authorImage = '';

  factory Blog._fromStrapiJson(Map<String, dynamic> json) {
    var model = SerializerBlog.fromJson(json);
    final id = model.id;
    final author = model.user!.displayName;
    final title = model.title;
    final subTitle = model.subTitle;
    final content = model.content;
    final imageFeature = Config().url! + model.images!.first.url!;
    final date = model.date;
    return Blog(
      author: author,
      title: title,
      subTitle: subTitle,
      content: content,
      id: id,
      date: date,
      imageFeature: imageFeature,
    );
  }

  Blog._fromListingJson(Map<String, dynamic> json)
      : id = json['id'],
        author = json['author_name'],
        title = HtmlUnescape().convert(json['title']['rendered']),
        subTitle = HtmlUnescape().convert(json['excerpt']['rendered']),
        content = json['content']['rendered'],
        imageFeature = json['image_feature'],
        date = DateFormat.yMMMMd('en_US').format(DateTime.parse(json['date'])),
        categoryId = 0,
        excerpt = '',
        slug = '',
        authorImage = '';

  factory Blog._fromWooJson(Map<String, dynamic> json) {
    String? imageFeature;
    var imgJson = json['better_featured_image'];
    if (imgJson != null) {
      if (imgJson['media_details']?['sizes']?['medium_large'] != null) {
        imageFeature =
            imgJson['media_details']?['sizes']?['medium_large']?['source_url'];
      }
    }

    if (imageFeature == null) {
      var imgMedia = json['_embedded']?['wp:featuredmedia'];
      if (imgMedia is List && imgMedia.isNotEmpty) {
        imageFeature =
            imgMedia[0]['media_details']?['sizes']?['large']?['source_url'];
        imageFeature ??= imgMedia[0]['source_url'];
      }
    }

    final author = json['_embedded']?['author'] != null
        ? json['_embedded']['author'][0]['name']
        : '';
    final date =
        DateFormat.yMMMMd('en_US').format(DateTime.parse(json['date']));

    final id = json['id'];
    final title = HtmlUnescape().convert(json['title']['rendered']);
    final subTitle = HtmlUnescape().convert(json['excerpt']['rendered']);
    final content = json['content']['rendered'];
    final categories = List.from(json['categories'] ?? []);
    final categoryId = categories.isNotEmpty ? categories.first : null;
    final excerpt = HtmlUnescape().convert(json['excerpt']['rendered']);
    final slug = json['slug'];
    final authorImage = json['_embedded']?['author']?[0]['avatar_urls']?['48'];

    return Blog(
      author: author,
      title: title,
      subTitle: subTitle,
      content: content,
      id: id,
      date: date,
      imageFeature: imageFeature,
      categoryId: categoryId,
      excerpt: excerpt,
      slug: slug,
      authorImage: authorImage,
    );
  }

  static Future getBlogs({String? url, categories, page = 1}) async {
    try {
      var param = '_embed&page=$page';
      if (categories != null) {
        param += '&categories=$categories';
      }
      final response =
          await httpGet('$url/wp-json/wp/v2/posts?$param'.toUri()!);

      if (response.statusCode != 200) {
        return [];
      }
      return jsonDecode(response.body);
    } on Exception catch (_) {
      return [];
    }
  }

  static Future<dynamic> getBlog({url, id}) async {
    final response =
        await httpGet('$url/wp-json/wp/v2/posts/$id?_embed'.toUri()!);
    return jsonDecode(response.body);
  }

  List<String?>? getAudioLinks() {
    late List<String?>? audioList;

    /// Detect .mp3 URLs in post content.
    final regExp =
        RegExp('https?.*?\.mp3', multiLine: true, caseSensitive: false);
    if (content == null) {
      return null;
    } else {
      try {
        var matches = regExp.allMatches(content!);

        /// Get audio URLs from RegExp matches
        final matchesGroup = matches.map((item) => item.group(0)).toList();

        /// Remove redundant URLs
        audioList = matchesGroup.toSet().toList();
        // ignore: empty_catches
      } catch (err) {}
      return audioList;
    }
  }

  bool isAudioDetected() {
    return getAudioLinks()?.isNotEmpty ?? false;
  }

  bool get isEmpty {
    return date == '' &&
        title == '' &&
        content == '' &&
        excerpt == '' &&
        imageFeature == '';
  }

  @override
  String toString() => 'Blog { id: $id  title: $title}';
}
