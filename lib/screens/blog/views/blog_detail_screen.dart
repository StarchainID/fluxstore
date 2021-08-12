import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/audio.dart';
import '../../../models/entities/blog.dart';
import '../../../modules/audio/audio_player.dart';
import '../../../widgets/blog/detailed_blog_fullsize_image.dart';
import '../../../widgets/blog/detailed_blog_half_image.dart';
import '../../../widgets/blog/detailed_blog_quarter_image.dart';
import '../../../widgets/blog/detailed_blog_view.dart';
import '../models/list_blog_model.dart';

class BlogDetailArguments {
  final Blog blog;
  final List<Blog>? listBlog;

  BlogDetailArguments({
    required this.blog,
    this.listBlog,
  });
}

class BlogDetailScreen extends StatefulWidget {
  final Blog blog;
  final List<Blog>? listBlog;
  BlogDetailScreen({required this.blog, this.listBlog});

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  PageController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listBlog = widget.listBlog ?? [];
    controller ??= PageController(
        initialPage:
            listBlog.indexWhere((element) => element.id == widget.blog.id));
    return AudioServiceWidget(
      child: PageView.builder(
        itemCount: listBlog.length,
        controller: controller,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              getDetailScreen(listBlog[index]),
              if (kBlogDetail['enableAudioSupport'] ?? false)
                Positioned(
                  bottom: 0,
                  child: _StickyAudioPlayer(context),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget getDetailScreen(Blog blog) {
    if (Videos.getVideoLink(blog.content!) != null) {
      return OneQuarterImageType(item: blog);
    } else {
      switch (kAdvanceConfig['DetailedBlogLayout']) {
        case kBlogLayout.halfSizeImageType:
          return HalfImageType(item: blog);
        case kBlogLayout.fullSizeImageType:
          return FullImageType(item: blog);
        case kBlogLayout.oneQuarterImageType:
          return OneQuarterImageType(item: blog);
        default:
          return BlogDetail(item: blog);
      }
    }
  }
}

Widget _StickyAudioPlayer(BuildContext context) {
  return Visibility(
    visible: Provider.of<AudioModel>(context, listen: true)
        .isStickyAudioWidgetActive,
    child: Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black12,
            width: 1.0,
          ),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: 130,
      child: Card(
        margin: EdgeInsets.zero,
        child: AudioWidget(),
      ),
    ),
  );
}
