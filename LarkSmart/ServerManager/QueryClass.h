//
//  QueryClass.h
//  CloudBox
//
//  Created by TTS on 15-4-24.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryClass : NSObject

@property (nonatomic, retain) NSString *urlBuy;
@property (nonatomic, retain) NSString *urlHelp;
@property (nonatomic, retain) NSString *urlProduct;
@property (nonatomic, retain) NSString *xmlyHelpUrl;
@property (nonatomic, retain) NSString *weiXinUrl;

+ (QueryClass *)parseQuery:(NSData *)data;

@end
