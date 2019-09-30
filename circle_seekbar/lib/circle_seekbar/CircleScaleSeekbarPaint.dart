import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:circle_seekbar/circle_seekbar/CircleSeekbar.dart';
import 'package:circle_seekbar/circle_seekbar/CircleSeekbar.dart' as prefix0;
import 'package:circle_seekbar/circle_seekbar/SeekbarModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix1;
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:ui' as ui;
num degToRad(num deg) => deg * (pi / 180.0);
num radToDeg(num rad) => rad * (180.0 / pi);

typedef ProgressChanged<double> = void Function(double value);
class CircleScaleSeekbarPaint extends StatefulWidget{
  //每一度画多少条scale
  final double angleRate;
  //最小温度
  final int minTemp;
  //最大温度
  final int maxTemp;
  final double width;
  final double height;
  //当前的progress
  final double progress;
  //是否要换成可调节半径的text
  final bool isMobleText;
  //打开角度，最多到270℃
  final double openAngle;
  //旋转角度
  final double rotateAngle;
  //基础的scale刻画
  final SeekbarScale1 seekbarScale1;
  //变色的scale刻画
  final SeekbarScale2 seekbarScale2;
  //可跟随滑动的刻度图片
  final SeekbarCursor seekbarCursor;
  //中间图片
  final SeekbarCenterBitmap seekbarCenterBitmap;
  //可调节半径的text
  final SeekbarMobileText seekbarMobileText;
  //是否显示可跟随滑动的刻度图片
  final bool isShowCursor ;
  //是否显示中间图片;
  final bool isShowCenterBitmap;
  //调节不能胡奥迪那个的区域
  final double banAreaAngle;
  //移动刻度条后改变progress
  final ProgressChanged progressChanged;
  //填充空白的刻度
  final SeekbarFillBlank seekbarFillBlank;
  //显示刻度字
  final SeekbarScaleText seekbarScaleText;
  const CircleScaleSeekbarPaint({
    Key key,
    this.seekbarScaleText,
    this.seekbarFillBlank,
    this.banAreaAngle = 0 ,
    this.rotateAngle = 135,
    this.openAngle = 270,
    this.isShowCenterBitmap,
    this.isShowCursor,
    this.seekbarMobileText,
    this.seekbarCenterBitmap,
    this.isMobleText,
    this.seekbarCursor,
    this.seekbarScale2,
    this.seekbarScale1,
    this.width = 350,
    this.height = 350,

    this.angleRate = 10,
    this.minTemp = 10,
    this.maxTemp = 60,
    this.progress,
    this.progressChanged}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CircleScaleSeekbarPaintState(
        seekbarFillBlank : seekbarFillBlank,
        seekbarCursor : seekbarCursor,
        seekbarScale1: seekbarScale1,
        seekbarScale2 : seekbarScale2,
        angleRate: angleRate,
        rotateAngle: rotateAngle,
        banAreaAngle:banAreaAngle,
        minTemp: minTemp,
        maxTemp: maxTemp,
        width: width,
        height: height,
        isMobleText : isMobleText,
        seekbarCenterBitmap: seekbarCenterBitmap,
        seekbarMobileText : seekbarMobileText,
        isShowCursor : isShowCursor ,
        isShowCenterBitmap:isShowCenterBitmap,
        seekbarScaleText : seekbarScaleText,
        openAngle:openAngle);
  }
}

class CircleScaleSeekbarPaintState extends State<CircleScaleSeekbarPaint>  with SingleTickerProviderStateMixin {
  AnimationController progressController;
  final SeekbarScaleText seekbarScaleText;
  final double openAngle;
  final double angleRate;
  final int minTemp;
  final int maxTemp;
  final bool isMobleText;
  final double width;
  final double banAreaAngle;
  final SeekbarMobileText seekbarMobileText;
  final SeekbarScale1 seekbarScale1;
  final SeekbarScale2 seekbarScale2;
  final SeekbarCenterBitmap seekbarCenterBitmap;
  final bool isShowCursor;
  final double height;
  final SeekbarCursor seekbarCursor;
  final bool isShowCenterBitmap;
  final GlobalKey paintKey = GlobalKey();
  final double rotateAngle ;
  final SeekbarFillBlank seekbarFillBlank;
  double goingValue = 0.0;
  bool isValidTouch = false;
  bool isDragStop = false;
  ui.Image bitmapImage;
  double bitmapRadians = 0;
  double bitmapAngle = 0;
  double blankTemp = 0;
  int nowPorgress = 0;
  double angleOne = 0;

  CircleScaleSeekbarPaintState({
    this.seekbarScaleText,
    this.seekbarFillBlank,
    this.seekbarMobileText,
    this.seekbarCenterBitmap,
    this.isMobleText,
    this.openAngle,
    this.seekbarCursor,
    this.seekbarScale1,
    this.seekbarScale2,
    this.isShowCursor,
    this.rotateAngle,
    this.angleRate,
    this.minTemp,
    this.isShowCenterBitmap,
    this.maxTemp,
    this.height,
    this.width,
    this.banAreaAngle});


  @override
  void initState() {
    super.initState();
//    _prepareImg();
    nowPorgress = minTemp;
    angleOne = openAngle/(maxTemp - minTemp);
    blankTemp = (1-(openAngle / 360)) * (maxTemp - minTemp).toInt() + 1;
    print("blankTemp的数量:" + blankTemp.toString());
    progressController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    if (widget.progress != null) progressController.value = widget.progress;
    progressController.addListener(() {
      if (widget.progressChanged != null)
        widget.progressChanged(progressController.value);
      setState(() {
//        if((progressController.value * (maxTemp - minTemp) * (3/2) + minTemp < maxTemp && progressController.value * (maxTemp - minTemp) * (3/2) + minTemp > maxTemp - 1 ))
//          nowPorgress = maxTemp;
//        else
        goingValue = progressController.value * (maxTemp - minTemp) * (360/openAngle);
        print("打印一下goingValue + minTemp : ${goingValue + minTemp}");
        if(maxTemp - (goingValue + minTemp) < 0.5) nowPorgress = maxTemp;
        else nowPorgress = goingValue.toInt()+minTemp;
      });
    });

    changeTemp();
  //**************************************************************************绘制图片可以用这个方法**********************************************************************************
//    getImage(seekbarCursor.cursorImage).then((data) {
//      if (mounted) {
//        setState(() {
//          bitmapImage = data;
//        });
//      }
//    });
  }

  static Future<ui.Image> getImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    var codec = (await ui.instantiateImageCodec(data.buffer.asUint8List()));
    FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("goingValue:${goingValue + minTemp}");
    print("nowPorgress:${nowPorgress}");
    final Size size = Size(width,width);
    // TODO: implement build
    return   GestureDetector(
        onPanStart: _onPanstart,
        onPanUpdate: _onPanUpdate,
        onPanEnd:_onPanEnd,
        child:Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Offstage(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(degToRad(seekbarFillBlank != null ? seekbarFillBlank.angleRotate : 0)),
                child: Container(
                  width: width,
                  height: height,
                  child: CustomPaint(
                    key: widget.key,
                    size: size,
                    painter: ScaleFillPainter(seekbarScale1: seekbarScale1,angleOne:angleOne,angleRate:angleRate,minTemp: minTemp,maxTemp: maxTemp,width: width,height: height,blankTemp: blankTemp),
                  ) ,
                ),
              ),
              offstage: (seekbarFillBlank == null),
            ),
            Offstage(
              child: Transform(
                  alignment: Alignment.center,
                  child: Image.asset(seekbarCenterBitmap.bitmap,width: seekbarCenterBitmap.width,height: seekbarCenterBitmap.height,),
                  transform: Matrix4.rotationZ(degToRad(!isDragStop ?  seekbarCenterBitmap.headingAngle + progressController.value * 360 : seekbarCenterBitmap.headingAngle+ (nowPorgress - minTemp) * angleOne))
              ),
              offstage: !isShowCenterBitmap,
            ),
//            transform: Matrix4.rotationZ( degToRad(nowPorgress == 0 ? -120 : -120+ (nowPorgress - minTemp) * angle)),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(degToRad(rotateAngle)),
              child: Container(
                width: width,
                height: height,
                child: CustomPaint(
                  key: widget.key,
                  size: size,
                  painter: Scale1Painter(seekbarScale1: seekbarScale1,angleOne:angleOne,angleRate:angleRate,minTemp: minTemp,maxTemp: maxTemp,width: width,height: height,openAngle: seekbarScale1.openAngle),
                ) ,
              ),
            ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(degToRad(rotateAngle)),
              child: Container(
                width: width,
                height: height,
                child: CustomPaint(
                  key: paintKey,
                  size: size,
                  painter: Scale2Painter(seekbarScale2: seekbarScale2,angleOne:angleOne,angleRate: angleRate,minTemp: minTemp,maxTemp: maxTemp,width: width,height: height,openAngle: openAngle,nowTemp: nowPorgress),
                ) ,
              ),
            ),
            Offstage(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(degToRad(seekbarCursor.mainAngle)),
                child: Transform(
                    alignment: Alignment.center,
                    child: Transform(
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Image.asset(seekbarCursor.cursorImage,width: seekbarCursor.cursorWidth,height: seekbarCursor.cursorHeight,),
                            Offstage(
                              child:  Transform(
                                transform: Matrix4.rotationZ(degToRad(!isDragStop ? seekbarCursor.textHeadingAngle - progressController.value * 360 : seekbarCursor.textHeadingAngle - (nowPorgress - minTemp) * angleOne)),
                                alignment: Alignment.center,
                                child: Text("${nowPorgress}${seekbarCursor.hindText}"),
                              ),
                              offstage: !seekbarCursor.showText,
                            ),

                          ],
                        ),
                        transform: Matrix4.rotationZ(degToRad(!isDragStop ?  seekbarCursor.cursorHeadingAngle + progressController.value * 360 : seekbarCursor.cursorHeadingAngle + (nowPorgress - minTemp) * angleOne))
                    ),
                    transform: Matrix4.translationValues(!isDragStop ? -seekbarCursor.cursorRradius * cos(degToRad(progressController.value*360)) : -seekbarCursor.cursorRradius * cos(degToRad(nowPorgress - minTemp) * angleOne) ,
                        !isDragStop ? -seekbarCursor.cursorRradius*sin(degToRad(progressController.value*360)) : -seekbarCursor.cursorRradius * sin(degToRad(nowPorgress - minTemp) * angleOne),0)
                ),),
              offstage: !isShowCursor,
            ),
            Offstage(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(degToRad(seekbarCursor.mainAngle)),
                child: Transform(
                    alignment: Alignment.center,
                    child: Transform(
                        alignment: Alignment.center,
                        child:
                           Transform(
                                transform: Matrix4.rotationZ(degToRad(!isDragStop ? seekbarMobileText.textHeadingAngle - progressController.value * 360 : seekbarMobileText.textHeadingAngle - (nowPorgress - minTemp) * angleOne)),
                                alignment: Alignment.center,
                                child: Text("${nowPorgress}${seekbarMobileText.hindText}"),
                              ),
                        transform: Matrix4.rotationZ(degToRad(!isDragStop ?  seekbarCursor.cursorHeadingAngle + progressController.value * 360 : seekbarCursor.cursorHeadingAngle + (nowPorgress - minTemp) * angleOne))
                    ),
                    transform: Matrix4.translationValues(!isDragStop ? -seekbarMobileText.textRadius * cos(degToRad(progressController.value*360)) : -seekbarMobileText.textRadius * cos(degToRad(nowPorgress - minTemp) * angleOne) ,
                        !isDragStop ? -seekbarMobileText.textRadius*sin(degToRad(progressController.value*360)) : -seekbarMobileText.textRadius * sin(degToRad(nowPorgress - minTemp) * angleOne),0)
                ),),
              offstage: !isMobleText,
            ),

           Transform(
                alignment: Alignment.center,
                transform:  Matrix4.rotationZ(degToRad(0)),
                child: Container(
                  width: width,
                  height: height,
                  child: CustomPaint(
                    key: widget.key,
                    size: size,
                    painter: ScaleTextPaint(seekbarScaleText: seekbarScaleText,angleOne:angleOne,angleRate:angleRate,minTemp: minTemp,maxTemp: maxTemp,width: width,height: height,openAngle: seekbarScale1.openAngle),
                  ) ,
                ),
              ),



//            Transform(
//              alignment: Alignment.center,
//              child: Transform(
//                alignment: Alignment.center,
//                child:Text("${nowPorgress}"),
//                transform: Matrix4.translationValues(!isDragStop ? -bitmapTadius * cos(degToRad(progressController.value*360)) : -bitmapTadius * cos(degToRad(nowPorgress - minTemp) * angle) ,
//                    !isDragStop ? -bitmapTadius*sin(degToRad(progressController.value*360)) : -bitmapTadius * sin(degToRad(nowPorgress - minTemp) * angle),0),
//              ),
//              transform: Matrix4.rotationZ(50),
//            )
//            Transform(
//              alignment: Alignment.center,
//              child: Image.asset("image/adjust.png",width: 50,height: 50,),
//              transform: Matrix4.rotationZ(degToRad(120)),
//            ),
          ],
        )
    );
  }

  void _onPanstart(DragStartDetails details) {
    RenderBox getBox = paintKey.currentContext.findRenderObject();
    Offset local = getBox.globalToLocal(details.globalPosition);
    isValidTouch = _checkValidTouch(local);

    if(!isValidTouch) return ;
    else   print("打印一下触摸地方: x:${local.dx},y:${local.dy}");
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if(!isValidTouch) return;
    setState(() {
     isDragStop = false;
    });
    RenderBox getBox = paintKey.currentContext.findRenderObject();
    Offset local = getBox.globalToLocal(details.globalPosition);
    final double x = local.dx;
    final double y = local.dy;
    final double center = width / 2;
    double radians = atan((x-center) / (center - y));

    if(y > center){
      radians = radians + degToRad(90.0);
//      print("y> center : 打印bitmapRadians:${bitmapRadians}");
      print("y> center : 打印radians:${radians}");
      progressController.value = radians / degToRad(360.0);
    }else if(x < center){
     if(radToDeg(radians) > banAreaAngle){
//       print("进入没有被画的区域 : 打印bitmapRadians:${bitmapRadians}");
       print("进入没有被画的区域");
     }else{
       print("x < center : 打印bitmapRadians:${bitmapRadians}");
       radians = radians + degToRad(270.0);
       bitmapRadians = radians;
//       print("x < center: 打印radians:${radians}");
       progressController.value = radians / degToRad(360.0);
     }
    }
//    else if(y > center - sin(radians) * circleRadius  && y < center && x > center){
//      print("y > center : 打印bitmapRadians:${bitmapRadians}");
//      print("进入没有被画区域");
//    }
  }
  void _onPanEnd(DragEndDetails details) {
    print("打印一下现在的比率：${progressController.value * 100.toInt()}");
    setState(() {
      isDragStop = true;
      if(isDragStop){
        if(goingValue + minTemp < minTemp + 1) nowPorgress = minTemp;

      }
    });
//    if(progressController.value * )
    if (!isValidTouch) {
      return;
    }
  }

  bool _checkValidTouch(Offset local) {
    final double validInnerRadius = seekbarScale1.scaleRaidus + 40;
    final double dx = local.dx;
    final double dy = local.dy;
    final double distanceToCenter =
    sqrt(pow(dx - width/2  , 2) + pow(dy - width/2, 2));
    print("算一下distanceToCenter:${distanceToCenter}");
    if (distanceToCenter < validInnerRadius) {
      return true;
    }
    return false;
  }

  void changeTemp() {
    print("进入changetemp方法");
    setState(() {
      eventbus.on<SeekbarModle>().listen((event){
       if(event.setTemp > 60)  nowPorgress = 60;
       else  nowPorgress = event.setTemp;
      });
    });
  }



}

class CircleScaleSeekbarPainter extends CustomPainter {
  final double circleRadius;
  final double bitmapTadius;
  final int angleRate;
  final int minTemp;
  final int maxTemp;
  final double width;
  final double height;
  final double openAngle;
  CircleScaleSeekbarPainter({
    this.circleRadius,
    this.bitmapTadius,
    this.angleRate,
    this.minTemp,
    this.maxTemp,
    this.height,
    this.width,
    this.openAngle});
  @override
  void paint(Canvas canvas, Size size) {
    final Offset offsetCenter = Offset(size.width/2, size.height/2);
    final Offset zeroPoint = Offset(0.0,0.0);
    final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0XFF000000)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;



    double circleRadians = degToRad(openAngle);
    final Rect arcRect = Rect.fromCircle(center: offsetCenter,radius:bitmapTadius);
    canvas.drawArc(arcRect, 0.0, circleRadians, false, ringPaint);
    canvas.drawCircle(zeroPoint, 1, ringPaint);
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
class Scale1Painter extends CustomPainter {
  final int minTemp;
  final int maxTemp;
  final double width;
  final double height;
  final double openAngle;
  final double angleRate;
  final SeekbarScale1 seekbarScale1;
  final double angleOne;
  Scale1Painter({
    this.seekbarScale1,
    this.angleOne,
    this.angleRate,
    this.minTemp,
    this.maxTemp,
    this.height,
    this.width,
    this.openAngle});
  @override
  void paint(Canvas canvas, Size size) {
    final Offset offsetCenter = Offset(size.width/2, size.height/2);
    final Offset zeroPoint = Offset(0.0,0.0);
    final scalePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(seekbarScale1.colorInt)
      ..strokeWidth = seekbarScale1.scaleWidth
      ..strokeCap = seekbarScale1.strokeType;

    if(seekbarScale1.showDiffHeight)
      getDiffLineOffset(angleOne,canvas,scalePaint,size,angleRate);
    else
      getLineOffset(angleOne,canvas,scalePaint,size,angleRate);
    // TODO: implement paint
  }
//
  getDiffLineOffset(double angle,Canvas canvas,Paint scalePaint,Size size,double angleRate){
    int count = 0;
    for(double i = 0; i <=  angle * (maxTemp - minTemp); angleRate == 0 ? i = i+angle :i = i+angle/angleRate){
      if(i == 0)
        canvas.drawLine(new Offset(size.width/2+seekbarScale1.scaleRaidus, size.width/2), new Offset(size.width/2+seekbarScale1.scaleRaidus + seekbarScale1.scaleLongerHeight, size.width/2), scalePaint);
      else
      if(count % 5 ==0)
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale1.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleLongerHeight),size.width/2+sin(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleLongerHeight)), scalePaint);
      else
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale1.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight),size.width/2+sin(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight)), scalePaint);
      count++;
    }
  }
  getLineOffset(double angle,Canvas canvas,Paint scalePaint,Size size,double angleRate){
    int count = 0;
    for(double i = 0; i <=  angle * (maxTemp - minTemp); angleRate == 0 ? i = i+angle :i = i+angle/angleRate){
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale1.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight),size.width/2+sin(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight)), scalePaint);
      count++;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
class Scale2Painter extends CustomPainter {
  final double angleRate;
  final int minTemp;
  final int maxTemp;
  final double height;
  final double width;
  final double openAngle;
  final int nowTemp;
  final double angleOne;
  final SeekbarScale2 seekbarScale2;

  Scale2Painter({this.seekbarScale2,this.angleOne,this.minTemp,this.angleRate,this.maxTemp,this.height,this.width,this.openAngle,this.nowTemp});
  @override
  void paint(Canvas canvas, Size size) {

//    final double progressAngle = 360 * progress;
//    print("打印一下progressAngle: ${progressAngle}");
    final Offset offsetCenter = Offset(size.width/2, size.height/2);
    final Offset zeroPoint = Offset(0.0,0.0);
    final scalePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(seekbarScale2.colorInt)
      ..strokeWidth = seekbarScale2.scaleWidth
      ..strokeCap = seekbarScale2.strokeType;

  if(seekbarScale2.showDiffHeight)
    getDiffLineOffset(angleOne,canvas,scalePaint,size, angleRate);
  else
    getLineOffset(angleOne,canvas,scalePaint,size, angleRate);
    // TODO: implement paint
  }
//
  getDiffLineOffset(double angle,Canvas canvas,Paint scalePaint,Size size,double angleRate){
    int count = 0;
    for(double i = 0; i <=  angle * (nowTemp - minTemp); angleRate == 0.0 ? i = i+angle :i = i+angle/angleRate){
      if(i == 0)
        canvas.drawLine(new Offset(size.width/2+seekbarScale2.scaleRaidus, size.width/2), new Offset(size.width/2+seekbarScale2.scaleRaidus + seekbarScale2.scaleLongerHeight, size.width/2), scalePaint);
      else
      if(count % 5 ==0)
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale2.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale2.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale2.scaleRaidus+seekbarScale2.scaleLongerHeight),size.width/2+sin(degToRad(i))*(seekbarScale2.scaleRaidus+seekbarScale2.scaleLongerHeight)), scalePaint);
      else
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale2.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale2.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale2.scaleRaidus+seekbarScale2.scaleHeight),size.width/2+sin(degToRad(i))*(seekbarScale2.scaleRaidus+seekbarScale2.scaleHeight)), scalePaint);
      count++;
    }
  }

  getLineOffset(double angle,Canvas canvas,Paint scalePaint,Size size,double angleRate) {
    int count = 0;
    for(double i = 0; i <=  angle * (nowTemp - minTemp); angleRate == 0.0 ? i = i+angle :i = i+angle/angleRate){
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale2.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale2.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale2.scaleRaidus+seekbarScale2.scaleHeight),size.width/2+sin(degToRad(i))*(seekbarScale2.scaleRaidus+seekbarScale2.scaleHeight)), scalePaint);
      count++;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
class ScaleFillPainter extends CustomPainter {
  final int minTemp;
  final int maxTemp;
  final double width;
  final double height;
  final double blankTemp;
  final double angleRate;
  final SeekbarScale1 seekbarScale1;
  final double angleOne;
  ScaleFillPainter({
    this.seekbarScale1,
    this.angleOne,
    this.angleRate,
    this.minTemp,
    this.maxTemp,
    this.height,
    this.width,
    this.blankTemp});
  @override
  void paint(Canvas canvas, Size size) {
    final Offset offsetCenter = Offset(size.width/2, size.height/2);
    final Offset zeroPoint = Offset(0.0,0.0);
    final scalePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(seekbarScale1.colorInt)
      ..strokeWidth = seekbarScale1.scaleWidth
      ..strokeCap = seekbarScale1.strokeType;

    if(seekbarScale1.showDiffHeight)
      getDiffLineOffset(angleOne,canvas,scalePaint,size,angleRate);
    else
      getLineOffset(angleOne,canvas,scalePaint,size,angleRate);
    // TODO: implement paint
  }
//
  getDiffLineOffset(double angle,Canvas canvas,Paint scalePaint,Size size,double angleRate){
    int count = 0;
    for(double i = 0; i <=  angle * blankTemp; angleRate == 0 ? i = i+angle :i = i+angle/angleRate){
      if(i == 0)
        canvas.drawLine(new Offset(size.width/2+seekbarScale1.scaleRaidus, size.width/2), new Offset(size.width/2+seekbarScale1.scaleRaidus + seekbarScale1.scaleLongerHeight, size.width/2), scalePaint);
      else
      if(count % 5 ==0)
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale1.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleLongerHeight),size.width/2+sin(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleLongerHeight)), scalePaint);
      else
        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale1.scaleRaidus),
            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight),size.width/2+sin(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight)), scalePaint);
      count++;
      print("ScaleFillPainter  的count:${count}");

    }
  }
  getLineOffset(double angle,Canvas canvas,Paint scalePaint,Size size,double angleRate){
    int count = 0;
    for(double i = 0; i <=  angle * blankTemp; angleRate == 0 ? i = i+angle :i = i+angle/angleRate){
      canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale1.scaleRaidus),
          new Offset(size.width/2+cos(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight),size.width/2+sin(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleHeight)), scalePaint);
      print("ScaleFillPainter  的count:${count}");
      count++;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
class ScaleTextPaint extends CustomPainter {
  final int minTemp;
  final int maxTemp;
  final double width;
  final double height;
  final double openAngle;
  final double angleRate;
  final SeekbarScaleText seekbarScaleText;
  final double angleOne;
  ScaleTextPaint({
    this.seekbarScaleText,
    this.angleOne,
    this.angleRate,
    this.minTemp,
    this.maxTemp,
    this.height,
    this.width,
    this.openAngle});
  @override
  void paint(Canvas canvas, Size size) {

//    final scalePaint = Paint()
//      ..style = PaintingStyle.stroke
//      ..color = Color(0xff000000)
//      ..strokeWidth = seekbarScale1.scaleWidth
//      ..strokeCap = seekbarScale1.strokeType;

//    canvas.drawParagraph(paragraph, new Offset(size.width/2+cos(degToRad(1))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(1))*seekbarScale1.scaleRaidus));


//    if(seekbarScale1.showDiffHeight)
//      getDiffLineOffset(angleOne,canvas,scalePaint,size,angleRate,paragraph);
//    else
      getLineOffset(angleOne,canvas,size,angleRate,minTemp,maxTemp);
    // TODO: implement paint
  }
//
//  getDiffLineOffset(double angle,Canvas canvas,Paint scalePaint,Size size,double angleRate,ParagraphBuilder pb){
//    pb.pushStyle(ui.TextStyle(color:Color(0xFF000000)));
//    ui.ParagraphConstraints pc = ParagraphConstraints(width: 2);
//    Paragraph paragraph = pb.build()..layout(pc);
//    int count = 0;
//    for(double i = 0; i <=  angle * (maxTemp - minTemp); angleRate == 0 ? i = i+angle :i = i+angle/angleRate){
//      Offset point ;
//      pb.addText(count.toString());
//        canvas.drawParagraph(paragraph, new Offset(size.width/2+cos(degToRad(90))*seekbarScaleText.textRadius,size.width/2+sin(degToRad(90))*seekbarScaleText.textRadius));
////        canvas.draw
////      else
////      if(count % 5 ==0)
////        canvas.drawLine(new Offset(size.width/2+cos(degToRad(i))*seekbarScale1.scaleRaidus,size.width/2+sin(degToRad(i))*seekbarScale1.scaleRaidus),
////            new Offset(size.width/2+cos(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleLongerHeight),size.width/2+sin(degToRad(i))*(seekbarScale1.scaleRaidus+seekbarScale1.scaleLongerHeight)), scalePaint);
//      count++;
//    }
//  }
  getLineOffset(double angle,Canvas canvas,Size size,double angleRate,int minTemp,int maxTemp){
    int count = 0;
    Paragraph paragraph;
    ui.ParagraphConstraints pc;
    ParagraphBuilder pb ;
    for(double i = seekbarScaleText.firstAngle; i <=  (maxTemp - minTemp) * angleOne + seekbarScaleText.firstAngle; i = i+angleOne * seekbarScaleText.howAngle){
      Offset point ;
      if(i == seekbarScaleText.firstAngle){
        pb = ParagraphBuilder(ParagraphStyle(
          textAlign:  TextAlign.center,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.normal,
          fontSize: 15.0,
        ));
//      pb.addText(count.toString());
//        if( i == seekbarScaleText.firstAngle)
        pb.pushStyle(seekbarScaleText.textStyle == null ? ui.TextStyle(fontSize: 15,color:Color(0xFF000000)) : seekbarScaleText.textStyle);
        pb.addText(minTemp.toString());
        pc = ParagraphConstraints(width: seekbarScaleText.constraintsWidth);
        paragraph = pb.build()..layout(pc);
        canvas.drawParagraph(paragraph, new Offset(size.width/2+cos(degToRad(i))*seekbarScaleText.textRadius - paragraph.width/2  ,size.width/2+sin(degToRad(i))*seekbarScaleText.textRadius - paragraph.height/2));
      }else{
        pb = ParagraphBuilder(ParagraphStyle(
          textAlign:  TextAlign.center,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.normal,
          fontSize: 15.0,
        ));
//      pb.addText(count.toString());
//        if( i == seekbarScaleText.firstAngle)
        pb.pushStyle(seekbarScaleText.textStyle == null ? ui.TextStyle(fontSize: 15,color:Color(0xFF000000)) : seekbarScaleText.textStyle);
        pb.addText(((i - seekbarScaleText.firstAngle)/ angleOne + minTemp).toInt().toString());
        pc = ParagraphConstraints(width: seekbarScaleText.constraintsWidth);
        paragraph = pb.build()..layout(pc);
        canvas.drawParagraph(paragraph, new Offset(size.width/2+cos(degToRad(i))*seekbarScaleText.textRadius - paragraph.width/2  ,size.width/2+sin(degToRad(i))*seekbarScaleText.textRadius - paragraph.height/2));
      }
      count++;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
//class BitmapPainter extends CustomPainter {
//  final double circleRadius;
//  final double bitmapTadius;
//  final double angleRate;
//  final int minTemp;
//  final int maxTemp;
//  final double width;
//  final double height;
//  final double openAngle;
//  final ui.Image bitmapImage ;
//  final int nowTemp;
//  BitmapPainter({this.circleRadius,this.bitmapTadius,this.angleRate,this.minTemp,this.maxTemp,this.height,this.width,this.openAngle,this.bitmapImage,this.nowTemp});
//
//
//  @override
//  void paint(Canvas canvas, Size size) {
//
//    final Offset offsetCenter = Offset(size.width/2, size.height/2);
//    final ringPaint = Paint()
//      ..style = PaintingStyle.stroke
//      ..color = Color(0XFF000000)
//      ..strokeWidth = 1
//      ..strokeCap = StrokeCap.round;
//    final bitmapPainter = Paint()
//      ..isAntiAlias = true;
//
//
//    double circleRadians = degToRad(openAngle);
//    final Rect arcRect = Rect.fromCircle(center: offsetCenter,radius:bitmapTadius);
//    canvas.drawArc(arcRect, 0.0, circleRadians, false, ringPaint);
//
////    canvas.drawImage(bitmapImage,zeroPoint, bitmapPainter);
////    getLineOffset(scaleAngle,canvas,bitmapPainter,size,angleRate: 3.0);
//
//    // TODO: implement paint
//  }
//  Offset getLineOffset(double angle,Canvas canvas,Paint bitmapPaint,Size size,{double angleRate  = 0}){
//    int count = 0;
//    Offset imageOffset ;
//    for(double i = 0; i <=  angle * (nowTemp - minTemp); angleRate == 0.0 ? i = i+angle :i = i+angle/angleRate){
//     imageOffset = new Offset(size.width/2+cos(degToRad(i))*bitmapTadius,size.width/2+sin(degToRad(i))*bitmapTadius);
//      count++;
//    }
//    canvas.drawImage(bitmapImage,imageOffset, bitmapPaint);
////    canvas.drawImage(bitmapImage,new Offset(size.width/2+cos(degToRad(i))*bitmapTadius,size.width/2+sin(degToRad(i))*bitmapTadius), bitmapPaint);
//  }
//  @override
//  bool shouldRepaint(CustomPainter oldDelegate) {
//    // TODO: implement shouldRepaint
//    return true;
//  }
//
//
////  _prepareImg() {
////    _loadImage('images/icon_hzw02.jpg', false).then((image1) {
////      _image1 = image1;
////    }).whenComplete(() {
////      _loadImage('https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=703702342,1604162245&fm=26&gp=0.jpg', true)
////          .then((image2) {
////        _image2 = image2;
////      }).whenComplete(() {
////        _prepDone = true;
////        if (this.mounted) {
////          setState(() {});
////        }
////      });
////    });
////  }
//}