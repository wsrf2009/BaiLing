//
//  AboutAPPViewController.m
//  CloudBox
//
//  Created by TTS on 15-4-1.
//  Copyright (c) 2015年 宇音天下. All rights reserved.
//

#import "AboutAPPViewController.h"
#import "NewVersion.h"
#import "UIImageView+WebCache.h"
#import "SuggestionViewController.h"
#import "HelperViewController.h"
#import "PublicAccountViewController.h"

@interface AboutAPPViewController ()
@property (nonatomic, retain) IBOutlet UILabel *labelAppVersion;

@end

@implementation AboutAPPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"aboutLark", @"hint", nil)];
    
    [self hideEmptySeparators:self.tableView];

    [self.navigationController setToolbarHidden:YES];
    
    NSString *appVersion = [SystemToolClass appVersion];
    NSString *appBuild = [SystemToolClass appBuildVersion];
    [_labelAppVersion setText:[NSString stringWithFormat:@"v%@ b%@", appVersion, appBuild]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (0 == indexPath.section) {
        if (1 == indexPath.row) {
            HelperViewController *helperVC = [[UIStoryboard storyboardWithName:@"QuestionHelper" bundle:nil] instantiateViewControllerWithIdentifier:@"HelperViewController"];
            helperVC.deviceManager = self.deviceManager;
            if (nil != helperVC) {
                [self.navigationController pushViewController:helperVC animated:YES];
            }
            
        } else if (2 == indexPath.row) {
            PublicAccountViewController *publicAccountVC = [[UIStoryboard storyboardWithName:@"WeiChat" bundle:nil] instantiateViewControllerWithIdentifier:@"PublicAccountViewController"];
            publicAccountVC.deviceManager = self.deviceManager;
            if (nil != publicAccountVC) {
                [self.navigationController pushViewController:publicAccountVC animated:YES];
            }
        
        } else if (3 == indexPath.row) {
            SuggestionViewController *suggestionVC = [[UIStoryboard storyboardWithName:@"Feedback" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestionViewController"];
            suggestionVC.deviceManager = self.deviceManager;
            if (nil != suggestionVC) {
                [self.navigationController pushViewController:suggestionVC animated:YES];
            }
            
        }
    }
}

@end
