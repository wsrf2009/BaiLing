//
//  ProductInfo.h
//  CloudBox
//
//  Created by TTS on 15-6-1.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ITEMMETHOD_VALUE_GETPRODUCTINFO     @"getProductInfo"

#define PRODUCTINFO_GUIDETYPE_NET           1
#define PRODUCTINFO_GUIDETYPE_DEFINE        2

@interface ProductInfo : NSObject
@property (nonatomic, retain) NSString *productId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *descri;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *guideImage;
@property (nonatomic, retain) NSString *lastUpdateTime;
@property (nonatomic, assign) NSInteger guideType;

+ (NSDictionary *)getAllTheProductsInfo;
+ (void)parseProductInfo:(NSData *)data;

@end
