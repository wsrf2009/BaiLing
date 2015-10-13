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
+ (CategoryClass *)parseCategory:(NSDictionary *)categoryItem;
+ (CategoryClass *)getSubCategoryFromRootCategoryArray:(NSMutableArray *)rootArray withSubCategoryId:(NSString *)Id;

@end
