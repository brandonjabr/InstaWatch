//
//  MainViewController.h
//  InstaWatch
//
//  Created by Brandon Jabr on 9/7/15.
//  Copyright © 2015 Brandon Jabr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JabrProfileTableViewCell.h"
#import <InstagramKit/InstagramKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <RMStore/RMStore.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>


@import GoogleMobileAds;


@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate,RMStoreContentDownloader,RMStoreObserver,RMStoreReceiptVerificator,RMStoreTransactionPersistor>

@property (retain, strong) UITableView *tblView;
@property (retain, strong) NSMutableArray *followerArray;
@property (retain, strong) InstagramPaginationInfo *currentPaginationInfo;
@property (retain, strong) MBProgressHUD *HUD;
@property (retain, strong) UIWebView *webProfileView;
@property (retain, strong) UIButton *backBtn;
@property (retain, strong) UIButton *unlockBtn;
@property (retain, nonatomic) SLComposeViewController *mySLComposerSheet;




@end
