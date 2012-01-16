//
//  tubeAppDelegate.h
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

@class MainViewController;
@class CityMap;

#define kParseComplete @"kParseComplete"

@interface tubeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
    CityMap *cityMap;
    
    NSOperationQueue    *parseQueue;
    
    //soj
    NSDictionary *mapsInfo;
    NSMutableArray *purchasedMaps;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) CityMap *cityMap;
@property (nonatomic, retain) NSOperationQueue *parseQueue; 


@end

