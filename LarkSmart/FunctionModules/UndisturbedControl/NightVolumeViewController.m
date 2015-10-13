//
//  NightVolumeViewController.m
//  CloudBox
//
//  Created by TTS on 15/7/20.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "NightVolumeViewController.h"
#import "NightVolumeTableViewCell.h"

@interface NightVolumeViewController ()

@property (nonatomic, retain) NSIndexPath *selectPath;

@end

@implementation NightVolumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"nightVolume", @"hint", nil)];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self hideEmptySeparators:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.deviceManager.device.userData.undisturbedControl.nightVolumes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NightVolumeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NightVolumeTableViewCell"];
    
    NSDictionary *dic = [self.deviceManager.device.userData.undisturbedControl.nightVolumes objectAtIndex:indexPath.row];
    [cell.labelVolumeTitle setText:[dic allKeys][0]];
    
    if ([[self.deviceManager.device.userData.undisturbedControl getVolumeTitleAccrodingToIndex:self.deviceManager.device.userData.undisturbedControl.undisturbedInitVolume] isEqualToString:cell.labelVolumeTitle.text]) {

        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        _selectPath = indexPath;
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NightVolumeTableViewCell *cell = (NightVolumeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (nil != _selectPath) {
        [[tableView cellForRowAtIndexPath:_selectPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
    _selectPath = indexPath;
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    NSInteger index = [self.deviceManager.device.userData.undisturbedControl getIndexAccrodingToVolumeTitle:cell.labelVolumeTitle.text];
    
    self.deviceManager.device.userData.undisturbedControl.undisturbedInitVolume = index;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
