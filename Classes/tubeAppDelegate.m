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

@implementation tubeAppDelegate

@synthesize window;
@synthesize mainViewController;
@synthesize cityMap;
@synthesize cityName;
@synthesize parseQueue;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
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
    
    if (IS_IPAD) {
        TubeSplitViewController *splitController = [[TubeSplitViewController alloc] init];
        splitController.mainViewController = self.mainViewController;
        [window addSubview:[splitController view]];
        [window makeKeyAndVisible];
    } else {
        mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
        [window addSubview:[mainViewController view]];
        [window makeKeyAndVisible];
    }
}

- (void)awakeFromNib
{
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
    
    if (alertView.tag=1) {
        if (buttonIndex == 0) {
            
            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger:40 forKey:@"launches"];
            [prefs synchronize];
            
        } else if (buttonIndex == 1) {
            
            NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger:40 forKey:@"launches"];
            [prefs synchronize];
            
            NSURL *url = [NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=513581498"]; 
            
            [[UIApplication sharedApplication] openURL:url];
            
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
    if (alertView.tag=1) {
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
    NSString *mapFileName =[NSString stringWithString:[[dict objectForKey:@"default"] objectForKey:@"filename"]];
    [dict release];
    
    return mapFileName;
}

-(NSString*)getDefaultCityName
{
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
    NSString *cityFileName =[NSString stringWithString:[[dict objectForKey:@"default"] objectForKey:@"name"]];
    [dict release];
    
    return cityFileName;
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


- (void)dealloc {
    [mainViewController release];
    [window release];
    [cityMap release];
    [super dealloc];
}

@end
