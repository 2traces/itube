//
//  tubeAppDelegate.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "CityMap.h"

@implementation tubeAppDelegate

@synthesize window;
@synthesize mainViewController;
@synthesize cityMap;
@synthesize parseQueue;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] init];
	self.mainViewController = aController;
	[aController release];
    
    CityMap *cm = [[CityMap alloc] init];
    [cm loadMap:@"Metro"];
    self.cityMap = cm;
    [cm release];
	
	DLog(@"applicationDidFinishLaunching");
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
