import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../../models/entities/blog.dart';
import '../../services/service_config.dart';

class ShareButton extends StatelessWidget {
  final Blog? blog;
  ShareButton({this.blog});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Share.share(
          Config().url! + '/' + blog!.slug.toString(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Icon(
          Icons.share,
          size: 18.0,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
