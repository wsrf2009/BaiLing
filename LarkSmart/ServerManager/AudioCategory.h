//
//  AudioCategory.h
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ITEMMETHOD_VALUE_GETAUDIOCATEGORY       @"getAudioCategory"

@interface AudioCategory : NSObject

- (NSDictionary *)getAudioCategoryWithID:(NSString *)Id;

/** 从data中解析出音乐列表 */
- (NSMutableArray *)analyzeAudioCategoryData:(NSData *)data;

/** 从rootListArray中获取出类别ID为subId的子类 */
+ (NSMutableArray *)getSubCategoryListFromRootCategoryListArray:(NSMutableArray *)rootListArray withSubCategoryId:(NSString *)subId;

/** 在类ID为rootId的categoryList中找到ID为subId的子类的标题 */
+ (NSString *)getTitleFromCategoryList:(NSMutableArray *)categoryList withRootCategoryID:(NSString *)rootId withSubCategoryId:(NSString *)subId;

@end

