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
- (NSMutableArray *)analyzeAudioCategoryData:(NSData *)data;
+ (NSMutableArray *)getSubCategoryListFromRootCategoryListArray:(NSMutableArray *)rootListArray withSubCategoryId:(NSString *)subId;
+ (NSString *)getTitleFromCategoryList:(NSMutableArray *)categoryList withRootCategoryID:(NSString *)rootId withSubCategoryId:(NSString *)subId;

@end

