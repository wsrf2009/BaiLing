//
//  LocalMusicTableViewCell.h
//  CloudBox
//
//  Created by TTS on 15/7/21.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSLibraryImport.h"



@interface LocalMusicTableViewCell : UITableViewCell
//@property (nonatomic, retain) IBOutlet UILabel *labelAlbum;
//@property (nonatomic, retain) IBOutlet UIView *viewAlbum;
//@property (nonatomic, retain) IBOutlet UIImageView *imageViewAlbum;
@property (nonatomic, retain) IBOutlet UILabel *title;
//@property (nonatomic, retain) IBOutlet UILabel *artists;
@property (nonatomic, retain) IBOutlet UILabel *time;
//@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityInd;

//@property (nonatomic, retain) IBOutlet UIButton *buttonExport;
@property (nonatomic, retain) IBOutlet UILabel *labelAddingFailed;
//@property (nonatomic, assign) NSInteger duration;
//@property (nonatomic, assign) BOOL isSelected;


@end
