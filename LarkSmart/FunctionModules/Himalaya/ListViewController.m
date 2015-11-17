//
//  SecondCategoryViewController.m
//  CloudBox
//
//  Created by TTS on 15-5-11.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ListViewController.h"
#import "UIImageView+WebCache.h"
#import "CategoryViewCell.h"
#import "ContentViewController.h"
//#import "M2DHudView.h"
#import "MainMenuViewController.h"

@interface ListViewController ()
{
    NSMutableArray *secondCategory;
//    M2DHudView *hud;
}

@end

@implementation ListViewController

- (void)viewDidLoad {
    
//    NSLog(@"%s", __func__);
    
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"returnToMainMenu", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(returnToMainMenu)];
    
    [self hideEmptySeparators:self.tableView];
    
    self.toolbarItems = [_toolBarPlayer toolItems];
//    hud = [[M2DHudView alloc] init];
    
    [self getCategory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/** 返回到主菜单 */
- (void)returnToMainMenu {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MainMenuViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = secondCategory.count;
    
    if (count > 0) {
        
        CategoryClass *category = secondCategory[0];
        [self.navigationItem setTitle:category.title];
        
        if (1 == count) {
            return 1;
        } else if (count > 1) {
            return count-1;
        }
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryViewCell" forIndexPath:indexPath];
    NSUInteger count = secondCategory.count;
    CategoryClass *category;
    
    if (1 == count) {
        category = secondCategory[0];
    } else if (count > 1) {
        category = [secondCategory objectAtIndex:indexPath.row+1];
    } else {
        return nil;
    }
    
    [cell.image sd_setImageWithURL:[NSURL URLWithString:category.icon] placeholderImage:[UIImage imageNamed:@"default_small.png"]]; // 从网络获取节目的icon
    [cell.text setText:category.title];
    cell.categoryID = category.categoryId;
    cell.hasSub = category.hassub;
    if (category.hassub) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%s", __func__);
    
    CategoryViewCell *cell = (CategoryViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.hasSub) {
        /* 其下还有子类 */
        ListViewController *subCategoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
        subCategoryVC.deviceManager = self.deviceManager;
        subCategoryVC.parentCategoryID = cell.categoryID;
        subCategoryVC.toolBarPlayer = _toolBarPlayer;
        if (nil != subCategoryVC) {
            [self.navigationController pushViewController:subCategoryVC animated:YES];
        }
        
    } else {
        /* 无子类则进入到节目列表 */
        ContentViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentViewController"];
        contentVC.deviceManager = self.deviceManager;
        contentVC.parentCategoryID = cell.categoryID;
        contentVC.toolBarPlayer = _toolBarPlayer;
        contentVC.categoryTitle = cell.text.text;
        if (nil != contentVC) {
            [self.navigationController pushViewController:contentVC animated:YES];
        }
    }
}

/** 获取节目子类 */
- (void)getCategory {

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    [self.deviceManager.serverService requestSubCategorysWithCateogryId:_parentCategoryID requestMode:YYTXHttpRequestPostAndAsync requestFinish:^(NSMutableArray *subCategorys, YYTXHttpRequestReturnCode code) {
        
        NSLog(@"%s %@ %d", __func__, subCategorys, code);

        if (YYTXHttpRequestSuccessful == code) {
            dispatch_async(dispatch_get_main_queue(), ^{

                [self removeEffectView];
                secondCategory = subCategorys; // 节目子类
                
                [self.tableView reloadData]; // 刷新界面
            });
        } else if (YYTXHttpRequestTimeout == code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showTitle:NSLocalizedStringFromTable(@"getProgramListFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"networkTimeout", @"hint", nil)];
            });
        } else if (YYTXHttpRequestUnknownError == code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showTitle:NSLocalizedStringFromTable(@"getProgramListFailed", @"hint", nil) hint:@""];
            });
        }
        
    }];
}

@end
