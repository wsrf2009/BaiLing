//
//  RemindTableViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-27.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "RemindViewController.h"
#import "NSDateNSStringConvert.h"
#import "IQTextView.h"

#define LeadingSpaceToSuperView         15.0f
#define TrailingSpaceToSuperView         15.0f
#define TopSpaceToSuperView         5.0f
#define BottomSpaceToSuperView      10.0f

@interface RemindViewController () <UITextViewDelegate, YYTXDeviceManagerDelegate>
@property (nonatomic, retain) IBOutlet UIButton *buttonOpenRemind;
@property (nonatomic, retain) IBOutlet UIButton *buttonDeleteRemind;
@property (nonatomic, retain) IBOutlet IQTextView *textViewContent;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UILabel *labelContentLength;
//@property (nonatomic, retain) IBOutlet UILabel *labelContentMaxLength;
@property (nonatomic, retain) IBOutlet UILabel *labelRemindHint;

@property (nonatomic, retain) UIFont *fontForHint;

@end

@implementation RemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    self.deviceManager.delegate = self;
    
    if (_isAddAlarm) {

    } else {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }

    UIBarButtonItem *buttonSave;
    if (_isAddAlarm) {
        /* 添加备忘闹铃 */
    } else {
        /* 修改备忘闹铃 */
        buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifyRemind)];
    }
    /* 设置工具条 */
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:space, buttonSave, space, nil];
    
//    _textViewContent.placeHolder = NSLocalizedStringFromTable(@"remindPlaceholder", @"hint", nil);
//    _textViewContent.customTextColor = [UIColor colorWithRed:.0f green:128.0f/255.0f blue:1.0f alpha:1.0f];
    [_textViewContent setPlaceholder:NSLocalizedStringFromTable(@"remindPlaceholder", @"hint", nil)];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"remidAlarm", @"hint", nil)];
    
//    [_labelContentMaxLength setText:[NSString stringWithFormat:@"/%d", MAXCONTENTLENGTH]];
//    [_labelContentMaxLength setTextColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
    
    _fontForHint = [UIFont systemFontOfSize:15.0f];

    
    NSString *hint = NSLocalizedStringFromTable(@"remindHint", @"hint", nil);
    // 创建可变属性化字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:hint];
    NSUInteger length = [hint length];
    // 设置基本字体
    UIFont *baseFont = [UIFont systemFontOfSize:14.0f];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, length)];
    UIColor *baseColor = [UIColor grayColor];
    [attrString addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, length)];

    NSRange range1 = [hint rangeOfString:@"“"];
    NSRange range2 = [hint rangeOfString:@"”"];
    if (range1.location != NSNotFound && range2.location != NSNotFound) {
        length = range2.location - range1.location-1;
        NSRange range = NSMakeRange(range1.location+1, length);
        //将需要提示的字体增大
        UIFont *biggerFont = [UIFont systemFontOfSize:15.0f];
        [attrString addAttribute:NSFontAttributeName value:biggerFont range:range];
        // 将需要提示的字体设为红色
        UIColor *color = [UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    [_labelRemindHint setAttributedText:attrString];
    
    [self hideEmptySeparators:self.tableView];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
    
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (0 == section) {
        if (_isAddAlarm) {
            return 0;
        } else {
            return 1;
        }
    } else if (1 == section) {
        return 1;
    } else if (2 == section) {
        return 1;
    } else if (3 == section) {
        return 1;
    }
    
    return 0;
}

- (BOOL)contentLengthCheck {
    NSInteger length = _textViewContent.text.length;
    NSString *str = [NSString stringWithFormat:@"%@/%@", @(length), @MAXCONTENTLENGTH];
    NSRange range = [str rangeOfString:@"/"];
    NSLog(@"%s range:%@", __func__, NSStringFromRange(range));
    NSRange range1 = NSMakeRange(0, range.location);
    NSLog(@"%s range1:%@", __func__, NSStringFromRange(range1));
    BOOL statusCode;
    // 创建可变属性化字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置基本字体
    UIFont *baseFont = [UIFont systemFontOfSize:15.0f];
    UIColor *baseColor = [UIColor grayColor];
    [attrString addAttributes:@{NSFontAttributeName:baseFont, NSForegroundColorAttributeName:baseColor} range:NSMakeRange(0, str.length)];
    
    if ((0 < length) && (length <= MAXCONTENTLENGTH)) {
        statusCode = YES;
    } else {
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range1];
        
        statusCode = NO;
    }
    
    _labelContentLength.attributedText = attrString;
    
    return statusCode;
}

- (BOOL)inputParametersIsValid {
    
    _remind.content = _textViewContent.text;
    
    /* 检查字数是否符合要求 */
    if (![self contentLengthCheck]) {
        
        if (_remind.content.length <= 0) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"theRemindIsEmpty", @"hint", nil)];
        } else {
            [QXToast showMessage:NSLocalizedStringFromTable(@"remindIsTooLong", @"hint", nil)];
        }
        
        [_textViewContent becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        return NO;
    }
    
    /* 去掉空格和换行 */
    NSString *str = [_remind.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    [_textViewContent setText:str];
    if (str.length <= 0) {
        
        [_textViewContent becomeFirstResponder];
        [QXToast showMessage:NSLocalizedStringFromTable(@"theRemindInvalid", @"hint", nil)];
        return NO;
    } else {
        _remind.content = str;
    }
    
    NSString *current = [[NSDate date] getDateString];
    if ([_remind.date compare:current] == NSOrderedAscending) {
        
        [QXToast showMessage:NSLocalizedStringFromTable(@"theDateOfRemindIsInvalid", @"hint", nil)];
        
        return NO;
    }
    
    return YES;
}

- (void)updateUI {
    
    if (!_isAddAlarm) {
        if ([_remind is_valid]) {
            [_buttonOpenRemind setSelected:YES];
        } else {
            [_buttonOpenRemind setSelected:NO];
        }
    }

    [_textViewContent setText:_remind.content];
        
    [self contentLengthCheck];
        
    NSDate *date = [_remind.date convertToNSDateFromDateString];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    if (nil != date) {
        [_datePicker setDate:date animated:YES];
    }
}

- (IBAction)buttonOpenRemindClick:(id)sender {
    NSString *open = NSLocalizedStringFromTable(@"open", @"hint", nil);
    NSString *close = NSLocalizedStringFromTable(@"close", @"hint", nil);
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    NSString *message;
    NSString *buttonOkTitle;
    
    if ([_remind is_valid]) {
        
        message = NSLocalizedStringFromTable(@"closeThisRemind?", @"hint", nil);
        buttonOkTitle = NSLocalizedStringFromTable(@"close", @"hint", nil);
    } else {
        
        message = NSLocalizedStringFromTable(@"openThisRemind?", @"hint", nil);
        buttonOkTitle = NSLocalizedStringFromTable(@"open", @"hint", nil);
    }
    
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        /* IOS8.0及以后 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonOkTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if ([action.title isEqualToString:open]) {
                [self openRemind:YES];
            } else if ([action.title isEqualToString:close]) {
                [self openRemind:NO];
            }
        }]];
        
        if (nil != alertController) {
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS6.0 及以后，但是低于IOS8.0 */
        UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:buttonOkTitle, nil];
        
        [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
            if ([buttonTitle isEqualToString:open]) {
                [self openRemind:YES];
            } else if ([buttonTitle isEqualToString:close]) {
                [self openRemind:NO];
            }
        }];
    }
}

- (IBAction)buttonDeleteRemindClick:(id)sender {
    NSString *message = NSLocalizedStringFromTable(@"deleteThisRemind?", @"hint", nil);
    NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
    NSString *buttonDeleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
    
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        /* IOS8.0及以后 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonDeleteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [self deleteRemind];
        }]];
        
        if (nil != alertController) {
            NSLog(@"%s +++++++++++++", __func__);
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS6.0 及以后，但是低于IOS8.0 */
        UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:buttonDeleteTitle, nil];
        NSLog(@"%s ----------------", __func__);
        [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
            if ([title isEqualToString:buttonDeleteTitle]) {
                [self deleteRemind];
            }
        }];
    }
}

- (IBAction)datePickerValueChange:(id)sender {
    NSString *date = [_datePicker.date getDateString];
    _remind.date = date;
}

#pragma UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length >= 1) {
        /* 检查是否以包含空格 */
        NSRange range1 = [textView.text rangeOfString:@" "];
        if (NSNotFound != range1.location) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForRemindInfo", @"hint", nil)];
            textView.text = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            [self contentLengthCheck];
            return;
        }
#if 0
        if (0 == range1.location) {
            [self showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForRemindInfo", @"hint", nil) messageType:0];
            textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self contentLengthCheck];
            return;
        }
        
        /* 检查是否以空格结束 */
        NSString *sub = [textView.text substringFromIndex:textView.text.length-1];
        if ([sub isEqualToString:@" "]) {
            [self showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForRemindInfo", @"hint", nil) messageType:0];
            textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self contentLengthCheck];
            return;
        }
#endif
        /* 检查是否包含回车符 */
        NSRange range2 = [textView.text rangeOfString:@"\n"];
        if (NSNotFound != range2.location) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"invalidCharacterOrFormatForRemindInfo", @"hint", nil)];
            textView.text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [self contentLengthCheck];
            return;
        }
    }
    
    _remind.content = textView.text;
    [self contentLengthCheck];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self contentLengthCheck];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self contentLengthCheck];
}

#pragma Mark:备忘信息数据源

- (void)openRemind:(BOOL)open {
    NSString *successful;
    NSString *failed;
    
    if (open) {
        
        successful = NSLocalizedStringFromTable(@"openRemindSuccessful", @"hint", nil);
        failed = NSLocalizedStringFromTable(@"openRemindFailed", @"hint", nil);
        _remind.is_valid = YES;
    } else {
        
        successful = NSLocalizedStringFromTable(@"closeRemindSuccessful", @"hint", nil);
        failed = NSLocalizedStringFromTable(@"closeRemindFailed", @"hint", nil);
        _remind.is_valid = NO;
    }
    
    [self showActiviting];
    
    [self.deviceManager.device modifyRemind:_remind parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)modifyRemind {
    
    if (![self inputParametersIsValid]) {
        return;
    }

    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    NSString *successful = NSLocalizedStringFromTable(@"modifyRemindSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"modifyRemindFailed", @"hint", nil);
    
    [self.deviceManager.device modifyRemind:_remind parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)deleteRemind {
    NSString *successful = NSLocalizedStringFromTable(@"deleteSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"deleteFailed", @"hint", nil);
    
    [self showActiviting];
    
    [self.deviceManager.device deleteRemind:_remind.ID params:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeEffectView];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)addRemind:(void (^)(void))popVC {
    
    NSLog(@"%s", __func__);
    
    if (![self inputParametersIsValid]) {
        return;
    }

    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    NSString *successful = NSLocalizedStringFromTable(@"insertRemindAlarmSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"insertRemindAlarmFailed", @"hint", nil);
    __block RemindViewController *remindVC = self;
    [self.deviceManager.device addRemind:_remind parameter:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [remindVC removeEffectView];
            [remindVC.navigationController popViewControllerAnimated:YES];
        });
    }];
}

@end
