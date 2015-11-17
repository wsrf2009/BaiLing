//
//  ProductInfo.m
//  CloudBox
//
//  Created by TTS on 15-6-1.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ProductInfo.h"
#import "BoxDatabase.h"
#import "YYTXJsonObject.h"

#define JSONITEM_PRODUCTINFO_PRODUCT    @"product"
#define JSONITEM_PRODUCTINFO_PRODUCTID  @"productid"
#define JSONITEM_PRODUCTINFO_TITLE      @"title"
#define JSONITEM_PRODUCTINFO_DESCRIPTION    @"description"
#define JSONITEM_PRODUCTINFO_ICON           @"icon"
#define JSONITEM_PRODUCTINFO_URL            @"url"
#define JSONITEM_PRODUCTINFO_GUIDEIMAGE     @"guideimage"
#define JSONITEM_PRODUCTINFO_LASTUPDATETIME     @"lastupdatetime"
#define JSONITEM_PRODUCTINFO_GUIDETYPE      @"guidetype"

@implementation ProductInfo

+ (NSDictionary *)getAllTheProductsInfo {
    NSArray *productsItem = @[];
    
    return [NSDictionary dictionaryWithObject:productsItem forKey:JSONITEM_PRODUCTINFO_PRODUCTID];
}

+ (void)parseProductInfo:(NSData *)data {

    if (NULL == data) {
        return;
    }
    
    NSError *err;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (nil == root) {
        NSLog(@"%s %@", __func__, err);
        return;
    }
    
    NSDictionary *resultItem = [[[YYTXJsonObject alloc] init] getResultValueFromRootObject:root];
    if (nil == resultItem) {
        return;
    }
    
    NSArray *productItems = [resultItem objectForKey:JSONITEM_PRODUCTINFO_PRODUCT];
    if (NULL != productItems) {
        for (NSDictionary *productItem in productItems) {

            ProductInfo *product = [[ProductInfo alloc] init];
            
            NSString *productIdItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_PRODUCTID];
            if (nil != productIdItem) {
                product.productId = productIdItem;
            } else {
                product.productId = @"";
            }
            
            NSString *titleItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_TITLE];
            if (nil != titleItem) {
                product.title = titleItem;
            } else {
                product.title = @"";
            }
            
            NSString *descriItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_DESCRIPTION];
            if (nil != descriItem) {
                product.descri = descriItem;
            } else {
                product.descri = @"";
            }
            
            NSString *iconItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_ICON];
            if (nil != iconItem) {
                product.icon = iconItem;
            } else {
                product.icon = @"";
            }
            
            NSString *urlItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_URL];
            if (nil != urlItem) {
                product.url = urlItem;
            } else {
                product.url = @"";
            }
            
            NSString *guideImageItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_GUIDEIMAGE];
            if (nil != guideImageItem) {
                product.guideImage = guideImageItem;
            } else {
                product.guideImage = @"";
            }
            
            NSString *lastUpdateTimeItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_LASTUPDATETIME];
            if (nil != lastUpdateTimeItem) {
                product.lastUpdateTime = lastUpdateTimeItem;
            } else {
                product.lastUpdateTime = @"";
            }
            
            NSNumber *guideTypeItem = [productItem objectForKey:JSONITEM_PRODUCTINFO_GUIDETYPE];
            if (nil != guideTypeItem) {
                product.guideType = [guideTypeItem integerValue];
            } else {
                product.guideType = 0;
            }
            
            /* 将解析到的产品信息写入到数据库 */
            [BoxDatabase addProductId:product.productId title:product.title description:product.descri icon:product.icon url:product.url guideImage:product.guideImage lastUpdateTime:product.lastUpdateTime guideType:product.guideType];
        }
    }
}

@end
