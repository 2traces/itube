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
#import "StatusViewController.h"
#import <MapKit/MapKit.h>
#import "ManagedObjects.h"
#import "MainView.h"
#import "SSTheme.h"

#import <sys/utsname.h>

NSString* machineName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

NSString* DisplayStationName(NSString* stName) {
    NSString *tmpStr = [[stName stringByReplacingOccurrencesOfString:@"_" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    tmpStr = [[tmpStr stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [[tmpStr stringByReplacingOccurrencesOfString:@"." withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@implementation tubeAppDelegate

@synthesize window;
@synthesize mainViewController;
@synthesize glViewController = gl;
@synthesize cityMap;
@synthesize cityName;
@synthesize parseQueue;
@synthesize tubeSplitViewController;

-(void)showSettings
{
    if (IS_IPAD) {
        // show setting modal
        [[self mainViewController] showiPadSettingsModalView];
    } else {
        [[[self mainViewController] view] showSettings];
    }
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

-(void)setUserGeoPosition:(CGPoint)userGeoPosition
{
    userGeoP = userGeoPosition;
    [gl setUserGeoPosition:userGeoP];
    MainView *mv = (MainView*)mainViewController.view;
    [mv setGeoPosition:userGeoPosition withZoom:mv.containerView.zoomScale];
}

-(CGPoint)userGeoPosition
{
    return userGeoP;
}

-(void)errorWithGeoLocation
{
    [gl errorWithGeoLocation];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [SSThemeManager customizeAppAppearance];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    gl = [[GlViewController alloc] initWithNibName:@"GlViewController" bundle:[NSBundle mainBundle]];
	MainViewController *aController = [[MainViewController alloc] init];
	self.mainViewController = aController;
	[aController release];
    
    CityMap *cm = [[CityMap alloc] init];
    NSString *mapName =[self nameCurrentMap];
    [cm loadMap:mapName];
    
    self.cityMap = cm;
    [cm release];
    
    self.cityName= [self nameCurrentCity];
    
    // Override point for customization after application launch.
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[TubeAppIAPHelper sharedHelper]];
    
    self.window.frame = [[UIScreen mainScreen] bounds];
    
    if (IS_IPAD) {
        TubeSplitViewController *splitController = [[TubeSplitViewController alloc] init];
        self.tubeSplitViewController=splitController;
        splitController.mainViewController = self.mainViewController;
        [window addSubview:[splitController view]];
        [window setRootViewController:splitController];
        navController = splitController.navigationController;
        [splitController release];
        [window makeKeyAndVisible];
    } else {
        navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
        navController.navigationBarHidden = YES;
        mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
        [window addSubview:[mainViewController view]];
        [window setRootViewController:navController];
        [window makeKeyAndVisible];
    }
}

- (void)awakeFromNib
{
    NSString *      initialDefaultsPath;
    NSDictionary *  initialDefaults;

    initialDefaultsPath = [[NSBundle mainBundle] pathForResource:@"InitialDefaults" ofType:@"plist"];
    initialDefaults = [NSDictionary dictionaryWithContentsOfFile:initialDefaultsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
    
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"launches"])
	{
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"launches"]==10) {
            
            [self askForRate];
            
        } else if  ([[NSUserDefaults standardUserDefaults] integerForKey:@"launches"]<10) {
            
            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"launches"]+1 forKey:@"launches"];
            [prefs synchronize];
        }
	} else {
        NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:1 forKey:@"launches"];
        [prefs synchronize];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag==1) {
        if (buttonIndex == 0) {
            
            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger:40 forKey:@"launches"];
            [prefs synchronize];
            
        } else if (buttonIndex == 1) {
            
            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger:40 forKey:@"launches"];
            [prefs synchronize];
            
            NSString *address = [[NSUserDefaults standardUserDefaults] objectForKey:@"RateMeURL"];
            if (address) {
                NSURL *url = [NSURL URLWithString:address];
                [[UIApplication sharedApplication] openURL:url];
            }
            
        } else if (buttonIndex == 2) {
            
            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger:1 forKey:@"launches"];
            [prefs synchronize];
        } else if (buttonIndex == 3) {
            
            [self showMailComposer:nil];
        }
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
    NSString *cancelButtonLabel = NSLocalizedString(@"No, Thanks", @"No, Thanks");
    NSString *remindButtonLabel = NSLocalizedString(@"Remind Me Later", @"Remind Me Later");
    NSString *rateButtonLabel = NSLocalizedString(@"Rate It Now", @"Rate It Now");
    NSString *mailButtonLabel = NSLocalizedString(@"Drop Us An EMail", @"Drop Us An EMail");
    NSString *rateLabel = [NSString stringWithFormat:NSLocalizedString(@"Rate", @"Rate"),[self getAppName]];
    NSString *rateMessageLabel = [NSString stringWithFormat:NSLocalizedString(@"RateMessage", @"RateMessage"),[self getAppName]];
    
    UIAlertView *buttonAlert = [[UIAlertView alloc] initWithTitle:rateLabel message:rateMessageLabel delegate:self cancelButtonTitle:cancelButtonLabel otherButtonTitles:rateButtonLabel, nil];
    
    buttonAlert.tag=1;
    
    [buttonAlert addButtonWithTitle:remindButtonLabel];
    [buttonAlert addButtonWithTitle:mailButtonLabel];
    [buttonAlert show];
    [buttonAlert release];
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

-(CGRect)getDefaultSearchBox
{
    [self loadConfig];
    NSString *searchBox = [config objectForKey:@"searchBox"];
    if(nil != searchBox && searchBox.length > 0) {
        NSArray *coords = [searchBox componentsSeparatedByString:@";"];
        if(coords.count >= 4) {
            CGRect r;
            r.origin.x = [[coords objectAtIndex:0] floatValue];
            r.origin.y = [[coords objectAtIndex:1] floatValue];
            r.size.width = [[coords objectAtIndex:2] floatValue] - r.origin.x;
            r.size.height = [[coords objectAtIndex:3] floatValue] - r.origin.y;
            
            if(r.size.width < 0) {
                r.origin.x += r.size.width;
                r.size.width = -r.size.width;
            }
            if(r.size.height < 0) {
                r.origin.y += r.size.height;
                r.size.height = -r.size.height;
            }
            
            return r;
        }
    }
    return CGRectZero;
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
    CGRect pos;
    NSMutableArray *data = [NSMutableArray array];
    MainView *mv = (MainView*)mainViewController.view;
    pos = [mv getMapVisibleRect];
    pos = [cityMap getGeoCoordsForRect:pos coordinates:data];
    [navController pushViewController:gl animated:YES];
    [gl setGeoPosition:pos];
    if([data count] > 0) {
        [gl setStationsPosition:data withMarks:!CGRectIsNull(cityMap.activeExtent)];
    }
    if (IS_IPAD) {
        [tubeSplitViewController hideTopViewAnimated];
        [tubeSplitViewController hideLeftView];
    }
    [gl showDownloadPopup];
}

-(void)showMetroMap
{
    [navController popToRootViewControllerAnimated:YES];
    if (IS_IPAD) {
        [tubeSplitViewController showTopViewAnimated];
    }
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
            [picker setToRecipients:[NSArray arrayWithObject:[NSString stringWithFormat:@"fusio@yandex.ru"]]];
            [self.mainViewController presentModalViewController:picker animated:YES];
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
    
//    if (error) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't send email" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alertView show];
//        [alertView release];
//
//        NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
//        
//        [self.mainViewController dismissModalViewControllerAnimated:YES];
//        return;
//    }
    
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
    [self.mainViewController dismissModalViewControllerAnimated:YES];
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

- (BOOL)isIPodTouch4thGen {
    NSString *device = machineName();
    if ([device rangeOfString:@"iPod4" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    return NO;
}


- (void)dealloc {
    [gl release];
    [mainViewController release];
    [window release];
    [cityMap release];
    [super dealloc];
}

@end
