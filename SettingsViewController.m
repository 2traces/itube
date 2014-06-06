//
//  SettingsViewController.m
//  tube
//
//  Created by sergey on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "CityCell.h"
#import "MyNavigationBar.h"
#import "CityMap.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "TubeAppIAPHelper.h"
#import "DemoMapViewController.h"
#import "SSTheme.h"
#import "CustomPhotoViewerViewController.h"
#import "LCUtil.h"
#import "RectObject.h"
#import "Reachability.h"

@implementation SettingsViewController

@synthesize imagesScrollView;
@synthesize selectedPath;
@synthesize delegate;
@synthesize timer;
@synthesize progressArrows;
@synthesize languages;
@synthesize feedback;
@synthesize purchaseIndex;
@synthesize buyAllButton;
@synthesize buyButton;
@synthesize reloadButton;
@synthesize paging;
@synthesize quitButton;
@synthesize subviewPositions;
@synthesize fullProductPurchased;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.subviewPositions = [NSMutableDictionary dictionary];
        tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.languages=appdelegate.cityMap.languages;
        
        int currentLanguageIndex = [[MHelper sharedHelper] languageIndex];
        if (currentLanguageIndex == 2 && [self.languages count] == 2) {
            selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:0],[languages objectAtIndex:1], nil];
        } else {
            selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:currentLanguageIndex], nil];
        }

        self.feedback = [NSArray arrayWithObjects:NSLocalizedString(@"FeedbackRate",@"FeedbackRate"),NSLocalizedString(@"FeedbackMail",@"FeedbackMail"),NSLocalizedString(@"FeedbackTell",@"FeedbackTell"), nil];
        
        isFirstTime=YES;
    }
    return self;
}

-(void)checkFullProductInitialState{
    NSDictionary *map = [tubeAppDelegate.instance.maps objectAtIndex:FULL_PRODUCT_INDEX];
    NSString *prodID = [map objectForKey:@"prodID"];
    self.fullProductPurchased = ([[NSUserDefaults standardUserDefaults] integerForKey:@"additionalContentAccessLevel"] == 1) || [tubeAppDelegate.instance isProductStatusPurchased:prodID];
    if(self.fullProductPurchased) {
        NSLog(@"Full product is puchased");
        [self setBuyButtonDownloadMapState];
    }else{
        NSLog(@"Full product is not purchased");
    }
    if ([tubeAppDelegate.instance isProductDownloaded:[map objectForKey: @"prodID"]]){
        [self setBuyButtonDownloadCompleteState];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)resortMapArray
{
    [tubeAppDelegate.instance resortMapArray];
    [self setCurrentMapSelectedPath];
}

#pragma mark - View lifecycle

- (void)mapChanged:(NSNotification*)note
{
    tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.languages=appdelegate.cityMap.languages;
    
    int currentLanguageIndex = [[MHelper sharedHelper] languageIndex];
    if (currentLanguageIndex == 2 && [self.languages count] == 2) {
        selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:0],[languages objectAtIndex:1], nil];
    } else {
        selectedLanguages = [[NSMutableArray alloc] initWithObjects:[languages objectAtIndex:currentLanguageIndex], nil];
    }
}

- (void) loadImages{
    tubeAppDelegate *appdelegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *configPath = [NSString stringWithFormat:@"%@/settings_images.json", appdelegate.mapDirectoryPath];
    NSData *jsonData = [NSData dataWithContentsOfFile:configPath];
    self.imagesScrollView.delegate = self;
    self.imagesScrollView.showsHorizontalScrollIndicator = NO;
    if (jsonData) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"Error reading JSON: %@, %@", [error localizedFailureReason], [error localizedDescription]);
        }
        NSArray *imagePaths = [json objectForKey:@"images"];
        CGFloat parentWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat imageHeight;
        CGFloat yOffset = 0;
        if (IS_IPAD) {
            imageHeight = 1496 * parentWidth / 1536;
        }else{
            if(appdelegate.isIPHONE5){
                imageHeight = 393;
            }else{
                imageHeight = 393;
                yOffset = -85;
            }
        }
        self.imagesScrollView.pagingEnabled = YES;
        self.imagesScrollView.frame = CGRectMake(0, yOffset, parentWidth, imageHeight);
        self.imagesScrollView.contentSize = CGSizeMake(parentWidth * imagePaths.count, imageHeight);
        self.paging.numberOfPages = imagePaths.count;
        if(imagePaths){
            for (int i = 0; i < imagePaths.count; i++) {
                NSString *imagePath = [imagePaths objectAtIndex:i];
                NSString *localizedPath = [LCUtil getLocalizedPhotoPathWithMapDirectory:appdelegate.mapDirectoryPath withPath:imagePath iphone5:appdelegate.isIPHONE5];
                CGFloat xOffset = i * parentWidth;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, 0, parentWidth, imageHeight)];
                UIImage *image = [UIImage imageWithContentsOfFile:localizedPath];
                imageView.image = image;
                [self.imagesScrollView addSubview:imageView];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:kMapChanged object:nil];
    [TubeAppIAPHelper sharedHelper];
    [self loadImages];
    [self rememberPositions];
    [self checkFullProductInitialState];
}

-(void)rememberPositions{
    int tag = 0;
    for (UIView *subview in self.view.subviews){
        tag += 1;
        subview.tag = tag;
        RectObject *rect = [RectObject rectWithCGRect:subview.frame];
        [self.subviewPositions setObject:rect forKey:[NSNumber numberWithInt: tag]];
    }
}

- (IBAction)buyFullProduct:(id)sender{
    [self buyMap:[tubeAppDelegate.instance.maps objectAtIndex:FULL_PRODUCT_INDEX]];
}

- (void) resetPositions{
    for (UIView *subview in self.view.subviews){
        RectObject *rect = [self.subviewPositions objectForKey:[NSNumber numberWithInt: subview.tag]];
        if (rect != nil) {
            if(subview.autoresizingMask == 13){
                CGFloat delta = [UIScreen mainScreen].bounds.size.height - 480;
                subview.frame = CGRectMake(rect.rect.origin.x, rect.rect.origin.y + delta,
                                           rect.rect.size.width, rect.rect.size.height);
            }else{
                subview.frame = rect.rect;
            }
        }
    }
}

-(void)setCurrentMapSelectedPath
{
    int mapsC = [tubeAppDelegate.instance.maps count];
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    
    for (int i=0;i<mapsC;i++) {
        if ([[[tubeAppDelegate.instance.maps objectAtIndex:i] objectForKey:@"filename"] isEqual:currentMap]) {
            self.selectedPath=[NSIndexPath indexPathForRow:i inSection:0];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [tubeAppDelegate.instance processPurchases];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }    
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMapChanged object:nil];
    
    [timer release];
    [progressArrows release];
    self.imagesScrollView.delegate = nil;
    [imagesScrollView release];
    
    [selectedLanguages release];
    [selectedPath release];
    delegate = nil;
    [super dealloc];
}

-(void)setBuyButtonDownloadingState:(NSIndexPath*)path
{
    self.buyButton.enabled = NO;
    NSDictionary *map = [tubeAppDelegate.instance.maps objectAtIndex:path.row];
    CGFloat part = (float)[[map objectForKey:@"progressPart"] longValue] / (1024.0f*1024.0f);
    CGFloat whole = (float)[[map objectForKey:@"progressWhole"] longValue] / (1024.0f*1024.0f);
    NSString *title = [NSString stringWithFormat:@"%@... %.1f/%.1f Mb", NSLocalizedString(@"Downloading", @"Downloading"), part, whole];
    [self.buyButton setTitle:title forState:UIControlStateDisabled];
}

- (void)setBuyButtonDownloadMapState{
    [self.buyButton setTitle:NSLocalizedString(@"DownloadMap", @"DownloadMap") forState:UIControlStateNormal];
    self.buyButton.enabled = YES;
    UIImage *image;
    if (IS_IPAD) {
        image = [UIImage imageNamed:@"download_map"];
    }else{
        image = [UIImage imageNamed:@"download_map_iphone"];
    }
    [self.buyButton setBackgroundImage:image forState:UIControlStateNormal];
}
         
- (void)setBuyButtonDownloadCompleteState{
    [self.buyButton setTitle:NSLocalizedString(@"DownloadComplete", @"DownloadComplete") forState:UIControlStateDisabled];
    self.buyButton.enabled = NO;
}


- (void)setBuyButtonUnpackingState{
    [self.buyButton setTitle:NSLocalizedString(@"Unpacking", @"Unpacking") forState:UIControlStateDisabled];
    self.buyButton.enabled = NO;
}

- (void)setBuyButtonUnpackingState:(NSIndexPath*)path{
    [self setBuyButtonUnpackingState];
}

/*
-(IBAction)updatePressed:(id)sender
{
    DownloadServer *server = [[[DownloadServer alloc] init] autorelease];
    server.listener=self;
    
    [servers addObject:server];
    
    NSString *bundleName = [NSString stringWithFormat:@"%@.plist",[[NSBundle mainBundle] bundleIdentifier]];
    requested_file_type=plist_;
    [server loadFileAtURL:bundleName];
    [self spinLayer:progressArrows.layer duration:2.0 direction:1];
    [self startTimer];
}
 */

-(void)buyMap:(NSDictionary*)map
{
    NSString *prodID = [map valueForKey:@"prodID"];
    NSLog(@"Process prodID %@", prodID);
    if ([tubeAppDelegate.instance isProductStatusAvailable:prodID]) {
        [tubeAppDelegate.instance purchaseProduct:prodID];
    } else if ([tubeAppDelegate.instance isProductStatusPurchased:prodID]) {
        [tubeAppDelegate.instance downloadProduct:prodID withBlock:^(int result, NSString* prodID) {
        }];
    }
}

- (NetworkStatus) connectionStatus
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
               
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // if target host is not reachable
        return NotReachable;
    }
    
    NetworkStatus retVal = NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = ReachableViaWiFi;
    }
    
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = ReachableViaWWAN;
    }
    return retVal;
}

-(IBAction)openAppStoreLink:(NSDictionary*)map
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[map objectForKey:@"appstore_link"]]];
}

-(NSString*)getMapNameForProduct:(NSString*)prodID
{
    for (NSMutableDictionary *map in tubeAppDelegate.instance.maps) {
        if ([[map valueForKey:@"prodID"] isEqual:prodID]) {
            return [map valueForKey:@"filename"];
        }
    }
    
    return nil;
}


- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [self timerFired:self.timer];
}

- (void)stopTimer {
    [timer invalidate];
}

-(void)timerFired:(NSTimer *)timer
{
    //[self spinLayer:progressArrows.layer duration:2.0 direction:1];
    for (NSDictionary *map in tubeAppDelegate.instance.maps) {
        if([map[@"status"] isEqualToString:@"N"]) {
            [self setBuyButtonDownloadingState:[tubeAppDelegate.instance getIndexPathProdID:map[@"prodID"]]];
        } else if([map[@"status"] isEqualToString:@"ZIP"]) {
            [self setBuyButtonUnpackingState:[tubeAppDelegate.instance getIndexPathProdID:map[@"prodID"]]];
        } else if([map[@"status"] isEqualToString:@"P"]) {
            [self setBuyButtonDownloadMapState];
        } else if([map[@"status"] isEqualToString:@"I"]) {
            [self setBuyButtonDownloadCompleteState];
        }
    }
}

- (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration
        direction:(int)direction
{
    CABasicAnimation* rotationAnimation;
    
    // Rotate about the z axis
    rotationAnimation = 
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // Rotate 360 degress, in direction specified
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * direction];
    
    // Perform the rotation over this many seconds
    rotationAnimation.duration = inDuration;
    
    // Set the pacing of the animation
    rotationAnimation.timingFunction = 
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Add animation to the layer and make it so
    [inLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)returnWithPurchase:(NSString *)prodID
{
    [self.navigationController popViewControllerAnimated:YES];
    [tubeAppDelegate.instance purchaseProduct:prodID];
}

#pragma mark - in-app purchase

- (void)productsLoaded:(NSNotification *)notification
{
    [self resortMapArray];
}

- (void)productPurchased:(NSNotification *)notification
{
    [self setBuyButtonDownloadMapState];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = [[UIScreen mainScreen] bounds].size.width;
    int page = floor((self.imagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.paging.currentPage = page;
}

- (void)viewDidAppear:(BOOL)animated{
    [self resetPositions];
    [self startTimer];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.imagesScrollView.frame.size.width * self.paging.currentPage;
    frame.origin.y = 0;
    frame.size = self.imagesScrollView.frame.size;
    [self.imagesScrollView scrollRectToVisible:frame animated:YES];
}

-(IBAction)donePressed:(id)sender 
{
    [self quitController];
}

- (void)quitController{
    if ([languages count] > 1) {
        
        if ([selectedLanguages count]>1) {
            [[MHelper sharedHelper] saveLanguageIndex:2];
        } else {
            [[MHelper sharedHelper] saveLanguageIndex:[languages indexOfObject:[selectedLanguages lastObject]]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLangChanged object:nil];
    }
    [delegate donePressed];
}


#pragma mark - Mail methods

// Displays an email composition interface inside the app // and populates all the Mail fields.
-(void)showMailComposer:(NSArray*)recipient subject:(NSString*)subject body:(NSString*)body
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        // Test to ensure that device is configured for sending emails.
        if ([mailClass canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:subject];
            [picker setToRecipients:recipient];
            [picker setMessageBody:body isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
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
    [buyAllButton release];
    [buyButton release];
    [reloadButton release];
    [paging release];
    [quitButton release];
    [subviewPositions release];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
