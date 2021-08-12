import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/entities/blog.dart';
import '../../models/text_style_model.dart';
import '../../services/services.dart';
import 'blog_heart_button.dart';
import 'blog_share_button.dart';
import 'text_adjustment_button.dart';

mixin DetailedBlogMixin<T extends StatefulWidget> on State<T> {
  Widget renderBlogFunctionButtons(Blog blog) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _renderTextAdjustmentButton(),
          _renderShareButton(blog),
          _renderHeartButton(blog),
        ],
      );

  Widget renderRelatedBlog(dynamic blogId) =>
      Services().widget.renderRelatedBlog(
            categoryId: blogId,
            type: kAdvanceConfig['DetailedBlogLayout'],
          );

  Widget renderCommentLayout(dynamic blogId) => kBlogDetail['showComment']
      ? Services()
          .widget
          .renderCommentLayout(blogId, kAdvanceConfig['DetailedBlogLayout'])
      : const SizedBox();

  Widget renderCommentInput(dynamic blogId) => kBlogDetail['showComment']
      ? Services().widget.renderCommentField(blogId)
      : const SizedBox();

  Widget renderBlogContentWithTextEnhancement(Blog blog) =>
      Consumer<TextStyleModel>(builder: (context, textStyleModel, child) {
        return HtmlWidget(
          blog.content!,
          webView: true,
          hyperlinkColor: Theme.of(context).primaryColor.withOpacity(0.9),
          textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: textStyleModel.contentTextSize,
              height: 1.4,
              color: kAdvanceConfig['DetailedBlogLayout'] ==
                      kBlogLayout.fullSizeImageType
                  ? Colors.white
                  : Theme.of(context).accentColor),
        );
      });

  Widget _renderHeartButton(Blog blog) => kBlogDetail['showHeart']
      ? Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: BlogHeartButton(
            blog: blog,
            size: 16,
            isTransparent: true,
          ),
        )
      : const SizedBox();

  Widget _renderShareButton(Blog blog) => kBlogDetail['showSharing']
      ? ShareButton(
          blog: blog,
        )
      : const SizedBox();

  Widget _renderTextAdjustmentButton() => kBlogDetail['showTextAdjustment']
      ? TextAdjustmentButton(18.0)
      : const SizedBox();
}
