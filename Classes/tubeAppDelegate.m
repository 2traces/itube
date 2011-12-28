//
//  tubeAppDelegate.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "tubeAppDelegate.h"
#import "MainViewController.h"

@implementation tubeAppDelegate

@synthesize window;
@synthesize mainViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] init];
	self.mainViewController = aController;
	[aController release];
	
	DLog(@"applicationDidFinishLaunching");
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
    queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *op = [[[NSInvocationOperation alloc] initWithTarget:[self.mainViewController.view mapView] selector:@selector(drawThread) object:nil] autorelease];
    [queue addOperation:op];
}


- (void)dealloc {
    [queue cancelAllOperations];
    [queue release];
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
