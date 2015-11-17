//
//  ContentViewController.m
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ContentViewController.h"
#import "ContentItemViewCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "MainMenuViewController.h"
#import "SolidCircle.h"

#define ProgramsNumberPerPage       20

@interface programItem :NSObject
@property (nonatomic, retain) AudioClass *audio;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation programItem
@end

@interface ContentViewController () <ToolBarPlayerDelegate>
{
    NSInteger selectRow;
    NSUInteger page_;
    MJRefreshAutoNormalFooter *footer;
    UIColor *HightLightColor;
}

@property (assign, nonatomic) int count;
@property (nonatomic, retain) NSMutableArray *programArray;
@property (nonatomic, retain) UIBarButtonItem *barButtonItemMainMenu;

@property (nonatomic, retain) UIBarButtonItem *barButtonItemDone;
@property (nonatomic, retain) UIBarButtonItem *barbuttonItemSelectAll;
@property (nonatomic, retain) NSArray *listControlItemsArray;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    
    NSLog(@"%s", __func__);
    
    [super viewDidLoad];
    
    _barButtonItemMainMenu = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"returnToMainMenu", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(returnToMainMenu)];

    self.navigationItem.rightBarButtonItem = _barButtonItemMainMenu;
    
    [self hideEmptySeparators:self.tableView];
    
    self.toolbarItems = [_toolBarPlayer toolItems];
    _programArray = [[NSMutableArray alloc] init];


    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // 设置文字
    [footer setTitle:NSLocalizedStringFromTable(@"pullupToGetMore", @"hint", nil) forState:MJRefreshStateIdle];
    [footer setTitle:NSLocalizedStringFromTable(@"gettingProgramList", @"hint", nil) forState:MJRefreshStateRefreshing];
    footer.stateLabel.font = [UIFont systemFontOfSize:17]; // 设置字体
    footer.stateLabel.textColor = [UIColor grayColor]; // 设置颜色
    self.tableView.footer = footer;
    
    selectRow = -1; // 初始化
    
    page_ = 1; // 初始化，获取第一页
    [self.tableView.footer setState:MJRefreshStateRefreshing];

    [self.navigationItem setTitle:_categoryTitle];
    
    HightLightColor = [UIColor colorWithRed:58.0f/255.0f green:171.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__);
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/** 返回主菜单 */
- (void)returnToMainMenu {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MainMenuViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _programArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContentItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContentItemViewCell" forIndexPath:indexPath];
    
    NSLog(@"%s %@ %@", __func__, @(indexPath.section), @(indexPath.row));

    AudioClass *audio = [_programArray objectAtIndex:indexPath.row]; // 获取曲目
    if (selectRow == indexPath.row) { // 当前行是否为选中的行
        [cell.title setTextColor:HightLightColor];
        [cell.time setTextColor:HightLightColor];
    } else {
        [cell.title setTextColor:[UIColor blackColor]];
        [cell.time setTextColor:[UIColor grayColor]];
    }

    [cell.image sd_setImageWithURL:[NSURL URLWithString:audio.icon] placeholderImage:[UIImage imageNamed:@"default_small.png"]]; // 从网络获取曲目的icon
    [cell.title setText:audio.title];
    
    /* 曲目时长 */
    NSUInteger min = audio.duration/60;
    NSUInteger sec = audio.duration%60;
    [cell.time setText:[NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)min, (unsigned long)sec]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [self showBusying:NSLocalizedStringFromTable(@"pleaseWaiting", @"hint", nil)]; // 提示用户当前正忙，也防止频繁点击
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self removeEffectView];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
    
    /* 播放选中的曲目 */
    _toolBarPlayer.playList = _programArray;
    _toolBarPlayer.delegate = self;
    [_toolBarPlayer playAudioAtIndex:indexPath.row];
}

#pragma ToolBarPlayerDelegate

- (void)indexOfPlaying:(NSUInteger)index programTitle:(NSString *)title {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (selectRow >= 0) {
            /* 将之前已选中的行更改状态 */
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectRow inSection:0];
            ContentItemViewCell *cell = (ContentItemViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell.title setTextColor:[UIColor blackColor]];
            [cell.time setTextColor:[UIColor grayColor]];
        }
    
        selectRow = index;
        /* 将第selectRow行置为已选中的行 */
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectRow inSection:0];
        ContentItemViewCell *cell = (ContentItemViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.title setTextColor:HightLightColor];
        [cell.time setTextColor:HightLightColor];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
}

/** 从后台获取播放曲目列表 */
- (void)getContent:(NSUInteger)page {

    [self.deviceManager.serverService requestAudioListWithCategoryId:_parentCategoryID pageNo:page itemsPerpage:ProgramsNumberPerPage requestMode:YYTXHttpRequestPostAndAsync requestFinish:^(NSMutableArray *audioList, YYTXHttpRequestReturnCode code) {
        
        if (YYTXHttpRequestSuccessful == code) {
            /* 获取成功 */
            if (audioList.count > 1) {
                [audioList removeObjectAtIndex:0]; // 第一个是父类，需要去掉

                [_programArray addObjectsFromArray:audioList];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (audioList.count < ProgramsNumberPerPage) {
                        /* 已经加载完成 */
                        [footer setTitle:NSLocalizedStringFromTable(@"noMoreProgram", @"hint", nil) forState:MJRefreshStateNoMoreData];
                        [self.tableView.footer setState:MJRefreshStateNoMoreData];
                    } else {
                        [self.tableView.footer setState:MJRefreshStateIdle];
                    }
                    [self.tableView reloadData]; // 刷新列表
                });
            } else if (audioList.count <= 1) {
                /* 没有获取到曲目 */
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_programArray.count <= 0) {
                        /* 该节目类下没有曲目 */
                        [footer setTitle:NSLocalizedStringFromTable(@"noProgramFound", @"hint", nil) forState:MJRefreshStateNoMoreData];
                    } else {
                        /* 已经加载完成 */
                        [footer setTitle:NSLocalizedStringFromTable(@"noMoreProgram", @"hint", nil) forState:MJRefreshStateNoMoreData];
                    }
                
                    [self.tableView.footer setState:MJRefreshStateNoMoreData];
                });
            }
        } else if (YYTXHttpRequestTimeout == code) {
            /* 超时 */
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [footer setTitle:NSLocalizedStringFromTable(@"networkTimeout", @"hint", nil) forState:MJRefreshStateNoMoreData];
                [self.tableView.footer setState:MJRefreshStateIdle];
            });
        } else if (YYTXHttpRequestUnknownError == code) {
            /* 未知错误 */
            dispatch_async(dispatch_get_main_queue(), ^{
                    
                [footer setTitle:NSLocalizedStringFromTable(@"getProgramListFailed", @"hint", nil) forState:MJRefreshStateNoMoreData];
                [self.tableView.footer setState:MJRefreshStateIdle];
            });
        }
    }];
}

/* 加载曲目 */
- (void)loadMoreData {
    NSLog(@"%s", __func__);
    
    [self getContent:page_++];
}

@end
