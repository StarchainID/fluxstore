import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class IntroSliderWrapper extends IntroSlider {
  IntroSliderWrapper({
    List<SlideWrapper>? slides,
    TextStyle? styleSkipBtn,
    TextStyle? styleDoneBtn,
    String? namePrevBtn,
    String? nameSkipBtn,
    String? nameNextBtn,
    String? nameDoneBtn,
    Color? colorSkipBtn,
    Color? colorDoneBtn,
    bool? isShowDoneBtn,
    Function? onDonePress,
  }) : super(
          slides: slides,
          styleSkipBtn: styleSkipBtn,
          styleDoneBtn: styleDoneBtn,
          namePrevBtn: namePrevBtn,
          nameSkipBtn: nameSkipBtn,
          nameNextBtn: nameNextBtn,
          nameDoneBtn: nameDoneBtn,
          showDoneBtn: isShowDoneBtn,
          onDonePress: onDonePress,
          colorSkipBtn: colorSkipBtn,
          colorDoneBtn: colorDoneBtn,
        );
}

class SlideWrapper extends Slide {
  SlideWrapper({
    Widget? widgetTitle,
    String? title,
    int? maxLineTitle,
    TextStyle? styleTitle,
    EdgeInsets? marginTitle,
    String? pathImage,
    double? widthImage,
    double? heightImage,
    BoxFit? foregroundImageFit,
    Widget? centerWidget,
    Function? onCenterItemPress,
    Widget? widgetDescription,
    String? description,
    int? maxLineTextDescription,
    TextStyle? styleDescription,
    EdgeInsets? marginDescription,
    Color? backgroundColor,
    Color? colorBegin,
    Color? colorEnd,
    AlignmentGeometry? directionColorBegin,
    AlignmentGeometry? directionColorEnd,
    String? backgroundImage,
    BoxFit? backgroundImageFit,
    double? backgroundOpacity,
    Color? backgroundOpacityColor,
    BlendMode? backgroundBlendMode,
  }) : super(
          widgetTitle: widgetTitle,
          title: title,
          maxLineTitle: maxLineTitle,
          styleTitle: styleTitle,
          marginTitle: marginTitle,
          pathImage: pathImage,
          widthImage: widthImage,
          heightImage: heightImage,
          foregroundImageFit: foregroundImageFit,
          centerWidget: centerWidget,
          onCenterItemPress: onCenterItemPress,
          widgetDescription: widgetDescription,
          description: description,
          maxLineTextDescription: maxLineTextDescription,
          styleDescription: styleDescription,
          marginDescription: marginDescription,
          backgroundColor: backgroundColor,
          colorBegin: colorBegin,
          colorEnd: colorEnd,
          directionColorBegin: directionColorBegin,
          directionColorEnd: directionColorEnd,
          backgroundImage: backgroundImage,
          backgroundImageFit: backgroundImageFit,
          backgroundOpacity: backgroundOpacity,
          backgroundOpacityColor: backgroundOpacityColor,
          backgroundBlendMode: backgroundBlendMode,
        );
}
