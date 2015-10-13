//
//  DatePickerViewController.h
//  CloudBox
//
//  Created by TTS on 15-4-29.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDate (ConvertToNSString)

/**
 * 将NSDate转为格式为yyyy-MM-dd的字符串
 */
- (NSString *)getDateString;

/**
 * 将NSDate转为格式为HH:mm:ss的时间字符串
 */
- (NSString *)getTimeString;

/**
 * 将NSDate转为格式为HH:mm的时间字符串
 */
- (NSString *)shortTimeStringFromDate:(NSDate *)date;

@end

@interface NSString (ConvertToNSDate)

/**
 * 将格式为yyyy-MM-dd的日期字符串转为NSDate
 */
- (NSDate *)convertToNSDateFromDateString;

/**
 * 将格式为HH:mm:ss的时间字符串转为NSDate格式
 */
- (NSDate *)convertToNSDateFromTimeString;

/**
 * 将格式为HH:mm的时间字符串转为NSDate格式
 */
- (NSDate *)dateFromShortTimeString:(NSString *)time;

@end
