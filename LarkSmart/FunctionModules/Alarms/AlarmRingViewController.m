//
//  AlarmRingViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-10.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AlarmRingViewController.h"
#import "AlarmRingClass.h"
#import "AlarmRingCell.h"
#import "Toast.h"

@interface AlarmRingViewController () <YYTXDeviceManagerDelegate>
{
    NSArray *rings;
}

@end

@implementation AlarmRingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deviceManager.delegate = self;
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"ringSelection", @"hint", nil)];

    rings = [AlarmRingClass getRingArray];
    
    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
    
    [self.deviceManager.device stopPlay:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return rings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    AlarmRingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmRingCellView" forIndexPath:indexPath];
    
    AlarmRingClass *ring = [rings objectAtIndex:row];
    [cell.label_name setText:[NSString stringWithFormat:@"%@(%@)", ring.name, ring.info]];

    [cell.button_test setTag:row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __func__);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;

    _selectRow = row;
    _getupSet.ringPath = [AlarmRingClass getPathViaIndex:row];
    _getupSet.ringType = RING_TYPE_LOCAL;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma ring test

- (IBAction)buttonClick_test:(UIButton *)button {
    
    NSLog(@"%s row:%ld", __func__, (long)button.tag);

    [button setEnabled:NO];
    [self showBusying:NSLocalizedStringFromTable(@"pleaseWaiting", @"hint", nil)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self removeEffectView];
        [button setEnabled:YES];
    });
    
    NSString *ringPath = [AlarmRingClass getPathViaIndex:button.tag];

    [self.deviceManager.device playFilePath:ringPath completionBlock:nil];
}

@end
