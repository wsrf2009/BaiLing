//
//  SleepMusicTimeTableViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-22.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "PlayTimeViewController.h"
#import "SleepMusicViewCell.h"

@interface PlayTimeViewController ()
{
    NSIndexPath *selectPath;
}

@end

@implementation PlayTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    [self hideEmptySeparators:self.tableView];
    
    [self.navigationItem setTitle:@"播放时长"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%s", __func__);

    return _sleepMusic.timeList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SleepMusicViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SleepMusicViewCell" forIndexPath:indexPath];
    
    sleepMusicTime *time = [_sleepMusic.timeList objectAtIndex:indexPath.row];
    [cell.title setText:time.miunteLable];
    
    if (time.seconds == _sleepMusic.playTime) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        selectPath = indexPath;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (nil != selectPath) {
        [[tableView cellForRowAtIndexPath:selectPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    selectPath = indexPath;
    sleepMusicTime *time = [_sleepMusic.timeList objectAtIndex:indexPath.row];
    _sleepMusic.playTime = time.seconds;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
