//
//  AudioCategory.m
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AudioCategory.h"
#import "YYTXJsonObject.h"
#import "CategoryClass.h"

@implementation AudioCategory

- (NSDictionary *)getAudioCategoryWithID:(NSString *)Id {
    return [CategoryClass getCategoryWithCategoryId:Id];
}

- (NSMutableArray *)analyzeAudioCategoryData:(NSData *)data {
    if (nil == data) {
        return nil;
    }
    
    NSError *err;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (nil == root) {
        NSLog(@"%s %@", __func__, err);
        return nil;
    }
    
    NSDictionary *resultItem = [[[YYTXJsonObject alloc] init] getResultValueFromRootObject:root];
    if (nil == resultItem) {
        return nil;
    }
    
    NSDictionary *rootCategoryItem = [resultItem objectForKey:JSONITEM_CATEGORY_CATEGORY];
    if (nil == rootCategoryItem) {
        return nil;
    }
    
    NSMutableArray *category = [[NSMutableArray alloc] init];
    
    /* 首先将音乐类自身添加进category，如果该音乐类有子类，则继续将子类添加进去 */
    CategoryClass *rootCategory = [CategoryClass parseCategory:rootCategoryItem];
    [category addObject:rootCategory];
    if (rootCategory.hassub) {
        NSArray *subCategoryItems = [resultItem objectForKey:JSONITEM_CATEGORY_SUBCATEGORY];
        if (nil == subCategoryItems) {
            return category;
        }
        
        for (NSDictionary *subCategoryItem in subCategoryItems) {
            CategoryClass *subCategory = [CategoryClass parseCategory:subCategoryItem];
            if (nil == subCategory) {
                return category;
            }
            
            [category addObject:subCategory];
        }
    }
    
    return category;
}

+ (NSString *)getTitleFromCategoryList:(NSMutableArray *)categoryList withRootCategoryID:(NSString *)rootId withSubCategoryId:(NSString *)subId {
    CategoryClass *rootCategory = categoryList[0];
    if ([rootCategory.categoryId isEqualToString:rootId]) {
        for (CategoryClass *c in categoryList) {
            if ([c.categoryId isEqualToString:subId]) {
                return c.title;
            }
        }
    }
    
    return nil;
}

+ (NSMutableArray *)getSubCategoryListFromRootCategoryListArray:(NSMutableArray *)rootListArray withSubCategoryId:(NSString *)subId {
    
    for (NSMutableArray *categoryList in rootListArray) {
        CategoryClass *c = categoryList[0];

        if ([c.categoryId isEqualToString:subId]) {
            return categoryList;
        }
    }
    
    return nil;
}

@end
