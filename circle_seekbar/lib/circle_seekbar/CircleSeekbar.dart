import 'package:circle_seekbar/circle_seekbar/CircleScaleSeekbarPaint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CircleScaleSeekbar extends StatefulWidget{
  final double centerImageWidth;
  final String imageName ;
  CircleScaleSeekbar({this.centerImageWidth = 200 ,this.imageName = "image/bg_wk_round.png" });
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CircleScaleSeekbarState(centerImageWidth : centerImageWidth,imageName:imageName);
  }
}

class CircleScaleSeekbarState extends State<CircleScaleSeekbar>{
  double centerImageWidth;
  String imageName ;
  CircleScaleSeekbarState({this.centerImageWidth,this.imageName});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircleScaleSeekbarPaint(
            //openAngle : 240 , rotateAngle : 150, banAreaAgle : -28 ,mainAgle = -30
            //openAngle : 270 , rotateAngle : 135, banAreaAgle : 0 , mainAngle = -45
            width: 300,
            height: 300,
            openAngle: 270,
            rotateAngle: 135,
            banAreaAngle: 0,
            seekbarScale1: SeekbarScale1(scaleWidth: 3,openAngle: 360,showDiffHeight: false),
            seekbarFillBlank : SeekbarFillBlank(angleRotate: 53),
            seekbarScale2 : SeekbarScale2(scaleWidth: 3),
            angleRate: 1,
            minTemp: 10,
            maxTemp: 40,
            seekbarCursor: new SeekbarCursor(showText: true,textHeadingAngle: 100,mainAngle: -45),
            seekbarCenterBitmap: new SeekbarCenterBitmap(),
            seekbarMobileText: SeekbarMobileText(textHeadingAngle : 100),
            isMobleText: false,
            isShowCursor: false,
            isShowCenterBitmap :false,
            seekbarScaleText: SeekbarScaleText(),
          )
        ],
    );
  }
}
class SeekbarText{

}
class SeekbarOpenAngle{

}
class SeekbarScale1{
  final double scaleRaidus;
  final int colorInt;
  final double scaleWidth;
  final StrokeCap strokeType;
  final double scaleHeight;
  final double scaleLongerHeight;
  final bool showDiffHeight;
  final double openAngle;

  SeekbarScale1({this.openAngle = 270 ,this.showDiffHeight = true,this.scaleRaidus = 120,this.colorInt = 0XFF00FFFF,this.scaleWidth = 8,this.scaleHeight = 20,this.strokeType = StrokeCap.square,this.scaleLongerHeight = 40});
}

class SeekbarScale2{
  final double scaleRaidus;
  final int colorInt;
  final double scaleWidth;
  final StrokeCap strokeType;
  final double scaleHeight;
  final double scaleLongerHeight;
  final bool showDiffHeight;

  SeekbarScale2({this.showDiffHeight = false ,this.scaleRaidus = 120,this.colorInt = 0XFF000000,this.scaleWidth = 8,this.scaleHeight = 20,this.strokeType = StrokeCap.square,this.scaleLongerHeight = 40});
}
class SeekbarCursor{
  final double cursorRradius;
  final double cursorHeadingAngle;
  final double mainAngle;
  final double textHeadingAngle;
  final String cursorImage;
  final double cursorWidth;
  final double cursorHeight;
  final String hindText;
  final TextStyle textStyle;
  final bool showText;

  SeekbarCursor({this.cursorHeadingAngle = -75,this.cursorRradius = 150, this.mainAngle = -30,this.textHeadingAngle = 100,
   this.hindText = "" , this.cursorImage = "image/adjust.png",this.cursorHeight = 50,this.cursorWidth = 70,this.textStyle,this.showText = true});
}

class SeekbarCenterBitmap{
  final String bitmap;
  final double width;
  final double height;
  final double headingAngle;

  SeekbarCenterBitmap({this.bitmap = "image/bg_wk_round.png",this.width = 200 , this.height = 200,this.headingAngle = -120});
}

class SeekbarMobileText{
  final String hindText;
  final double textRadius;
  final double textHeadingAngle;

  SeekbarMobileText({this.textHeadingAngle = 100 , this.textRadius = 100,this.hindText = ""});
}

class SeekbarScaleText{
  final double howAngle;
  final double textRadius;
  final double firstAngle;
  final double constraintsWidth;
  final ui.TextStyle textStyle;

  SeekbarScaleText({this.constraintsWidth = 20.0,this.firstAngle = 135 ,this.textRadius = 100,this.textStyle,this.howAngle = 5});
}

class SeekbarFillBlank{
  final double angleRotate;
  SeekbarFillBlank({this.angleRotate = 54});
}



//class SeekbarFillBlank{
//  final double angleRotate;
//
//  SeekbarFillBlank({this.angleRotate});
//}
