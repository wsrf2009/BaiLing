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

+ (NSArray *) getRingArray;
+ (NSString *)getNameFromPath:(NSString *)path;
+ (NSInteger) getIndexFromPath:(NSString *)path;
+ (NSString *) getPathViaIndex:(NSInteger)index;

@end
