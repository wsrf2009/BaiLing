//
//  UICustomCollectionViewController.m
//  CloudBox
//
//  Created by TTS on 15/9/18.
//  Copyright © 2015年 宇音天下. All rights reserved.
//

#import "UICustomCollectionViewController.h"

@interface UICustomCollectionViewController ()

@end

@implementation UICustomCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isAnimating = YES;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _isAnimating = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isAnimating = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _isAnimating = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
