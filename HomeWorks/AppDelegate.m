//
//  AppDelegate.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/2/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "AppDelegate.h"
#import "MKStoreManager.h"
#import <Parse/Parse.h>
#import "HomeworksIAPHelper.h"

@implementation AppDelegate

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:16 * 1024 * 1024
														 diskCapacity:100 * 1024 * 1024
															 diskPath:nil];

	[NSURLCache setSharedURLCache:URLCache];

//	[MKStoreManager sharedManager];

    [Parse setApplicationId:@"2wqftsBZHPXzTiA1DPeggSwicLdOkIJpXymMc5IM"
                  clientKey:@"mN2tTXVIBEqaO6PzKF5thqfgWiyeGsKdPm5OZK6g"];
    
    [[HomeworksIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self.products = products;
        }
    }];
    
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
