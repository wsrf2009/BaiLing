//
//  AlarmListCellView.h
//  CloudBox
//
//  Created by TTS on 15-4-2.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SWTableViewCell.h"

@interface AlarmTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imageViewType;
@property (nonatomic, retain) IBOutlet UILabel *lableTime;
@property (nonatomic, retain) IBOutlet UILabel *lableTitle;
@property (nonatomic, retain) IBOutlet UILabel *lableDetail;
@property (nonatomic, retain) IBOutlet UIButton *buttonImage;

@end
