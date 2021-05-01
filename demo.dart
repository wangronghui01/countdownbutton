import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shape Editor',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber,
        primaryColorBrightness: Brightness.dark,
        sliderTheme: SliderTheme.of(context).copyWith(
          inactiveTrackColor: Colors.black.withOpacity(0.2),
          thumbColor: Colors.amber,
          activeTrackColor: Colors.amber,
          overlayColor: Colors.amber.withOpacity(0.2),
        ),
      ),
      home: Myhome(),
    );
  }
}

class Myhome extends StatefulWidget {
  @override
  _MyhomeState createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> with SingleTickerProviderStateMixin {
  //动画控制器

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Path动画"),
      ),
      body: Center(
        child: Column(
          children: [
            //第一部分 画布 画线处
            SizedBox(
              height: 20,
            ),
            _CountDownButton(
              duration: Duration(seconds: 10),
              width: 100,
              height: 50,
              radius: Radius.circular(18),
              child: Text("send"),
            ),
            SizedBox(
              height: 20,
            ),
            _CountDownButton(
              duration: Duration(seconds: 1),
              width: 100,
              height: 100,
              radius: Radius.circular(100),
              child: Text("send"),
            ),
            SizedBox(
              height: 20,
            ),
            _CountDownButton(
              duration: Duration(seconds: 100),
              width: 100,
              height: 100,
              radius: Radius.circular(0),
              child: Text("send"),
            ),
            SizedBox(
              height: 20,
            ),
            _CountDownButton(
              duration: Duration(seconds: 100),
              width: 100,
              height: 300,
              radius: Radius.circular(100),
              child: Text("send"),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountDownButton extends StatefulWidget {
  final double width;
  final double height;
  final Radius radius;
  final Widget? child;
  final Duration duration;

  _CountDownButton({
    required this.width,
    required this.height,
    this.radius = const Radius.circular(8),
    required this.duration,
    this.child,
  });

  @override
  __CountDownButtonState createState() => __CountDownButtonState();
}

class __CountDownButtonState extends State<_CountDownButton>
    with SingleTickerProviderStateMixin {
  //动画控制器
  AnimationController? _animationController;

  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    _animationController =
        new AnimationController(vsync: this, duration: widget.duration);
    //动画监听
    _animationController!.addListener(() {
      setState(() {});
    });
    //添加一个动画状态监听
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed && _counter.value == 1) {
        _counter.value = 2;
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_counter.value == 0) {
          _counter.value = 1;
          //重置动画
          _animationController!.reset();
          //正向执行动画
          _animationController!.forward();
        }else  if (_counter.value == 1) {
          _counter.value = 0;
        }

      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.loose,
          clipBehavior: Clip.none,
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(widget.radius),
                color: Theme.of(context).accentColor,
              ),
              child: ValueListenableBuilder(
                builder: (BuildContext context, int value, Widget? child) {
                  if (value == 0) {
                    return widget.child!;
                  } else if (value == 1) {
                    return Text("发送中....");
                  }
                  return Text("发送完成");
                },
                valueListenable: _counter,
              ),
            ),
            Positioned(
              left: (widget.width - widget.height) / 2,
              top: (widget.height - widget.width) / 2,
              child: ValueListenableBuilder(
                builder: (BuildContext context, int value, Widget? child) {
                  return Visibility(
                      visible: value > 0,
                      child: Transform.rotate(
                        angle: pi / 2,
                        child: Container(
                          width: widget.height,
                          height: widget.width,
                          child: CustomPaint(
                            //定义一个画布
                            painter: PathPainter(
                                _animationController!.value,
                                _CountDownButtonSize.mark(
                                    width: widget.width,
                                    height: widget.height,
                                    borderWidth: 5,
                                    radius: widget.radius)),
                          ),
                        ),
                      ));
                },
                valueListenable: _counter,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CountDownButtonSize {
  _CountDownButtonSize(
      {required this.width,
      required this.borderWidth,
      required this.radius,
      required this.height});

  final double width;
  final double height;
  final Radius radius;
  final double borderWidth;

  factory _CountDownButtonSize.mark(
          {required double width,
          required double borderWidth,
          required Radius radius,
          required double height}) =>
      _CountDownButtonSize(
          width: width,
          borderWidth: borderWidth,
          radius: radius,
          height: height);
}

class PathPainter extends CustomPainter {
  //记录绘制进度 0.0  - 1.0
  double progress = 0.0;
  _CountDownButtonSize buttonSize;
  Paint? _paint;
  Paint? _paint2;

  PathPainter(this.progress, this.buttonSize) {
    _paint = new Paint()
      ..color = Colors.blue //画笔颜色
      ..style = PaintingStyle.stroke
      ..strokeWidth = buttonSize.borderWidth
      ..isAntiAlias = true;
    _paint2 = new Paint()
      ..color = Colors.black38 //画笔颜色
      ..style = PaintingStyle.stroke
      ..strokeWidth = buttonSize.borderWidth
      ..isAntiAlias = true;
  }

  //定义画笔

  @override
  void paint(Canvas canvas, Size size) {
    Path startPath = new Path();
    startPath.addRRect(
      RRect.fromLTRBR(
          -1.7, -1.7, buttonSize.height+1.7, buttonSize.width+1.7, buttonSize.radius),
    );
    //测量Path
    PathMetrics pathMetrics = startPath.computeMetrics();
    PathMetric pathMetric = pathMetrics.first;
    //测量并裁剪Path
    Path extrPath = pathMetric.extractPath(0, pathMetric.length * progress,
        startWithMoveTo: true);
    canvas.drawPath(startPath, _paint2!);
    canvas.drawPath(extrPath, _paint!);

    // canvas.drawPath(startPath, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //返回ture 实时更新
    return true;
  }
}
