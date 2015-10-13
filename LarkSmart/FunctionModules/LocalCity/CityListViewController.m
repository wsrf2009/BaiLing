//
//  CityListViewController.m
//  CloudBox
//
//  Created by TTS on 15/8/19.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "CityListViewController.h"
#import "CityTableViewCell.h"
#import "ChinaCityClass.h"
#import "pinyin.h"
#import "SystemToolClass.h"

@interface CityListViewController () <UISearchBarDelegate>

@property (nonatomic, retain) NSIndexPath *selectedPath;

@property (nonatomic, retain) NSMutableArray *groupedCitys;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBarCity;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL showSearchResults;

@end

@implementation CityListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_searchBarCity setHidden:YES];
    
    [self hideEmptySeparators:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    if (nil != _selectedPath) {
//        [self.tableView scrollToRowAtIndexPath:_selectedPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSelectedCitys:(NSArray *)selectedCitys {
//    _selectedCitys = selectedCitys;
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *city in selectedCitys) {
        [mutableArray addObject:@{city:[[HTFirstLetter pinYin:city] uppercaseString]}];
    }
    
    NSArray *orderedCitys = [mutableArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dic1 = obj1;
        NSDictionary *dic2 = obj2;
        NSString *pinYin1 = [dic1.allValues objectAtIndex:0];
        NSString *pinYin2 = [dic2.allValues objectAtIndex:0];
        
        return [pinYin1 localizedCompare:pinYin2];
    }];
    NSLog(@"%s _ord:%@", __func__, [orderedCitys componentsJoinedByString:@","]);
    
    _groupedCitys = [NSMutableArray array];
    NSString *groupTitle;
    NSMutableArray *arr;
    for (NSDictionary *city in orderedCitys) {
//        NSString *firstLetter = [HTFirstLetter firstLetter:city].uppercaseString;
        NSString *firstLetter = [[city.allValues objectAtIndex:0] substringToIndex:1];
        
        NSLog(@"%s g:%@, f:%@", __func__, groupTitle, firstLetter);
        
        if (nil == groupTitle) {
            groupTitle = firstLetter;
            arr = [NSMutableArray array];
            [_groupedCitys addObject:arr];
            [arr addObject:groupTitle];
            [arr addObject:city.allKeys[0]];
        } else {
            if ([groupTitle isEqualToString:firstLetter]) {
                [arr addObject:city.allKeys[0]];
            } else {
                groupTitle = firstLetter;
                arr = [NSMutableArray array];
                [_groupedCitys addObject:arr];
                [arr addObject:groupTitle];
                [arr addObject:city.allKeys[0]];
            }
        }
    }
    
    for (NSMutableArray *arr in _groupedCitys) {
        NSLog(@"%s %@", __func__, [arr componentsJoinedByString:@","]);
    }
    
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_showSearchResults) {
        return 1;
    } else {
        return _groupedCitys.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_showSearchResults) {
        return _searchResults.count;
    } else {
        NSArray *arr = [_groupedCitys objectAtIndex:section];
    
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
    NSArray *group = [_groupedCitys objectAtIndex:section];
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
    
        for (NSArray *group in _groupedCitys) {
            [arr addObject:[group objectAtIndex:0]];
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
        NSArray *group = [_groupedCitys objectAtIndex:indexPath.section];
        cell.labelTitle.text = [group objectAtIndex:indexPath.row+1];
    }
    
    NSRange range = [_selectedCity rangeOfString:cell.labelTitle.text];
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
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedPath];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    CityTableViewCell *cell = (CityTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    _selectedCity = cell.labelTitle.text;

    
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
        
        for (NSMutableArray *arr in _groupedCitys) {
            NSRange range = [searchText.uppercaseString rangeOfString:[arr objectAtIndex:0]];
            if (range.length > 0) {
                _searchResults = [NSMutableArray arrayWithArray:arr];
                [_searchResults removeObjectAtIndex:0];
                _showSearchResults = YES;
                break;
            }
        }
        
        if (!_showSearchResults) {
            
            for (NSString *province in _selectedCitys) {
                NSRange range = [province rangeOfString:searchText];
                if (range.length > 0) {
                    [_searchResults addObject:province];
                    _showSearchResults = YES;
                }
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

@end
