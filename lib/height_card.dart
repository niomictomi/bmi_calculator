import 'dart:math' as math;

import 'package:bmi_calculator/card_title.dart';
import 'package:bmi_calculator/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeightCard extends StatefulWidget {
  @override
  HeightCardState createState() => HeightCardState();
}

class HeightCardState extends State<HeightCard> {
  int height = 170;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.only(top: screenAwareSize(16.0, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CardTitle(
              "HEIGHT",
              subtitle: "(cm)",
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: screenAwareSize(8.0, context)),
                child: LayoutBuilder(builder: (context, constraints) {
                  return HeightPicker(
                    widgetHeight: constraints.maxHeight,
                    height: height,
                    onChange: (val) => setState(() => height = val),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const int minHeight = 145;
const int maxHeight = 190;
const int totalUnits = maxHeight - minHeight;
const double circleSize = 32.0;
const double bottomMargin = circleSize / 2;
const double topMargin = 26.0;

const double labelsFontSize = 13.0;
const double selectedLabelFontSize = 14.0;

class HeightPicker extends StatelessWidget {
  final double widgetHeight;
  final int height;
  final ValueChanged<int> onChange;

  const HeightPicker({Key key, this.widgetHeight, this.height, this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double sliderPosition = _sliderPosition(context);
    double personImageHeight =
        sliderPosition + screenAwareSize(circleSize / 2, context);
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: SvgPicture.asset(
            "images/person.svg",
            height: personImageHeight,
            width: personImageHeight / 3,
          ),
        ),
        Positioned(
          child: _drawSlider(context),
          left: 0.0,
          right: 0.0,
          bottom: _sliderPosition(context),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IgnorePointer(child: _drawLabels(context)),
        ),
      ],
    );
  }

  double _sliderPosition(BuildContext context) {
    return _pixelsPerUnit(context) * (height - minHeight) +
        screenAwareSize(labelsFontSize/2, context);
  }

  double _pixelsPerUnit(BuildContext context) {
    double drawingHeight = widgetHeight -
        screenAwareSize(bottomMargin + topMargin+ labelsFontSize, context) ;
    return drawingHeight / totalUnits;
  }

  Widget _drawLabels(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: screenAwareSize(12.0, context),
        bottom: screenAwareSize(bottomMargin, context),
        top: screenAwareSize(topMargin, context),
      ),
      child: Column(
        children: List.generate(
          10,
          (idx) {
            return Text(
              "${190 - 5 * idx}",
              style: TextStyle(
                color: Color.fromRGBO(216, 217, 223, 1.0),
                fontSize: screenAwareSize(labelsFontSize, context),
              ),
            );
          },
        ),
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Widget _drawSlider(BuildContext context) {
    return DraggableSlider(
      height: height,
      onChange: onChange,
      pixelsPerUnit: _pixelsPerUnit(context),
    );
  }
}

class DraggableSlider extends StatefulWidget {
  final int height;
  final ValueChanged<int> onChange;
  final double pixelsPerUnit;

  const DraggableSlider(
      {Key key, this.height, this.onChange, this.pixelsPerUnit})
      : super(key: key);

  @override
  _DraggableSliderState createState() => _DraggableSliderState();
}

class _DraggableSliderState extends State<DraggableSlider> {
  double yStartOffset;
  int heightStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
              left: screenAwareSize(4.0, context),
              bottom: screenAwareSize(2.0, context)),
          child: Text(
            "${widget.height}",
            style: TextStyle(
              fontSize: screenAwareSize(selectedLabelFontSize, context),
              color: Color.fromRGBO(77, 123, 243, 1.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: onDragStart,
          onVerticalDragUpdate: onDragUpdate,
          child: Row(
            children: <Widget>[
              SliderCircle(),
              Expanded(child: SliderLine()),
            ],
          ),
        ),
      ],
    );
  }

  int normalizeHeight(int height) {
    return math.max(minHeight, math.min(maxHeight, height));
  }

  void onDragStart(DragStartDetails dragStartDetails) {
    setState(() {
      yStartOffset = dragStartDetails.globalPosition.dy;
      heightStart = widget.height;
    });
  }

  void onDragUpdate(DragUpdateDetails dragUpdateDetails) {
    double currentYOffset = dragUpdateDetails.globalPosition.dy;
    double verticalDifference = yStartOffset - currentYOffset;
    int diffHeight = verticalDifference ~/ widget.pixelsPerUnit;
    int height = normalizeHeight(heightStart + diffHeight);
    setState(() => widget.onChange(height));
  }
}

class SliderLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(
          40,
          (i) => Expanded(
                child: Container(
                  height: 2.0,
                  decoration: BoxDecoration(
                      color: i.isEven
                          ? Color.fromRGBO(77, 123, 243, 1.0)
                          : Colors.white),
                ),
              )),
    );
  }
}

class SliderCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenAwareSize(32.0, context),
      height: screenAwareSize(32.0, context),
      decoration: BoxDecoration(
        color: Color.fromRGBO(77, 123, 243, 1.0),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.unfold_more,
        color: Colors.white,
        size: screenAwareSize(24.0, context),
      ),
    );
  }
}
