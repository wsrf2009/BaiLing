//
//  EventClass.m
//  CloudBox
//
//  Created by TTS on 15-4-25.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "EventIndClass.h"

#define JSONITEM_EVENTIND_NAME          @"name"
//#define JSONITEM_EVENTIND_MEDIAINFO     @"mediaInfo"

//#define JSONITEM_EVENTIND_QUERY         @"query"
//#define JSONITEM_EVENTIND_REPLY         @"reply"
#define JSONITEM_EVENTIND_HELP          @"help"
#define JSONITEM_EVENTIND_STATUS        @"status"


@implementation EventIndClass

+ (EventIndClass *)parseEventIndJsonItem:(NSDictionary *)eventItem {
    
    if (nil == eventItem) {
        return nil;
    }
    
//    NSLog(@"%s %s", __func__, cJSON_Print(eventItem));
    
    EventIndClass *eventInd = [[EventIndClass alloc] init];
    
    NSString *nameItem = [eventItem objectForKey:JSONITEM_EVENTIND_NAME];
    if (nil != nameItem) {
        eventInd.name = nameItem;
    }
    
    NSDictionary *mediaInfoItem = [eventItem objectForKey:JSONITEM_EVENTIND_MEDIAINFO];
    if (nil != mediaInfoItem) {
        NSString *queryItem = [mediaInfoItem objectForKey:JSONITEM_EVENTIND_QUERY];
        if (nil != queryItem) {
            eventInd.query = queryItem;
        }
        
        NSString *replyItem = [mediaInfoItem objectForKey:JSONITEM_EVENTIND_REPLY];
        if (nil != replyItem) {
            eventInd.replay = replyItem;
        }
        
        NSString *helpItem = [mediaInfoItem objectForKey:JSONITEM_EVENTIND_HELP];
        if (nil != helpItem) {
            eventInd.help = helpItem;
        }
        
        NSString *statusItem = [mediaInfoItem objectForKey:JSONITEM_EVENTIND_STATUS];
        if (nil != statusItem) {
            eventInd.status = statusItem;
        }
    }
    
    eventInd.time = [self stringFromDate:[NSDate date]];
    
    return eventInd;
}

+ (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

+ (NSDictionary *)createMediaInfo:(NSString *)queryValue reply:(NSString *)replyValue {
    return [NSDictionary dictionaryWithObjects:@[replyValue, queryValue] forKeys:@[JSONITEM_EVENTIND_REPLY, JSONITEM_EVENTIND_QUERY]];
}

@end
