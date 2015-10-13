//
//  ConfigViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-13.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "ConfigViewController.h"
#import "AudioPlayViewController.h"
#import "WifiConfigClass.h"

@interface ConfigViewController ()
{
    NSData *prompt;
}

@end

@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"send", @"hint", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(nextStep)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [self setToolbarItems:@[space, nextStep, space] animated:YES];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"configurationConsiderations", @"hint", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nextStep {
    
    if (self.isAnimating) {
        return;
    }
    
    AudioPlayViewController *audioPlayVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioPlayViewController"];
    audioPlayVC.deviceManager = self.deviceManager;
    audioPlayVC.data = _data;
    if (nil != audioPlayVC) {
        [self.navigationController pushViewController:audioPlayVC animated:YES];
    }
}

@end
