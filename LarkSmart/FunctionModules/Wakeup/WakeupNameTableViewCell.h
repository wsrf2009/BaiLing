//
//  WakeupNameTableViewCell.h
//  CloudBox
//
//  Created by TTS on 15-4-16.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewVersion.h"

@interface WakeupNameTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *buttonChecked;
@property (nonatomic, retain) IBOutlet UILabel *lable_Name;
@property (nonatomic, retain) IBOutlet UIButton *button_SoundTest;
@property (nonatomic, retain) IBOutlet NewVersion *viewRecommend;

@end
