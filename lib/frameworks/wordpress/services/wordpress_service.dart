import 'dart:async';
import 'dart:convert' as convert;
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/constants.dart';
import '../../../models/comment.dart';
import '../../../models/entities/index.dart';
import '../../../services/base_services.dart';

class WordPressService extends BaseServices {
  WordPressService({
    required String domain,
    String? blogDomain,
  })  : isSecure = domain.contains('https') ? '' : '&insecure=cool',
        super(
          domain: domain,
          blogDomain: blogDomain,
        );

  final String isSecure;

  @override
  Future<List<Category>> getCategories({lang = 'en'}) async {
    try {
      var response = await blogApi.getAsync('categories?per_page=20');
      var list = <Category>[];
      for (var item in response) {
        if (item['slug'] == 'uncategorized') {
          continue;
        }
        list.add(Category.fromWordPress(item));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Blog> getPageById(int? pageId) async {
    try {
      var response = await blogApi.getAsync('pages/$pageId?_embed');
      return Blog.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Blog>> fetchBlogsByCategory(
      {categoryId, page, lang, order = 'desc'}) async {
    try {
      var list = <Blog>[];

      var endPoint =
          'posts?_embed&lang=$lang&per_page=15&page=$page&order=${order ?? 'desc'}';
      if (categoryId != null) {
        endPoint += '&categories=$categoryId';
      }
      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        list.add(Blog.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> loginFacebook({String? token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$domain/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime'
          // ignore: prefer_single_quotes
          "&access_token=$token$isSecure";

      var response = await httpGet(endPoint.toUri()!);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String? token}) async {
    try {
      //var endPoint = "$url/wp-json/api/flutter_user/sms_login/?access_token=$token$isSecure";
      var endPoint =
          // ignore: prefer_single_quotes
          "$domain/wp-json/api/flutter_user/firebase_sms_login?phone=$token$isSecure";

      var response = await httpGet(endPoint.toUri()!);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User?> loginApple({String? token}) async {
    try {
      var endPoint = '$domain/wp-json/api/flutter_user/apple_login';

      var response = await httpPost(endPoint.toUri()!,
          body: convert.jsonEncode({'token': token}),
          headers: {'Content-Type': 'application/json'});

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User?> loginGoogle({String? token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$domain/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime'
                  '&access_token=$token$isSecure'
              .toUri()!;

      var response = await httpGet(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User?> getUserInfo(cookie) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(cookie);
      final response = await httpGet(
          '$domain/wp-json/api/flutter_user/get_currentuserinfo?token=$base64Str&$isSecure'
              .toUri()!);
      final body = convert.jsonDecode(response.body);
      if (body['user'] != null) {
        var user = body['user'];
        return User.fromAuthUser(user, cookie);
      } else {
        if (body['message'] != 'Invalid cookie') {
          throw Exception(body['message']);
        }
        return null;

        /// we may handle if Invalid cookie here
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      var niceName = [firstName ?? '', lastName ?? ''].join(' ').trim();

      final response = await http.post(
          '$domain/wp-json/api/flutter_user/register/?insecure=cool'.toUri()!,
          body: convert.jsonEncode({
            'user_email': username,
            'user_login': username,
            'username': username,
            'user_pass': password,
            'email': username,
            'user_nicename': niceName,
            'display_name': niceName,
          }));

      var body = convert.jsonDecode(response.body);

      if (response.statusCode == 200 && body['message'] == null) {
        var cookie = body['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = body['message'];
        throw Exception(message ?? 'Can not create the user.');
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document
      rethrow;
    }
  }

  @override
  Future<User?> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final response = await httpPost(
          '$domain/wp-json/api/flutter_user/generate_auth_cookie/?insecure=cool&$isSecure'
              .toUri()!,
          body: convert.jsonEncode({'seconds': cookieLifeTime.toString(), 'username': username, 'password': password}),
          headers: {'Content-Type': 'application/json'});

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        final jwtAuthToken = await getJwtAuth(username, password);
        var user = await getUserInfo(body['cookie']);
        user?.jwtToken = jwtAuthToken;
        return user;
      } else {
        throw Exception('The username or password is incorrect.');
      }
    } catch (err, trace) {
      printLog('🔥 Integration error:');
      printLog(err);
      printLog(trace);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  Future<String?> getJwtAuth(String username, String password) async {
    try {
      var endPoint =
          '$domain/wp-json/jwt-auth/v1/token?username=$username&password=$password'
              .toUri();
      var response = await http.post(endPoint!);
      var jsonDecode = convert.jsonDecode(response.body);
      if (jsonDecode['token'] == null) {
        throw Exception(jsonDecode['code']);
      }
      debugPrint("[getJwtAuth]: ${jsonDecode['token']}");
      return jsonDecode['token'];
    } catch (e, trace) {
      debugPrint('[getJwtAuth] fail: $trace');
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document or contact supporters/
      rethrow;
    }
  }

  Future<void> createBlog(
      {required File file,
      required String jwtToken,
      required Map<String, dynamic> data}) async {
    try {
      int mediaImageId;
      if (jwtToken.isEmpty) {
        debugPrint('Error on getting JwtToken');
      } else {
        await blogApi.uploadBlogImage(file, jwtToken).then((response) {
          mediaImageId = response['id'];
          data['featured_media'] = mediaImageId;
        });
        await blogApi.postAsync('posts', data, token: jwtToken);
      }
    } catch (e, trace) {
      debugPrint('createBlog: fail');
      debugPrint(trace.toString());
      rethrow;
    }
  }

  Future<List<Blog>?> getBlogsByUserId(String userId) async {
    try {
      var response = await blogApi.getAsync('posts?_embed&author=$userId');
      var list = <Blog>[];
      for (var item in response) {
        list.add(Blog.fromJson(item));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Blog>> searchBlog({required String name}) async {
    try {
      var response = await blogApi.getAsync('posts?_embed&search=$name');

      var list = <Blog>[];
      for (var item in response) {
        list.add(Blog.fromJson(item));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Comment>?> getCommentsByPostId({postId}) async {
    try {
      var list = <Comment>[];

      var endPoint = 'comments?';
      if (postId != null) {
        endPoint += '&post=$postId';
      }

      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        list.add(Comment.fromJson(item));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createComment(
      {int? blogId,
      String? content,
      String? authorName,
      String? authorAvatar,
      String? userEmail,
      String? date}) async {
    try {
      //return true if comment created successful, false if otherwise
      var data = {
        'content': content,
        'author_name': authorName,
        'author_avatar_urls': authorAvatar,
        'email': userEmail,
        'date': date
      };
      var dataResponse = await blogApi.postAsync('comments?post=$blogId', data);
      if (dataResponse['id'] != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Blog>?> getBlogsByCategory(int cateId) async {
    try {
      var response = await blogApi.getAsync('posts?_embed&categories=$cateId');
      var list = <Blog>[];
      for (var item in response) {
        list.add(Blog.fromJson(item));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }
}
