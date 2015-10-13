//
//  SemanticAnalysis.m
//  CloudBox
//
//  Created by TTS on 15/6/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SemanticAnalysis.h"

#define JSONITEM_SEMANTICANALYSIS_BAIDU         @"baidu"
#define JSONITEM_SEMANTICANALYSIS_CONTENT       @"content"

@implementation SemanticAnalysis

+ (NSDictionary *)sendJsonItem:(NSData *)data {
    
    if (nil == data) {
        return nil;
    }
    
    NSError *err;
    NSDictionary *contentItem = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (nil == contentItem) {
        NSLog(@"%s %@", __func__, err);
        return nil;
    }
    
    NSDictionary *baiduItem = [NSDictionary dictionaryWithObject:contentItem forKey:JSONITEM_SEMANTICANALYSIS_CONTENT];
    return [NSDictionary dictionaryWithObject:baiduItem forKey:JSONITEM_SEMANTICANALYSIS_BAIDU];
}

@end
