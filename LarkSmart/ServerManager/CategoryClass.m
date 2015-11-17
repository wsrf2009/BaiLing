//
//  CategoryClass.m
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "CategoryClass.h"

#define JSONITEM_AUDIOCATEGORY_CATEGORYID   @"categoryid"
#define JSONITEM_AUDIOCATEGORY_TITLE        @"title"
#define JSONITEM_AUDIOCATEGORY_ICON         @"icon"
#define JSONITEM_AUDIOCATEGORY_HASSUB       @"hassub"

// 是否有子目录 JSONITEM_AUDIOCATEGORY_HASSUB
#define CATEGORY_HAS_SUB        @"true"
#define CATEGORY_NO_SUB         @"false"
 
@implementation CategoryClass

+ (NSDictionary *)getCategoryWithCategoryId:(NSString *)cId {
    return @{JSONITEM_AUDIOCATEGORY_CATEGORYID:cId};
}

+ (CategoryClass *)parseCategory:(NSDictionary *)categoryItem {
    if (nil == categoryItem) {
        return nil;
    }
    
    CategoryClass *category = [[CategoryClass alloc] init];
    
    NSString *categoryIdItem = [categoryItem objectForKey:JSONITEM_AUDIOCATEGORY_CATEGORYID];
    if (nil != categoryIdItem) {
        category.categoryId = categoryIdItem;
    }
    
    NSString *categoryTitleItem = [categoryItem objectForKey:JSONITEM_AUDIOCATEGORY_TITLE];
    if (nil != categoryTitleItem) {
        category.title = categoryTitleItem;
    }
    
    NSString *categoryIconItem = [categoryItem objectForKey:JSONITEM_AUDIOCATEGORY_ICON];
    if (nil != categoryIconItem) {
        category.icon = categoryIconItem;
    }
    
    NSNumber *categoryHassubItem = [categoryItem objectForKey:JSONITEM_AUDIOCATEGORY_HASSUB];
    if (nil != categoryHassubItem) {
        category.hassub = [categoryHassubItem boolValue];
    }
    
    return category;
}

+ (CategoryClass *)getSubCategoryFromRootCategoryArray:(NSMutableArray *)rootArray withSubCategoryId:(NSString *)Id {
    for (CategoryClass *category in rootArray) {
        if ([category.categoryId isEqualToString:Id]) {
            return category;
        }
    }
    
    return nil;
}

@end
