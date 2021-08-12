import 'package:flutter/material.dart';

import '../../../common/config.dart';
import '../../../models/entities/blog.dart';
import '../../../screens/base_screen.dart';
import '../../../services/service_config.dart';
import '../detailed_blog/detailed_blog_quarter_image.dart';

class BlogView extends StatefulWidget {
  final String? id;
  BlogView({this.id});

  @override
  _StateBlogView createState() => _StateBlogView();
}

class _StateBlogView extends BaseScreen<BlogView> {
  Blog? blog;

  @override
  void afterFirstLayout(BuildContext context) async {
    var res =
        await Blog.getBlog(url: Config().blog ?? Config().url, id: widget.id);
    setState(() {
      blog = Blog.fromJson(res);
    });
  }

  Widget getDetailBlog() {
    switch (kAdvanceConfig['DetailedBlogLayout']) {
      // case kBlogLayout.fullSizeImageType:
      //   return FullImageType(
      //     item: blog,
      //   );
//    case kBlogLayout.halfSizeImageType:
//      return HalfImageType(item: blog);
//
//
//    case kBlogLayout.oneQuarterImageType:
//      return OneQuarterImageType(
//        item: blog,
//      );
      default:
        return OneQuarterImageType(item: blog);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (blog == null) return Scaffold(body: kLoadingWidget(context));

    return getDetailBlog();
  }
}
