//
//  AppDelegate.m
//  InstaWatch
//
//  Created by Brandon Jabr on 9/7/15.
//  Copyright © 2015 Brandon Jabr. All rights reserved.
//

#import "AppDelegate.h"
#import <Google/Analytics.h>
#import <RMStore/RMStore.h>

@interface AppDelegate ()

@property (retain, nonatomic) IBOutlet GADInterstitial  *interstitial;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.interstitial = [self createAndLoadInterstitial];
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    
    //Load In-App-Purchases
    NSSet *products = [NSSet setWithArray:@[@"top10", @"top20", @"allfriends",@"viewsUnlocked"]];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"Products loaded");
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
    }];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   NSInteger appOpens = [[NSUserDefaults standardUserDefaults] integerForKey:@"appOpens"];
    appOpens++;
    [[NSUserDefaults standardUserDefaults] setInteger:appOpens forKey:@"appOpens"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"appOpens"] % 3 == 0){
        if ([self.interstitial isReady]) {
            [self.interstitial presentFromRootViewController:self.window.rootViewController.presentedViewController];
        }
    }
}

#pragma GADIntersitial Ad Delegate

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"94dd68bab284765e46a597f725fa9f02" ];
    [interstitial loadRequest:request];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
