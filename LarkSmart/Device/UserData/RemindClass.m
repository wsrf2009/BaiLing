//
//  RemindClass.m
//  CloudBox
//
//  Created by TTS on 15-4-8.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "RemindClass.h"
#import "NSDateNSStringConvert.h"

// remind
#define JSONITEM_REMIND_ID                  @"ID"
#define JSONITEM_REMIMD_ISVALID             @"is_valid"
#define JSONITEM_REMIND_DATE                @"date"
#define JSONITEM_REMIND_CONTENT             @"content"

#define REMINDID_MIN        0
#define REMINDID_MAX        65535

@implementation RemindClass

- (instancetype)initWithRemindList:(NSMutableArray *)remindList {
    self = [super init];
    if (nil != self) {
        _list = [[NSMutableArray alloc] init];
        
        _ID = [RemindClass getFreeId:remindList];
        _is_valid = YES;
        _date = [[NSDate date] getDateString];
        _content = @"";
    }
    
    return self;
}

+ (NSInteger)getFreeId:(NSMutableArray *)list {
    NSUInteger i;
    BOOL isValid;
    
    for (i=REMINDID_MIN; i<=REMINDID_MAX; i++) {
        isValid = YES;
        for (RemindClass *remind in list) {
            if (remind.ID == i) {
                isValid = NO;
                break;
            }
        }
        
        if (isValid) {
            return i;
        }
    }
    
    return -1;
}

+ (BOOL)parseReminds:(NSArray *)remindsItem remindList:(NSMutableArray *)list {
    
    NSLog(@"%s", __func__);

    if (nil == remindsItem) {
        return NO;
    }

    for (NSDictionary *remindItem in remindsItem) {
        RemindClass *remind = [[RemindClass alloc] init];
        
        NSNumber *idItem = [remindItem objectForKey:JSONITEM_REMIND_ID];
        if (nil != idItem) {
            remind.ID = [idItem integerValue];
        }
        
        NSNumber *isValidItem = [remindItem objectForKey:JSONITEM_REMIMD_ISVALID];
        if (nil != isValidItem) {
            remind.is_valid = [isValidItem integerValue];
        }
        
        NSString *dateItem = [remindItem objectForKey:JSONITEM_REMIND_DATE];
        if (nil != dateItem) {
            remind.date = dateItem;
        }
        
        NSString *contentItem = [remindItem objectForKey:JSONITEM_REMIND_CONTENT];
        if (nil != contentItem) {
            remind.content = contentItem;
        }
        
        [list addObject:remind];
    }
    
    return YES;
}

+ (NSArray *)modifyRemind:(RemindClass *)remind {
    
    if (nil == remind) {
        return nil;
    }
    
    NSDictionary *remindItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:remind.ID], JSONITEM_REMIND_ID, [NSNumber numberWithInteger:remind.is_valid], JSONITEM_REMIMD_ISVALID, remind.date, JSONITEM_REMIND_DATE, remind.content, JSONITEM_REMIND_CONTENT, nil];
    
    return @[remindItem];
}

+ (NSArray *)deleteRemindWithRemindId:(NSInteger)remindId {
    NSDictionary *idItem = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:remindId] forKey:JSONITEM_REMIND_ID];
    
    return @[idItem];
}

@end
