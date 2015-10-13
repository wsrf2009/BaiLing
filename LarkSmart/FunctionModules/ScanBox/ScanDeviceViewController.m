//
//  ScanBoxViewController.m
//  CloudBox
//
//  Created by TTS on 15-3-17.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ScanDeviceViewController.h"
#import "DeviceManagerViewController.h"
#import "ScanDeviceResultViewCell.h"
#import "DeviceConfigNavigationController.h"
#import "DeviceManagerViewController.h"
#import "ScanAddDeviceViewController.h"
#import "YYTXCustomNavigationController.h"

#define SCAN_PERIOD     1.0
#define SCAN_TIME       10

#define kDegreesToRadian(x) (M_PI * (x) / 180.0 )
#define kRadianToDegrees(radian) (radian* 180.0 )/(M_PI)

@interface ScanDeviceViewController () <UITableViewDelegate, UITableViewDataSource>
{
    int time;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView_ScanResult;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *decCounter;
@property (nonatomic, retain) NSTimer *timer_Scan;
@property (nonatomic, retain) DeviceManagerViewController *deviceManagerVC;
@property (nonatomic, retain) IBOutlet UIButton *buttonStopScan;

@end

@implementation ScanDeviceViewController

- (void)viewDidLoad {
    
    NSLog(@"%s", __func__);
    
    [super viewDidLoad];
    
    _deviceManager.delegate = self;
    _tableView_ScanResult.delegate = self;
    _tableView_ScanResult.dataSource = self;
    
    [self hideEmptySeparators:_tableView_ScanResult];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_deviceManager checkNetWorkStatus];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s", __func__);
    
    _image.layer.masksToBounds = YES;
    NSMutableArray *animateArray = [[NSMutableArray alloc] initWithCapacity:24];
    [animateArray addObject:[UIImage imageNamed:@"scaning_01.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_02.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_03.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_04.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_05.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_06.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_07.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_08.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_09.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_10.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_11.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_12.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_13.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_14.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_15.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_16.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_17.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_18.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_19.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_20.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_21.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_22.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_23.png"]];
    [animateArray addObject:[UIImage imageNamed:@"scaning_24.png"]];
    _image.animationImages = animateArray;
    _image.animationDuration = SCAN_PERIOD;

    // 初始化倒数计时显示
    time = SCAN_TIME;
    _decCounter.text = [NSString stringWithFormat:@"%d", time];
    // 启动定时器
    _timer_Scan = [NSTimer scheduledTimerWithTimeInterval:SCAN_PERIOD target:self selector:@selector(scanTimerExpired) userInfo:nil repeats:YES];
    [self startAnimation];
    [_deviceManager searchDeviceInHighFreq];
    [_timer_Scan fire];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)startAnimation {

    [_image startAnimating];
}

- (void) scanTimerExpired {
    
    _decCounter.text = [NSString stringWithFormat:@"%d", time];
    
    if (time <= 0) {
        // 时间到，停止扫描
        [self buttonClick_StopScan:nil];
    }
    
    time--;
}

- (void)viewSwitch {
    if ([_deviceManager deviceCount] > 0) {
        YYTXCustomNavigationController *deviceListNC = [[UIStoryboard storyboardWithName:@"DeviceList" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceListNavigationController"];
        DeviceManagerViewController *deviceManagerVC = [[deviceListNC viewControllers] firstObject];
        deviceManagerVC.deviceManager = _deviceManager;
        if (nil != deviceListNC) {
            [self presentViewController:deviceListNC animated:YES completion:nil];
        }
    } else {
        DeviceConfigNavigationController *deviceConfigNC = [[UIStoryboard storyboardWithName:@"DeviceConfig" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceConfigNavigationController"];
        ScanAddDeviceViewController *scanAddDeviceVC = [[deviceConfigNC viewControllers] firstObject];
        scanAddDeviceVC.deviceManager = _deviceManager;
        if (nil != deviceConfigNC) {
            [self presentViewController:deviceConfigNC animated:YES completion:nil];
        }
    }
}

- (IBAction)buttonClick_StopScan:(id)sender {
    
    NSLog(@"%s", __func__);

    [_timer_Scan invalidate];
    time = -1;
    [_deviceManager pauseSearchDevice];
    
    [self viewSwitch];
}

#pragma mark - Table view data source

- (void)hideEmptySeparators:(UITableView *)tableView {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:v];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [_deviceManager deviceCount];
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 30.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%s", __func__);
    
    NSInteger row = indexPath.row;
    ScanDeviceResultViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScanResultCellView" forIndexPath:indexPath];
    
    DeviceDataClass *device = [_deviceManager deviceAtIndex:row];
    [cell.lable_Name setText:device.userData.generalData.nickName];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)deviceListUpdate {
    
    NSLog(@"%s", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_tableView_ScanResult reloadData];
    });
}

@end
