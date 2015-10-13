//
//  XMLYHelpViewController.m
//  CloudBox
//
//  Created by TTS on 15/8/24.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "XMLYHelpViewController.h"
#import "HimalayaViewController.h"

@interface XMLYHelpViewController () <UIWebViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) UIActivityIndicatorView *activityInd;
@property (nonatomic, retain) NSString *finalUrl;
@property (nonatomic, retain) IBOutlet UIButton *buttonPopHelper;
@property (nonatomic, assign) BOOL isAutoPop;

@end

@implementation XMLYHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.toolbar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"back", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    
    _activityInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-35, 12, 20, 20)];
    [_activityInd setColor:[UIColor grayColor]];
    [self.navigationController.navigationBar addSubview:_activityInd];
    
    _isAutoPop = [BoxDatabase autoPopHimalayaHelper];
    if (_isAutoPop) {
        [_buttonPopHelper setSelected:NO];
    } else {
        [_buttonPopHelper setSelected:YES];
    }
    
    UIBarButtonItem *enterHimalaya = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"enterHimalaya", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(gotoHimalaya)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[space, enterHimalaya, space]];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"himalayaHelp", @"hint", nil)];
    
    _finalUrl = [BoxDatabase getUrlWithName:DT_ITEM_XMLYHELPURL];
    
    [self getWebPage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_activityInd stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getWebPage {
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:_finalUrl]];
    
    NSLog(@"%s url:%@", __func__, _finalUrl);
    
    [_webview loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    NSLog(@"%s", __func__);
    
    [self performSelectorOnMainThread:@selector(setActivityIndState:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"%s", __func__);
    
    [self performSelectorOnMainThread:@selector(setActivityIndState:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"%s", __func__);
    
    [self performSelectorOnMainThread:@selector(setActivityIndState:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
    
    NSString *message = [error localizedDescription];
    NSString *buttonOkTitle = NSLocalizedStringFromTable(@"ok", @"hint", nil);
    
    if ([SystemToolClass systemVersionIsNotLessThan:@"8.0"]) {
        
        /* IOS8.0及以后的系统 */
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:buttonOkTitle style:UIAlertActionStyleDefault handler:nil]];
        if (nil != alertController) {
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        /* IOS8.0以前的系统 */
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:buttonOkTitle, nil];
        [alertView show];
    }
    
}

- (void)backButtonClick {
    
    NSLog(@"%s", __func__);
    
    if ([_webview canGoBack]) {
        [_webview goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setActivityIndState:(NSNumber *)state {
    
    if ([state boolValue]) {
        [_activityInd startAnimating];
    } else {
        [_activityInd stopAnimating];
    }
}

- (IBAction)buttonPopHelperClick:(UIButton *)button {
    
    NSLog(@"%s _isAutoPop:%d", __func__, _isAutoPop);

    if (_isAutoPop) {
        [_buttonPopHelper setSelected:YES];
        _isAutoPop = NO;
    } else {
        [_buttonPopHelper setSelected:NO];
        _isAutoPop = YES;
    }
    
    [BoxDatabase changeHimalayaPopHelperState:_isAutoPop];
}

- (void)gotoHimalaya {
    // 喜马拉雅
    HimalayaViewController *himalayaVC = [[UIStoryboard storyboardWithName:@"Himalaya" bundle:nil] instantiateViewControllerWithIdentifier:@"HimalayaViewController"];
    himalayaVC.deviceManager = _deviceManager;
    himalayaVC.toolBarPlayer = _toolBarPlayer;
    if (nil != himalayaVC) {
        [self.navigationController pushViewController:himalayaVC animated:YES];
    }
}
@end
