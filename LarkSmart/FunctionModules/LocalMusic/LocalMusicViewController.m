//
//  LocalMusicViewController.m
//  CloudBox
//
//  Created by TTS on 15/7/21.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "LocalMusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LocalMusicTableViewCell.h"
#import "SolidCircle.h"
#import "UICustomAlertView.h"
#import "MJRefresh.h"

@interface LocalMusicViewController () <ToolBarPlayerDelegate, UISearchBarDelegate, YYTXMediaExportDelegate>
{
    UIColor *HightLightColor;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBarSong;

@property (nonatomic, retain) NSIndexPath *selectedPath;
@property (nonatomic, retain) NSString *selectedProgramTitle;

@property (nonatomic, retain) NSArray *listControlItemsArray;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL showSearchResults;

@property (nonatomic, retain) UIBarButtonItem *itemRefresh;
@property (nonatomic, retain) NSMutableArray *mediaList;
@property (nonatomic, retain) LocalMusicTask *mediaTask;

//@property (nonatomic, retain) MJRefreshAutoNormalFooter *footer;

@end

@implementation LocalMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_searchBarSong setHidden:YES];

    self.toolbarItems = [_toolBarPlayer toolItems];

    [self hideEmptySeparators:self.tableView];
    
    _itemRefresh = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"refresh", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(refreshSongsList)];
    self.navigationItem.rightBarButtonItem = _itemRefresh;

    _showSearchResults = NO;
    _searchResults = [[NSMutableArray alloc] init];
    
    _selectedPath = nil;
    
    HightLightColor = [UIColor colorWithRed:58.0f/255.0f green:171.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
    
    _mediaTask = self.deviceManager.mediaTask;
    _mediaTask.delegate = self;
    _mediaList = self.deviceManager.mediaTask.musicItems;
    
    if (_mediaList.count <= 0) {
        [self refreshSongsList];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshSongsList {
    
    NSLog(@"%s +++++++++++++++++++++++++++++++++++", __func__);
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [self removeEffectView];
    
    [_itemRefresh setEnabled:NO];
    [self showBusying:NSLocalizedStringFromTable(@"pleaseWaiting", @"hint", nil)];
    
    [_mediaTask clearMediaList];
    [self.tableView reloadData];
    
    [_mediaTask regainMedias];
    [self.tableView reloadData];
    
    [_itemRefresh setEnabled:YES];
    [self removeEffectView];
    
    NSInteger count = 0;
    for (NSArray *sArr in _mediaList) {
        count += sArr.count-1;
    }
    
    if (count <= 0) {
        
        [self showTitle:NSLocalizedStringFromTable(@"noSongFound", @"hint", nil) hint:nil];
    }
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    NSLog(@"%s -----------------------------------", __func__);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (_showSearchResults) {
        return 1;
    } else {

        NSInteger count = 0;
        for (NSArray *sArr in _mediaList) {
            count += sArr.count-1;
        }
        [self.navigationItem setTitle:[NSString stringWithFormat: NSLocalizedStringFromTable(@"localMusic%d", @"hint", nil), count]];
        
        return _mediaList.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_showSearchResults) {
        return _searchResults.count;
    } else {

        NSArray *sArr = [_mediaList objectAtIndex:section];
    
        return sArr.count-1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 25.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] init];
    [header setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:0.8f]];
    UILabel *label = [[UILabel alloc] init];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:15]];
    NSArray *group = [_mediaList objectAtIndex:section];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setText:[group objectAtIndex:0]];
    
    [header addSubview:label];
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[label]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=5)-[label]-3-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    
    return header;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_showSearchResults) {
        return nil;
    } else {
        NSMutableArray *arr = [NSMutableArray array];
        
        for (NSArray *group in _mediaList) {
            [arr addObject:[group objectAtIndex:0]];
        }
        
        return arr;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocalMusicTableViewCell *cell = (LocalMusicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LocalMusicTableViewCell"];

    YYTXMediaItem *item;
    if (_showSearchResults) {
        item = [_searchResults objectAtIndex:indexPath.row];
    } else {
        NSArray *arr = [_mediaList objectAtIndex:indexPath.section];
        item = [arr objectAtIndex:indexPath.row+1];
    }
    
    [cell.title setText:item.audio.title];
    cell.time.text = [NSString stringWithFormat:@"%02d:%02d", item.audio.duration/60, item.audio.duration%60];

    if ((YYTXMediaExportingStateUnknown == item.state) || (YYTXMediaExportingStateWaiting == item.state)) {
                
        cell.userInteractionEnabled = NO;
        [cell.labelAddingFailed setHidden:YES];
        [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    } else if (YYTXMediaExportingStateExporting == item.state) {
        
        cell.userInteractionEnabled = NO;
        [cell.labelAddingFailed setHidden:YES];
        [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity startAnimating];
        [cell setAccessoryView:activity];
        
    } else if (YYTXMediaExportingStateCompleted == item.state) {

        cell.userInteractionEnabled = YES;
        [cell.labelAddingFailed setHidden:YES];
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];

    } else if (YYTXMediaExportingStateFailed == item.state || YYTXMediaExportingStateCancelled == item.state) {

        cell.userInteractionEnabled = YES;
        [cell.labelAddingFailed setHidden:NO];
        [cell.labelAddingFailed setText:NSLocalizedStringFromTable(@"addingFailed", @"hint", nil)];
        [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    if ([_selectedProgramTitle isEqualToString:item.audio.title]) {
        [cell.title setTextColor:HightLightColor];
        [cell.time setTextColor:HightLightColor];
    } else {
        [cell.title setTextColor:[UIColor blackColor]];
        [cell.time setTextColor:[UIColor grayColor]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showBusying:NSLocalizedStringFromTable(@"pleaseWaiting", @"hint", nil)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self removeEffectView];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });

    YYTXMediaItem *item;
    if (_showSearchResults) {
        item = [_searchResults objectAtIndex:indexPath.row];
    } else {
        NSArray *arr = [_mediaList objectAtIndex:indexPath.section];
        item = [arr objectAtIndex:indexPath.row+1];
    }
    
    NSLog(@"%s item:%@", __func__, item);

    if (YYTXMediaExportingStateFailed == item.state || YYTXMediaExportingStateCancelled == item.state) {

        [self deleteSongItem:item indexPath:indexPath];
        
        return;
    }

    [_toolBarPlayer.playList removeAllObjects];
    if (_showSearchResults) {
        for (YYTXMediaItem *item in _searchResults) {
            [_toolBarPlayer.playList addObject:item.audio];
        }
    } else {

        for (NSInteger i=0; i<_mediaList.count; i++) {
            NSArray *arr = [_mediaList objectAtIndex:i];
            for (NSInteger j=0; j<arr.count; j++) {
                id obj = arr[j];
                if ([obj isKindOfClass:[YYTXMediaItem class]]) {
                    YYTXMediaItem *item = obj;
                    [_toolBarPlayer.playList addObject:item.audio];
                }
            }
        }
    }
    _toolBarPlayer.delegate = self;

    NSInteger index = 0;
    for (NSInteger i=0; i<indexPath.section; i++) {
        NSArray *arr = _mediaList[i];
        index += arr.count-1;
    }
    index += indexPath.row;
    [_toolBarPlayer playAudioAtIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NSLocalizedStringFromTable(@"delete", @"hint", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *arr = [_mediaList objectAtIndex:indexPath.section];
        YYTXMediaItem *item = [arr objectAtIndex:indexPath.row+1];
        
        NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"areYouSureYouWantToDeleteThisSong", @"hint", nil), item.audio.title];
        NSString *buttonCancelTitle = NSLocalizedStringFromTable(@"cancel", @"hint", nil);
        NSString *buttonDeleteTitle = NSLocalizedStringFromTable(@"delete", @"hint", nil);
                             
        if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SystemToolClass appName] message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:buttonCancelTitle style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:buttonDeleteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                
                [self deleteSongItem:item indexPath:indexPath];
            }]];
            
            if (nil != alertController) {
                [self presentViewController:alertController animated:YES completion:nil];
            }
        } else {
            UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:[SystemToolClass appName] message:message delegate:self cancelButtonTitle:buttonCancelTitle otherButtonTitles:buttonDeleteTitle, nil];
            [alertView showAlertViewWithCompleteBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
                if ([buttonTitle isEqualToString:buttonDeleteTitle]) {
                    [self deleteSongItem:item indexPath:indexPath];
                }
            }];
        }

    }
}

- (void)deleteSongItem:(YYTXMediaItem *)item indexPath:(NSIndexPath *)indexPath {
    
    [[NSFileManager defaultManager] removeItemAtPath:item.file error:nil]; // 删除最终文件

    for (NSInteger i=0; i<_mediaList.count; i++) {
        NSArray *arr = [_mediaList objectAtIndex:i];
        for (NSInteger j=0; j<arr.count; j++) {
            id obj = arr[j];
            if ([obj isKindOfClass:[YYTXMediaItem class]]) {
                YYTXMediaItem *item1 = obj;
                if ([item1.audio.title isEqualToString:item.audio.title]) {
                    [_mediaList removeObject:item1];
                }
            }
        }
    }
    
    if (_showSearchResults) {
        NSArray *sArr = [NSArray arrayWithArray:_searchResults];
        for (YYTXMediaItem *song in sArr) {
            if ([song.audio.title isEqualToString:item.audio.title]) {
                [_searchResults removeObject:song];
            }
        }
    }
    
    NSArray *pArr = [NSArray arrayWithArray:_toolBarPlayer.playList];
    for (AudioClass *audio in pArr) {
        if ([audio.title isEqualToString:item.audio.title]) {
            [_toolBarPlayer.playList removeObject:audio];
        }
    }
    
    NSMutableArray *arr = [_mediaList objectAtIndex:indexPath.section];
    
    if (arr.count <= 2) {
        [_mediaList removeObject:arr];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]  withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [arr removeObject:item];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)indexOfPlaying:(NSUInteger)index programTitle:(NSString *)title {
    NSInteger section = 0;
    NSInteger row = 0;

    _selectedProgramTitle = title;
    
    if (_showSearchResults) {
        if (_searchResults.count <= 0) {
            return;
        }

        for (row=0; row<_searchResults.count; row++) {
            YYTXMediaItem *item = _searchResults[row];
            if ([title isEqualToString:item.audio.title]) {
                break;
            }
        }
        
        if (row>= _searchResults.count) {
            return;
        }
    } else {

        BOOL isEnd = NO;
        for (section=0; section<_mediaList.count; section++) {
            NSArray *arr = _mediaList[section];
            for (row=1; row<arr.count; row++) {
                YYTXMediaItem *item = arr[row];
                if ([title isEqualToString:item.audio.title]) {
                    isEnd = YES;
                    break;
                }
            }
            
            if (isEnd) {
                break;
            }
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:section];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil != _selectedPath) {
            LocalMusicTableViewCell *cell = (LocalMusicTableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedPath];
            [cell.title setTextColor:[UIColor blackColor]];
            [cell.time setTextColor:[UIColor grayColor]];
        }

        _selectedPath = indexPath;

        LocalMusicTableViewCell *cell = (LocalMusicTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.title setTextColor:HightLightColor];
        [cell.time setTextColor:HightLightColor];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
}

#pragma UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"%s %@", __func__, searchText);

    [_searchResults removeAllObjects];
    if (nil != searchText && ![searchText isEqualToString:@""]) {
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:_mediaList];
        for (YYTXMediaItem *item in arr) {
            if ([item.audio.title rangeOfString:searchText options:NSCaseInsensitiveSearch].length>0) {
                [_searchResults addObject:item];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _showSearchResults = YES;
            [self.tableView reloadData];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _showSearchResults = NO;
            [self.tableView reloadData];
        });
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [searchBar resignFirstResponder];
}

- (void)mediaExportStateChange {

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
    });
}

@end
