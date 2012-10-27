//
//  tubeAppDelegate.h
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "GlViewController.h"

@class MainViewController;
@class CityMap;

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );

#define kParseComplete @"kParseComplete"
#define kLaunchesBeforeShowingAd 3

@interface tubeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GlViewController *mainViewController;
    CityMap *cityMap;
    NSString *cityName;
    CGPoint userGeoP;
    NSOperationQueue    *parseQueue;
    
    //soj
    NSDictionary *mapsInfo;
    NSMutableArray *purchasedMaps;
    BOOL shouldShowAd;
    UIImageView *splashScreen;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) GlViewController *mainViewController;
@property (nonatomic, retain) CityMap *cityMap;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic, retain) NSOperationQueue *parseQueue; 
@property (nonatomic, assign) BOOL shouldShowAd;
@property (nonatomic, assign) CGPoint userGeoPosition;

-(NSString*)nameCurrentMap;
-(NSString*)nameCurrentCity;
-(NSString*)getDefaultMapName;
-(NSString*)getDefaultMapUrl1;
-(NSString*)getDefaultMapUrl2;
-(NSString*)getDefaultCityName;
-(void)getDefaultExtent:(CGPoint*)pos level:(int*)level;

@end

