//
//  CategoryListTableViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SubCategoryListViewController.h"
#import "SleepMusicViewCell.h"

@interface SubCategoryListViewController ()
{
    NSIndexPath *selectPath;
}

@end

@implementation SubCategoryListViewController

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
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (nil == _source) {
        return 0;
    } else {
        return _source.count-1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SleepMusicViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryListViewCell" forIndexPath:indexPath];
    
    CategoryClass *category = [_source objectAtIndex:indexPath.row+1];
    [cell.title setText:category.title];
    
    NSLog(@"%s (%ld) %@ %@", __func__, (long)indexPath.row, category.categoryId, _selectId);
    if ([category.categoryId isEqualToString:_selectId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        selectPath = indexPath;
    } else {
       [cell setAccessoryType:UITableViewCellAccessoryNone];
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
    CategoryClass *category = [_source objectAtIndex:indexPath.row+1];
    _selectId = category.categoryId;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
