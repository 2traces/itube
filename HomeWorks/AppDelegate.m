//
//  AppDelegate.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/2/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "AppDelegate.h"
#import "IAPManager.h"
#import <QuickLook/QuickLook.h>

@implementation AppDelegate

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:16 * 1024 * 1024
														 diskCapacity:100 * 1024 * 1024
															 diskPath:nil];

	[NSURLCache setSharedURLCache:URLCache];

    [IAPManager sharedManager];
    
	//[[UITableView appearance] setBackgroundView:nil];

    //Setting up app appearence
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];

        }
        else {
            [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];

        }

    }
    else {

    }
    
    
//    UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(22.0, 5.0, 22.0, 5.0)];
//    
//    [[UINavigationBar appearance] setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];

    
    
    
	return YES;
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
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
