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
#import "TubeAppIAPHelper.h"
#import "TubeSplitViewController.h"
#import "StatusViewController.h"
#import <MapKit/MapKit.h>
#import "ManagedObjects.h"
#import "MainView.h"
#import "NavigationViewController.h"
#import "PhotosViewController.h"
#import "CategoriesViewController.h"
#import "RatePopupViewController.h"
#import "WeatherHelper.h"
#import "Reachability.h"
#import "SSZipArchive.h"

#define plist_ 1
#define zip_  2

NSString* DisplayStationName(NSString* stName) {
    NSString *tmpStr = [[stName stringByReplacingOccurrencesOfString:@"_" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    tmpStr = [[tmpStr stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [[tmpStr stringByReplacingOccurrencesOfString:@"." withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@implementation tubeAppDelegate {
void(^downloadBlock)(int result, NSString* product);
    int requested_file_type;
    NSString *mapID;
}

@synthesize window;
@synthesize mainViewController;
@synthesize glViewController = gl;
@synthesize cityMap;
@synthesize cityName;
@synthesize parseQueue;
@synthesize navigationViewController;
@synthesize mapDirectoryPath;
@synthesize shouldShowRateScreen;
@synthesize servers;
@synthesize maps;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

+(tubeAppDelegate*)instance
{
    return (tubeAppDelegate*)[UIApplication sharedApplication].delegate;
}

-(void)setUserGeoPosition:(CGPoint)userGeoPosition
{
    BOOL firstSet = CGPointEqualToPoint(userGeoP, CGPointZero);
    userGeoP = userGeoPosition;
    [gl setUserGeoPosition:userGeoP];
    MainView *mv = (MainView*)mainViewController.view;
    if(mv.followUserGPS) [mv setGeoPosition:userGeoPosition withZoom:mv.containerView.zoomScale];
    if(firstSet) [self.navigationViewController.photosController updateInfoForCurrentPage];
}

-(CGPoint)userGeoPosition
{
    return userGeoP;
}

-(void)setUserHeading:(double)userHeading
{
    userH = userHeading;
    [gl setUserHeading:userH];
}

-(double)userHeading
{
    return userH;
}

-(void)errorWithGeoLocation
{
    [gl errorWithGeoLocation];
}

- (void)placeAddedToFavorites:(MPlace*)place {
    [self.navigationViewController placeAddedToFavorites:place];
}

- (void)placeRemovedFromFavorites:(MPlace*)place {
    [self.navigationViewController placeRemovedFromFavorites:place];
}

- (void)centerMapOnPlace:(MPlace*)place {
    [self.navigationViewController centerMapOnPlace:place];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    self.servers = [[[NSMutableArray alloc] init] autorelease];
    self.maps = [self getMapsList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    gl = [[GlViewController alloc] initWithNibName:@"GlViewController" bundle:[NSBundle mainBundle]];
	MainViewController *aController = [[MainViewController alloc] init];

	self.mainViewController = aController;
    self.navigationViewController = [[[NavigationViewController alloc] initWithNibName:@"NavigationViewController" bundle:[NSBundle mainBundle] mainViewController:self.mainViewController glViewController:gl] autorelease];
	[aController release];
    CityMap *cm = [[CityMap alloc] init];
    NSString *mapName =[self nameCurrentMap];
    [cm loadMap:mapName];
    
    self.cityMap = cm;
    [cm release];
    
    self.cityName= [self nameCurrentCity];
    
    // Override point for customization after application launch.
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[TubeAppIAPHelper sharedHelper]];
    
    self.parseQueue = [[NSOperationQueue alloc] init];
    
    self.window.frame = [[UIScreen mainScreen] bounds];
    
    if (IS_IPAD) {
        TubeSplitViewController *splitController = [[TubeSplitViewController alloc] init];
        splitController.mainViewController = self.mainViewController;
        
        
                
        //navController = [[UINavigationController alloc] initWithRootViewController:self.navigationViewController];
        //navController.navigationBarHidden = YES;
        //   CGRect main = [UIScreen mainScreen].applicationFrame;
       // mainViewController.view.frame = self.navigationViewController.view.frame = [UIScreen mainScreen].applicationFrame;
       // CGRect mainViewFrame = mainViewController.view.frame;
       // mainViewFrame.origin.y = 0;
        //mainViewController.view.frame = mainViewFrame;
        ///navController.view.layer.cornerRadius = 5;
        //window.layer.cornerRadius = 5;
        //[window addSubview:[navController view]];
        //[window setRootViewController:navController];
        
        [window addSubview:[splitController view]];
        
        
         [window setRootViewController:splitController];
         navController = splitController.navigationController;
         //[splitController release];
         //[window makeKeyAndVisible];

        [window makeKeyAndVisible];
    } else {
        navController = [[UINavigationController alloc] initWithRootViewController:self.navigationViewController];
        navController.navigationBarHidden = YES;
     //   CGRect main = [UIScreen mainScreen].applicationFrame;
        mainViewController.view.frame = self.navigationViewController.view.frame = [UIScreen mainScreen].applicationFrame;
        CGRect mainViewFrame = mainViewController.view.frame;
        mainViewFrame.origin.y = 0;
        mainViewController.view.frame = mainViewFrame;
        navController.view.layer.cornerRadius = 5;
        window.layer.cornerRadius = 5;
        [window addSubview:[navController view]];
        [window setRootViewController:navController];
        [window makeKeyAndVisible];
    }
}


-(NSArray*)getMapsList
{
    //NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"maps" ofType:@"plist"];
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSArray *mapIDs = [dict allKeys];
    NSMutableArray *mapsInfoArray = [[[NSMutableArray alloc] initWithCapacity:[mapIDs count]] autorelease];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSMutableDictionary *productContent = nil;
    NSString *contentID = nil;
    
    for (NSString* mapId in mapIDs) {
        NSMutableDictionary *product = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:mapId]];
        [product setObject:@"3" forKey:@"sortingPosition"];
        [product setObject:mapId forKey:@"prodID"];
        
        if ([mapId isEqual:bundleIdentifier]) {
            [product setObject:@"1" forKey:@"sortingPosition"];
            
            [product setObject:@"D" forKey:@"status"];
            productContent = [NSMutableDictionary dictionaryWithDictionary:product];
            [productContent setObject:@"2" forKey:@"sortingPosition"];
            
            contentID = [NSString stringWithFormat:@"%@.content", mapId];
            [productContent setObject:contentID forKey:@"prodID"];
            if ([self isProductInstalled:contentID]) {
                [productContent setObject:@"I" forKey:@"status"];
            }
            if ([self isProductPurchased:bundleIdentifier]) {
                [product setObject:@"P" forKey:@"status"];
            }
        } else if ([self isProductPurchased:mapId]) {
            if ([self isProductInstalled:[product valueForKey:@"filename"]]) {
                [product setObject:@"I" forKey:@"status"];
            } else {
                [product setObject:@"P" forKey:@"status"];
            }
        } else {
            [product setObject:@"Z" forKey:@"status"];
        };
        
        [mapsInfoArray addObject:product];
        [product release];
    }
    
    if (productContent) {
        [mapsInfoArray addObject:productContent];
    }
    
    
    [dict release];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [mapsInfoArray sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
    
    [sortDescriptor2 release];
    [sortDescriptor1 release];
    
    return mapsInfoArray;
}

- (void)awakeFromNib
{
    NSString *      initialDefaultsPath;
    NSDictionary *  initialDefaults;

    initialDefaultsPath = [[NSBundle mainBundle] pathForResource:@"InitialDefaults" ofType:@"plist"];
    initialDefaults = [NSDictionary dictionaryWithContentsOfFile:initialDefaultsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
    
    //self.shouldShowRateScreen = YES;
    
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"launches"])
	{
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"launches"]==[[NSUserDefaults standardUserDefaults] integerForKey:@"maxLaunches"]) {
            self.shouldShowRateScreen = YES;
            
        } else if  ([[NSUserDefaults standardUserDefaults] integerForKey:@"launches"]<[[NSUserDefaults standardUserDefaults] integerForKey:@"maxLaunches"]) {
            
            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"launches"]+1 forKey:@"launches"];
            [prefs synchronize];
        }
	} else {
        NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:1 forKey:@"launches"];
        [prefs setInteger:6 forKey:@"maxLaunches"];
        [prefs synchronize];
    }
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [gl purgeUnusedCache];
}

- (void)rateNowFromPopup:(RatePopupViewController*)vc {
    
    [UIView animateWithDuration:0.5 animations:^{
        vc.view.alpha = 0;
    } completion:^(BOOL finished) {
        [vc.view removeFromSuperview];
        
        [vc autorelease];
    }];
    
    NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:40 forKey:@"launches"];
    [prefs synchronize];
    
    NSString *address = [self getRateUrl];
    
    
    
    if (address) {
        NSURL *url = [NSURL URLWithString:address];
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (void)rateFeedbackFromPopup:(RatePopupViewController*)vc {
    
    [UIView animateWithDuration:0.5 animations:^{
        vc.view.alpha = 0;
    } completion:^(BOOL finished) {
        [vc.view removeFromSuperview];
        
        [vc autorelease];
    }];
    
    [self showMailComposer:nil];

}


- (void)rateDismissFromPopup:(RatePopupViewController*)vc {
    
    [UIView animateWithDuration:0.5 animations:^{
        vc.view.alpha = 0;
    } completion:^(BOOL finished) {
        [vc.view removeFromSuperview];

        [vc autorelease];
    }];
    
    NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:1 forKey:@"launches"];
    [prefs setInteger:25 forKey:@"maxLaunches"];
    [prefs synchronize];
}

- (void) reloadContent {
    [self.navigationViewController reloadCategories];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag==1) {
//        if (buttonIndex == 0) {
//            
//            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
//            [prefs setInteger:40 forKey:@"launches"];
//            [prefs synchronize];
//            
//        } else if (buttonIndex == 1) {
//            
//            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
//            [prefs setInteger:40 forKey:@"launches"];
//            [prefs synchronize];
//            
//            NSString *address = [self getRateUrl];
//            if (address) {
//                NSURL *url = [NSURL URLWithString:address];
//                [[UIApplication sharedApplication] openURL:url];
//            }
//            
//        } else if (buttonIndex == 2) {
//            
//            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
//            [prefs setInteger:1 forKey:@"launches"];
//            [prefs synchronize];
//        } else if (buttonIndex == 3) {
//            
//            [self showMailComposer:nil];
//        }
    }
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return [self.navigationViewController supportedInterfaceOrientations];
}

-(NSString*)getAppName
{
    NSString *appName;
    
    appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([appName length] == 0)
    {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    }
    
    return appName;
}

-(void)askForRate
{
    
    RatePopupViewController *rateVC = [[RatePopupViewController alloc] initWithNibName:@"RatePopupViewController" bundle:[NSBundle mainBundle]];
    rateVC.view.alpha = 0;
    [self.window addSubview:rateVC.view];

    [UIView animateWithDuration:0.5 animations:^{
        rateVC.view.alpha = 1;

    }];
    
//    NSString *cancelButtonLabel = NSLocalizedString(@"No, Thanks", @"No, Thanks");
//    NSString *remindButtonLabel = NSLocalizedString(@"Remind Me Later", @"Remind Me Later");
//    NSString *rateButtonLabel = NSLocalizedString(@"Rate It Now", @"Rate It Now");
//    NSString *mailButtonLabel = NSLocalizedString(@"Drop Us An EMail", @"Drop Us An EMail");
//    NSString *rateLabel = [NSString stringWithFormat:NSLocalizedString(@"Rate", @"Rate"),[self getAppName]];
//    NSString *rateMessageLabel = [NSString stringWithFormat:NSLocalizedString(@"RateMessage", @"RateMessage"),[self getAppName]];
//    
//    UIAlertView *buttonAlert = [[UIAlertView alloc] initWithTitle:rateLabel message:rateMessageLabel delegate:self cancelButtonTitle:cancelButtonLabel otherButtonTitles:rateButtonLabel, nil];
//    
//    buttonAlert.tag=1;
//    
//    [buttonAlert addButtonWithTitle:remindButtonLabel];
//    [buttonAlert addButtonWithTitle:mailButtonLabel];
//    [buttonAlert show];
//    [buttonAlert release];
}

- (void)resizeAlertView:(UIAlertView *)alertView
{
    if (alertView.tag==1) {
        NSInteger imageCount = 0;
        CGFloat offset = 0.0f;
        CGFloat messageOffset = 0.0f;
        for (UIView *view in alertView.subviews)
        {
            CGRect frame = view.frame;
            if ([view isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)view;
                if ([label.text isEqualToString:alertView.title])
                {
                    [label sizeToFit];
                    offset = label.frame.size.height - fmax(0.0f, 45.f - label.frame.size.height);
                    if (label.frame.size.height > frame.size.height)
                    {
                        offset = messageOffset = label.frame.size.height - frame.size.height;
                        frame.size.height = label.frame.size.height;
                    }
                }
                else if ([label.text isEqualToString:alertView.message])
                {
                    label.alpha = 1.0f;
                    label.lineBreakMode = NSLineBreakByWordWrapping;
                    label.numberOfLines = 0;
                    [label sizeToFit];
                    offset += label.frame.size.height + 20 - frame.size.height;
                    frame.origin.y += messageOffset;
                    frame.size.height = label.frame.size.height;
                }
            }
            else if ([view isKindOfClass:[UITextView class]])
            {
                view.alpha = 0.0f;
            }
            else if ([view isKindOfClass:[UIImageView class]])
            {
                if (imageCount++ > 0)
                {
                    view.alpha = 0.0f;
                }
            }
            else if ([view isKindOfClass:[UIControl class]])
            {
                frame.origin.y += offset;
            }
            view.frame = frame;
        }
        CGRect frame = alertView.frame;
        frame.origin.y -= roundf(offset/2.0f);
        frame.size.height += offset;
        alertView.frame = frame;
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    [self resizeAlertView:alertView];
}

//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    [self.mainViewController.statusViewController refreshStatusInfo];
//}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.mainViewController.statusViewController refreshStatusInfo];
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

-(NSString*)nameCurrentCity
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentCity =  [defaults stringForKey:@"current_city"];
    
    if (!currentCity) {
        currentCity = [self getDefaultCityName];    
        [defaults setObject:currentCity forKey:@"current_city"];
        [defaults synchronize];
    }
    
    return currentCity;
}

-(NSDictionary*)mapsPlist
{
    static NSDictionary *_maps = nil;
    if(nil == _maps) {
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if (![manager fileExistsAtPath:path]) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSError *error = nil;
            NSString *mapsBundlePath = [bundle pathForResource:@"maps" ofType:@"plist"];
            
            [manager copyItemAtPath:mapsBundlePath toPath:path error:&error];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        _maps = [dict objectForKey:bundleIdentifier];
    }
    return _maps;
}

- (NSString*)getAppStoreUrl {
    return [self.mapsPlist objectForKey:@"appstore_link"];
}

- (NSString*)getRateUrl {
    return [self.mapsPlist objectForKey:@"rate_link"];
}

- (NSArray*)getTeasersForMaps {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSError *error = nil;
        NSString *mapsBundlePath = [bundle pathForResource:@"maps" ofType:@"plist"];
        
        [manager copyItemAtPath:mapsBundlePath toPath:path error:&error];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSMutableArray *teasers = [NSMutableArray arrayWithCapacity:3];
    
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:bundleIdentifier]) {
            continue;
        }
        NSDictionary *city = [dict objectForKey:key];
        HCTeaserObject *teaser = [HCTeaserObject teaserObjectWithName:[city objectForKey:@"name"]
                                                                image:[UIImage imageNamed:[city objectForKey:@"icon"]]
                                                                  url:[city objectForKey:@"appstore_link"]];
        [teasers addObject:teaser];
    }
    
    [dict release];
    
    return teasers;
}

-(NSString*)getDefaultMapName
{
    return [self.mapsPlist objectForKey:@"filename"];
}

-(NSString*)getDefaultCityName
{
    return [self.mapsPlist objectForKey:@"name"];
}

-(NSString*)getDefaultMapUrl1
{
    return [self.mapsPlist objectForKey:@"url1"];
}

-(NSString*)getDefaultMapUrl2
{
    return [self.mapsPlist objectForKey:@"url2"];
}

#pragma mark - manage maps

-(void)showRasterMap
{
    CGRect pos;
    NSMutableArray *data = [NSMutableArray array];
    MainView *mv = (MainView*)mainViewController.view;
    pos = [mv getMapVisibleRect];
    pos = [cityMap getGeoCoordsForRect:pos coordinates:data];
    [self.navigationViewController showRasterMap];
    [gl removeAllPins];
    [gl setGeoPosition:pos];
    if([data count] > 0) {
        [gl setStationsPosition:data withMarks:!CGRectIsNull(cityMap.activeExtent)];
    }
}

-(void)showMetroMap
{
    [self.navigationViewController showMetroMap];
}

-(void)switchMapMode
{
    BOOL isMetro = [self.navigationViewController isMetroMode];
    if (isMetro)
        [self showRasterMap];
    else
        [self showMetroMap];
}

-(void)showBookmarks
{
    [self.navigationViewController showBookmarksLayer];
}

-(void)hideBookmarks {
    [self.navigationViewController hideBookmarksLayer];
}

- (void)showSettings {
    [self.navigationViewController showSettings];
}

#pragma mark - Mail methods

// Displays an email composition interface inside the app // and populates all the Mail fields.
-(IBAction)showMailComposer:(id)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        // Test to ensure that device is configured for sending emails.
        if ([mailClass canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:[NSString stringWithString:[self getAppName]]];
            [picker setToRecipients:[NSArray arrayWithObject:[NSString stringWithFormat:@"oxana.bakuma@hotmail.com"]]];
            [self.navigationViewController presentViewController:picker animated:YES completion:nil];
            [picker release];
        } else {
            // Device is not configured for sending emails, so notify user.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't send email" message:@"This device not configured to send emails" delegate:self cancelButtonTitle:@"Ok, I will try later" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    } 
}

// Dismisses the Mail composer when the user taps Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSString *resultTitle = nil; NSString *resultMsg = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            resultTitle = @"Email cancelled";
            resultMsg = @"You cancelled you email"; break;
        case MFMailComposeResultSaved:
            resultTitle = @"Email saved";
            resultMsg = @"Your draft email was saved"; break;
        case MFMailComposeResultSent: resultTitle = @"Email sent";
            resultMsg = @"Your email was sent successfully";
            break;
        case MFMailComposeResultFailed:
            resultTitle = @"Email failed";
            resultMsg = @"Your email was failed"; break;
        default:
            resultTitle = @"Email was not sent";
            resultMsg = @"Your email was not sent"; break;
    }
    // Notifies user of any Mail Composer errors received with an Alert View dialog.
    UIAlertView *mailAlertView = [[UIAlertView alloc] initWithTitle:resultTitle message:resultMsg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [mailAlertView show];
    [mailAlertView release];
    [resultTitle release];
    [resultMsg release];
    [self.navigationViewController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    /*if ([MKDirectionsRequest isDirectionsRequestURL:url]) {

        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
        
        MKMapItem *startItem = [request source];
        MKMapItem *endItem = [request destination];
        
        CGPoint startPoint = CGPointMake(startItem.placemark.coordinate.latitude, startItem.placemark.coordinate.longitude);
        CGPoint endPoint = CGPointMake(endItem.placemark.coordinate.latitude, endItem.placemark.coordinate.longitude);
        
        Station *startStation  = [cityMap findNearestStationTo:startPoint];
        Station *endStation  = [cityMap findNearestStationTo:endPoint];
        
        [request release];

        MStation *mStartStation = [[MHelper sharedHelper] getStationWithIndex:startStation.index andLineIndex:startStation.line.index];
        MStation *mEndStation = [[MHelper sharedHelper] getStationWithIndex:endStation.index andLineIndex:endStation.line.index];
        
        [mainViewController returnFromSelection:[NSArray arrayWithObjects:mStartStation, mEndStation,nil]];
        
        return YES;
    }*/
    
    return NO;
}

-(BOOL)isIPHONE5
{
    if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        CGFloat scale = [UIScreen mainScreen].scale;
        result = CGSizeMake(result.width * scale, result.height * scale);
        
        if(result.height == 1136){
            return YES;
        }
    }
    
    return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [[WeatherHelper sharedHelper] getWeatherInformation];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [servers release];
    [maps release];
    [gl release];
    [mainViewController release];
    [window release];
    [cityMap release];
    [super dealloc];
}

#pragma mark - Purchase & Download

-(void) processPurchases
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        NSLog(@"No internet connection!");
    } else {
        if ([TubeAppIAPHelper sharedHelper].products == nil) {
            [[TubeAppIAPHelper sharedHelper] requestProducts];
        } else {
            [self enableProducts];
            [self resortMapArray];
        }
    }
}

- (void)productsLoaded:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self enableProducts];
    [self resortMapArray];
}

-(void)purchaseProduct:(NSString*)prodID
{
    NSArray *products = [TubeAppIAPHelper sharedHelper].products;
    
    for (SKProduct *product in products) {
        if ([product.productIdentifier isEqual:prodID]) {
            
            NSLog(@"Buying %@...", product.productIdentifier);
            [[TubeAppIAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
            
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:130.0];
            
        }
    }
}

- (void)timeout:(id)arg {
    NSLog(@"timeout");
}

-(void)downloadProduct:(NSString*)prodID withBlock:(void (^)(int result, NSString* product))block
{
    downloadBlock = Block_copy(block);
    NSLog(@"Download product with prodID %@", prodID);
    DownloadServer *server = [[[DownloadServer alloc] init] autorelease];
    server.listener=self;
    server.prodID = prodID;
    
    [servers addObject:server];
    
    NSString *zipFile = [self getZipFileForProduct:prodID];
    
    requested_file_type=zip_;
    NSString *tempDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"1.zip"]];
    [server loadFileAtFullURL:[NSURL URLWithString:zipFile] toFile:path];
}



- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error!"
                                                         message:transaction.error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        [alert show];
    }
}

-(void)downloadDone:(NSMutableData *)data prodID:(NSString*)prodID server:(DownloadServer *)myid
{
    if (requested_file_type==plist_) {
        [self processPlistFromServer:data];
    } else if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"ZIP" forKey:@"status"];
                }
            }
        }
        mapID = [prodID retain];
        [self performSelector:@selector(processZipFromServer:) withObject:myid.filename afterDelay:1];
    }
    
    [servers removeObject:myid];
}


-(void)downloadFailed:(DownloadServer*)myid
{
    NSLog(@"Downloading failed");
    [servers removeObject:myid];
    if(downloadBlock) downloadBlock(2, myid.prodID);
}

-(void)downloadedBytes:(long)part outOfBytes:(long)whole prodID:(NSString*)prodID
{
    NSLog(@"downloaded bytes %li/%li, prodID %@", part, whole, prodID);
    if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"N" forKey:@"status"];
                    [map setValue:[NSNumber numberWithLong:part] forKey:@"progressPart"];
                    [map setValue:[NSNumber numberWithLong:whole] forKey:@"progressWhole"];
                }
            }
        }
    }
    if(downloadBlock) downloadBlock(0, prodID);
}

-(void)downloadedBytes:(float)part prodID:(NSString*)prodID
{
    NSLog(@"downloaded bytes %f, prodId %@", part, prodID);
    if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"N" forKey:@"status"];
                    [map setValue:[NSNumber numberWithFloat:part] forKey:@"progress"];
                }
            }
        }
    }
    if(downloadBlock) downloadBlock(0, prodID);
}

-(void)cancelDownloading
{
    for (DownloadServer *server in servers) {
        [server cancel];
    }
    
    [servers removeAllObjects];
}

-(void)startDownloading:(NSString*)prodID
{
    if (requested_file_type==zip_) {
        NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
        
        if (mapIndexPath) {
            for (NSDictionary *map in self.maps) {
                if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                    [map setValue:@"N" forKey:@"status"];
                }
            }
        }
    }
}

- (void)productPurchased:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *productIdentifier = (NSString *) notification.object;
    
    [self markProductAsPurchased:productIdentifier];
    [self resortMapArray];
}

-(void)markProductAsPurchased:(NSString*)prodID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *contentIdentifier = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && ([[map valueForKey:@"status"] isEqual:@"V"] || [[map valueForKey:@"status"] isEqual:@"Z"]) ) {
            [map setObject:@"P" forKey:@"status"];
            if ([prodID isEqualToString:bundleIdentifier]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:bundleIdentifier];
                [self markProductAsInstalled:contentIdentifier];
            }
        }
    }
    
    if ([prodID isEqualToString:contentIdentifier]) {
        [self markProductAsInstalled:prodID];
    }
    
}

-(void)markProductAsInstalled:(NSString*)prodID
{
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID]) {
            [map setObject:@"I" forKey:@"status"];
        }
    }
    NSString *contentIdentifier = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    if ([prodID isEqualToString:contentIdentifier]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSNumber numberWithInt:1] forKey:@"additionalContentAccessLevel"];
        [defaults synchronize];
        tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate reloadContent];
    }
    
}

-(void)processZipFromServer:(NSString*)fn {
    [tubeAppDelegate.instance processZipFromServer:fn prodID:mapID];
}

-(void)processZipFromServer:(NSString*)fn prodID:(NSString*)prodID
{
    NSIndexPath *mapIndexPath = [self getIndexPathProdID:prodID];
    
    if (mapIndexPath) {
        for (NSDictionary *map in self.maps) {
            if ([[map objectForKey:@"prodID"] isEqual:prodID]) {
                [map setValue:@"ZIP" forKey:@"status"];
            }
        }
        
    }
    
    // save data to file in tmp
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //SHOULD BE ASYNC!
    __block BOOL success = NO;
    
    success = [SSZipArchive unzipFileAtPath:fn toDestination:cacheDir];
    
    
    // delete file from temp
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:fn error:nil];
    
    if (success) {
        [self markProductAsInstalled:prodID];
        NSLog(@"Product installed!");
    }
    
    [self resortMapArray];
    if(downloadBlock) {
        downloadBlock(1, prodID);
        [downloadBlock release];
        downloadBlock = nil;
    }
}


-(void)processPlistFromServer:(NSMutableData*)data
{
    NSLog(@"Process plist from server");
    NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
    
    NSArray *array = [dict allKeys];
    
    NSMutableArray *productToDonwload = [NSMutableArray array];
    
    if ([array count]>0) {
        NSString *tempDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"maps.plist"]];
        [data writeToFile:path atomically:YES];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        
        /*
        for (NSDictionary *mmap in self.maps) {
            if ([self isProductPurchased:[mmap objectForKey:@"prodID"]] || [[mmap objectForKey:@"prodID"] isEqual:bundleIdentifier]) {
                for (NSString *prodId in array) {
                    if ([prodId isEqual:[mmap objectForKey:@"prodID"]]) {
                        if ([[mmap objectForKey:@"ver"] integerValue]<[[[dict objectForKey:prodId] objectForKey:@"ver"] integerValue]) {
                            [productToDonwload addObject:[mmap objectForKey:@"prodID"]];
                        }
                    }
                }
            }
        }
         */
        
        self.maps = [self getMapsList];
        
        [self enableProducts];
        [self resortMapArray];
        
        NSSet *newProductIdentifiers = [[[NSSet alloc] initWithArray:array] autorelease];
        
        [[TubeAppIAPHelper sharedHelper] setProductIdentifiers:newProductIdentifiers];
        NSLog(@"Request products, new products ids: %@", newProductIdentifiers.description);
        [[TubeAppIAPHelper sharedHelper] requestProducts];
    }
    
    BOOL onceRestored = [[NSUserDefaults standardUserDefaults] boolForKey:@"restored"];
    
    if (!onceRestored) {
        // запрашиваем старые покупки
        [[TubeAppIAPHelper sharedHelper] restoreCompletedTransactions];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        // если вышла новая версия дефолтной карты то ее сразу закачиваем
        for (NSString *prodId in productToDonwload) {
            if ([prodId isEqual:bundleIdentifier]) {
                [self downloadProduct:prodId withBlock:downloadBlock];
            }
        }
    } else {
        for (NSString *prodId in productToDonwload ) {
            [self downloadProduct:prodId withBlock:downloadBlock];
        }
    }
    
    if(downloadBlock) downloadBlock(1, nil);
}


#pragma mark - some helpers

-(BOOL)isProductInstalled:(NSString*)mapName
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *contentIdentifier = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    
    if ([mapName isEqualToString:contentIdentifier]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults objectForKey:@"additionalContentAccessLevel"] integerValue] > 0) {
            return  YES;
        }
    }
    return [self isProductDownloaded:mapName];
}

- (BOOL) isProductDownloaded:(NSString*)mapName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mapDirPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[mapName lowercaseString]]];
    
    BOOL mapFile = NO;
    BOOL trpFile = NO;
    BOOL trpNewFile = NO;
    
    if ([[manager contentsOfDirectoryAtPath:mapDirPath error:nil] count]>0) {
        NSDirectoryEnumerator *dirEnum = [manager enumeratorAtPath:mapDirPath];
        NSString *file;
        
        while (file = [dirEnum nextObject]) {
            if ([[file pathExtension] isEqualToString: @"map"]) {
                mapFile=YES;
            } else if ([[file pathExtension] isEqualToString: @"trp"]) {
                trpFile=YES;
            } else if ([[file pathExtension] isEqualToString: @"trpnew"]) {
                trpNewFile=YES;
            }
        }
    }
    if (mapFile && (trpFile || trpNewFile)) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isProductPurchased:(NSString*)prodID
{
    //   NSMutableSet *purchasedProducts = [[TubeAppIAPHelper sharedHelper] purchasedProducts];
    //   return [purchasedProducts intersectsSet:[NSMutableSet setWithArray:[NSArray arrayWithObject:prodID]]];
    return [[NSUserDefaults standardUserDefaults] boolForKey:prodID];
}

-(BOOL)isProductAvailable:(NSString*)prodID
{
    return YES;
}

-(BOOL)isProductStatusDownloading:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"N"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusUnpacking:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"ZIP"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusInstalled:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"I"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusPurchased:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"P"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusAvailable:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID] && [[map valueForKey:@"status"] isEqual:@"V"]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isProductStatusDefault:(NSString*)prodID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([prodID isEqual:bundleIdentifier]) {
        return YES;
    }
    
    return NO;
}


-(BOOL)isProductContentPurchase:(NSString*)prodID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *purchaseId = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    
    if ([prodID isEqual:purchaseId]) {
        return YES;
    }
    
    return NO;
}

-(void)resortMapArray
{
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"sortingPosition" ascending:YES];
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.maps];
    
    [temp sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor2, nil]];
    
    self.maps = [NSArray arrayWithArray:temp];
    
    [sortDescriptor2 release];
}

-(void)enableProducts
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"status"] isEqual:@"D"]) {
            for (SKProduct *product in [TubeAppIAPHelper sharedHelper].products) {
                if ([product.productIdentifier isEqual:[map valueForKey:@"prodID"]]) {
                    [map setObject:@"V" forKey:@"status"];
                    
                    [numberFormatter setLocale:product.priceLocale];
                    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
                    
                    [map setObject:formattedString forKey:@"price"];
                }
            }
        }
    }
    
    [numberFormatter release];
}

-(NSIndexPath*)getIndexPathProdID:(NSString*)prodID
{
    int mapsC = [self.maps count];
    
    for (int i=0;i<mapsC;i++) {
        if ([[[self.maps objectAtIndex:i] objectForKey:@"prodID"] isEqual:prodID]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}


-(NSString*)getZipFileForProduct:(NSString*)prodID
{
    for (NSMutableDictionary *map in self.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID]) {
            return [map valueForKey:@"zipFile"];
        }
    }
    
    return nil;
}

@end
