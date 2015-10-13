//
//  WakeupNameViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-16.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "WakeupNameViewController.h"
#import "WakeupNameTableViewCell.h"

@interface WakeupNameViewController ()
{
    NSIndexPath *selectPath;
}

@end

@implementation WakeupNameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifyWakeup)];
    [self setToolbarItems:[[NSArray alloc] initWithObjects:space, buttonSave, space, nil] animated:YES];
    
    self.deviceManager.delegate = self;
    
    [self getWakeupData];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"wakeupName", @"hint", nil)];
    
    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.deviceManager.device.userData.wakeup arrayName] count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        NSString *hint = NSLocalizedStringFromTable(@"wakeupHint", @"hint", nil);
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
        
        UILabel *label = [[UILabel alloc] init];
        [label setAttributedText:attrString];
        [label setNumberOfLines:0];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell addSubview:label];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==15)-[label]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=15)-[label]-(==10)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
        
    } else {
    
        WakeupNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WakeupNameTableCellView"];
    
        WakeupName *wakeup = [[self.deviceManager.device.userData.wakeup arrayName] objectAtIndex:indexPath.row-1];
        [cell.lable_Name setText:wakeup.name];
        if (wakeup.highlight) {
            [cell.viewRecommend setHidden:NO];
            [cell.viewRecommend setText:@"推荐"];
        } else {
            [cell.viewRecommend setHidden:YES];
        }
    
        [cell.button_SoundTest setTag:indexPath.row];
        [cell.buttonChecked setTag:indexPath.row];
    
        if ([self.deviceManager.device.userData.wakeup.name isEqualToString:wakeup.name]) {
            [cell.buttonChecked setImage:[UIImage imageNamed:@"rb_checked.png"] forState:UIControlStateNormal];
            selectPath = indexPath;
        } else {
            [cell.buttonChecked setImage:[UIImage imageNamed:@"rb_normal.png"] forState:UIControlStateNormal];
        }
    
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.section) {
        if (indexPath.row > 0) {
            
            if (selectPath) {
                if ([selectPath isEqual:indexPath]) {
                   return;
                }
                
                WakeupNameTableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:selectPath];
                [uncheckCell.buttonChecked setImage:[UIImage imageNamed:@"rb_normal.png"] forState:UIControlStateNormal];
            }
            
            WakeupNameTableViewCell *cell = (WakeupNameTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.buttonChecked setImage:[UIImage imageNamed:@"rb_checked.png"] forState:UIControlStateNormal];
            selectPath = indexPath;
            
            [self.deviceManager.device.userData.wakeup setName:cell.lable_Name.text];
        }
    }
}

- (IBAction)buttonCheckedClicked:(UIButton *)button {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    if (nil != selectPath) {
        WakeupNameTableViewCell *uncheckCell = [self.tableView cellForRowAtIndexPath:selectPath];
        [uncheckCell.buttonChecked setImage:[UIImage imageNamed:@"rb_normal.png"] forState:UIControlStateNormal];
    }
    
    WakeupNameTableViewCell *cell = (WakeupNameTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.buttonChecked setImage:[UIImage imageNamed:@"rb_checked.png"] forState:UIControlStateNormal];
    selectPath = indexPath;
    
    [self.deviceManager.device.userData.wakeup setName:cell.lable_Name.text];
}

- (IBAction)buttonClick_SoundTest:(UIButton *)button {
    
    [button setEnabled:NO];
    [self showBusying:NSLocalizedStringFromTable(@"pleaseWaiting", @"hint", nil)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self removeEffectView];
        [button setEnabled:YES];
    });
    
    WakeupName *wakeup = [[self.deviceManager.device.userData.wakeup arrayName] objectAtIndex:button.tag-1];

    [self.deviceManager.device playFileId:wakeup.identifier completionBlock:nil];
}

#pragma 唤醒设置数据源

- (void)getWakeupData {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    [self.deviceManager.device getWakeup:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (YYTXOperationSuccessful == code) {
                
                [self removeEffectView];
                [self.tableView reloadData];
            } else if (YYTXTransferFailed == code) {
                
                [self showTitle:NSLocalizedStringFromTable(@"getWakeupFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
            } else {
                [self showTitle:NSLocalizedStringFromTable(@"getWakeupFailed", @"hint", nil) hint:@""];
            }
        });
    }];
}

- (void)modifyWakeup {
    
    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    NSString *successful = NSLocalizedStringFromTable(@"modifyWakeupNameSuccessful", @"hint", nil);
    NSString *failed = NSLocalizedStringFromTable(@"modifyWakeupNameFailed", @"hint", nil);
    [self.deviceManager.device modifyWakeup:@{DevicePlayTTSWhenOperationSuccessful:successful, DevicePlayTTSWhenOperationFailed:failed} completionBlock :^(YYTXDeviceReturnCode code) {
        
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
