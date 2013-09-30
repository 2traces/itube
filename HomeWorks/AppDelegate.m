//
//  AppDelegate.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/2/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "HomeworksIAPHelper.h"
#import <QuickLook/QuickLook.h>

@implementation AppDelegate

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:16 * 1024 * 1024
														 diskCapacity:100 * 1024 * 1024
															 diskPath:nil];
    //[[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeueCyr-Light" size:]];
	[NSURLCache setSharedURLCache:URLCache];

//	[MKStoreManager sharedManager];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        
    }
    else {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"back_bt"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 5)]
                                                          forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsDefault];
    }

    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:84.0f/255.0f green:186.0f/255.0f blue:231.0f/255.0f alpha:1]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:24.0], UITextAttributeFont,nil]];
    
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3 forBarMetrics:UIBarMetricsDefault];
    
    [[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeueCyr-Light" size:17]];
    [[UITextView appearance] setFont:[UIFont fontWithName:@"HelveticaNeueCyr-Light" size:17]];
    [[UITextField appearance] setFont:[UIFont fontWithName:@"HelveticaNeueCyr-Light" size:17]];


    [[UIButton appearance] setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
    UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0)];
	//[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:4.0f/255.0f green:192.0f/255.0f blue:237.0f/255.0f alpha:1]];
    }
    else {
        [[UINavigationBar appearance] setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 3) forBarMetrics:UIBarMetricsDefault];

    }
    
    [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:4.0f/255.0f green:192.0f/255.0f blue:237.0f/255.0f alpha:1]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:16.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, 3) forBarMetrics:UIBarMetricsDefault];
    
    [Parse setApplicationId:@"4xkE7I5Ku3iOFNPypTxPpj5GS7hH3oKYas2kuV1Y"
                  clientKey:@"eDZbfw2GRcQt0EvsaaxFK089AkP6xmbMeJjEc6qp"];
    
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
