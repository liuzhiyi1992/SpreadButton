# SpreadButton  
![](https://img.shields.io/badge/pod-v0.2.1-blue.svg)
![](https://img.shields.io/badge/license-MIT-brightgreen.svg)
![](https://img.shields.io/badge/supporting-Swift2.2-orange.svg)
![](https://img.shields.io/badge/supporting-objectiveC-yellow.svg)
![](https://img.shields.io/badge/build-passing-brightgreen.svg)  

##Summary:  
A Button spread its sub path buttons like the flower or sickle(two spread mode) if you click it, once again, close.And you can also change the SpreadPositionMode between FixedMode & TouchBorderMode， while one like the marbleBall fixed on the wall, another one like the AssistiveTouch is iphone。  
顾名思义，一个会散开的功能按钮，主体按钮被点击后，触发目录按钮的展开，选择其中一个功能子按钮或点击任意地方，触发子按钮的收缩隐藏。 SpreadButton设计有 2种展开方式，2种位置模式，8种展开方向。   

###近期更新：  
- 0.2.1： 适配 swift3.0  
- 0.2.0:  更新 swift2.2语法, oc版可变参对CGPoint更稳定  
- 0.1.6:  更新 objective-C 版  
- 0.1.5:  SpreadPositionModeTouchBorder (you can use it like the IOS AssistiveTouch but in the app)(应用内的AssistiveTouch)  
- 0.1.4:  SpreadPositionModeFixed 增加物理吸附效果(可拖动，送开回弹)，凸显层次性，告别生硬的坐标约束

![](https://raw.githubusercontent.com/liuzhiyi1992/MyStore/master/%E9%80%81%E6%99%BA1.gif)  

<br>
>个人博客原文: http://zyden.vicp.cc/zyspreadbutton/  
欢迎转载，请注明出处谢谢   

<br>

![](https://raw.githubusercontent.com/liuzhiyi1992/MyStore/master/SpreadButton%E6%BC%94%E7%A4%BApart1.gif)
![](https://raw.githubusercontent.com/liuzhiyi1992/MyStore/master/SpreadButton%E6%BC%94%E7%A4%BApart2.gif)  
**两种展开模式(SpreadMode)：**镰刀模式 & 花朵模式  

<br>
![](https://raw.githubusercontent.com/liuzhiyi1992/MyStore/master/SpreadButton%E5%8F%8CPosition%E6%A8%A1%E5%BC%8F%E6%BC%94%E7%A4%BA.gif)  
**两种位置模式(SpreadPositionMode)：**锁定模式 & 粘连边缘模式，在粘连边缘模式下，根据主体按钮的位置，会实时更新展开模式  
<br>

##Contact  
####you can play the demo online in [appetize.io](https://appetize.io/app/dqfahewadr8g08ghdvxffqe6j4?device=iphone5s&scale=75&orientation=portrait&osVersion=9.2)    
####在这里可以在线试玩这个应用
<br>  

##Installation  
####Cocoapods   
```
pod 'SpreadButton', '~> 0.2.1'
```
####Fork from my github
you can select SpreadButton coded by objc or swift in directory corresponding  
目前已支持oc和swift两种语言，可以根据需要在相应的文件夹中找到  

<br>  
##Custom-made
**Property：**  
- animationDuring: assign the ‘animationDuring’ can also change ‘animationDuringSpread’ & ‘animationDuringClose’，default is 0.2  
- coverAlpha  
- coverColor  
- mode:    `case SpreadModeSickleSpread  case SpreadModeFlowerSpread`  
- radius: spread Radius  
- direction:  `case SpreadDirectionTop case SpreadDirectionBottom case SpreadDirectionLeft case SpreadDirectionRight case SpreadDirectionLeftUp case SpreadDirectionLeftDown case SpreadDirectionRightUp case SpreadDirectionRightDown`  
- touchBorderMargin: margin border in SpreadPositionModeTouchBorder  
- buttonWillSpreadBlock  
- buttonDidSpreadBlock  
- buttonWillCloseBlock  
- buttonDidCloseBlock  
<br>  
**private static:**  
---you can edit the default in the source---  
- private static let sickleSpreadAngleDefault: CGFloat = 90.0  
- private static let flowerSpreadAngleDefault: CGFloat = 120.0  
- private static let spredaDirectionDefault: SpreadDirection = .SpreadDirectionTop  
- private static let spreadRadiusDefault: CGFloat = 100.0  
- private static let coverAlphaDefault: CGFloat = 0.1  
- private static let touchBorderMarginDefault: CGFloat = 10.0  
- private static let touchBorderAnimationDuringDefault = 0.5  
- private static let animationDuringDefault = 0.2

##Usage
以swift为例子：  
1.通过SpreadButton的构造方法来创建一个SpreadButton对象，传入主体按钮的背景图片，高亮图片(非必须)，还有位置，如果传入的UIImage为nil，放心，编译时就会报错
```swift
let spreadButton = SpreadButton(image: UIImage(named: "powerButton"),
                       highlightImage: UIImage(named: "powerButton_highlight"),
                             position: CGPointMake(40, UIScreen.mainScreen().bounds.height - 40))
```

2.创建子按钮(SpreadSubButton)，传入背景图片，高亮图片(非必须)，还有一个尾随闭包，子按钮被点击后我们这个闭包会被调用，同样的，如果传入的UIImage为nil，编译时会报错  
```swift
let btn1 = SpreadSubButton(backgroundImage: UIImage(named: "clock"), 
                            highlightImage: UIImage(named: "clock_highlight")) { (index, sender) -> Void in
     print("first button be clicked!!!")
}

let btn2 = SpreadSubButton(backgroundImage: UIImage(named: "pencil"), 
                            highlightImage: UIImage(named: "pencil_highlight")) { (index, sender) -> Void in
     print("second button be clicked!!!")
}
//像这样你可以创建更多
```

3.通过-setSubButtons为SpreadButton设置子按钮，这里你可以传入nil或者SpreadButton?试试，没关系，里面做了保险，会排除，哈哈扯远了，用到的知识可以看看我的[这篇文章](http://zyden.vicp.cc/map-those-arrays/)
```swift
spreadButton?.setSubButtons([btn1, btn2, btn3, btn4, btn5])
```

4.根据你的需求，去定制这个SpreadButton，具体可以选什么参数，看看上面的Custom-made
```swift
spreadButton?.mode = SpreadMode.SpreadModeSickleSpread
spreadButton?.direction = SpreadDirection.SpreadDirectionRightUp
spreadButton?.positionMode = SpreadPositionMode.SpreadPositionModeFixed

/*  and you can assign a newValue to change the default
spreadButton?.animationDuring = 0.2
spreadButton?.animationDuringClose = 0.25
spreadButton?.radius = 180
spreadButton?.coverAlpha = 0.3
spreadButton?.coverColor = UIColor.yellowColor()  
spreadButton?.touchBorderMargin = 10.0
*/
```

5.每种动作的前后，都有对应的Block供使用，像这样给他们赋值:
```swift
spreadButton?.buttonWillSpreadBlock = { print(CGRectGetMaxY($0.frame)) }
spreadButton?.buttonDidSpreadBlock = { _ in print("did spread") }
spreadButton?.buttonWillCloseBlock = { _ in print("will closed") }
spreadButton?.buttonDidCloseBlock = { _ in print("did closed") }
```

6.最后加到你的view里面，ok，可以开始玩耍
```swift
if spreadButton != nil {
    self.view.addSubview(spreadButton!)
}
```

##Relation  
[@liuzhiyi1992](https://github.com/liuzhiyi1992) on Github  
[SpreadButton](http://zyden.vicp.cc/zyspreadbutton/) in my Blog
  
<br>
##License  
SpreadButton is released under the MIT license. See LICENSE for details.
