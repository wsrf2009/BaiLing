//
//  YYTXCustomNavigationController.h
//  CloudBox
//
//  Created by TTS on 15/9/28.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYTXNavigationBarDelegate <NSObject>

@required
- (BOOL)shouldPopItem;

@end

@interface YYTXCustomNavigationController : UINavigationController

@end
