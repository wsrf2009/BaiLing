//
//  LocalCitySetViewController.m
//  CloudBox
//
//  Created by TTS on 15-5-13.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "LocalCityViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ChinaCityViewController.h"
//#import "M2DHudView.h"
#import "Toast.h"
#import "CityListViewController.h"
#import "ProvinceListViewController.h"
#import "ChinaCityClass.h"

#define LeadingSpaceToSuperView         15.0f
#define TrailingSpaceToSuperView         15.0f
#define TopSpaceToSuperView         5.0f
#define BottomSpaceToSuperView      10.0f

@interface LocalCityViewController () <CLLocationManagerDelegate, YYTXDeviceManagerDelegate>
{
//    ChinaCityViewController *chinaCityVC;
}

//@property (nonatomic, retain) IBOutlet UIPickerView *pickerViewChinaCity;
@property (nonatomic, retain) IBOutlet UILabel *labelProvinceTitle;
@property (nonatomic, retain) IBOutlet UILabel *labelCityTitle;
@property (nonatomic, retain) IBOutlet UILabel *currentProvince;
@property (nonatomic, retain) IBOutlet UILabel *currentCity;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) UIFont *fontForHint;

@property (nonatomic, retain) CityListViewController *cityListVC;
@property (nonatomic, retain) ProvinceListViewController *provinceListVC;

@property (nonatomic, retain) NSMutableArray *selectedCitys;
@property (nonatomic, retain) IBOutlet UILabel *labelLocalCityHint;
@property (nonatomic, assign) BOOL displayProvinceCity;

@end

@implementation LocalCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    self.deviceManager.delegate = self;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"hint", nil) style:UIBarButtonItemStyleDone target:self action:@selector(modifyLocalCitySet)];
    self.toolbarItems = @[space, save, space];

    [self getLocalCitySet];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"localCitySet", @"hint", nil)];
    
    _fontForHint = [UIFont systemFontOfSize:15.0f];
    
    NSString *hint = NSLocalizedStringFromTable(@"localCityHint", @"hint", nil);
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
    [_labelLocalCityHint setAttributedText:attrString];
    
    [self hideEmptySeparators:self.tableView];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.tableView.frame.size.width, 0, 0)];
    
    _displayProvinceCity = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];

    if (nil != _cityListVC) {
        _currentCity.text = _cityListVC.selectedCity;
    }
    
    if (nil != _provinceListVC) {
        
        NSRange range = [_currentProvince.text rangeOfString:_provinceListVC.selectedProvince];
        if (range.length <= 0) {
            
            _currentProvince.text = _provinceListVC.selectedProvince;
            _selectedCitys = _provinceListVC.selectedCitys;
            _currentCity.text = _selectedCitys[0];
            
            if (nil == _cityListVC) {
                _cityListVC = [[UIStoryboard storyboardWithName:@"LocalCity" bundle:nil] instantiateViewControllerWithIdentifier:@"CityListViewController"];
            }
            _cityListVC.selectedCitys = _selectedCitys;
            _cityListVC.selectedCity = _selectedCitys[0];

            NSLog(@"%s %@", __func__, [_selectedCitys componentsJoinedByString:@","]);
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

- (void)manualSetEnable:(BOOL)yesOrNo {

    if (yesOrNo && !_displayProvinceCity) {
        _displayProvinceCity = YES;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (!yesOrNo && _displayProvinceCity){
        _displayProvinceCity = NO;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

- (void)updateUI {

    if (USERSET_AUTOMATICPOSITIONING == self.deviceManager.device.userData.generalData.userSet) {
            [self setCellCheckMark:0 section:0];
            [self setCellUncheckMark:1 section:0];
        [self manualSetEnable:NO];
    } else if (USERSET_MANUALSET == self.deviceManager.device.userData.generalData.userSet) {
        [self setCellCheckMark:1 section:0];
        [self setCellUncheckMark:0 section:0];
        [self manualSetEnable:YES];
    }
    
    [_currentProvince setText:self.deviceManager.device.userData.generalData.province];
    [_currentCity setText:self.deviceManager.device.userData.generalData.city];
}

- (void)selectedProvince:(NSString *)province selectedCity:(NSString *)city {

    self.deviceManager.device.userData.generalData.province = province;
    self.deviceManager.device.userData.generalData.city = city;
}

#pragma mark - Table view data source

- (void)setCellCheckMark:(NSUInteger)row section:(NSUInteger)section {
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void)setCellUncheckMark:(NSUInteger)row section:(NSUInteger)section {
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]] setAccessoryType:UITableViewCellAccessoryNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (0 == section) {
        return 2;
    } else if (1 == section) {
        if (_displayProvinceCity) {
            return 2;
        } else {
            return 0;
        }
    } else if (2 == section) {
        return 1;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
            
            self.deviceManager.device.userData.generalData.userSet = USERSET_AUTOMATICPOSITIONING;
        } else if (1 == indexPath.row) {
            self.deviceManager.device.userData.generalData.userSet = USERSET_MANUALSET;
        }
        
        [self updateUI];
    } else if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            if (nil == _provinceListVC) {
                _provinceListVC = [[UIStoryboard storyboardWithName:@"LocalCity" bundle:nil] instantiateViewControllerWithIdentifier:@"ProvinceListViewController"];
            }
            _provinceListVC.selectedProvince = _currentProvince.text;
            if (nil != _provinceListVC) {
                [self.navigationController pushViewController:_provinceListVC animated:YES];
            }
            
        } else if (1 == indexPath.row) {
            if (nil == _cityListVC) {
                _cityListVC = [[UIStoryboard storyboardWithName:@"LocalCity" bundle:nil] instantiateViewControllerWithIdentifier:@"CityListViewController"];
            }
            
            if (nil == _selectedCitys) {
                _selectedCitys = [NSMutableArray arrayWithArray:[ChinaCityClass getCitysWithProvince:_currentProvince.text]];
                _cityListVC.selectedCitys = _selectedCitys;
            }
            
//            _cityListVC.selectedCitys = _selectedCitys;
            _cityListVC.selectedCity = _currentCity.text;
            if (nil != _cityListVC) {
                [self.navigationController pushViewController:_cityListVC animated:YES];
            }
            
        }
    }
}

#pragma 本地城市数据源

- (void)getLocalCitySet {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showActiviting];
    });
    
    [self.deviceManager.device getGeneral:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (YYTXOperationSuccessful == code) {

                [self removeEffectView];
                [self updateUI];
            } else if (YYTXTransferFailed == code) {
                    
                [self showTitle:NSLocalizedStringFromTable(@"getLocalCitySetFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                    
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
            } else {
                [self showTitle:NSLocalizedStringFromTable(@"getLocalCitySetFailed", @"hint", nil) hint:@""];
            }
        });
    }];
}

- (void)modifyLocalCitySet {
    
    self.deviceManager.device.userData.generalData.province = _currentProvince.text;
    self.deviceManager.device.userData.generalData.city = _currentCity.text;

    [self showBusying:NSLocalizedStringFromTable(@"saving", @"hint", nil)];
    
    [self.deviceManager.device modifyGeneral:@{DevicePlayFileWhenOperationSuccessful:devicePromptFileIdModifySuccessful, DevicePlayFileWhenOperationFailed:devicePromptFileIdModifyFailed} completionBlock:^(YYTXDeviceReturnCode code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (YYTXOperationSuccessful == code) {
                
                [self.navigationController popViewControllerAnimated:YES];
            } else if (YYTXTransferFailed == code) {
                    
                [self showTitle:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil) hint:NSLocalizedStringFromTable(@"hintForTransferFailed", @"hint", nil)];
            } else if (YYTXDeviceIsAbsent == code) {
                    
                [self showTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"iphoneDisconnectedTo %@", @"hint", nil), self.deviceManager.device.userData.generalData.nickName] hint:NSLocalizedStringFromTable(@"hintForDeviceDisconnect", @"hint", nil)];
            } else if (YYTXOperationIsTooFrequent == code) {
                [self removeEffectView];
            } else {
                
                [self removeEffectView];
                [Toast showWithText:NSLocalizedStringFromTable(@"savingFailed", @"hint", nil)];
            }
        });
    }];
}

#if 0
#pragma Mark: automatic positioning

- (void)positioning {
    
    NSLog(@"%s", __func__);
    
    if (![CLLocationManager locationServicesEnabled]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"定位服务当前可能尚未打开，请设置打开！" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        if (nil != alertController) {
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        
        return;
    }
    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        
        [_locationManager requestWhenInUseAuthorization];

    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {

        _locationManager.delegate=self; //设置代理
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest; //设置定位精度
        _locationManager.distanceFilter = 10.0; // 定位频率, 十米定位一次
        [_locationManager startUpdatingLocation]; //启动跟踪定位
        
        [self performSelectorOnMainThread:@selector(activityIndicatorStartAnimating) withObject:nil waitUntilDone:NO];
    }
}

// 错误信息
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"%s ", __func__);
    
    [manager stopUpdatingLocation];
    
    [self performSelectorOnMainThread:@selector(activityIndicatorStopAnimating) withObject:nil waitUntilDone:NO];
}

// 6.0 以上调用这个函数
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"%s", __func__);

//    [manager stopUpdatingLocation];
//    [_activityIndicator stopAnimating];
    
    CLLocation *newLocation = locations[0];
    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
    NSLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);
    
    //------------------位置反编码---5.0之后使用-----------------
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error){
        
        for (CLPlacemark *place in placemarks) {
            
            NSLog(@"name, %@", place.name); // 位置名
            
            if (nil != place.administrativeArea && nil != place.locality) {
                [manager stopUpdatingLocation];
                [self performSelectorOnMainThread:@selector(activityIndicatorStopAnimating) withObject:nil waitUntilDone:NO];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"定位成功" message:@"请选择您所在的市/县/区" preferredStyle:UIAlertControllerStyleAlert];
                
                if (nil != place.subAdministrativeArea) {
                    [alertController addAction:[UIAlertAction actionWithTitle:place.subAdministrativeArea style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [_city setText:[NSString stringWithFormat:@"%@·%@", place.administrativeArea, place.subAdministrativeArea]];
                    }]];
                }
                
                if (nil != place.locality) {
                    [alertController addAction:[UIAlertAction actionWithTitle:place.locality style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [_city setText:[NSString stringWithFormat:@"%@·%@", place.administrativeArea, place.locality]];
                    }]];
                }
                
                if (nil != place.subLocality) {
                    [alertController addAction:[UIAlertAction actionWithTitle:place.subLocality style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [_city setText:[NSString stringWithFormat:@"%@·%@·%@", place.administrativeArea, place.locality, place.subLocality]];
                    }]];
                }
                
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                
                if (nil != alertController) {
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                
            }
        }
                       
    }];
    
}

// 6.0 调用此函数
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"%s", __func__);
    
    [manager stopUpdatingLocation];
    
    [self performSelectorOnMainThread:@selector(activityIndicatorStopAnimating) withObject:nil waitUntilDone:NO];
}
#endif
@end
