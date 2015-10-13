//
//  ContentItemViewCell.h
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentItemViewCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *time;

//@property (nonatomic, retain) NSString *url;
//@property (nonatomic, assign) NSUInteger duration;

@end
