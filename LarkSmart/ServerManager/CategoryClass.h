//
//  CategoryClass.h
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JSONITEM_CATEGORY_CATEGORY      @"category"
#define JSONITEM_CATEGORY_SUBCATEGORY   @"subCategory"

@interface CategoryClass : NSObject
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, assign) BOOL hassub;

+ (NSDictionary *)getCategoryWithCategoryId:(NSString *)cId;

/** 解析音乐类，获取categoryId，title，icon，hassub */
+ (CategoryClass *)parseCategory:(NSDictionary *)categoryItem;

/** 根据Id从给定的rootArray音乐类列表中获取出相应的音乐类 */
+ (CategoryClass *)getSubCategoryFromRootCategoryArray:(NSMutableArray *)rootArray withSubCategoryId:(NSString *)Id;

@end
