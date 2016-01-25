//
//  MainViewController.m
//  InstaWatch
//
//  Created by Brandon Jabr on 9/7/15.
//  Copyright © 2015 Brandon Jabr. All rights reserved.
//

#import "MainViewController.h"
#import <BFKit/BFKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Google/Analytics.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>

#define AD_END 150
#define APP_STORE_LINK @"https://itunes.apple.com/us/app/who-viewed-my-profile-instawatch/id1037975436?ls=1&mt=8"


@interface MainViewController ()

@property (retain, nonatomic) IBOutlet GADBannerView  *bannerView;
@property (retain, nonatomic) IBOutlet GADInterstitial  *interstitial;
@property (retain, nonatomic) UIRefreshControl *refreshIt;



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _followerArray = [NSMutableArray new];
    [[RMStore defaultStore] addStoreObserver:self];

    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"appOpens"] % 3 == 0){
        if ([self.interstitial isReady]) {
            [self.interstitial presentFromRootViewController:self];
        }
    }

    // Do any additional setup after loading the view.
    UIImageView *BGView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [BGView setImage:[UIImage imageNamed:@"InstaWatchBG.jpg"]];
    [self.view addSubview:BGView];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.view.bounds;
    [self.view addSubview:visualEffectView];
    
    UIImageView *myProfileImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.center.x-35, 22, 70, 70)];
    myProfileImage.layer.cornerRadius = myProfileImage.frame.size.height /2;
    myProfileImage.layer.masksToBounds = YES;
    myProfileImage.layer.borderWidth = 1;
    myProfileImage.layer.borderColor = [UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0].CGColor;
    [self.view addSubview:myProfileImage];
    
    //BACK BTN
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(28, 28, 44, 44)];
    [backBtn setImage:[[UIImage imageNamed:@"back-icon@2x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backBtn setTintColor:[UIColor whiteColor]];
    [backBtn setHidden:YES];
    [self.view addSubview:backBtn];
    _backBtn = backBtn;
    [_backBtn addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    
    //SHARE BTN
    UIButton *shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-32-44, 32, 44, 44)];
    [shareBtn setImage:[[UIImage imageNamed:@"back-icon@2x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareBtn setTintColor:[UIColor whiteColor]];
    [shareBtn setHidden:NO];
    [self.view addSubview:shareBtn];
    [shareBtn setImage:[[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareBtn setTintColor:[UIColor whiteColor]];
    [shareBtn addTarget:self action:@selector(shareApp) forControlEvents:UIControlEventTouchUpInside];
    
    
    //UNLOCK BTN
    UIButton *unlockBtn = [[UIButton alloc]initWithFrame:CGRectMake(32, 34, 36, 36)];
    [unlockBtn setImage:[[UIImage imageNamed:@"back-icon@2x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [unlockBtn setTintColor:[UIColor whiteColor]];
    [unlockBtn setHidden:NO];
    [self.view addSubview:unlockBtn];
    [unlockBtn setImage:[[UIImage imageNamed:@"unlock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [unlockBtn setTintColor:[UIColor whiteColor]];
    _unlockBtn = unlockBtn;
    [_unlockBtn addTarget:self action:@selector(buyUnlocks) forControlEvents:UIControlEventTouchUpInside];
    
    _tblView = [[UITableView alloc]initWithFrame:CGRectMake(0, AD_END, self.view.frame.size.width, self.view.frame.size.height-100) style:UITableViewStylePlain];
    _tblView.delegate = self;
    _tblView.dataSource = self;
    _tblView.backgroundView.backgroundColor = [UIColor whiteColor];
    _tblView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tblView];
    
    
    //Refresh Control
    self.refreshIt = [[UIRefreshControl alloc] init];
    self.refreshIt.backgroundColor = [UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0];
    self.refreshIt.tintColor = [UIColor whiteColor];
    [self.refreshIt addTarget:self
                       action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    [_tblView addSubview:self.refreshIt];
    [self.refreshIt setTintColor:[UIColor whiteColor]];
    [self.refreshIt tintColorDidChange];
    
    //SET UP ADMOB
    _bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeSmartBannerPortrait origin:CGPointMake(0, 100)];
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    GADRequest *adReq = [GADRequest request];
    
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    adReq.testDevices = @[ @"94dd68bab284765e46a597f725fa9f02" ];
    [self.bannerView loadRequest:adReq];
    
    _webProfileView = [[UIWebView alloc]initWithFrame:CGRectMake(0, AD_END, self.view.frame.size.width, self.view.frame.size.height-100)];
    _webProfileView.alpha = 0.0;
    _webProfileView.delegate = self;
    [self.view addSubview:_webProfileView];
    
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    
    //Load HUD
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.labelText = @"Loading...";
    _HUD.detailsLabelText = @"Getting Friends";
    _HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:_HUD];
    
    [_HUD show:YES];
    
    [engine getSelfUserDetailsWithSuccess:^(InstagramUser *user) {
        int iterations = user.followsCount / 99;
        NSMutableArray *followingIDs = [NSMutableArray new];
        [myProfileImage sd_setImageWithURL:user.profilePictureURL placeholderImage:[UIImage imageNamed:@"hidden"]];
        //GET USERS FOLLOWING
         for(int i = 0; i < iterations; i++){
             [engine getUsersFollowedByUser:user.Id maxId:self.currentPaginationInfo.nextMaxId
                                withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
                                    
                                    if (paginationInfo) {
                                        self.currentPaginationInfo = paginationInfo;
                                    }
                                    
                                    for (InstagramUser *follower in users) {
                                        
                                        [followingIDs addObject:follower.Id];
                                    }
                                    
        //----------------------------GET MUTUAL FRIENDS--------------------------------
                                    for(int i = 0; i < iterations; i++){
                                        
                                        [engine getFollowersOfUser:user.Id maxId:self.currentPaginationInfo.nextMaxId withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
                                            
                                            if (paginationInfo) {
                                                self.currentPaginationInfo = paginationInfo;
                                            }
                                            
                                            //Add follower info as dictionaries
                                            for (InstagramUser *follower in users) {
                                                if([followingIDs containsObject:follower.Id]){
                                                    NSMutableDictionary *followerDict = [NSMutableDictionary dictionaryWithObjects:@[follower.username,follower.fullName,follower.profilePictureURL,@0] forKeys:@[@"username",@"fullName",@"profileURL",@"myPostsLiked"]];
                                                    
                                                    [_followerArray addObject:followerDict];
                                                }
                                            }

                                        
                                        } failure:^(NSError *error, NSInteger serverStatusCode) {
                                            NSLog(@"%@",error);
                                        }];
                                        
                                    }
        //----------------------------END MUTUAL FRIENDS--------------------------------

                                    
                                } failure:^(NSError *error, NSInteger serverStatusCode) {
                                    NSLog(@"%@",error);
                                }];
         }

        
        //DONE
        } failure:^(NSError *error, NSInteger serverStatusCode) {
            NSLog(@"%@",error);
        }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [self getFriendLikeCount];
}

-(void)viewWillAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Main Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [_tblView reloadData];
    [refreshControl endRefreshing];
}

-(void)shareApp {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Vote
    [alert addButton:@"Vote to get Top 10 List" actionBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_LINK]];
    }];
    
    
    //Facebook
    [alert addButton:@"Facebook" actionBlock:^(void) {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
        {
            _mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
            _mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [_mySLComposerSheet setInitialText:[NSString stringWithFormat:@"Check out who viewed your Instagram profile with InstaWatch. App Store link: %@",APP_STORE_LINK]];

            [self presentViewController:_mySLComposerSheet animated:YES completion:nil];
        }
        [_mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successfull";
                    break;
                    
                default:
                    break;
            } //check if everything worked properly. Give out a message on the state.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            if ([output isEqualToString:@"Post Successfull"]){
                NSLog(@"TOP 10 Purchased");
                //Give em Top 10 list
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:@"top10"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [_tblView reloadData];
            }
        }];
    }];
    
    //Twitter
    [alert addButton:@"Twitter" actionBlock:^(void) {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) //check if Facebook Account is linked
        {
            _mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
            _mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [_mySLComposerSheet setInitialText:[NSString stringWithFormat:@"Check out who viewed your Instagram profile with InstaWatch. App Store link: %@",APP_STORE_LINK]];
            
            [self presentViewController:_mySLComposerSheet animated:YES completion:nil];
        }
        [_mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successfull";
                    break;
                    
                default:
                    break;
            } //check if everything worked properly. Give out a message on the state.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            if ([output isEqualToString:@"Post Successfull"]){
                NSLog(@"TOP 10 Purchased");
                //Give em Top 10 list
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:@"top10"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [_tblView reloadData];
            }
        }];
    }];
    
    
    
    
    
    
    [alert showCustom:self image:[UIImage imageNamed:@"5stars2"] color:[UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0] title:@"Vote to get Top 10" subTitle:@"OR share on Facebook or Twitter" closeButtonTitle:@"Done" duration:0.0f];
}

-(void)buyUnlocks {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Vote
    [alert addButton:@"Buy Top 10   $0.99" actionBlock:^{
        [[RMStore defaultStore] addPayment:@"top10" success:^(SKPaymentTransaction *transaction) {
            
            NSLog(@"PURCHASED TOP 10");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"top10"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tblView reloadData];

        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            NSLog(@"Something went wrong");
            
        }];
    }];
    
    
    
    [alert addButton:@"Buy Top 20   $1.99" actionBlock:^(void) {
        [[RMStore defaultStore] addPayment:@"top20" success:^(SKPaymentTransaction *transaction) {
            
            NSLog(@"PURCHASED TOP 20");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"top20"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tblView reloadData];

        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            NSLog(@"Something went wrong");
            
            NSLog(@"PURCHASED TOP 20");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"top20"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tblView reloadData];

        }];
    }];
    
    
    [alert addButton:@"Buy All Friends   $4.99" actionBlock:^(void) {
        [[RMStore defaultStore] addPayment:@"allfriends" success:^(SKPaymentTransaction *transaction) {
           
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"allfriends"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tblView reloadData];
            
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            NSLog(@"Something went wrong");

        }];
    }];
    
    [alert addButton:@"Unlock View Count   $0.99" actionBlock:^(void) {
        [[RMStore defaultStore] addPayment:@"viewsUnlocked" success:^(SKPaymentTransaction *transaction) {
           
            NSLog(@"PURCHASED VIEW COUNT");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"viewsUnlocked"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tblView reloadData];

        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            NSLog(@"Something went wrong");

        }];
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"unlock"] color:[UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0] title:@"Buy to Unlock" subTitle:@"" closeButtonTitle:@"Done" duration:0.0f];
    
}

-(void)getFriendLikeCount{
    //GET TOTAL LIKES PER MUTUAL FRIEND
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    [engine getSelfFeedWithCount:50 maxId:nil success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        __block int count = 0;
        for(InstagramMedia *insta in media){
            [engine getLikesOnMedia:insta.Id withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
                _HUD.detailsLabelText = @"Ranking Profile Views";
                for(InstagramUser *user in users){
                    for (int i = 0; i < _followerArray.count; i++){
                        NSMutableDictionary *getMutualFriend = [_followerArray objectAtIndex:i];
                        if([[getMutualFriend objectForKey:@"username"] isEqualToString:user.username]){
                            //LIKER FOUND
                            NSInteger likeValue = [[getMutualFriend objectForKey:@"myPostsLiked"]integerValue];
                            likeValue++;
                            
                            [getMutualFriend setObject:[NSNumber numberWithInteger:likeValue] forKey:@"myPostsLiked"];
                        }
                    }
                }
                
                NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"myPostsLiked"  ascending:NO];
                _followerArray = [[_followerArray sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
                [_tblView reloadData];
                
                count++;
                if (count == media.count-1){
                    [_HUD hide:YES];
                    
                }

            } failure:^(NSError *error, NSInteger serverStatusCode) {
                
            }];
        }
  
    } failure:^(NSError *error, NSInteger serverStatusCode) {
        NSLog(@"%@",error);
        
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _followerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JabrProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JabrProfileCell"];
    if(!cell){
        [tableView registerNib:[UINib nibWithNibName:@"JabrProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"JabrProfileCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"JabrProfileCell"];
    }
    
    cell.locked = NO;
    cell.viewsLocked = NO;
    //SET PERMISSIONS
    if(indexPath.row >= 5 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"top10"]){
        cell.locked = YES;
    } else if(indexPath.row >= 10 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"top20"]){
        cell.locked = YES;
    } else if(indexPath.row >= 20 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"allfriends"]){
        cell.locked = YES;
    }
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"allfriends"]){
        cell.locked = NO;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"viewsUnlocked"]){
        cell.viewsLocked = YES;
    }

    return cell;
}

-(double)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
        return 75;
    }

-(void)tableView:(nonnull UITableView *)tableView willDisplayCell:(nonnull JabrProfileTableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height /2;
    cell.profileImageView.layer.masksToBounds = YES;
    cell.profileImageView.layer.borderWidth = 1;
    cell.profileImageView.layer.borderColor = [UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0].CGColor;
    cell.rankLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
    cell.viewsLabel.text = @"?";
    
    //HIDE LOCKED CELLS
    if(cell.locked){
        cell.fullNameLabel.text = @"Locked";
        cell.profileNameLabel.text = @"(Click to unlock)";
        [cell.profileImageView setImage:[UIImage imageNamed:@"hidden"]];
    } else {
        NSDictionary *follower = [_followerArray objectAtIndex:indexPath.row];
        
        if(follower){
            cell.fullNameLabel.text = [follower objectForKey:@"fullName"];
            cell.profileNameLabel.text = [follower objectForKey:@"username"];
            [cell.profileImageView sd_setImageWithURL:[follower objectForKey:@"profileURL"] placeholderImage:[UIImage imageNamed:@"hidden"]];
            
            if(!cell.viewsLocked){
                cell.viewsLabel.text = [NSString stringWithFormat:@"%d",(int)[follower objectForKey:@"myPostsLiked"] * 3];
            }
        }
    }
    
}

-(void)closeWebView {
    _backBtn.hidden = YES;
    _unlockBtn.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _webProfileView.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];

}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    JabrProfileTableViewCell *getCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(!getCell.locked){
        NSString *profileStr = [NSString stringWithFormat:@"https://instagram.com/%@/",getCell.profileNameLabel.text];
        
        NSURL *instagramURL = [NSURL URLWithString:profileStr];
        NSURLRequest *req = [NSURLRequest requestWithURL:instagramURL];
        [_webProfileView loadRequest:req];
        [MBProgressHUD showHUDAddedTo:_webProfileView animated:YES];
        [UIView animateWithDuration:0.2 animations:^{
            _webProfileView.alpha = 1.0;
            _backBtn.hidden = NO;
            _unlockBtn.hidden = YES;
        }];
    }
    
}

-(void)webViewDidFinishLoad:(nonnull UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:_webProfileView animated:YES];
}

- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    NSLog(@"%@",productIdentifier);
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification
{
    NSError *error = notification.rm_storeError;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    
    NSLog(@"Attempted to purchase: %@",productIdentifier);
}




@end
