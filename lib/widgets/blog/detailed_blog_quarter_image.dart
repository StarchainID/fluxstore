import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../models/entities/blog.dart';
import '../../models/index.dart' show Blog;
import '../../modules/audio/audio_components.dart';
import '../../screens/base_screen.dart';
import 'detailed_blog_mixin.dart';

class OneQuarterImageType extends StatefulWidget {
  final Blog item;

  OneQuarterImageType({Key? key, required this.item}) : super(key: key);

  @override
  _OneQuarterImageTypeState createState() => _OneQuarterImageTypeState();
}

class _OneQuarterImageTypeState extends BaseScreen<OneQuarterImageType>
    with DetailedBlogMixin {
  ScrollController? _scrollController;
  bool isExpandedListView = true;
  bool isVideoDetected = false;
  String? videoUrl;
  Key key = UniqueKey();

  @override
  void initState() {
    if (Videos.getVideoLink(widget.item.content!) != null) {
      setState(() {
        videoUrl = Videos.getVideoLink(widget.item.content!);

        isVideoDetected = true;
      });
    } else {
      isVideoDetected = false;
    }

    if (kAdConfig['enable'] ?? false) {
      // _initAds();
    }

    _scrollController = ScrollController();
    _scrollController!.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController!.offset == 0) {
      setState(() {
        isExpandedListView = true;
      });
    } else {
      setState(() {
        isExpandedListView = false;
      });
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.item.isAudioDetected() && kBlogDetail['enableAudioSupport']) {
      showDialog(
          context: context, builder: (context) => AudioDialog(widget.item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListView(
                        controller: _scrollController,
                        children: <Widget>[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  width: MediaQuery.of(context).size.width - 30,
                                  child: Stack(
                                    children: <Widget>[
                                      ImageTools.image(
                                        url: widget.item.imageFeature,
                                        fit: BoxFit.cover,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        size: kSize.medium,
                                      ),
                                      isVideoDetected
                                          ? WebView(
                                              key: key,
                                              initialUrl: videoUrl,
                                              javascriptMode:
                                                  JavascriptMode.unrestricted,
                                            )
                                          : ImageTools.image(
                                              url: widget.item.imageFeature,
                                              fit: BoxFit.cover,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              size: kSize.large,
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 5),
                            child: Text(
                              widget.item.title!,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 25,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.8),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          renderBlogContentWithTextEnhancement(widget.item),
                          renderRelatedBlog(widget.item.categoryId),
                          renderCommentLayout(widget.item.id),
                          renderCommentInput(widget.item.id),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 90,
              child: AnimatedOpacity(
                opacity: isExpandedListView ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 180,
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(5.0),
                              child: const Icon(
                                Icons.person,
                                size: 30.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'by ${widget.item.author} ',
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.item.date!,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Container(
                    margin: const EdgeInsets.all(12.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_sharp,
                      size: 20.0,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                renderBlogFunctionButtons(widget.item),
              ],
            )
          ],
        ),
      ),
    );
  }
}
