//
//  RemindTableViewCell.h
//  CloudBox
//
//  Created by TTS on 15/7/23.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface RemindTableViewCell : SWTableViewCell
@property (nonatomic, retain) IBOutlet UIImageView *imageViewType;
@property (nonatomic, retain) IBOutlet UILabel *labelDate;
@property (nonatomic, retain) IBOutlet UILabel *remind;

@end
