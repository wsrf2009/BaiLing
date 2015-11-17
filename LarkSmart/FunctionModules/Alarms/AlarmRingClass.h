//
//  AlarmRingClass.h
//  CloudBox
//
//  Created by TTS on 15-4-10.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmRingClass : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) NSString *fileName;

/** 获取起床闹铃的铃声数组 */
+ (NSArray *) getRingArray;

/** 从给定的路径path中取出铃声的名字 */
+ (NSString *)getNameFromPath:(NSString *)path;

/** 从给定的路径path中找出该铃声在铃声数组中的位置－－－偏移量 */
+ (NSInteger) getIndexFromPath:(NSString *)path;

/** 依赖于给定的数组偏移量生成对应的铃声完全路径 */
+ (NSString *) getPathViaIndex:(NSInteger)index;

@end
