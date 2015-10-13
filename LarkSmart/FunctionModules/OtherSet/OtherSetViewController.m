//
//  OtherSetViewController.m
//  CloudBox
//
//  Created by TTS on 15/7/20.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "OtherSetViewController.h"
#import "LoopPlayTimeTableViewController.h"

#define LeadingSpaceToSuperView         15.0f
#define TrailingSpaceToSuperView         15.0f
#define TopSpaceToSuperView         5.0f
#define BottomSpaceToSuperView      10.0f

@interface OtherSetViewController () <YYTXDeviceManagerDelegate>

@property (nonatomic, retain) IBOutlet UILabel *labelForLoopPlayTime;
@property (nonatomic, retain) IBOutlet UISwitch *switchForChime;
@property (nonatomic, retain) IBOutlet UISwitch *switchForHalfChime;
@property (nonatomic, retain) IBOutlet UILabel *labelLoopPlayHint;

@property (nonatomic, retain) UIFont *fontForHint;

@property (nonatomic, retain) LoopPlayTimeTableViewController *loopPlayTimeTVC;

@end

@implementation OtherSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deviceManager.delegate = self;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifyParameter1)];
    self.toolbarItems = @[space, buttonSave, space];
    
    [self getParameter1];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"otherSet", @"hint", nil)];
    
    _fontForHint = [UIFont systemFontOfSize:15.0f];
    
    NSString *loopPlayHint = NSLocalizedStringFromTable(@"loopPlayHint", @"hint", nil);
    // 创建可变属性化字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:loopPlayHint];
    NSUInteger length = [loopPlayHint length];
    // 设置基本字体
    UIFont *baseFont = [UIFont systemFontOfSize:14.0f];
    [attrString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, length)];
    UIColor *baseColor = [UIColor grayColor];
    [attrString addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, length)];
    [_labelLoopPlayHint setAttributedText:attrString];
    
    [self hideEmptySeparators:self.tableView];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.deviceManager.delegate = self;
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (nil != _loopPlayTimeTVC) {
        [self updateUI];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            _loopPlayTimeTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoopPlayTimeTableViewController"];
            _loopPlayTimeTVC.deviceManager =  self.deviceManager;
            [self.navigationController pushViewController:_loopPlayTimeTVC animated:YES];
        }
    }
}

- (void)updateUI {

    [_labelForLoopPlayTime setText:[self.deviceManager.device.userData.parameter1 getTimeTitleAccrodingToTime:self.deviceManager.device.userData.parameter1.loopPlayTime]];
    
    [_switchForChime setOn:self.deviceManager.device.userData.parameter1.chime animated:YES];
    [_switchForHalfChime setOn:self.deviceManager.device.userData.parameter1.halfChime animated:YES];
}

- (IBAction)chimeValueChange:(id)sender {
    
    self.deviceManager.device.userData.parameter1.chime = _switchForChime.isOn;
}

- (IBAction)halfChimeValueChange:(id)sender {

    self.deviceManager.device.userData.parameter1.halfChime = _switchForHalfChime.isOn;
}

#pragma 其他设置数据源

- (void)getParameter1 {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    [self.deviceManager.device getParameter1:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (YYTXOperationSuccessful == code) {
                
                [self removeEffectView];
                [self updateUI];
            } else if (YYTXTransferFailed == code) {
                
                [self showTitle:NSLocalizedStringFromTable(@"getOtherSetFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];

            } else {
                [self showTitle:NSLocalizedStringFromTable(@"getNightControlFailed", @"hint", nil) hint:@""];
            }
        });
    }];
}

- (void)modifyParameter1 {
    
    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    [self.deviceManager.device modifyParameter1:@{DevicePlayFileWhenOperationSuccessful:devicePromptFileIdModifySuccessful, DevicePlayFileWhenOperationFailed:devicePromptFileIdModifyFailed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (YYTXOperationSuccessful == code) {
                
                [self.navigationController popViewControllerAnimated:YES];
            } else if (YYTXTransferFailed == code) {
                
                [self showTitle:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];

            } else {
                [self removeEffectView];
                [Toast showWithText:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil)];
            }
        });
    }];
}

@end
