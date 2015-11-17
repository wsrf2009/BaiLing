//
//  ChinaCityClass.h
//  CloudBox
//
//  Created by TTS on 15-3-31.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChinaCityClass : NSObject

/** 获得中国所有按省份分类的城市列表 */
+ (NSArray *)cityArray;
//+ (NSArray *)provinceArray;

/** 获得某一省name的所有城市列表 */
+ (NSArray *)getCitysWithProvince:(NSString *)name;

@end
