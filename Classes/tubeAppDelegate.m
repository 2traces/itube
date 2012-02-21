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
    NSString *mapName =[self nameCurrentMap];
//    [cm loadMap:mapName];
    [cm loadMap:@"london"];
    
    self.cityMap = cm;
    [cm release];
	
	DLog(@"applicationDidFinishLaunching");
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    MHelper *helper = [MHelper sharedHelper];
    [helper saveBookmarkFile];
    [helper saveHistoryFile];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    MHelper *helper = [MHelper sharedHelper];
    [helper saveBookmarkFile];
    [helper saveHistoryFile];
}

-(NSString*)nameCurrentMap
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentMap =  [defaults stringForKey:@"current_map"];
    
    if (!currentMap) {
        currentMap = [self getDefaultMapName];    
        [defaults setObject:currentMap forKey:@"current_map"];
        [defaults synchronize];
    }
    
    return currentMap;
}

-(NSString*)getDefaultMapName
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path]) {
        NSBundle *bundle = [NSBundle mainBundle]; 
        NSError *error = nil; 
        NSString *mapsBundlePath = [bundle pathForResource:@"maps" ofType:@"plist"]; 
        
        [manager copyItemAtPath:mapsBundlePath toPath:path error:&error];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *mapFileName =[NSString stringWithString:[dict objectForKey:@"default"]];
    [dict release];
    
    return mapFileName;
}

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
