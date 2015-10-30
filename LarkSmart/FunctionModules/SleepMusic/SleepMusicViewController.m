//
//  SleepMusicTableViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-22.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "SleepMusicViewController.h"
#import "PlayTimeViewController.h"
#import "SubCategoryListViewController.h"
#import "MusicListViewController.h"
#import "QXToast.h"

#define LeadingSpaceToSuperView         15.0f
#define TrailingSpaceToSuperView         15.0f
#define TopSpaceToSuperView         5.0f
#define BottomSpaceToSuperView      10.0f

@interface SleepMusicViewController () <YYTXDeviceManagerDelegate>
{
    NSMutableArray *musicCategory; // 包含了所有的音乐子类，如睡眠音乐、儿童音乐、佛教音乐等，但仅是包含类名，并不包含该类下的音乐列表
    NSMutableArray *subCategoryListArray; // 包含音乐子类下所有含有孙类的音乐子类，就不仅仅是包含一个类名，比如儿童音乐含有子类，则subCategoryListArray就会包含儿童音乐以及儿童音乐下的子类，假如睡眠音乐没有子类，则不会包含在其中
    NSMutableArray *selectSubCategoryList; // 选中的音乐子类，包含该音乐子类以及该子类下的所有子类，如果该音乐子类没有子类，则只是包含该类名
    NSString *musicCategoryId; // 音乐类的ID，如002
    NSString *subCategoryId; // 音乐类下子类的ID，如002001
    NSString *musicId; // 音乐ID，如002001001
    SubCategoryListViewController *subCategoryListVC;
    MusicListViewController *musicListVC;
    PlayTimeViewController *playTimeVC;
//    M2DHudView *hud;
}

@property (nonatomic, retain) IBOutlet UILabel *lableType;
@property (nonatomic, retain) IBOutlet UILabel *lableAlbum;
@property (nonatomic, retain) IBOutlet UILabel *lableTime;
@property (nonatomic, retain) IBOutlet UISwitch *switchEnableSleepMusic;
@property (nonatomic, retain) IBOutlet UILabel *labelSleepMusicHint;

@property (nonatomic, retain) UIFont *fontForHint;

@end

@implementation SleepMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.deviceManager.delegate = self;
    subCategoryListArray = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifySleepMusic)];
    [self setToolbarItems:[NSArray arrayWithObjects:space, buttonSave, space, nil]];
    
    [self getSleepMusic];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"sleepMusicSet", @"hint", nil)];
    
    _fontForHint = [UIFont systemFontOfSize:15.0f];
    
    NSString *hint = NSLocalizedStringFromTable(@"sleepMusicHint", @"hint", nil);
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
    [_labelSleepMusicHint setAttributedText:attrString];
    
    [self hideEmptySeparators:self.tableView];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"enter %s", __func__);
    
    self.deviceManager.delegate = self;
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (self.deviceManager.device.isAbsent) {
        
        [self initEffectViewWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
        
        return;
    }
    
    NSString *timeTitle = [self.deviceManager.device.userData.sleepMusic getMinuteLableAccrodingToSecond:self.deviceManager.device.userData.sleepMusic.playTime];
    
    [self performSelectorOnMainThread:@selector(setPlayTime:) withObject:timeTitle waitUntilDone:NO];
    
    /*
     * 如果是从音乐子类列表页面返回
     */
    if (nil != subCategoryListVC) {
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        
        /*
         * 选中的音乐子类与之前已选中的子类不同
         */
        if (nil != subCategoryId && nil != subCategoryListVC.selectId) {
            if (![subCategoryId isEqualToString:subCategoryListVC.selectId]) {
                
                subCategoryId = subCategoryListVC.selectId;
                NSString *title = [AudioCategory getTitleFromCategoryList:musicCategory withRootCategoryID:musicCategoryId withSubCategoryId:subCategoryId]; // 获取新的音乐子类名
                [self setSubMusicCategoryTitle:title];

                CategoryClass *category = [CategoryClass getSubCategoryFromRootCategoryArray:musicCategory withSubCategoryId:subCategoryId]; // 获取新的音乐子类
                
                if (category.hassub) {
                    /*
                     * 如果选中的音乐子类包含孙类
                     */
                    
                    NSMutableArray *subCategoryList = [AudioCategory getSubCategoryListFromRootCategoryListArray:subCategoryListArray withSubCategoryId:subCategoryId]; // 获取孙类列表
                    
                    NSLog(@"subCategoryList:%@", subCategoryList);
                    
                    if (nil != subCategoryList) {
                        /*
                         * 获取孙类成功
                         */
                        selectSubCategoryList = subCategoryList;
                        CategoryClass *rootCategory = selectSubCategoryList[0];
                        
                        if (selectSubCategoryList.count > 1) {
                            CategoryClass *subCategory = selectSubCategoryList[1];
                            self.deviceManager.device.userData.sleepMusic.categoryId = subCategory.categoryId;
                            [_lableAlbum setText:subCategory.title];
                        } else {
                            /*
                             * 孙类下的信息获取有误
                             */
                            self.deviceManager.device.userData.sleepMusic.categoryId = rootCategory.categoryId;
                            [_lableAlbum setText:rootCategory.title];
                        }
                    } else {
                        /*
                         * 获取孙类失败
                         */
                        selectSubCategoryList = [NSMutableArray arrayWithObject:category];
                        self.deviceManager.device.userData.sleepMusic.categoryId = category.categoryId;
                        [_lableAlbum setText:category.title];
                    }
                } else {
                    /*
                     * 该类不包含子类
                     */
                    selectSubCategoryList = [NSMutableArray arrayWithObject:category];
                    self.deviceManager.device.userData.sleepMusic.categoryId = category.categoryId;
                    [_lableAlbum setText:category.title];
                }
                
                if (nil != musicListVC) {
                    musicListVC.selectId = self.deviceManager.device.userData.sleepMusic.categoryId;
                }
            }
        }
    }
    
    /*
     * 从音乐孙类列表页面返回
     */
    if (nil != musicListVC) {
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        
        if (nil != self.deviceManager.device.userData.sleepMusic.categoryId && nil != musicListVC.selectId) {
            if (![self.deviceManager.device.userData.sleepMusic.categoryId isEqualToString:musicListVC.selectId]) {
                self.deviceManager.device.userData.sleepMusic.categoryId = musicListVC.selectId;
                NSString *title = [AudioCategory getTitleFromCategoryList:selectSubCategoryList withRootCategoryID:subCategoryId withSubCategoryId:musicListVC.selectId];
                [_lableAlbum setText:title];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.deviceManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            subCategoryListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SubCategoryListViewController"];
            subCategoryListVC.selectId = subCategoryId;
            subCategoryListVC.source = musicCategory;
            [self.navigationController pushViewController:subCategoryListVC animated:YES];
        } else if (1 == indexPath.row) {
            musicListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MusicListViewController"];
            musicListVC.selectId = self.deviceManager.device.userData.sleepMusic.categoryId;
            musicListVC.source = selectSubCategoryList;
            [self.navigationController pushViewController:musicListVC animated:YES];
        } else if (2 == indexPath.row) {
            playTimeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayTimeViewController"];
            playTimeVC.sleepMusic = self.deviceManager.device.userData.sleepMusic;
            [self.navigationController pushViewController:playTimeVC animated:YES];
        }
    }
}

- (IBAction)enableSleepMusicChange:(UISwitch *)sender {
    
    self.deviceManager.device.userData.sleepMusic.isValid = sender.isOn;
}

#pragma Mark:update UI

- (void)setPlayTime:(NSString *)text {

    [_lableTime setText:text];
}

- (void)setSubMusicCategoryTitle:(NSString *)title {
    
    [_lableType setText:title];
}

- (void)setMusicTitle:(NSString *)title {

    [_lableAlbum setText:title];
}

- (void)getMusicCategory {
    
    NSLog(@"%s", __func__);
    
    NSString *timeTitle = [self.deviceManager.device.userData.sleepMusic getMinuteLableAccrodingToSecond:self.deviceManager.device.userData.sleepMusic.playTime];
    
    [self performSelectorOnMainThread:@selector(setPlayTime:) withObject:timeTitle waitUntilDone:NO];
    
    if (nil != self.deviceManager.device.userData.sleepMusic.categoryId && self.deviceManager.device.userData.sleepMusic.categoryId.length >= 3) {
        musicCategoryId = [self.deviceManager.device.userData.sleepMusic.categoryId substringWithRange:NSMakeRange(0, 3)];
        
        if (self.deviceManager.device.userData.sleepMusic.categoryId.length >= 6) {
            subCategoryId = [self.deviceManager.device.userData.sleepMusic.categoryId substringWithRange:NSMakeRange(0, 6)];
            
            if (self.deviceManager.device.userData.sleepMusic.categoryId.length >= 9) {
                musicId = [self.deviceManager.device.userData.sleepMusic.categoryId substringWithRange:NSMakeRange(0, 9)];
            }
        }
    }
    
    // 同步请求目录
    dispatch_async(dispatch_get_main_queue(), ^{

        [_switchEnableSleepMusic setOn:self.deviceManager.device.userData.sleepMusic.isValid animated:YES];
    });

    [self.deviceManager.serverService requestSubCategorysWithCateogryId:musicCategoryId requestMode:YYTXHttpRequestPostAndSync requestFinish:^(NSMutableArray *array, YYTXHttpRequestReturnCode code) {

        /* 获取音乐类002的子类成功 */
        if (YYTXHttpRequestSuccessful == code) {

            musicCategory = array;
            /*
             * 遍历音乐类下的每个字目录，获取包含子类的音乐子类，并且根据选中的音乐子类和音乐更新UI
             */
            for (CategoryClass *category in musicCategory) {
                
                /*
                 * 不再重复获取音乐类002的子类
                 */
                NSLog(@"%s %@ %@", __func__, category.categoryId, musicCategoryId);
                if (![category.categoryId isEqualToString:musicCategoryId]) {
                    
                    /*
                     * 如果该类包含子类
                     */
                    NSLog(@"%s %d %@", __func__, category.hassub, subCategoryId);
                    if (category.hassub) {
                        
                        /*
                         * 同步请求包含子目录的音乐子类
                         */
                        [self.deviceManager.serverService requestSubCategorysWithCateogryId:category.categoryId requestMode:YYTXHttpRequestPostAndSync requestFinish:^(NSMutableArray *array, YYTXHttpRequestReturnCode code) {
                            
                            // 请求子类成功
                            if (YYTXHttpRequestSuccessful == code) {
                                
                                // 将其添加到包含子类的音乐子类列表
                                [subCategoryListArray addObject:array];
                                
                                // 如果该子类为当前选中的音乐子类
                                if ([category.categoryId isEqualToString:subCategoryId]) {
                                    
                                    // 获取选中的音乐名
                                    NSString *title = [AudioCategory getTitleFromCategoryList:array withRootCategoryID:subCategoryId withSubCategoryId:musicId];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        // 显示选中的音乐子类名
                                        [self setSubMusicCategoryTitle:category.title];
                                        
                                        // 显示选中的音乐名
                                        [self setMusicTitle:title];
                                    });
                                    
                                    // 选中的音乐子类的音乐列表
                                    selectSubCategoryList = array;
                                }
                            } else if (YYTXHttpRequestTimeout == code) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [self showTitle:NSLocalizedStringFromTable(@"getMusicListFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"networkTimeout", @"hint", nil)];

                                    return;
                                });
                            } else if (YYTXHttpRequestUnknownError == code) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [self showTitle:NSLocalizedStringFromTable(@"getMusicListFailed", @"hint", nil) hint:@""];
                                    return;
                                });
                            }
                        }];
                    } else if ([category.categoryId isEqualToString:subCategoryId]) {
                        /*
                         * 如果不包含子类但该类恰好为当前选中的音乐子类
                         */
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self setSubMusicCategoryTitle:category.title];
                            
                            [self setMusicTitle:category.title];
                        });
                        
                        // 构造了一个音乐子类的音乐列表，为其自身
                        selectSubCategoryList = [NSMutableArray arrayWithObject:category];
                    }
                }
            }

            [self.navigationController setToolbarHidden:NO animated:YES];
            [self removeEffectView];
        } else if (YYTXHttpRequestTimeout == code) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showTitle:NSLocalizedStringFromTable(@"getMusicListFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"networkTimeout", @"hint", nil)];
            });
        } else if (YYTXHttpRequestUnknownError == code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showTitle:NSLocalizedStringFromTable(@"getMusicListFailed", @"hint", nil) hint:@""];
            });
        }
    }];
}

#pragma 睡前音乐数据源

- (void)getSleepMusic {

    dispatch_async(dispatch_get_main_queue(), ^{

        [self showActiviting];
    });
    
    [self.deviceManager.device getSleepMusic:^(YYTXDeviceReturnCode code) {
        
        if (YYTXOperationSuccessful == code) {
            // 获取睡前音乐成功则更新UI
            [self performSelectorInBackground:@selector(getMusicCategory) withObject:nil];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{

                if (YYTXTransferFailed == code) {
                    
                    [self showTitle:NSLocalizedStringFromTable(@"getSleepMusicSetFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
                } else if (YYTXDeviceIsAbsent == code) {
                    
                    [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
                } else if (YYTXOperationIsTooFrequent == code) {
                    [self removeEffectView];

                } else {
                    [self showTitle:NSLocalizedStringFromTable(@"getSleepMusicSetFailed", @"hint", nil) hint:@""];
                }
            });
        }
    }];
}

- (void)modifySleepMusic {
    
    NSLog(@"%s", __func__);

    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];

    [self.deviceManager.device modifySleepMusicSuccessful:@{DevicePlayFileWhenOperationSuccessful:devicePromptFileIdModifySuccessful, DevicePlayFileWhenOperationFailed:devicePromptFileIdModifyFailed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (YYTXOperationSuccessful == code) {

                [self.navigationController popViewControllerAnimated:YES];
            } else if (YYTXTransferFailed == code) {
                    
                [self showTitle:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                    
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
//                [Toast showWithText:NSLocalizedStringFromTable(@"operationIsTooFrequenct", @"hint", nil)];
            } else {
                [self removeEffectView];
                [QXToast showMessage:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil)];
            }
        });
    }];
}

@end
