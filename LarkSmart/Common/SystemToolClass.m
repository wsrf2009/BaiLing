//
//  SystemToolClass.m
//  CloudBox
//
//  Created by TTS on 15-5-5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SystemToolClass.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "sys/utsname.h"

@implementation SystemToolClass

/** 获得设备型号 */
+ (NSString *)getCurrentDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"])
        return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"])
        return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"])
        return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"])
        return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"])
        return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"])
        return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"])
        return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"])
        return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"])
        return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"])
        return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"])
        return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"])
        return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"])
        return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"])
        return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"])
        return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])
        return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])
        return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])
        return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])
        return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])
        return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])
        return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])
        return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])
        return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])
        return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])
        return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])
        return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])
        return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])
        return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])
        return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])
        return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])
        return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])
        return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])
        return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])
        return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])
        return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])
        return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])
        return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])
        return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])
        return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])
        return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])
        return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])
        return @"iPhone Simulator";
    
    return platform;
}

+ (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSString *)IOSVersion {
    NSString *sysNam = [[UIDevice currentDevice] systemName];
    NSString *sysVer = [[UIDevice currentDevice] systemVersion];
    
    return [sysNam stringByAppendingFormat:@" %@", sysVer];
}

+ (BOOL)systemVersionIsNotLessThan:(NSString *)version {
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSComparisonResult result = [version compare:systemVersion];
    if ((NSOrderedAscending == result) || (NSOrderedSame == result)) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)appName {

    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (nil != name) {
        return name;
    }
    
    name = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (nil != name) {
        return name;
    }
    
    name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    return name;
}

+ (NSString *)appVersion {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildVersion {

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*)uuid {
    /*
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    return (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
     */
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

// Get IP Address
+ (NSString *)IPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)httpServerPort {

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"HttpServerPort"];
}

+ (UIViewController *)appRootViewController {
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    return topVC;
}

+ (CGFloat)statustBarHeight {
    
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+ (CGFloat)navigationBarHeight {
    
    return [self appRootViewController].navigationController.navigationBar.frame.size.height;
}

+ (CGFloat)screenWidth {
    
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)screenHeigth {
    
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (CGFloat)screenScale {

    return [UIScreen mainScreen].scale;
}

+ (int)getRandomNumber:(int)from to:(int)to {
    
    return (int)(from + (arc4random() % (to - from + 1)));
}

NSInteger stringCompare(id obj1, id obj2, void *context) {
    NSString *str1 = obj1;
    NSString *str2 = obj2;
    
    return  [str1 localizedCompare:str2];
}

@end
