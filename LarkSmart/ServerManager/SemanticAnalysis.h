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

+ (NSDictionary *)sendJsonItem:(NSData *)data;

@end
