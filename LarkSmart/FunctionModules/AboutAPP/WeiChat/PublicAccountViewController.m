//
//  PublicAccountViewController.m
//  CloudBox
//
//  Created by TTS on 15/8/24.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "PublicAccountViewController.h"

@interface PublicAccountViewController () <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) UIActivityIndicatorView *activityInd;
@property (nonatomic, retain) NSString *finalUrl;

@end

@implementation PublicAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _webview.scalesPageToFit =YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"back", @"hint", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    
    _activityInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-35, 12, 20, 20)];
    [_activityInd setColor:[UIColor grayColor]];
    [self.navigationController.navigationBar addSubview:_activityInd];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"weiChatAccount", @"hint", nil)];
    
    NSString *url = [BoxDatabase getUrlWithName:DT_ITEM_WEIXINURL]; // 从数据库获取微信公众号的url
    _finalUrl = url;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self getWebPage];
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
    
    [_webview loadRequest:request];
}

#pragma UIWebViewDelegate

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

/** 点击了后退按钮 */
- (void)backButtonClick {
    
    NSLog(@"%s", __func__);
    
    if ([_webview canGoBack]) {
        [_webview goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/** 活动指示 */
- (void)setActivityIndState:(NSNumber *)state {
    
    if ([state boolValue]) {
        [_activityInd startAnimating];
    } else {
        [_activityInd stopAnimating];
    }
}
@end
