//
//  tubeAppDelegate.h
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GlViewController.h"
#import "TubeSplitViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@class MainViewController;
@class CityMap;

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );

NSString* DisplayStationName(NSString* stName);

#define kParseComplete @"kParseComplete"

@interface tubeAppDelegate : NSObject <UIApplicationDelegate,MFMailComposeViewControllerDelegate> {
    UIWindow *window;
    GlViewController *gl;
    MainViewController *mainViewController;
    UINavigationController *navController;
    CityMap *cityMap;
    NSString *cityName;
    CGPoint userGeoP;
    NSOperationQueue    *parseQueue;
    
    //soj
    NSDictionary *mapsInfo;
    NSMutableArray *purchasedMaps;
    NSDictionary *config;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, readonly) GlViewController *glViewController;
@property (nonatomic, retain) CityMap *cityMap;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, assign) CGPoint userGeoPosition;
@property (nonatomic, retain) TubeSplitViewController *tubeSplitViewController;

-(NSString*)nameCurrentMap;
-(NSString*)nameCurrentCity;
-(NSString*)getDefaultMapName;
-(NSString*)getDefaultCityName;
-(NSString*)getDefaultMapUrl1;
-(NSString*)getDefaultMapUrl2;
-(CGRect)getDefaultSearchBox;

-(BOOL)isIPHONE5;
- (BOOL)isIPodTouch4thGen;

-(void)showRasterMap;
-(void)showMetroMap;
-(void)errorWithGeoLocation;
-(void)showSettings;

@end

