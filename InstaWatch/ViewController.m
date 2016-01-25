//
//  ViewController.m
//  InstaWatch
//
//  Created by Brandon Jabr on 9/7/15.
//  Copyright © 2015 Brandon Jabr. All rights reserved.
//

#import "ViewController.h"
#import <InstagramKit/InstagramKit.h>
#import <BFKit/BFKit.h>
#import "MainViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Google/Analytics.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    UIImageView *BGView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [BGView setImage:[UIImage imageNamed:@"InstaWatchBG.jpg"]];
    [self.view addSubview:BGView];
    
    BFButton *signInButton = [[BFButton alloc]initWithFrame:CGRectMake(0, 0, 300, 60)];
    signInButton.center = self.view.center;
    [signInButton setTitle:@"Sign In With Instagram" forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signInButton setBackgroundColor:[UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0]];
    [signInButton setCornerRadius:6.0f];
    [signInButton addTarget:self action:@selector(signInstaBaby) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signInButton];
    signInButton.alpha = 0.0;
    signInButton.tag = 100;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self signInstaBaby];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {

}

-(void)signInstaBaby {
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(2, 100, self.view.frame.size.width-4, 225)];
    [webView setCornerRadius:10];
    [webView.layer setBorderColor:[UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0].CGColor];
    [webView.layer setBorderWidth:2.0];
    [webView setCenter:self.view.center];
    webView.alpha = 0.0;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    NSURL *authURL = [[InstagramEngine sharedEngine] authorizarionURL];
    [webView loadRequest:[NSURLRequest requestWithURL:authURL]];
    
}

-(void)checkInstaAuth {
    [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *user) {
        MainViewController *mainView = [[MainViewController alloc]init];
        [self presentViewController:mainView animated:YES completion:nil];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(NSError *error, NSInteger serverStatusCode) {
        [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view viewWithTag:100].alpha = 1.0;
        } completion:^(BOOL finished) {
            //NEW USER, SET ALL PERMISSIONS TO NO
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:@"top10"];
            [defaults setBool:NO forKey:@"top20"];
            [defaults setBool:NO forKey:@"allfriends"];
            [defaults setInteger:1 forKey:@"appOpens"];
            [defaults setBool:NO forKey:@"viewsUnlocked"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Intro Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSError *error;
    if ([[InstagramEngine sharedEngine] receivedValidAccessTokenFromURL:request.URL error:&error]) {
        [self checkInstaAuth];
    } else {
        [UIView animateWithDuration:0.25 delay:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            webView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    return YES;
}

@end
