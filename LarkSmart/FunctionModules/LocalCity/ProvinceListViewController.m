//
//  ProvinceListViewController.m
//  CloudBox
//
//  Created by TTS on 15/8/19.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ProvinceListViewController.h"
#import "CityTableViewCell.h"
#import "ChinaCityClass.h"
#import "pinyin.h"
#import "SystemToolClass.h"

@interface ProvinceListViewController ()

@property (nonatomic, retain) NSIndexPath *selectedPath;

@property (nonatomic, retain) NSMutableArray *provinces;
@property (nonatomic, retain) NSMutableArray *groupedProvinces;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBarProvince;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL showSearchResults;

@end

@implementation ProvinceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_searchBarProvince setHidden:YES];
    
    /* 获取所有省的列表 */
    _provinces = [NSMutableArray array];
    for (NSDictionary *province in [ChinaCityClass cityArray]) {
        [province enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            [_provinces addObject:key]; // 每一个城市列表的key就是所在省市的名称
        }];
    }
    NSLog(@"%s _pro:%@", __func__, [_provinces componentsJoinedByString:@","]);
    
    /* 给每个省加上拼音 */
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *province in _provinces) {
        [mutableArray addObject:@{province:[[HTFirstLetter pinYin:province] uppercaseString]}];
    }
    
    /* 按照拼音对省进行排序 */
    NSArray *orderedProvinces = [mutableArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dic1 = obj1;
        NSDictionary *dic2 = obj2;
        NSString *pinYin1 = [dic1.allValues objectAtIndex:0];
        NSString *pinYin2 = [dic2.allValues objectAtIndex:0];
        
        return [pinYin1 localizedCompare:pinYin2];
        
    }];
    NSLog(@"%s _ord:%@", __func__, [orderedProvinces componentsJoinedByString:@","]);
    
    _groupedProvinces = [NSMutableArray array];
    
    /* 对排列好的省市列表按照首字母进行分组 */
    NSString *groupTitle;
    NSMutableArray *arr;
    for (NSDictionary *province in orderedProvinces) {
//        NSString *firstLetter = [HTFirstLetter firstLetter:province].uppercaseString;
        NSString *firstLetter = [[province.allValues objectAtIndex:0] substringToIndex:1];
        
        NSLog(@"%s g:%@, f:%@", __func__, groupTitle, firstLetter);
        
        if (nil == groupTitle) {
            groupTitle = firstLetter;
            arr = [NSMutableArray array];
            [_groupedProvinces addObject:arr];
            [arr addObject:groupTitle]; // 每一组的第一个元素就是首字母
            [arr addObject:province.allKeys[0]];
        } else {
            if ([groupTitle isEqualToString:firstLetter]) {
                [arr addObject:province.allKeys[0]];
            } else {
                groupTitle = firstLetter;
                arr = [NSMutableArray array];
                [_groupedProvinces addObject:arr];
                [arr addObject:groupTitle]; // 每一组的第一个元素就是首字母
                [arr addObject:province.allKeys[0]];
            }
        }
    }
    
    NSLog(@"%s %@", __func__, [_groupedProvinces componentsJoinedByString:@","]);
    
    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_showSearchResults) {
        return 1;
    } else {
        return _groupedProvinces.count; // 省市的组个数
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_showSearchResults) {
        return _searchResults.count;
    } else {
        /* 每组中省市的个数 */
        NSArray *arr = [_groupedProvinces objectAtIndex:section];
        return arr.count-1;
    }
}
#if 1
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 25.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *header = [[UIView alloc] init];
    [header setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:0.8f]];
    UILabel *label = [[UILabel alloc] init];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:15]];
    NSArray *group = [_groupedProvinces objectAtIndex:section];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setText:[group objectAtIndex:0]];

    [header addSubview:label];
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[label]-(>=15)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=5)-[label]-3-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    
    return header;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *arr = [NSMutableArray array];
    
    if (_showSearchResults) {
        return nil;
    } else {
        for (NSArray *group in _groupedProvinces) {
            [arr addObject:[group objectAtIndex:0]]; // 获取每个组的首字母
        }
    
        return arr;
    }
}
#endif
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityTableViewCell"];
    
    if (_showSearchResults) {
        cell.labelTitle.text = [_searchResults objectAtIndex:indexPath.row];
    } else {
        NSArray *group = [_groupedProvinces objectAtIndex:indexPath.section];
        cell.labelTitle.text = [group objectAtIndex:indexPath.row+1]; // 找到对应的省市的名字
    }
    
    /* 是否为已选中的省市 */
    NSRange range = [_selectedProvince rangeOfString:cell.labelTitle.text];
    if (range.length > 0) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        _selectedPath = indexPath;
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (nil != _selectedPath) {
        /* 取消之前已选中的 */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedPath];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    CityTableViewCell *cell = (CityTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    /* 设置当前已选中的 */
    _selectedProvince = cell.labelTitle.text;
    _selectedCitys = [NSMutableArray arrayWithArray:[ChinaCityClass getCitysWithProvince:_selectedProvince]];
    
    [self.navigationController popViewControllerAnimated:YES];
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
        
        for (NSMutableArray *arr in _groupedProvinces) {
            NSRange range = [searchText.uppercaseString rangeOfString:[arr objectAtIndex:0]];
            if (range.length > 0) {
                _searchResults = [NSMutableArray arrayWithArray:arr];
                [_searchResults removeObjectAtIndex:0];
                _showSearchResults = YES;
                break;
            }
        }
        
        if (!_showSearchResults) {
            
            for (NSString *province in _provinces) {
                NSRange range = [province rangeOfString:searchText];
                if (range.length > 0) {
                    [_searchResults addObject:province];
                    _showSearchResults = YES;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            _showSearchResults = YES;
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

@end
