//
//  CategoryViewCell.h
//  CloudBox
//
//  Created by TTS on 15-5-12.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *text;
@property (nonatomic, retain) NSString *categoryID;
@property (nonatomic, assign) BOOL hasSub;

@end
