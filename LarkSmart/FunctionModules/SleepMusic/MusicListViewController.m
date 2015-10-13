//
//  SubCategoryListTableViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "MusicListViewController.h"
#import "SleepMusicViewCell.h"
//#import "ServerServceManager.h"

@interface MusicListViewController ()
{
    NSIndexPath *selectPath;
}

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (1 == _source.count) {
        return 1;
    } else {
        return _source.count-1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SleepMusicViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubCategoryListViewCell" forIndexPath:indexPath];
    if (_source.count == 1) {
        CategoryClass *category = [_source objectAtIndex:0];
        [cell.title setText:category.title];
        
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        selectPath = indexPath;
    } else {
        CategoryClass *category = [_source objectAtIndex:indexPath.row+1];
        [cell.title setText:category.title];
        
        if ([category.categoryId isEqualToString:_selectId]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            selectPath = indexPath;
        }
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
    
    CategoryClass *category;
    if (_source.count == 1) {
        category = [_source objectAtIndex:0];
    } else {
        category = [_source objectAtIndex:indexPath.row+1];
    }
    _selectId = category.categoryId;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
