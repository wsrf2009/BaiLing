//
//  AudioList.h
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ITEMMETHOD_VALUE_GETAUDIOLIST           @"getAudioList"

@interface AudioList : NSObject

- (NSDictionary *)getAudioListWithCategoryId:(NSString *)cId pageNo:(NSUInteger)page itemsPerpage:(NSUInteger)number;
- (NSMutableArray *)parseAudioList:(NSData *)data;

@end
