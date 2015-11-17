//
//  ConfigFailedViewController.m
//  CloudBox
//
//  Created by TTS on 15/6/29.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "NoHintTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface NoHintTableViewController ()

@end

@implementation NoHintTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hideEmptySeparators:self.tableView];
    
    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"resend", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(resend)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [self setToolbarItems:@[space, nextStep, space] animated:YES];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"noHint", @"hint", nil)];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _needFSKConfig = NO; // 初始化
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (0 == section) {
        return 1;
    } else if (1 == section) {
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (1 == section) {
        return 30.0f;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            return 400.0f;
        }
    } else if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            return 60.0f;
        }
    }
    
    return .0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (1 == section) {
        UIView *header = [[UIView alloc] init];
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:15]];
        [label setText:NSLocalizedStringFromTable(@"currentVolume", @"hint", nil)];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [header addSubview:label];
        
        [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[label]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[label]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        
        return header;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifinoremind.png"]];
            [imageview setContentMode:UIViewContentModeScaleAspectFit];
//            [imageview sizeToFit];
            imageview.translatesAutoresizingMaskIntoConstraints = NO;
            [cell addSubview:imageview];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:imageview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:imageview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:imageview attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:imageview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    } else if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            
            /* 从MPVolumeView中获取出音量控制器MPVolumeSlider */
            MPVolumeView *volumeView = [[MPVolumeView alloc] init];
            UISlider* volumeViewSlider = nil;
            for (UIView *view in [volumeView subviews]){
                if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                    volumeViewSlider = (UISlider*)view;
                    break;
                }
            }
            
            [volumeViewSlider setThumbImage:[UIImage imageNamed:@"volume.png"] forState:UIControlStateNormal];
            volumeViewSlider.translatesAutoresizingMaskIntoConstraints = NO;
            
            [cell addSubview:volumeViewSlider];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:volumeViewSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(tableView.frame)-30]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:volumeViewSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:volumeViewSlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:volumeViewSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (void)resend {
    
    if (self.isAnimating) {
        return;
    }
    
    _needFSKConfig = YES; // 重新发送FSK声波
    [self.navigationController popViewControllerAnimated:YES];
}

@end
