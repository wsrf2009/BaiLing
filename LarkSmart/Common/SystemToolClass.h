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

/** 获得设备型号 */
+ (NSString *)getCurrentDeviceModel;

/*
 *  返回手机别名，用户自定义的名字
 */
+ (NSString *)deviceName;
/*
 * 返回当前手机操作系统的版本号
 */
+ (NSString *)IOSVersion;

+ (BOOL)systemVersionIsNotLessThan:(NSString *)version;

+ (NSString *)appName;

/*
 * 返回APP当前的版本号
 */
+ (NSString *)appVersion;

+ (NSString *)appBuildVersion;

/*
 * 获取APP的唯一识别号，在重新安装后，该号会更改
 */
+ (NSString*)uuid;
/*
 * 获取手机的IP地址
 */
+ (NSString *)IPAddress;

/*
 * 获取Http 服务器的端口号
 */
+ (NSString *)httpServerPort;

/*
 * 获取当前正在显示的视图控制器
 */
+ (UIViewController *)appRootViewController;

/*
 * 获取状态条的高度
 */
+ (CGFloat)statustBarHeight;

/*
 * 获取导航条的高度
 */
+ (CGFloat)navigationBarHeight;

+ (CGFloat)screenWidth;

+ (CGFloat)screenHeigth;
/** 获取屏幕的scale */
+ (CGFloat)screenScale;

/** 获取一个［from， to）之间的整数，包括from，不包括to */
+ (int)getRandomNumber:(int)from to:(int)to;

extern NSInteger stringCompare(id obj1, id obj2, void *context);

@end
