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

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@class MainViewController;
@class NavigationViewController;
@class CityMap;

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );

NSString* DisplayStationName(NSString* stName);

#define kParseComplete @"kParseComplete"

@class RatePopupViewController;

@interface tubeAppDelegate : NSObject <UIApplicationDelegate,MFMailComposeViewControllerDelegate, DownloadServerListener> {
    UIWindow *window;
    GlViewController *gl;
    NavigationViewController *navigationViewController;
    MainViewController *mainViewController;
    UINavigationController *navController;
    CityMap *cityMap;
    NSString *cityName;
    CGPoint userGeoP;
    double userH;
    NSOperationQueue    *parseQueue;
    
    //soj
    NSDictionary *mapsInfo;
    NSMutableArray *purchasedMaps;
    NSString *mapDirectoryPath;
    
    BOOL shouldShowRateScreen;
    NSMutableArray *servers;
    NSArray *maps;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) NavigationViewController *navigationViewController;
@property (nonatomic, readonly) GlViewController *glViewController;
@property (nonatomic, retain) CityMap *cityMap;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, assign) CGPoint userGeoPosition;
@property (nonatomic, assign) double userHeading;
@property (nonatomic, retain) NSString *mapDirectoryPath;
@property (nonatomic, assign) BOOL shouldShowRateScreen;
@property (nonatomic, retain) NSMutableArray *servers;
@property (nonatomic, retain) NSArray *maps;

+(tubeAppDelegate*)instance;

-(NSString*)nameCurrentMap;
-(NSString*)nameCurrentCity;
-(NSString*)getDefaultMapName;
-(NSString*)getDefaultCityName;
-(NSString*)getDefaultMapUrl1;
-(NSString*)getDefaultMapUrl2;
- (NSArray*)getTeasersForMaps;

-(BOOL)isIPHONE5;

-(void)showRasterMap;
-(void)showMetroMap;
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

#pragma mark - Purchase & Download

-(void) processPurchases;
-(void)purchaseProduct:(NSString*)prodID;
-(void)downloadProduct:(NSString*)prodID withBlock:(void(^)(int result, NSString* product))block;
-(void)cancelDownloading;
-(void)resortMapArray;

#pragma mark - some helpers

-(BOOL)isProductInstalled:(NSString*)mapName;
- (BOOL) isProductDownloaded:(NSString*)mapName;
-(BOOL)isProductPurchased:(NSString*)prodID;
-(BOOL)isProductAvailable:(NSString*)prodID;
-(BOOL)isProductStatusDownloading:(NSString*)prodID;
-(BOOL)isProductStatusUnpacking:(NSString*)prodID;
-(BOOL)isProductStatusInstalled:(NSString*)prodID;
-(BOOL)isProductStatusPurchased:(NSString*)prodID;
-(BOOL)isProductStatusAvailable:(NSString*)prodID;
-(BOOL)isProductStatusDefault:(NSString*)prodID;
-(BOOL)isProductContentPurchase:(NSString*)prodID;
-(NSIndexPath*)getIndexPathProdID:(NSString*)prodID;
-(void)enableProducts;
-(void)processZipFromServer:(NSString*)fn prodID:(NSString*)prodID;

@end

