//
//  SuggestionViewController.m
//  CloudBox
//
//  Created by TTS on 15/8/17.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SuggestionViewController.h"
#import "JGActionSheet.h"
#import "UICustomActionSheet.h"
#import "IQTextView.h"

#define MAXSUGGESTIONLENGTH         200
#define MAXCONTACTLENGTH            50

@interface SuggestionViewController () <UITextViewDelegate, UIActionSheetDelegate, JGActionSheetDelegate>
@property (nonatomic, retain) IBOutlet IQTextView *textViewSuggestion;
@property (nonatomic, retain) IBOutlet IQTextView *textViewContact;
@property (nonatomic, retain) IBOutlet UILabel *labelMaxSuggestionLength;
@property (nonatomic, retain) IBOutlet UILabel *labelSuggestionLength;
@property (nonatomic, retain) IBOutlet UILabel *labelMaxContactLength;
@property (nonatomic, retain) IBOutlet UILabel *labelContactLength;
@property (nonatomic, retain) IBOutlet UILabel *labelSoftOrHard;
@property (nonatomic, retain) IBOutlet UILabel *labelFeedbackType;
@property (nonatomic, retain) NSArray *softHard;
@property (nonatomic, retain) NSArray *feedbackType;

@end

@implementation SuggestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hideEmptySeparators:self.tableView];
    
    _softHard = @[@"百灵APP软件", @"百灵硬件终端"];
    _feedbackType = @[@"错误或异常", @"新想法", @"体验差"];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"suggestionFeedback", @"hint", nil)];
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"submit", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(suggestionSubmit)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[space, submit, space]];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    /* 给textview添加边框 */
    _textViewSuggestion.layer.cornerRadius = 10;
    _textViewSuggestion.layer.masksToBounds = YES;
    [_textViewSuggestion.layer setBorderWidth:0.5f];
    [_textViewSuggestion.layer setBorderColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor];
    
    _textViewContact.layer.cornerRadius = 10;
    _textViewContact.layer.masksToBounds = YES;
    [_textViewContact.layer setBorderWidth:0.5f];
    [_textViewContact.layer setBorderColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f].CGColor];
    
    _textViewSuggestion.delegate = self;
    _textViewContact.delegate = self;
    
    [_labelMaxSuggestionLength setText:[NSString stringWithFormat:@"/%d", MAXSUGGESTIONLENGTH]];
    [_labelMaxSuggestionLength setTextColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
    [self contentLengthCheck];
    
    [_labelMaxContactLength setText:[NSString stringWithFormat:@"/%d", MAXCONTACTLENGTH]];
    [_labelMaxContactLength setTextColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
    [self contactLengthCheck];
    
    [_labelSoftOrHard setText:_softHard[0]];
    [_labelFeedbackType setText:_feedbackType[0]];
    [_textViewSuggestion setPlaceholder:NSLocalizedStringFromTable(@"pleaseInputYourSuggestion", @"hint", nil)];
    [_textViewContact setPlaceholder:NSLocalizedStringFromTable(@"pleaseLeftYourContactInformation", @"hint", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            /* 反馈的问题：百灵APP软件、百灵硬件终端 */
            NSString *title = NSLocalizedStringFromTable(@"questionYouWantToFeedbackBelongTo", @"hint", nil);
            
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:title message:nil buttonTitles:_softHard buttonStyle:JGActionSheetButtonStyleBlue]; // 初始化section
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0]]; // 初始化sheet
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                /* ipad中指定显示的位置 */
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_labelSoftOrHard.bounds)};
                p = [self.navigationController.view convertPoint:p fromView:_labelSoftOrHard];
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            } else {
                /* iphone */
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
                /* 在sheet之外点击 */
                [sheet dismissAnimated:YES];
            }];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                /* 点中了某一个section */
                [sheet dismissAnimated:YES];
                
                if (0 == indexPath.section) {
                    [_labelSoftOrHard setText:[_softHard objectAtIndex:indexPath.row]];
                }
            }];
        } else if (1 == indexPath.row) {
            /* 反馈的类型：错误或异常、新想法、体验差 */
            NSString *title = NSLocalizedStringFromTable(@"typeYouWantToFeedbackBelongTo", @"hint", nil);
            JGActionSheetSection *s0 = [JGActionSheetSection sectionWithTitle:title message:nil buttonTitles:_feedbackType buttonStyle:JGActionSheetButtonStyleBlue]; // 初始化section
            
            JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[s0]]; // 初始化sheet
            sheet.delegate = self;
            sheet.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                /* 指定在ipad中显示的位置 */
                CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(_labelFeedbackType.bounds)};
                p = [self.navigationController.view convertPoint:p fromView:_labelFeedbackType];
                [sheet showFromPoint:p inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
            }
            else {
                /* iphone */
                [sheet showInView:self.navigationController.view animated:YES];
            }
            
            [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
                /* sheet之外点击 */
                [sheet dismissAnimated:YES];
            }];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                /* sheet之内的某个section */
                [sheet dismissAnimated:YES];
                
                if (0 == indexPath.section) {
                    [_labelFeedbackType setText:[_feedbackType objectAtIndex:indexPath.row]];
                }
            }];
        }
    }
}

#pragma UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {

    NSLog(@"%s ＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋", __func__);
    
    if (textView.text.length >= 1) {
        /* 检查是否以空格或回车开始 */
        NSRange range1 = [textView.text rangeOfString:@" "];
        NSRange range2 = [textView.text rangeOfString:@"\n"];
        if (0 == range1.location || 0 == range2.location) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"feedbackInputIsInvalid", @"hint", nil)];
            textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            return;
        }
#if 0
        /* 检查是否以空格结束 */
        NSString *sub = [textView.text substringFromIndex:textView.text.length-1];
        if ([sub isEqualToString:@" "] || [sub isEqualToString:@"\n"]) {
            [self showMessage:NSLocalizedStringFromTable(@"feedbackInputIsInvalid", @"hint", nil) messageType:0];
            textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            return;
        }
#endif
    }
    
    if (textView == _textViewSuggestion) {
        [self contentLengthCheck];
    } else if (textView == _textViewContact) {
        [self contactLengthCheck];
    }
    
}

/** 检查反馈内容的长度 */
- (BOOL)contentLengthCheck {
    NSInteger length = _textViewSuggestion.text.length;
    
    if ((0 < length) && (length <= MAXSUGGESTIONLENGTH)) {
        [_labelSuggestionLength setText:[NSString stringWithFormat:@"%ld", (long)length]];
        [_labelSuggestionLength setTextColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
        
        return YES;
    } else {
        
        [_labelSuggestionLength setText:[NSString stringWithFormat:@"%ld", (long)length]];
        [_labelSuggestionLength setTextColor:[UIColor redColor]];
        
        return NO;
    }
}

/** 检查联系信息的长度 */
- (BOOL)contactLengthCheck {
    NSInteger length = _textViewContact.text.length;
    
    if ((0 < length) && (length <= MAXCONTACTLENGTH)) {
        [_labelContactLength setText:[NSString stringWithFormat:@"%ld", (long)length]];
        [_labelContactLength setTextColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
        
        return YES;
    } else {
        
        [_labelContactLength setText:[NSString stringWithFormat:@"%ld", (long)length]];
        [_labelContactLength setTextColor:[UIColor redColor]];
        
        return NO;
    }
}

- (void)suggestionSubmit {

    /* 检查输入的反馈内容字数是否符合要求 */
    if (![self contentLengthCheck]) {
        
        if (_textViewSuggestion.text.length <= 0) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"pleaseInputYourSuggestion", @"hint", nil)];
        } else {
            [QXToast showMessage:NSLocalizedStringFromTable(@"suggestionIsTooLong", @"hint", nil)];
        }
        
        [_textViewSuggestion becomeFirstResponder];
        
        return;
    } else {
        /* 判断是否全为空格或回车 */
        NSString *str = [_textViewSuggestion.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if (str.length <= 0) {
            
            [QXToast showMessage:NSLocalizedStringFromTable(@"feedBackInvalid", @"hint", nil)];
            
            _textViewSuggestion.text = NSLocalizedStringFromTable(@"pleaseInputYourSuggestion", @"hint", nil);
            [_textViewSuggestion becomeFirstResponder];
            
            return;
        } else {
            /* 删除文本首尾的空格和换行符 */
            _textViewSuggestion.text = [_textViewSuggestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    /* 检查联系方式的字数是否符合要求 */
    if (![self contactLengthCheck]) {
        
        if (_textViewContact.text.length <= 0) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"pleaseLeftYourContactInformation", @"hint", nil)];
        } else {
            [QXToast showMessage:NSLocalizedStringFromTable(@"contactsIsTooLong", @"hint", nil)];
        }
        
        [_textViewContact becomeFirstResponder];
        
        return;
    } else {
        /* 判断是否全为空格或回车 */
        NSString *str = [_textViewContact.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if (str.length <= 0) {
            
            [QXToast showMessage:NSLocalizedStringFromTable(@"contactInfoInvalid", @"hint", nil)];
            
            _textViewContact.text = NSLocalizedStringFromTable(@"pleaseLeftYourContactInformation", @"hint", nil);
            [_textViewContact becomeFirstResponder];
            
            return;
        } else {
            /* 删除文本首尾的空格和换行符 */
            _textViewContact.text = [_textViewContact.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    [self showBusying:NSLocalizedStringFromTable(@"submiting", @"hint", nil)];
    
    NSDictionary *dic = @{jsonItemKeySoftHartType:_labelSoftOrHard.text, jsonItemKeyFeedbackType:_labelFeedbackType.text, jsonItemKeyContent:_textViewSuggestion.text, jsonItemKeyContactWay:_textViewContact.text, jsonItemKeyYunBaoVersion:self.deviceManager.device.userData.deviceInfo.SWVersion, jsonItemKeyYunBaoBatchId:self.deviceManager.device.userData.deviceInfo.goodsId, jsonItemKeyYunBaoConfigId:self.deviceManager.device.userData.deviceInfo.config, jsonItemKeyYunBaoOpenId:self.deviceManager.device.userData.generalData.openid};
    [self.deviceManager.serverService postUserFeedback:dic requestFinish:^(NSString *message) {
        
        [self removeEffectView];
        
        if (nil == message) {
            [QXToast showMessage:NSLocalizedStringFromTable(@"submitSuccessful", @"hint", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [QXToast showMessage:message];
        }
    }];
}

@end
