//
//  LoopPlayTimeTableViewController.m
//  CloudBox
//
//  Created by TTS on 15/7/20.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "LoopPlayTimeTableViewController.h"
#import "LoopPlayTImeTableViewCell.h"

@interface LoopPlayTimeTableViewController ()

@property (nonatomic, retain) NSIndexPath *selectPath;

@end

@implementation LoopPlayTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self hideEmptySeparators:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.deviceManager.device.userData.parameter1.playTime.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LoopPlayTImeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoopPlayTImeTableViewCell"];
    
    NSDictionary *dic = [self.deviceManager.device.userData.parameter1.playTime objectAtIndex:indexPath.row];
    NSString *title = [dic allKeys][0];
    [cell.labelForTime setText:title];
    
    if ([[self.deviceManager.device.userData.parameter1 getTimeTitleAccrodingToTime:self.deviceManager.device.userData.parameter1.loopPlayTime] isEqualToString:cell.labelForTime.text]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        _selectPath = indexPath;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LoopPlayTImeTableViewCell *cell = (LoopPlayTImeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (nil != _selectPath) {
        [[tableView cellForRowAtIndexPath:_selectPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
    _selectPath = indexPath;
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    NSInteger time = [self.deviceManager.device.userData.parameter1 getTimeAccrodingToTimeTitle:cell.labelForTime.text];
    
    self.deviceManager.device.userData.parameter1.loopPlayTime = time;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
