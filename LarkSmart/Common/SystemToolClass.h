//
//  SystemToolClass.h
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SystemToolClass : NSObject

/** 获取设备型号，如@"iPhone 4S (A1387/A1431)" */
+ (NSString *)getCurrentDeviceModel;

/** 获取手机别名，用户自定义的名字 */
+ (NSString *)deviceName;

/** 获取当前手机操作系统的版本号，如IOS 8.0 */
+ (NSString *)IOSVersion;

/** 
 判断系统是否低于某一版本号
 @param version 给定的系统版本号，例如@"8.0"
 @return 如果系统版本高于给定的版本，YES；否则，NO
 */
+ (BOOL)systemVersionIsNotLessThan:(NSString *)version;

/** 获取APP的名字，如@"百灵智能" */
+ (NSString *)appName;

/** 获取APP当前的版本号，如@"01.00" */
+ (NSString *)appVersion;

/** 获取APP Build */
+ (NSString *)appBuildVersion;

/** 
 获取APP的唯一识别号
 @note 在重新安装APP后，该号会更改
 */
+ (NSString*)uuid;

/** 获取手机的IP地址 */
+ (NSString *)IPAddress;

/** 获取Http 服务器的端口号 */
+ (NSString *)httpServerPort;

/** 获取当前正在显示的视图控制器 */
+ (UIViewController *)appRootViewController;

/** 获取状态条的高度 */
+ (CGFloat)statustBarHeight;

/** 获取导航条的高度 */
+ (CGFloat)navigationBarHeight;

/** 获取屏幕的宽度 */
+ (CGFloat)screenWidth;

/** 获取屏幕的高度 */
+ (CGFloat)screenHeigth;

/** 获取屏幕的scale */
+ (CGFloat)screenScale;

/** 获取一个［from， to）之间的整数，包括from，不包括to */
+ (int)getRandomNumber:(int)from to:(int)to;

extern NSInteger stringCompare(id obj1, id obj2, void *context);

@end
