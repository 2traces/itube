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
#import "CrossDeviceMarcos.h"

@class NavigationViewController;

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );

NSString* DisplayStationName(NSString* stName);

#define kParseComplete @"kParseComplete"

@class RatePopupViewController;

@interface tubeAppDelegate : NSObject <UIApplicationDelegate,MFMailComposeViewControllerDelegate> {
    UIWindow *window;
    GlViewController *gl;
    NavigationViewController *navigationViewController;
    UINavigationController *navController;
    NSString *cityName;
    CGPoint userGeoP;
    double userH;
    NSOperationQueue    *parseQueue;
    
    //soj
    NSDictionary *mapsInfo;
    NSMutableArray *purchasedMaps;
    NSString *mapDirectoryPath;
    
    BOOL shouldShowRateScreen;
    
    NSDictionary *config;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NavigationViewController *navigationViewController;
@property (nonatomic, readonly) GlViewController *glViewController;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, assign) CGPoint userGeoPosition;
@property (nonatomic, assign) double userHeading;
@property (nonatomic, retain) NSString *mapDirectoryPath;
@property (nonatomic, assign) BOOL shouldShowRateScreen;

-(NSString*)nameCurrentMap;
-(NSString*)nameCurrentCity;
-(NSString*)getDefaultMapName;
-(NSString*)getDefaultCityName;
-(NSString*)getDefaultMapUrl1;
-(NSString*)getDefaultMapUrl2;
- (NSArray*)getTeasersForMaps;

-(BOOL)isIPHONE5;

-(void)showRasterMap;
-(void)switchMapMode;
-(void)showBookmarks;
-(void)hideBookmarks;
- (void)showSettings;
-(void)errorWithGeoLocation;

- (void)placeAddedToFavorites:(MPlace*)place;
- (void)placeRemovedFromFavorites:(MPlace*)place;

- (void)centerMapOnPlace:(MPlace*)place;

//Rate popup

- (void)rateNowFromPopup:(RatePopupViewController*)vc;
- (void)rateFeedbackFromPopup:(RatePopupViewController*)vc;
- (void)rateDismissFromPopup:(RatePopupViewController*)vc;

- (void) reloadContent;

- (NSString*)getAppStoreUrl;
- (NSString*)getRateUrl;

-(void)selectObject:(Object*)ob;
-(void)selectCluster:(Cluster*)cl;

@end

