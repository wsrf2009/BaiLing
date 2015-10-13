//
//  ProvinceListViewController.h
//  CloudBox
//
//  Created by TTS on 15/8/19.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "UICustomTableViewController.h"

@interface ProvinceListViewController : UICustomTableViewController
@property (nonatomic, retain) NSString *selectedProvince;
@property (nonatomic, retain) NSMutableArray *selectedCitys;

@end
