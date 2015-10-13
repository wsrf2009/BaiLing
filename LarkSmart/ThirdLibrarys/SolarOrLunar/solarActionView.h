//
//  solarActionView.h
//  iPhone4OriPhone5
//
//  Created by cqsxit on 13-11-14.
//  Copyright (c) 2013年 cqsxit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "solarOrLunar.h"

#define RUN_YUE     1
#define PING_YUE    0

#define SolarLeapMonth      @"leapMonth"
#define SolarNonLeapMonth   @"nonLeapMonth"

#define SolarDicKeyForYear     @"year"
#define SolarDicKeyForMonth    @"month"
#define SolarDicKeyForDay      @"day"
#define SolarDicKeyForLeap     @"leap"

typedef enum {
    Type_solar,
    type_lunar
}date_type;

@class ActionSheetView;
@protocol SolarActionDelegate <NSObject>

@optional

- (void)actionSheetSolarDate:(int)year Month:(int)month Day:(int)day;

/*返回小写的农历，比如1991-04-01*/
- (void)actionSheetSolarDate:(NSString *)year Month:(NSString *)month Day:(NSString *)day isLeapMonth:(BOOL)yesOrNo;
/*返回大写的农历，比如一九九一年四月一日*/
- (void)actionSheetTitleDateText:(NSString *)year Month:(NSString *)month day:(NSString *)day;

@end

@interface solarActionView : UIAlertController<UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>

- (instancetype)initWithTitle:(NSString *)title delegate:(id)delegate;
- (instancetype)initWithPicker:(UIPickerView *)picker delegate:(id)delegate ;
// 传入大写的农历，比如：二零一五， 三， 初十 或 二零一四， 润九， 初十
- (void)setLunarTitleYear:(NSString *)year lunarTitleMonth:(NSString *)month lunarTitleDay:(NSString *)day;
// 传入小写的农历，比如：2015，3，PING_YUE（平月），10 或 2014，9，RUN_YUE（润月），10
- (void)setLunarYear:(NSInteger)year lunarMonth:(NSInteger)month isLeapMonth:(BOOL)yesOrNo lunarDay:(NSInteger)day;
// 将NSdate类型的阳历转为大写农历：2015-04-28 ==> 二零一五， 三， 初十
+ (NSDictionary *)titleLunarArrayFromSolarDate:(NSDate *)date;
// 将NSDate类型的阳历转为小写农历：2015-04-28 ==> 2015, 03, 0(平月), 10
+ (NSDictionary *)lunarArrayFromSolarDate:(NSDate *)date;
// 将小写农历转为大写农历：2015, 3, 0(平月), 10 ==> 二零一五， 三， 初十
+ (NSDictionary *)titleLunarFromLunarYear:(NSString *)year lunarMonth:(NSString *)month lunarRunYue:(NSString *)run lunarDay:(NSString *)day;
// 将小写农历转为阳历
+ (NSDictionary *)solarFromLunar:(NSInteger)year lunarMonth:(NSInteger)month isLeapMonth:(BOOL)isLeapMonth lunarDay:(NSInteger)day;
// 将大写农历转为阳历
+ (NSDictionary *)solarFromTitleLunar:(NSString *)year lunarMonth:(NSString *)month lunarDay:(NSString *)day;
// 将NSInteger型的日期转为NSString型
+ (NSDictionary *)formatConversionLunar:(NSInteger)year lunarMonth:(NSInteger)month lunarRunYue:(BOOL)isLeap lunarDay:(NSInteger)day;

@property (assign ,nonatomic) id<SolarActionDelegate> solarAction;
@property (strong ,nonatomic) UIPickerView *pickerView;
@end
