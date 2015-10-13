//
//  solarActionView.m
//  iPhone4OriPhone5
//
//  Created by cqsxit on 13-11-14.
//  Copyright (c) 2013年 cqsxit. All rights reserved.
//

#import "solarActionView.h"
#import "Date+string.h"

@implementation solarActionView{
    NSArray * arrYear;/*年份*/
    NSMutableArray * arrMonthList;/*月份*/
    NSArray * arrDayBigList;/*大月天数*/
    NSArray  * arrDayLittleList;/*小月天数*/

    NSDictionary * dicYearBaseList;
    NSArray *leapMonthReferList;/*闰月数组*/
    NSArray *MonthReferList;/*月数组*/
    BOOL isBigMonth;
    NSString * strMonth;/*月份对应码，每一位代表一个月,为1则为大月,为0则为小月*/
    
    NSInteger indexYear;/*选择年份对应的行数下标*/
    NSInteger indexMonth;/*选择月份对应下标*/
    NSInteger indexDay;/*选择天数对应下标*/
}
//@synthesize solarAction;
//@synthesize pickerView;

- (void)initialize {
    arrYear =[[NSArray alloc] init];
    arrDayBigList =[[NSArray alloc] init];
    arrDayLittleList =[[NSArray alloc] init];
    
    
    arrYear = @[@"一九零一",@"一九零二",@"一九零三",@"一九零四",@"一九零五",@"一九零六",@"一九零七",@"一九零八",@"一九零九",/*1*/
               @"一九一零",@"一九一一",@"一九一二",@"一九一三",@"一九一四",@"一九一五",@"一九一六",@"一九一七",@"一九一八",@"一九一九",/*2*/
               @"一九二零",@"一九二一",@"一九二二",@"一九二三",@"一九二四",@"一九二五",@"一九二六",@"一九二七",@"一九二八",@"一九二九",/*3*/
               @"一九三零",@"一九三一",@"一九三二",@"一九三三",@"一九三四",@"一九三五",@"一九三六",@"一九三七",@"一九三八",@"一九三九",/*4*/
               @"一九四零",@"一九四一",@"一九四二",@"一九四三",@"一九四四",@"一九四五",@"一九四六",@"一九四七",@"一九四八",@"一九四九",/*5*/
               @"一九五零",@"一九五一",@"一九五二",@"一九五三",@"一九五四",@"一九五五",@"一九五六",@"一九五七",@"一九五八",@"一九五九",/*6*/
               @"一九六零",@"一九六一",@"一九六二",@"一九六三",@"一九六四",@"一九六五",@"一九六六",@"一九六七",@"一九六八",@"一九六九",/*7*/
               @"一九七零",@"一九七一",@"一九七二",@"一九七三",@"一九七四",@"一九七五",@"一九七六",@"一九七七",@"一九七八",@"一九七九",/*8*/
               @"一九八零",@"一九八一",@"一九八二",@"一九八三",@"一九八四",@"一九八五",@"一九八六",@"一九八七",@"一九八八",@"一九八九",/*9*/
               @"一九九零",@"一九九一",@"一九九二",@"一九九三",@"一九九四",@"一九九五",@"一九九六",@"一九九七",@"一九九八",@"一九九九",/*10*/
               @"二零零零",@"二零零一",@"二零零二",@"二零零三",@"二零零四",@"二零零五",@"二零零六",@"二零零七",@"二零零八",@"二零零九",/*11*/
               @"二零一零",@"二零一一",@"二零一二",@"二零一三",@"二零一四",@"二零一五",@"二零一六",@"二零一七",@"二零一八",@"二零一九",/*12*/
               @"二零二零",@"二零二一",@"二零二二",@"二零二三",@"二零二四",@"二零二五",@"二零二六",@"二零二七",@"二零二八",@"二零二九",/*13*/
               @"二零三零",@"二零三一",@"二零三二",@"二零三三",@"二零三四",@"二零三五",@"二零三六",@"二零三七",@"二零三八",@"二零三九",/*14*/
               @"二零四零",@"二零四一",@"二零四二",@"二零四三",@"二零四四",@"二零四五",@"二零四六",@"二零四七",@"二零四八",@"二零四九",/*15*/
               ];
    
    arrDayBigList =@[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                     @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                     @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十"];
    
    arrDayLittleList =@[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                        @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                        @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九"];
    
    MonthReferList =@[@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊"];
    leapMonthReferList=@[@"闰正",@"闰二",@"闰三",@"闰四",@"闰五",@"闰六",@"闰七",@"闰八",@"闰九",@"闰十",@"闰十一",@"闰腊"];
    
    /*
     *0x04bd8,代表阳历1900.1.31为始的阴历0年,是5个16进制数,共20bit
     * 1.前4位,即0在这一年是润年时才有意义,它代表这年润月的大小月,为1则润大月,为0则润小月。
     * 2.中间12位,即4bd,每位代表一个月,为1则为大月,为0则为小月
     * 3.最后4位,即8,代表这一年的润月月份,为0则不润,首4位要与末4位搭配使用
     */
    NSString * strBasePath =[[NSBundle mainBundle] pathForResource:@"lunarcalenda" ofType:@"plist"];
    dicYearBaseList =[[NSDictionary alloc] initWithContentsOfFile:strBasePath];
    arrMonthList =[[NSMutableArray alloc] init];
    
    indexYear=0;
    indexMonth=0;
    indexDay=0;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id)delegate {
    
    NSLog(@"%s", __func__);

    self = [solarActionView alertControllerWithTitle:title message:@"\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    if (nil != self) {
        
        [self initialize];
        
        _pickerView =[[UIPickerView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width-20, 216)];
        _pickerView.delegate=self;
        _pickerView.dataSource=self;
        [self.view addSubview:_pickerView];
        
        [self addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *year=[Date_string setYearInt:arrYear[indexYear]];
            NSString *month =[Date_string setMonthInt:arrMonthList[indexMonth]];
            NSString *day =[Date_string setDayInt:arrDayBigList[indexDay]];
            NSString *reserved =[Date_string setReservedInt:arrMonthList[indexMonth]];
            if ([_solarAction respondsToSelector:@selector(actionSheetSolarDate:Month:Day:isLeapMonth:)]) {
                if ([reserved isEqualToString:@"1"]) {
                    [_solarAction actionSheetSolarDate:year Month:month Day:day isLeapMonth:YES]; // 返回小写的农历
                } else {
                    [_solarAction actionSheetSolarDate:year Month:month Day:day isLeapMonth:NO]; // 返回小写的农历
                }
            }
            
            if ([_solarAction respondsToSelector:@selector(actionSheetTitleDateText:Month:day:)]) {
                [_solarAction actionSheetTitleDateText:arrYear[indexYear] Month:arrMonthList[indexMonth] day:arrDayBigList[indexDay]]; // 返回大写的农历
            }
            
        }]];
        [self addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        _solarAction = delegate;
    }

    return self;
}

- (instancetype)initWithPicker:(UIPickerView *)picker delegate:(id)delegate {
    self = [super init];
    if (nil != self) {
        [self initialize];
        _pickerView = picker;
        _pickerView.delegate=self;
        _pickerView.dataSource=self;
        
        _solarAction = delegate;
        
        NSDictionary *dic = [solarActionView titleLunarArrayFromSolarDate:[NSDate date]];
        NSString *sYear = [dic objectForKey:SolarDicKeyForYear];
        NSString *sMonth = [dic objectForKey:SolarDicKeyForMonth];
        NSString *sDay = [dic objectForKey:SolarDicKeyForDay];
        [self setLunarTitleYear:sYear lunarTitleMonth:sMonth lunarTitleDay:sDay];
    }
    
    return self;
}

// 传入大写的农历，比如：二零一五， 三， 初十 或 二零一四， 润九， 初十
- (void)setLunarTitleYear:(NSString *)year lunarTitleMonth:(NSString *)month lunarTitleDay:(NSString *)day {
    
    NSLog(@"%s %@ %@ %@", __func__, year, month, day);
    
    /* 指定年份 */
    for (int i=0; i<arrYear.count; i++) {
        if ([year isEqualToString:arrYear[i]]) {
            indexYear=i;
        }
    }
    [self setMonthAndDay:dicYearBaseList[arrYear[indexYear]]];
    
    /* 指定月份 */
    for (int i=0; i<arrMonthList.count; i++) {
        if ([month isEqualToString:arrMonthList[i]]) {
            indexMonth=i;
        }
    }
    
    [self setDay:indexMonth];
    
    /* 指定日份 */
    for (int i=0; i<arrDayBigList.count; i++) {
        if ([day isEqualToString:arrDayBigList[i]]) {
            indexDay=i;
        }
    }
    
    NSLog(@"indexYear:%ld, indexMonth:%ld, indexDay:%ld", (long)indexYear, (long)indexMonth, (long)indexDay);
    
    
    [_pickerView reloadAllComponents];
    
    [_pickerView selectRow:indexYear inComponent:0 animated:NO];
    [_pickerView selectRow:indexMonth inComponent:1 animated:NO];
    [_pickerView selectRow:indexDay inComponent:2 animated:NO];
}

// 传入小写的农历，比如：2015，3，PING_YUE（平月），10 或 2014，9，RUN_YUE（润月），10
- (void)setLunarYear:(NSInteger)year lunarMonth:(NSInteger)month isLeapMonth:(BOOL)yesOrNo lunarDay:(NSInteger)day {

    NSLog(@"%s %ld %ld %ld", __func__, (long)year, (long)month, (long)day);

    NSDictionary *dic1 = [solarActionView formatConversionLunar:year lunarMonth:month lunarRunYue:yesOrNo lunarDay:day];
    NSString *forYear = [dic1 objectForKey:SolarDicKeyForYear];
    NSString *forMonth = [dic1 objectForKey:SolarDicKeyForMonth];
    NSString *forRun = [dic1 objectForKey:SolarDicKeyForLeap];
    NSString *forDay = [dic1 objectForKey:SolarDicKeyForDay];
    
    NSDictionary *dic2 = [solarActionView titleLunarFromLunarYear:forYear lunarMonth:forMonth lunarRunYue:forRun lunarDay:forDay];
    NSString *sYear = [dic2 objectForKey:SolarDicKeyForYear];
    NSString *sMonth = [dic2 objectForKey:SolarDicKeyForMonth];
    NSString *sDay = [dic2 objectForKey:SolarDicKeyForDay];
    [self setLunarTitleYear:sYear lunarTitleMonth:sMonth lunarTitleDay:sDay];
}

// 将NSDate类型的阳历转为大写农历：2015-04-28 ==> 二零一五， 三， 初十
+ (NSDictionary *)titleLunarArrayFromSolarDate:(NSDate *)date {
    
    NSLog(@"%s %@", __func__, date);
    
    NSDictionary *dic = [self lunarArrayFromSolarDate:date];
    NSString *sYear = [dic objectForKey:SolarDicKeyForYear];
    NSString *sMonth = [dic objectForKey:SolarDicKeyForMonth];
    NSString *sRun = [dic objectForKey:SolarDicKeyForLeap];
    NSString *sDay = [dic objectForKey:SolarDicKeyForDay];
    
    NSLog(@"%s sYear:%@, sMonth:%@, sRun:%@ sDay:%@", __func__, sYear, sMonth, sRun, sDay);
    
    return [self titleLunarFromLunarYear:sYear lunarMonth:sMonth lunarRunYue:sRun lunarDay:sDay];
}

// 将NSDate类型的阳历转为小写农历：2015-04-28 ==> 2015, 03, 0(平月), 10
+ (NSDictionary *)lunarArrayFromSolarDate:(NSDate *)date {
    
    NSLog(@"%s %@", __func__, date);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *Date = [formatter stringFromDate:date];
    NSArray *arr=[Date componentsSeparatedByString:@"-"];
    NSInteger year =[arr[0] intValue];
    NSInteger month =[arr[1] intValue];
    NSInteger day =[arr[2] intValue];
    
    NSLog(@"%s %ld %ld %ld", __func__, (long)year, (long)month, (long)day);
    
    hjz lunar =solar_to_lunar((int)year, (int)month, (int)day); // 将当前的公历时间转换
    
    BOOL isLeap;
    if (lunar.reserved) {
        isLeap = YES;
    } else {
        isLeap = NO;
    }

    return [self formatConversionLunar:lunar.year lunarMonth:lunar.month lunarRunYue:isLeap lunarDay:lunar.day];
}

// 将小写农历转为大写农历：2015, 3, 0(平月), 10 ==> 二零一五， 三， 初十
+ (NSDictionary *)titleLunarFromLunarYear:(NSString *)year lunarMonth:(NSString *)month lunarRunYue:(NSString *)run lunarDay:(NSString *)day {
    
    NSLog(@"%s year:%@, month:%@, run:%@ sDay:%@", __func__, year, month, run, day);
    
    BOOL isLeap = NO;
    if ([run isEqualToString:SolarLeapMonth]) {
        isLeap = YES;
    }
    
    NSString *stringMonth = [NSString stringWithFormat:@"%@x%d", month, isLeap];
    
    NSString *sYear =[Date_string setYearBaseSting:year];
    NSString *sMonth =[Date_string setMonthBaseSting:stringMonth];
    NSString *sDay =[Date_string setDayBaseSting:day];
    
    NSLog(@"%s sYear:%@, sMonth:%@ sDay:%@", __func__, sYear, sMonth, sDay);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:sYear, SolarDicKeyForYear, sMonth, SolarDicKeyForMonth, sDay, SolarDicKeyForDay, nil];
//    return [NSArray arrayWithObjects:sYear, sMonth, sDay, nil];
}

// 将小写农历转为阳历：2015，3，0（平月），10 ==> 2015, 4, 28
+ (NSDictionary *)solarFromLunar:(NSInteger)year lunarMonth:(NSInteger)month isLeapMonth:(BOOL)isLeapMonth lunarDay:(NSInteger)day {
    
     NSLog(@"%s year:%ld month:%ld run:%ld lunarDay:%ld", __func__, (long)year, (long)month, (long)isLeapMonth, (long)day);
    
    hjz solar = lunar_to_solar((int)year, (int)month, (int)day, (int)isLeapMonth);
    NSString *sYear = [NSString stringWithFormat:@"%d", solar.year];
    NSString *sMonth = [NSString stringWithFormat:@"%02d", solar.month];
    NSString *sDay = [NSString stringWithFormat:@"%02d", solar.day];
    
    NSLog(@"%s sYear:%@, sMonth:%@ sDay:%@", __func__, sYear, sMonth, sDay);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:sYear, SolarDicKeyForYear, sMonth, SolarDicKeyForMonth, sDay, SolarDicKeyForDay, nil];
//    return [NSArray arrayWithObjects:sYear, sMonth, sDay, nil];
}

// 将大写农历转为阳历：二零一五，三，十 ==> 2015，4，28
+ (NSDictionary *)solarFromTitleLunar:(NSString *)year lunarMonth:(NSString *)month lunarDay:(NSString *)day {

    NSLog(@"%s year:%@ month:%@ lunarDay:%@", __func__, year, month, day);
    
    NSString *sYear=[Date_string setYearInt:year];
    NSString *sMonth =[Date_string setMonthInt:month];
    NSString *sDay =[Date_string setDayInt:day];
    NSString *sReserved =[Date_string setReservedInt:month];
    
    NSLog(@"%s sYear:%@, sMonth:%@, sReserved:%@ sDay:%@", __func__, sYear, sMonth, sReserved, sDay);
    
    BOOL isLeap;
    if ([sReserved isEqualToString:@"1"]) {
        isLeap = YES;
    } else {
        isLeap = NO;
    }
    
    return [self solarFromLunar:sYear.integerValue lunarMonth:sMonth.integerValue isLeapMonth:isLeap lunarDay:sDay.integerValue];
}

// 将NSInteger型的日期转为NSString型
+ (NSDictionary *)formatConversionLunar:(NSInteger)year lunarMonth:(NSInteger)month lunarRunYue:(BOOL)isLeap lunarDay:(NSInteger)day {
    
    NSLog(@"%s year:%ld month:%ld run:%ld lunarDay:%ld", __func__, (long)year, (long)month, (long)isLeap, (long)day);
    
    NSString *sYear = [NSString stringWithFormat:@"%ld", (long)year];
    NSString *sMonth = [NSString stringWithFormat:@"%02ld", (long)month];
    NSString *sDay = [NSString stringWithFormat:@"%02ld", (long)day];
    
    NSString *sIsLeap;
    if (isLeap) {
        sIsLeap = SolarLeapMonth;
    } else {
        sIsLeap = SolarNonLeapMonth;
    }
    
    NSLog(@"%s sYear:%@, sMonth:%@, sRun:%@ sDay:%@", __func__, sYear, sMonth, sIsLeap, sDay);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:sYear, SolarDicKeyForYear, sMonth, SolarDicKeyForMonth, sDay, SolarDicKeyForDay, sIsLeap, SolarDicKeyForLeap, nil];
}

// 将大写农历文本转为数组：二零一五年三月初十 ==> 二零一五，三，初十
- (NSArray *)getTitleLunarFromText:(NSString *)text {
    NSArray *arr1 = [text componentsSeparatedByString:@"年"];
    NSString *sYear = arr1[0];
    NSString *sMonthDay = arr1[1];
    NSArray *arr2 = [sMonthDay componentsSeparatedByString:@"月"];
    NSString *sMonth = arr2[0];
    NSString *sDay = arr2[1];
    
    return [NSArray arrayWithObjects:sYear, sMonth, sDay, nil];
}

#pragma mark - UIPickerViewDataSoure

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    NSLog(@"%s", __func__);
    return 3;
}


- (CGFloat)pickerView:(UIPickerView *)view widthForComponent:(NSInteger)component {
    CGFloat w;
    NSInteger width = view.frame.size.width;
    
    NSLog(@"%s %ld %ld", __func__, (long)width, (long)component);
    
    if (0 == component) {
        w = 100;
    } else if (1 == component) {
        w = 80;
    } else if (2 == component) {
        w = 60;
    } else {
        w = 0;
    }
    
    NSLog(@"%s %ld %ld %f", __func__, (long)width, (long)component, w);
    return w;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {

    return 32.0f;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSUInteger count;
    
    switch (component) {
        case 0:
        {
            count = arrYear.count;
        }
            break;
        case 1:
        {
            count = arrMonthList.count;
        }
            break;
        case 2:
        {
            if (isBigMonth)
                count = arrDayBigList.count;
            else
                count = arrDayLittleList.count;
        }
            break;
        default:
            count = 0;
            break;
    }

    NSLog(@"%s %ld %lu", __func__, (long)component, (unsigned long)count);
    return count;
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:22]];
    
    switch (component) {
        case 0:
            [label setText:arrYear[row]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
            break;
            
        case 1:
            [label setText:arrMonthList[row]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:1].width, [pickerView rowSizeForComponent:1].height)];
            break;
        case 2:
            if (isBigMonth) {
                [label setText:arrDayBigList[row]];
            } else {
                [label setText:arrDayLittleList[row]];
            }
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
            break;
        default:
            break;
    }
    
    return label;
}
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *title;
    
    switch (component) {
        case 0:
            title = arrYear[row];
            break;
        case 1:
            title = arrMonthList[row];
            break;
        case 2:
            if (isBigMonth) {
                title = arrDayBigList[row];
            } else {
                title = arrDayLittleList[row];
            }
            break;
        default:
            title = nil;
            break;
    }
    
    NSLog(@"%s %ld %ld %@", __func__, (long)row, (long)component, title);
    
    return title;
}
*/
- (void)pickerView:(UIPickerView *)view didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"%s", __func__);
    
    switch (component) {
        case 0:
            indexYear=row;
            [self setMonthAndDay:dicYearBaseList[arrYear[row]]];
            indexMonth = 0;
            [self setDay:indexMonth];
            indexDay = 0;
            [view reloadComponent:1];
            [view reloadComponent:2];
            [view selectRow:0 inComponent:1 animated:YES];
            [view selectRow:0 inComponent:2 animated:YES];
            break;
            
        case 1:
            indexMonth=row;
            [self setDay:indexMonth];
            indexDay = 0;
            [view reloadComponent:2];
            [view selectRow:0 inComponent:2 animated:YES];
            break;
            
        case 2:
            indexDay = row;
            break;
            
        default:
            break;
    }
    
    NSLog(@"%s indexYear:%d indexMonth:%d indexDay:%d", __func__, indexYear, indexMonth, indexDay);
    
    NSString *year=[Date_string setYearInt:arrYear[indexYear]];
    NSString *month =[Date_string setMonthInt:arrMonthList[indexMonth]];
    NSString *day =[Date_string setDayInt:arrDayBigList[indexDay]];
    NSString *reserved =[Date_string setReservedInt:arrMonthList[indexMonth]];
    BOOL isLeapMonth;
    if ([reserved isEqualToString:@"1"]) {
        isLeapMonth = YES;
    } else {
        isLeapMonth = NO;
    }
    
    NSLog(@"%s year:%@ month:%@ day:%@ leap:%@", __func__, year, month, day, reserved);
    
    if ([_solarAction respondsToSelector:@selector(actionSheetSolarDate:Month:Day:isLeapMonth:)]) {
        [_solarAction actionSheetSolarDate:year Month:month Day:day isLeapMonth:isLeapMonth]; // 返回小写的农历
    }
    
    if ([_solarAction respondsToSelector:@selector(actionSheetTitleDateText:Month:day:)]) {
        [_solarAction actionSheetTitleDateText:arrYear[indexYear] Month:arrMonthList[indexMonth] day:arrDayBigList[indexDay]]; // 返回大写的农历
    }
}

//刷新内容属性(月，日)
- (void)setMonthAndDay:(NSString *)strYearBase {/*传入对应的年份编码制*/
    NSLog(@"%s %@", __func__, strYearBase);
   NSString *MonthAndDay = [strYearBase substringFromIndex:3];
    NSLog(@"%s %@", __func__, MonthAndDay);
    strMonth  =[[self getBinaryByhex:MonthAndDay] substringToIndex:12];/*用于大月平月的判断字符串*/
    NSLog(@"%s %@", __func__, strMonth);
    [self setLeapMonth:strYearBase];/*判断闰月*/
}

//刷新内容属性(日)<判断是否为大月，平月>
- (void)setDay:(NSInteger)row{
    NSLog(@"%s", __func__);
    NSString * strBool;
    NSInteger count = row;
    NSInteger max = strMonth.length;
    
    if (count<max) {
        strBool=[strMonth substringFromIndex:row];
    }else{
        strBool=[strMonth substringFromIndex:strMonth.length-1];
    }
    
    NSLog(@"%s %@ %@", __func__, strMonth, strBool);
   
    strBool =[strBool substringToIndex:1];
    if ([strBool isEqualToString:@"0"])
        isBigMonth=NO;
    else
        isBigMonth=YES;
}

//判断闰月以及闰月的天数
- (void)setLeapMonth:(NSString *)YearBaseDate{
    NSLog(@"%s", __func__);
    NSString *isLeap=[YearBaseDate substringFromIndex:YearBaseDate.length-1];
    NSString *isBigLeap =[YearBaseDate substringToIndex:1];
    NSLog(@"%s isLeap:%@ isBigLeap:%@", __func__, isLeap, isBigLeap);
    if (![isLeap isEqualToString:@"0"]) {
        /*是否有闰月*/
        if ([isBigLeap isEqualToString:@"0"]) {
            /***************************************/
            /*闰小月*/
            if (arrMonthList) {
                [arrMonthList removeAllObjects];
            }
            
            NSInteger leapNumnber=[isLeap integerValue];
            if ([isLeap isEqualToString:@"a"] || [isLeap isEqualToString:@"A"]) {
                leapNumnber = 10;
            } if ([isLeap isEqualToString:@"b"] || [isLeap isEqualToString:@"B"]) {
                leapNumnber = 11;
            } else if ([isLeap isEqualToString:@"c"] || [isLeap isEqualToString:@"C"]) {
                leapNumnber = 12;
            }
            
            NSLog(@"%s %d", __func__, leapNumnber);
            for (int i=0; i<strMonth.length; i++) {
                
                [arrMonthList  addObject:MonthReferList[i]];
                NSLog(@"%s %@ 1", __func__, MonthReferList[i]);
                if (i == (leapNumnber-1)) {
                    [arrMonthList addObject:leapMonthReferList[leapNumnber-1]];
                    NSLog(@"%s %@ 2", __func__, leapMonthReferList[leapNumnber-1]);
                }
                
            }
            NSString *strOne =[strMonth substringToIndex:leapNumnber];
            NSString *strTwo =[strMonth substringFromIndex:leapNumnber];
            strMonth =[NSString stringWithFormat:@"%@0%@",strOne,strTwo];
            /***************************************/
        } else {
            /***************************************/
            /*闰大月*/
            if (arrMonthList) [arrMonthList removeAllObjects];
            int leapNumnber=[isLeap intValue];
            for (int i=0; i<strMonth.length; i++) {
                [arrMonthList  addObject:MonthReferList[i]];
                if (leapNumnber-1==i)[arrMonthList addObject:leapMonthReferList[leapNumnber-1]];
            }
            
            NSString * strOne =[strMonth substringToIndex:leapNumnber];
            NSString * strTwo =[strMonth substringFromIndex:leapNumnber];
            strMonth =[NSString stringWithFormat:@"%@1%@",strOne,strTwo];
            /***************************************/
        }
    } else {
        
        /* 如果不闰月 */
        
        if (arrMonthList) {
            [arrMonthList removeAllObjects];
        }
        arrMonthList =[[NSMutableArray alloc] initWithArray:MonthReferList];
        
        NSLog(@"arrMonthList count:%lu", (unsigned long)arrMonthList.count);
    }
    
//    NSLog(@"%s arrMonthList:%@", __func__, arrMonthList);
}


//将16进制转化为二进制
-(NSString *)getBinaryByhex:(NSString *)hex
{
    NSMutableDictionary  *hexDic;
    NSLog(@"%s", __func__);
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"a"];
    
    [hexDic setObject:@"1011" forKey:@"b"];
    
    [hexDic setObject:@"1100" forKey:@"c"];
    
    [hexDic setObject:@"1101" forKey:@"d"];
    
    [hexDic setObject:@"1110" forKey:@"e"];
    
    [hexDic setObject:@"1111" forKey:@"f"];
    
    NSString *binaryString=[[NSString alloc] init];
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        
        NSString * strLast =[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]];
        binaryString = [NSString stringWithFormat:@"%@%@",binaryString,strLast];
        
    }
    return binaryString;
    
}



@end
