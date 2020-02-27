// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';

enum _Element {
  background,
  text,
  overlayBackground,
  hourCircleBackground,
  hourCircleProgressBackground,
  hourCircleProgress,
  minutesCircleBackground,
  minutesCircleProgressBackground,
  minutesCircleProgress,
}

final _lightTheme = {
  _Element.background: const Color(0xFFD7F4EE),
  _Element.text: const Color(0xFF263238),
  _Element.overlayBackground: const Color(0xFFAFE9DD),
  _Element.hourCircleBackground: const Color(0xFFFFD5E5),
  _Element.hourCircleProgressBackground: const Color(0xFFFFAACC),
  _Element.hourCircleProgress: const Color(0xFFFF7DB0),
  _Element.minutesCircleBackground: const Color(0xFFAACCFF),
  _Element.minutesCircleProgressBackground: const Color(0xFF80B3FF),
  _Element.minutesCircleProgress: const Color(0xFF0088AA),
};

final _darkTheme = {
  _Element.background: const Color(0xFF333333),
  _Element.text: const Color(0xFFFFFFFF),
  _Element.overlayBackground: const Color(0xFF666666),
  _Element.hourCircleBackground: const Color(0xFFCCCCCC),
  _Element.hourCircleProgressBackground: const Color(0xFF999999),
  _Element.hourCircleProgress: const Color(0xFF37c8ab),
  _Element.minutesCircleBackground: const Color(0xFFB3B3B3),
  _Element.minutesCircleProgressBackground: const Color(0xFFD8D8D8),
  _Element.minutesCircleProgress: const Color(0xFF80B3FF),
};

final _weatherIcon = {
  'cloudy': 'assets/svg/wi-cloud.svg',
  'foggy': 'assets/svg/wi-fog.svg',
  'rainy': 'assets/svg/wi-rain.svg',
  'snowy': 'assets/svg/wi-snow.svg',
  'sunny': 'assets/svg/wi-sunny.svg',
  'thunderstorm': 'assets/svg/wi-thunderstorm.svg',
  'windy': 'assets/svg/wi-windy.svg',
  'default': 'assets/svg/wi-refresh.svg',
};

String _getWeatherIcon(String name) {
  return _weatherIcon.containsKey(name)
      ? _weatherIcon[name]
      : _weatherIcon['default'];
}

String _toCamelCase(String str) {
  if (str.isEmpty || str == null) return str;
  return str[0].toUpperCase() + str.substring(1).toLowerCase();
}

String _antePostNotation(int hour) {
  return hour < 12 ? ' AM' : ' PM';
}

String _lowHighString(ClockModel model) {
  return model.lowString + ' | ' + model.highString;
}

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  String _date;
  String _weekday;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

      // Update once per minute. If you want to update every second, use the
      // following code.
      //
      //_timer = Timer(
      //  Duration(minutes: 1) -
      //      Duration(seconds: _dateTime.second) -
      //      Duration(milliseconds: _dateTime.millisecond),
      //  _updateTime,
      //);

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );

      // Get date
      _date = DateFormat.yMMMd().format(_dateTime);
      // Get weekday
      _weekday = DateFormat.EEEE().format(_dateTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('s').format(_dateTime);
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Saira',
    );

    return Container(
      color: colors[_Element.background],
      child: LayoutBuilder(builder: (context, constraint) {
        final width = constraint.maxWidth;
        final height = constraint.maxHeight;
        return Center(
          child: DefaultTextStyle(
            style: defaultStyle,
            child: Stack(
              children: <Widget>[
                ////////////////////////////////////////////////////////////////
                // Overlay background
                Positioned(
                  left: -(width / 5),
                  top: -(height / 30),
                  child: CircleAvatar(
                    radius: (height / 2) + (height / 30),
                    backgroundColor: colors[_Element.overlayBackground],
                    foregroundColor: colors[_Element.text],
                  ),
                ),
                // Date & Weekday
                Positioned(
                  left: (width / 10) * 0.35,
                  top: (height / 10) * 0.75,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _date,
                        style: TextStyle(
                          fontFamily: defaultStyle.fontFamily,
                          fontSize: (height / 10) * 0.95,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        _weekday,
                        style: TextStyle(
                          fontFamily: defaultStyle.fontFamily,
                          fontSize: (height / 10) * 0.9,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Weather group
                Positioned(
                  left: (width / 10) * 0.25,
                  top: (height / 10) * 5.75,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SvgPicture.asset(
                            _getWeatherIcon(widget.model.weatherString),
                            color: colors[_Element.text],
                            height: (height / 10) * 1.75,
                          ),
                          Text(
                            widget.model.temperatureString,
                            style: TextStyle(
                              fontFamily: defaultStyle.fontFamily,
                              fontSize: (height / 10) * 0.85,
                              height: 2.0,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _lowHighString(widget.model),
                        style: TextStyle(
                          fontFamily: defaultStyle.fontFamily,
                          fontSize: (height / 10) * 0.55,
                          height: 1.45,
                        ),
                      ),
                      Text(
                        _toCamelCase(widget.model.weatherString),
                        style: TextStyle(
                          fontFamily: defaultStyle.fontFamily,
                          fontSize: (height / 10) * 0.75,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Hour circle
                Positioned(
                  left: (width / 10) * 4.4,
                  top: (height / 10) * 0.4,
                  child: CircleAvatar(
                    radius: (width / 10) * 1.28,
                    backgroundColor: colors[_Element.hourCircleBackground],
                    foregroundColor: colors[_Element.text],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (widget.model.is24HourFormat)
                          Text(
                            hour,
                            style: TextStyle(
                              fontFamily: defaultStyle.fontFamily,
                              fontSize: (height / 10) * 2.15,
                            ),
                          ),
                        if (!widget.model.is24HourFormat)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                hour,
                                style: TextStyle(
                                  fontFamily: defaultStyle.fontFamily,
                                  fontSize: (height / 10) * 2.15,
                                ),
                              ),
                              Text(
                                _antePostNotation(_dateTime.hour),
                                style: TextStyle(
                                  fontFamily: defaultStyle.fontFamily,
                                  fontSize: (height / 10) * 0.65,
                                  height: 2.95,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                // Hour progress circle
                Positioned(
                  left: (width / 10) * 4.4,
                  top: (height / 10) * 0.3,
                  child: CircularPercentIndicator(
                    radius: (2.0 * (width / 10)) * 1.3,
                    lineWidth: 5.75,
                    percent: (_dateTime.hour > 12)
                        ? (_dateTime.hour - 12) / 12
                        : _dateTime.hour / 12,
                    progressColor: colors[_Element.hourCircleProgress],
                    backgroundColor:
                        colors[_Element.hourCircleProgressBackground],
                  ),
                ),
                // Minutes circle
                Positioned(
                  left: (width / 10) * 6.5,
                  top: (height / 10) * 3.5,
                  child: CircleAvatar(
                    radius: (width / 10) * 1.52,
                    backgroundColor: colors[_Element.minutesCircleBackground],
                    foregroundColor: colors[_Element.text],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          minute,
                          style: TextStyle(
                            fontFamily: defaultStyle.fontFamily,
                            fontSize: (height / 10) * 2.35,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          int.parse(second) < 10 ? '0' + second : second,
                          style: TextStyle(
                            fontFamily: defaultStyle.fontFamily,
                            fontSize: (height / 10) * 0.75,
                            height: 0.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Minutes progress circle
                Positioned(
                  left: (width / 10) * 6.5,
                  top: (height / 10) * 3.4,
                  child: CircularPercentIndicator(
                    radius: (2.0 * (width / 10)) * 1.53,
                    lineWidth: 5.75,
                    percent: _dateTime.second / 60,
                    progressColor: colors[_Element.minutesCircleProgress],
                    backgroundColor:
                        colors[_Element.minutesCircleProgressBackground],
                  ),
                ),
                // Location
                Positioned(
                  left: (width / 10) * 4.35,
                  bottom: (height / 10) * 0.6,
                  child: Text(
                    widget.model.location,
                    style: TextStyle(
                      fontFamily: defaultStyle.fontFamily,
                      fontSize: (height / 10) * 0.65,
                    ),
                  ),
                ),
                ////////////////////////////////////////////////////////////////
              ],
            ),
          ),
        );
      }),
    );
  }
}
