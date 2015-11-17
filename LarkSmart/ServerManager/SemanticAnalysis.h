//
//  SemanticAnalysis.h
//  CloudBox
//
//  Created by TTS on 15/6/5.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define METHODVALUE_SEMANTICANALYSIS        @"semanticAnalysis"

@interface SemanticAnalysis : NSObject

/** 
 创建交由后台服务器解析的数据包 
 @param data 从百度返回的语意解析结果
 @return 生成的交由宇音天下后台服务器解析的数据包
 */
+ (NSDictionary *)sendJsonItem:(NSData *)data;

@end
