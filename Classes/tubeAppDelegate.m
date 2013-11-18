//
//  tubeAppDelegate.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "tubeAppDelegate.h"
#import "TubeSplitViewController.h"
#import <MapKit/MapKit.h>
#import "ManagedObjects.h"
#import "NavigationViewController.h"
#import "RatePopupViewController.h"
#import "SpotsListViewController.h"
#import "NavBarViewController.h"

NSString* DisplayStationName(NSString* stName) {
    NSString *tmpStr = [[stName stringByReplacingOccurrencesOfString:@"_" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    tmpStr = [[tmpStr stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [[tmpStr stringByReplacingOccurrencesOfString:@"." withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@implementation tubeAppDelegate

@synthesize window;
@synthesize glViewController = gl;
@synthesize cityName;
@synthesize parseQueue;
@synthesize navigationViewController;
@synthesize mapDirectoryPath;
@synthesize shouldShowRateScreen;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

-(void)setUserGeoPosition:(CGPoint)userGeoPosition
{
    BOOL firstSet = CGPointEqualToPoint(userGeoP, CGPointZero);
    userGeoP = userGeoPosition;
    gl.followUserGPS = firstSet;
    [gl setUserGeoPosition:userGeoP];
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
}

- (void)placeRemovedFromFavorites:(MPlace*)place {
}

- (void)centerMapOnPlace:(MPlace*)place {
    [self.navigationViewController centerMapOnPlace:place];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    gl = [[GlViewController alloc] initWithNibName:@"GlViewController" bundle:[NSBundle mainBundle]];

    
    self.navigationViewController = [[[NavigationViewController alloc] initWithNibName:@"NavigationViewController" bundle:[NSBundle mainBundle] glViewController:gl] autorelease];
    
    self.cityName= [self nameCurrentCity];
    
    // Override point for customization after application launch.
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:[TubeAppIAPHelper sharedHelper]];
    
    self.parseQueue = [[NSOperationQueue alloc] init];
    
    self.window.frame = [[UIScreen mainScreen] bounds];
    
    if (IS_IPAD) {
        TubeSplitViewController *splitController = [[TubeSplitViewController alloc] init];
        splitController.glViewController = gl;
        


        splitController.mapViewController = self.navigationViewController;
        
        NavBarViewController *nc = [[[NavBarViewController alloc] initWithNibName:@"NavBarViewController" bundle:[NSBundle mainBundle]] autorelease];
        
//        UIViewController *tvc = [[UIViewController alloc] init];
//        tvc.view.frame = vc.view.frame;
//        [tvc.view addSubview:nvc.view];
        
        splitController.listViewController = nc;
        
        [window addSubview:[splitController view]];
        
        [window setRootViewController:splitController];
        [window makeKeyAndVisible];
        
//        [splitController showLeftView];
    } else {
//        navController = [[UINavigationController alloc] initWithRootViewController:self.navigationViewController];
//        navController.navigationBarHidden = YES;
        gl.view.frame = self.navigationViewController.view.frame = [UIScreen mainScreen].applicationFrame;
//        CGRect mainViewFrame = gl.view.frame;
//        mainViewFrame.origin.y = 0;
//        gl.view.frame = mainViewFrame;
        navController.view.layer.cornerRadius = 5;
        window.layer.cornerRadius = 5;
        [window addSubview:self.navigationViewController.view];
        [window setRootViewController:self.navigationViewController];
        [window makeKeyAndVisible];
    }
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor lightGrayColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor lightGrayColor]];
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
    
    if (alertView.tag=1) {
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


- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (IS_IPAD)
        return UIInterfaceOrientationMaskAll ;//| UIInterfaceOrientationMaskPortraitUpsideDown;
    else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
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
                    label.lineBreakMode = UILineBreakModeWordWrap;
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

- (NSString*)getAppStoreUrl {
    [self loadConfig];
    return APPSTORE_URL_FULL;
}

- (NSString*)getRateUrl {
    [self loadConfig];
    return APPSTORE_URL_FULL;

}

- (NSArray*)getTeasersForMaps {
    return @[];
}

-(NSString*)getDefaultMapName
{
    [self loadConfig];
    NSString *filename = [config objectForKey:@"filename"];
    
    NSString *mapFileName =[NSString stringWithString:filename];

    return mapFileName;
}

-(NSString*)getDefaultCityName
{
    [self loadConfig];
    return [NSString stringWithString:[config objectForKey:@"name"]];
}

-(NSString*)getDefaultMapUrl1
{
    [self loadConfig];
    NSString *mapUrl =[NSString stringWithString:[config objectForKey:@"url1"]];
    
    return mapUrl;
}

-(NSString*)getDefaultMapUrl2
{
    [self loadConfig];
    NSString *mapUrl =[NSString stringWithString:[config objectForKey:@"url2"]];
    return mapUrl;
}

-(void)loadConfig
{
    if(nil == config) {
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
        config = [dict objectForKey:bundleIdentifier];
        if(nil == config)
            config = [dict objectForKey:@"default"];
        [config retain];
        [dict release];
    }
}

#pragma mark - manage maps

-(void)showRasterMap
{
    [self.navigationViewController showRasterMap];
    [gl removeAllPins];
    //[gl setGeoPosition:pos];
}

-(void)switchMapMode
{
    [self showRasterMap];
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
            [self.navigationViewController presentModalViewController:picker animated:YES];
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
    [self.navigationViewController dismissModalViewControllerAnimated:YES];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
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
    
}


- (void)dealloc {
    [gl release];
    [window release];
    [super dealloc];
}


-(void)selectObject:(WifiObject *)ob byPanel:(BOOL)panel
{
    if(panel) {
#ifdef SPOTS_FREE
        GlViewController *gl = self.glViewController;
        CGFloat distance = [gl calcGeoDistanceFrom:ob.geoP to:self.userGeoPosition];
        if (distance > 0.15f) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Free version heading", @"") message:NSLocalizedString(@"Free version message 1", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Free version appstore button", @""), nil];
            [alertView show];
            [alertView release];
            return;
        }
#endif
        // show selected object on GUI
        UIViewController *root = self.window.rootViewController;
        if ([root isKindOfClass:[NavigationViewController class]]) {
            [((NavigationViewController*)root) showSpotsListWithObject:ob];
        }
        else if ([root isKindOfClass:[TubeSplitViewController class]]) {
            [((TubeSplitViewController*)root) showInfoForObject:ob];
        }
    }
}

-(void)selectCluster:(Cluster *)cl byPanel:(BOOL)panel
{
    if(panel) {
        // show selected objects on GUI
        UIViewController *root = self.window.rootViewController;
        if ([root isKindOfClass:[NavigationViewController class]]) {
            
        }
        else if ([root isKindOfClass:[TubeSplitViewController class]]) {
            [((TubeSplitViewController*)root) showLeftView];
        }
    }
}

@end
