//
//  ChinaCityClass.h
//  CloudBox
//
//  Created by TTS on 15-3-31.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChinaCityClass : NSObject

+ (NSArray *)cityArray;
//+ (NSArray *)provinceArray;
+ (NSArray *)getCitysWithProvince:(NSString *)name;

@end
