//
//  DatePickerViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-29.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "NSDateNSStringConvert.h"

@implementation NSDate (ConvertToNSString)

/**
 * 将NSDate转为格式为yyyy-MM-dd的字符串
 */
- (NSString *)getDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:self];
}

/**
 * 将NSDate转为格式为HH:mm:ss的时间字符串
 */
- (NSString *)getTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    return [formatter stringFromDate:self];
}

/**
 * 将NSDate转为格式为HH:mm的时间字符串
 */
- (NSString *)shortTimeStringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:self];
}

@end

@implementation NSString (ConvertToNSDate)

/**
 * 将格式为yyyy-MM-dd的日期字符串转为NSDate
 */
- (NSDate *)convertToNSDateFromDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:self];
}

/**
 * 将格式为HH:mm:ss的时间字符串转为NSDate格式
 */
- (NSDate *)convertToNSDateFromTimeString {
    
    if (nil == self) {
        return [NSDate date];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if ([self isEqualToString:@"24:00:00"])
        return [formatter dateFromString:@"1970-01-01 00:00:00"];
    else
        return [formatter dateFromString:[@"1970-01-01 " stringByAppendingString:self]];
}

/**
 * 将格式为HH:mm的时间字符串转为NSDate格式
 */
- (NSDate *)dateFromShortTimeString:(NSString *)time {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    if ([self isEqualToString:@"24:00"])
        return [formatter dateFromString:@"00:00"];
    else
        return [formatter dateFromString:self];
}

@end
