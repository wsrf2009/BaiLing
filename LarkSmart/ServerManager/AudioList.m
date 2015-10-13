//
//  AudioList.m
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AudioList.h"
#import "AudioClass.h"
#import "YYTXJsonObject.h"
#import "CategoryClass.h"

#define JSONITEM_GETAUDIOLIST_CATEGORYID        @"categoryid"
#define JSONITEM_GETAUDIOLIST_PAGE              @"page"
#define JSONITEM_GETAUDIOLIST_PERPAGE           @"perpage"

@implementation AudioList

- (NSDictionary *)getAudioListWithCategoryId:(NSString *)cId pageNo:(NSUInteger)page itemsPerpage:(NSUInteger)number {
    
    return [NSDictionary dictionaryWithObjectsAndKeys:cId, JSONITEM_GETAUDIOLIST_CATEGORYID, [NSNumber numberWithUnsignedInteger:page], JSONITEM_GETAUDIOLIST_PAGE, [NSNumber numberWithUnsignedInteger:number], JSONITEM_GETAUDIOLIST_PERPAGE, nil];
}

- (NSMutableArray *)parseAudioList:(NSData *)data {
    
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
    
    NSDictionary *categoryItem = [resultItem objectForKey:JSONITEM_CATEGORY_CATEGORY];
    if (nil == categoryItem) {
        return nil;
    }
    
    NSMutableArray *audioList = [[NSMutableArray alloc] init];
    
    CategoryClass *category = [CategoryClass parseCategory:categoryItem];
    if (nil != category) {
        [audioList addObject:category];
    }
    
    NSArray *audioItems = [resultItem objectForKey:JSONITEM_AUDIOLIST_AUDIO];
    if (NULL != audioItems) {
//        for (NSDictionary *audioItem in audioItems) {
        for (NSInteger i=0; i<audioItems.count; i++) {
            NSDictionary *audioItem = audioItems[i];
            AudioClass *audio = [AudioClass parseAudio:audioItem];
            if (nil != audio) {
                [audioList addObject:audio];
            }
        }
    }
    
    return audioList;
}

@end
