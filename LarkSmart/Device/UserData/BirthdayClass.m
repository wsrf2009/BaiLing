//
//  BirthdayClass.m
//  CloudBox
//
//  Created by TTS on 15-4-8.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "BirthdayClass.h"
#import "NSDateNSStringConvert.h"

#define JSONITEM_BIRTHDAY_ID                @"ID"
#define JSONITEM_BIRTHDAY_WHO               @"who"
#define JSONITEM_BIRTHDAY_DATETYPE          @"date_formate"
#define JSONITEM_BIRTHDAY_DATEVALUE         @"data_value"
#define JSONITEM_BIRTHDAY_CONGRATULATION    @"congratulation"

#define BIRTHDAYID_MIN      0
#define BIRTHDAYID_MAX      65535

@implementation BirthdayClass

- (instancetype)initWithBirtdayList:(NSMutableArray *)birthdayList {
    
    self = [super init];
    if (nil != self) {
        _list = [[NSMutableArray alloc] init];
        
        _ID = [BirthdayClass getFreeId:birthdayList];
        _who = @"";
        _date_type = DATETYPE_SOLAR;
        _date_value = [[NSDate date] getDateString];
        _congratulations = @"";
    }
    
    return self;
}

+ (NSInteger)getFreeId:(NSMutableArray *)list {
    NSUInteger i;
    BOOL isValid;
    
    for (i=BIRTHDAYID_MIN; i<=BIRTHDAYID_MAX; i++) {
        isValid = YES;
        for (BirthdayClass *birthday in list) {
            if (birthday.ID == i) {
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

+ (BOOL)parseBirthdays:(NSArray *)birthdaysItem birthdayList:(NSMutableArray *)list {
    
    NSLog(@"%s", __func__);

    if (nil == birthdaysItem) {
        return NO;
    }
    
//    int index = 0;
//    cJSON *birthday = cJSON_GetArrayItem(birthdaysItem, index++);
//    while (NULL != birthday) {
    for (NSDictionary *birthdayItem in birthdaysItem) {
        BirthdayClass *birthday = [[BirthdayClass alloc] init];
        
        NSNumber *idItem = [birthdayItem objectForKey:JSONITEM_BIRTHDAY_ID];
//        cJSON *itemID = cJSON_GetObjectItem(birthday, JSONITEM_BIRTHDAY_ID);
        if (nil != idItem) {
            birthday.ID = [idItem integerValue];
        }
        
        NSString *whoItem = [birthdayItem objectForKey:JSONITEM_BIRTHDAY_WHO];
//        cJSON *itemWho = cJSON_GetObjectItem(birthday, JSONITEM_BIRTHDAY_WHO);
        if (nil != whoItem) {
            birthday.who = whoItem;
        }
        
        NSNumber *dateTypeItem = [birthdayItem objectForKey:JSONITEM_BIRTHDAY_DATETYPE];
//        cJSON *itemDateType = cJSON_GetObjectItem(birthday, JSONITEM_BIRTHDAY_DATETYPE);
        if (nil != dateTypeItem) {
            birthday.date_type = [dateTypeItem integerValue];
        }
        
        NSString *dateValue = [birthdayItem objectForKey:JSONITEM_BIRTHDAY_DATEVALUE];
//        cJSON *itemDateValue = cJSON_GetObjectItem(birthday, JSONITEM_BIRTHDAY_DATEVALUE);
        if (nil != dateValue) {
            birthday.date_value = dateValue;
        }
        
        NSString *congratulationItem = [birthdayItem objectForKey:JSONITEM_BIRTHDAY_CONGRATULATION];
//        cJSON *itemCongratulation = cJSON_GetObjectItem(birthday, JSONITEM_BIRTHDAY_CONGRATULATION);
        if (nil != congratulationItem) {
            birthday.congratulations = congratulationItem;
        }
        
        [list addObject:birthday];
        
//        birthday = cJSON_GetArrayItem(birthdaysItem, index++);
    }
    
    return YES;
}

+ (NSArray *)modifyBirthday:(BirthdayClass *)birthday {
    
    if (nil == birthday) {
        return nil;
    }
    
    NSDictionary *birthdayItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:birthday.ID], JSONITEM_BIRTHDAY_ID, birthday.who, JSONITEM_BIRTHDAY_WHO, [NSNumber numberWithInteger:birthday.date_type], JSONITEM_BIRTHDAY_DATETYPE, birthday.date_value, JSONITEM_BIRTHDAY_DATEVALUE, birthday.congratulations, JSONITEM_BIRTHDAY_CONGRATULATION, nil];
    
    return @[birthdayItem];
}

+ (NSArray *)deleteBirthdayWithBirthdayId:(NSInteger)birthdayId {
    NSDictionary *idItem = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:birthdayId] forKey:JSONITEM_BIRTHDAY_ID];
    
    return @[idItem];
}

@end
