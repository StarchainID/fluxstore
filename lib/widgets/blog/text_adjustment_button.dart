import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/text_style_model.dart';
import '../../screens/base_screen.dart';

class TextAdjustmentButton extends StatefulWidget {
  final double size;

  TextAdjustmentButton(this.size);

  @override
  _TextAdjustmentButtonState createState() => _TextAdjustmentButtonState();
}

class _TextAdjustmentButtonState extends BaseScreen<TextAdjustmentButton> {
  double textSize = 15.0;

  @override
  void afterFirstLayout(BuildContext context) {
    textSize =
        Provider.of<TextStyleModel>(context, listen: false).contentTextSize;
    super.afterFirstLayout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30 * (widget.size / 15),
      width: 30 * (widget.size / 15),
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        alignment: Alignment.center,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (context, StateSetter setState) {
                    return Container(
                      height: MediaQuery.of(context).copyWith().size.height *
                          (1 / 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.zoom_in_sharp,
                                    size: 30,
                                    color: Theme.of(context).iconTheme.color),
                                Icon(Icons.zoom_in_sharp,
                                    size: 40,
                                    color: Theme.of(context).iconTheme.color),
                                Icon(Icons.zoom_in_sharp,
                                    size: 50,
                                    color: Theme.of(context).iconTheme.color),
                              ],
                            ),
                          ),
                          Slider(
                            onChanged: (double value) {
                              setState(() {
                                textSize = value;
                              });
                            },
                            onChangeEnd: (double value) {
                              Provider.of<TextStyleModel>(context,
                                      listen: false)
                                  .adjustTextSize(value);
                            },
                            value: textSize,
                            min: 15.0,
                            max: 30.0,
                            divisions: 4,
                          ),
                        ],
                      ),
                    );
                  },
                );
              });
        },
        icon: Icon(
          FontAwesomeIcons.textHeight,
          color: Theme.of(context).accentColor,
          size: widget.size,
        ),
      ),
    );
  }
}
