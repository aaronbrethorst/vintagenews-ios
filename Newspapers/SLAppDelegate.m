//
//  SLAppDelegate.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLAppDelegate.h"
#import "SLNewspapersViewController.h"
#import "SLNewspaperDetailsViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "MYIntroductionPanel.h"
#import "MYIntroductionView.h"
#import "SLTutorial.h"

@interface SLAppDelegate ()
@property(strong) SLTutorial *tutorial;
@end

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"c84d1b759118d7506fea035b497a567d26a1c67b"];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-41954282-1"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    SLNewspapersViewController *newspapersViewController = [[SLNewspapersViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:newspapersViewController];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.window.rootViewController = self.navigationController;
    }
    else
    {        
        SLNewspaperDetailsViewController *detailViewController = [[SLNewspaperDetailsViewController alloc] init];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    	
    	newspapersViewController.detailViewController = detailViewController;
    	
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = @[self.navigationController, detailNavigationController];
        
        self.window.rootViewController = self.splitViewController;
    }

    [self.window makeKeyAndVisible];

    self.tutorial = [[SLTutorial alloc] init];
    [self.tutorial showTutorial:self.window];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
