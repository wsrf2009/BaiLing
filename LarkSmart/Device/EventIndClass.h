//
//  EventClass.h
//  CloudBox
//
//  Created by TTS on 15-4-25.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <Foundation/Foundation.h>

// 方法的值 JSONITEM_METHOD
#define ITEMVALUE_METHOD_EVENTIND       @"eventInd"

#define JSONITEM_EVENT          @"event"

// 事件类型 JSONITEM_EVENTIND_NAME
#define ITEMVALUE_EVENTIND_NAME_MEDIAPLAY   @"mediaPlay"

#define JSONITEM_EVENTIND_MEDIAINFO     @"mediaInfo"
#define JSONITEM_EVENTIND_QUERY         @"query"
#define JSONITEM_EVENTIND_REPLY         @"reply"

#define ITEMVALUE_EVENTIND_STATUS_START         @"start"
#define ITEMVALUE_EVENTIND_STATUS_STOP          @"stop"
#define ITEMVALUE_EVENTIND_STATUS_PAUSE         @"pause"
#define ITEMVALUE_EVENTIND_STATUS_RESUME        @"resume"

@interface EventIndClass : NSObject
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *query;
@property (nonatomic, retain) NSString *replay;
@property (nonatomic, retain) NSString *help;
@property (nonatomic, retain) NSString *status;

/** 解析event类 */
+ (EventIndClass *)parseEventIndJsonItem:(NSDictionary *)eventItem;

/** 创建媒体播放信息，方便设备发出EventInd通知 */
+ (NSDictionary *)createMediaInfo:(NSString *)queryValue reply:(NSString *)replyValue;

@end
