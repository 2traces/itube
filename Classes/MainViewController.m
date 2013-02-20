//
//  MainViewController.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "SelectingTabBarViewController.h"
#import "ManagedObjects.h"
#import "TopTwoStationsView.h"
#import "FastAccessTableViewController.h"
#import "tubeAppDelegate.h"
#import "PathBarView.h"
#import "PathDrawView.h"
#import "PathDrawVertView.h"
#import "TubeAppIAPHelper.h"
#import "UIColor-enhanced.h"
#import "LeftiPadPathViewController.h"
#import "CustomPopoverBackgroundView.h"
#import "StatusViewController.h"

#define FromStation 0
#define ToStation 1

@interface UIPopoverController(removeInnerShadow)

- (void)removeInnerShadow;
- (void)presentPopoverWithoutInnerShadowFromRect:(CGRect)rect
                                          inView:(UIView *)view
                        permittedArrowDirections:(UIPopoverArrowDirection)direction
                                        animated:(BOOL)animated;

- (void)presentPopoverWithoutInnerShadowFromBarButtonItem:(UIBarButtonItem *)item
                                 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                                                 animated:(BOOL)animated;

@end

@implementation UIPopoverController(removeInnerShadow)

- (void)presentPopoverWithoutInnerShadowFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)direction animated:(BOOL)animated
{
    [self presentPopoverFromRect:rect inView:view permittedArrowDirections:direction animated:animated];
    [self removeInnerShadow];
}

- (void)presentPopoverWithoutInnerShadowFromBarButtonItem:(UIBarButtonItem *)item
                                 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                                                 animated:(BOOL)animated
{
    [self presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
    [self removeInnerShadow];
}

- (void)removeInnerShadow
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    for (UIView *windowSubView in window.subviews)
    {
        if ([NSStringFromClass([windowSubView class]) isEqualToString:@"UIDimmingView"])
        {
            for (UIView *dimmingViewSubviews in windowSubView.subviews)
            {
                for (UIView *popoverSubview in dimmingViewSubviews.subviews)
                {
                    if([NSStringFromClass([popoverSubview class]) isEqualToString:@"UIView"])
                    {
                        for (UIView *subviewA in popoverSubview.subviews)
                        {
                            if ([NSStringFromClass([subviewA class]) isEqualToString:@"UILayoutContainerView"])
                            {
                                subviewA.layer.cornerRadius = 7;
                                subviewA.layer.borderColor = [UIColor grayColor].CGColor;
                                subviewA.layer.borderWidth = 0.0f;
                            }
                            
                            for (UIView *subviewB in subviewA.subviews)
                            {
                                if ([NSStringFromClass([subviewB class]) isEqualToString:@"UIImageView"] )
                                {
                                    [subviewB removeFromSuperview];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@end

@implementation MainViewController

@synthesize fromStation;
@synthesize toStation;
@synthesize route;
@synthesize stationsView;
@synthesize currentSelection;
@synthesize horizontalPathesScrollView;
@synthesize pathScrollView;
@synthesize timer;
@synthesize spltViewController;
@synthesize statusViewController;
@synthesize changeViewButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	DLog(@"initWithNibName");
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Stop holding onto the popover
    popover = nil;
    [self returnFromSelectionFastAccess:nil];
    
    if (currentSelection==0) {
        [stationsView.firstStation resignFirstResponder];
    } else {
        [stationsView.secondStation resignFirstResponder];
    }
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (!IS_IPAD) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
    }
    
    [(MainView*)self.view viewInit:self];
    
    if (!IS_IPAD) {
        NSString *url = [self getStatusInfoURL];
        if (url) {
            [self addStatusView:url];
        }
    }
    
    TopTwoStationsView *twoStationsView = [[TopTwoStationsView alloc] init];
    self.stationsView = twoStationsView;
    self.stationsView.navigationViewController = self.navigationViewController;
    [(MainView*)self.view addSubview:twoStationsView];
    [twoStationsView release];
    
    UISwipeGestureRecognizer *swipeRecognizerD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [swipeRecognizerD setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.stationsView addGestureRecognizer:swipeRecognizerD];
    [swipeRecognizerD release];
    
    [self performSelector:@selector(refreshInApp) withObject:nil afterDelay:0.2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:@"kLangChanged" object:nil];
    
}


- (void) moveModeButtonToFullScreen {
    MainView *view = self.view;
    //self.horizontalPathesScrollView.hidden = NO;
    [view moveModeButtonToFullScreen];
}

- (void) moveModeButtonToCutScreen {
    MainView *view = self.view;
    self.horizontalPathesScrollView.hidden = YES;
    [view moveModeButtonToCutScreen];
    
}

-(void)viewWillAppear:(BOOL)animated
{
}

// --- status lines

-(NSString*)getStatusInfoURL
{
    NSString *url;
    
    url = nil;
    
    NSString *mainURL=nil;
    NSString *altURL=nil;
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *mapIDs = [dict allKeys];
    for (NSString* mapID in mapIDs) {
        NSDictionary *map = [dict objectForKey:mapID];
        if ([[map objectForKey:@"filename"] isEqual:currentMap]) {
            if ([map objectForKey:@"statusURL"]) {
                mainURL = [NSString stringWithString:[map objectForKey:@"statusURL"]];
            }
            if ([map objectForKey:@"altStatusURL"]) {
                altURL = [NSString stringWithString:[map objectForKey:@"altStatusURL"]];
            }
            
        }
    }
    
    [dict release];
    
    if (!altURL) {
        url=mainURL;
    } else {
        NSString *composedLocalURL = [NSString stringWithFormat:@"http://metro.dim0xff.com/%@/data_%@.txt",[[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName],[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
        //        NSLog(@"%@",composedLocalURL);
        if ([mainURL isEqualToString:composedLocalURL]) {
            url = mainURL;
        } else {
            url = altURL;
        }
    }
    
    return url;
}


-(void)addStatusView:(NSString*)url
{
    StatusViewController *statusView = [[StatusViewController alloc] init];

    if (self.stationsView) {
        [(MainView*)self.view insertSubview:statusView.view belowSubview:self.stationsView];
    } else {
        [(MainView*)self.view addSubview:statusView.view];
    }
    
    self.statusViewController=statusView;
    self.statusViewController.infoURL=url;
    [self.statusViewController recieveStatusInfo];
    [statusView release];
}

-(void)handleSwipeDown:(UISwipeGestureRecognizer*)recognizer
{
    if (!self.horizontalPathesScrollView && self.statusViewController) {
        [StatusViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInitialSizeView) object:nil];
        [self.statusViewController showFullSizeView];
    }
}

- (void)showPurchases:(int)index
{
    if (IS_IPAD)
        [self showiPadPurchases:index];
    else
    {
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate.navigationViewController showPurchases:index];
    }
}
// --- status lines

-(void)refreshInApp
{
    [[TubeAppIAPHelper sharedHelper] requestProducts];
}

-(void)changeMapTo:(NSString*)newMap andCity:(NSString*)cityName
{
    [stationsView resetBothStations];
    [self.spltViewController hideLeftView];
    
    MHelper *helper = [MHelper sharedHelper];
    [helper saveBookmarkFile];
    [helper saveHistoryFile];
    
    [[MHelper sharedHelper] clearContent];
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    // FIXME !!! some classes don't release city map
    [(MainView*)self.view setCityMap:nil];
    [appDelegate.cityMap release];
    appDelegate.cityMap = nil;
    
    CityMap *cm = [[[CityMap alloc] init] autorelease];
    [cm loadMap:newMap];
    
    [(MainView*)self.view setCityMap:cm];
    appDelegate.cityMap=cm;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMapChanged object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newMap forKey:@"current_map"];
    [defaults setObject:cityName forKey:@"current_city"];
    [defaults synchronize];
    
    if (IS_IPAD) {
        [self.spltViewController changeStatusView];
    } else {
        [self.statusViewController.view removeFromSuperview];
        NSString *url=[self getStatusInfoURL];
        if (url) {
            [self addStatusView:url];            
        }
        
    }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if (IS_IPAD) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

//- (BOOL)shouldAutorotate {
//        return YES;
//}
//
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
//}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (IS_IPAD) {
        
    } else {
        MainView *mainView = (MainView*)self.view;
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            [mainView changedToLandscape:NO];
            self.stationsView.hidden=NO;
            self.horizontalPathesScrollView.hidden=NO;
            self.changeViewButton.hidden=NO;
            
            tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
            if ([[[delegate cityMap] activePath] count]>0) {
                if (!([[[delegate cityMap] activePath] count]==1 && [[[[delegate cityMap] activePath] objectAtIndex:0] isKindOfClass:[Transfer class]])) {
                    [stationsView transitToPathView];

                    [self showHorizontalPathesScrollView];
                }
            }
            
            [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 44.0, 320.0, 61.0)];
            
        } else {
            [mainView changedToLandscape:YES];
            self.stationsView.hidden=YES;
            self.horizontalPathesScrollView.hidden=YES;
            self.changeViewButton.hidden=YES;
            if (self.pathScrollView) {
                [self removeVerticalPathView];
            }
            
            if (self.statusViewController.isShown) {
                [self.statusViewController hideFullSizeView];
            }
            tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
            if ([appDelegate isIPHONE5]) {
                [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 0.0, 568.0, 61.0)];
            } else {
                [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 0.0, 480.0, 61.0)];
            }
            
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (IS_IPAD) {
        if (popover) {
            [popover dismissPopoverAnimated:YES];
            [popover.delegate popoverControllerDidDismissPopover:popover];
        }
    } else {
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            if ([appDelegate isIPHONE5]) {
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 0, 568, 320-20)];
            } else {
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 0, 480, 320-20)];
            }
        } else {
            if ([appDelegate isIPHONE5]) {
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 40, 320, 568-60)];
            } else {
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 40, 320, 480-60)];
            }
        }
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        [self dismissModalViewControllerAnimated:YES];
        
        self.stationsView.hidden=YES;
        self.horizontalPathesScrollView.hidden=YES;
        self.changeViewButton.hidden=YES;
        if (self.pathScrollView) {
            [self removeVerticalPathView];
        }
        
        if (self.statusViewController.isShown) {
            [self.statusViewController hideFullSizeView];
        }
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ([appDelegate isIPHONE5]) {
            [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 0.0, 568.0, 61.0)];
            [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 0, 568, 320-20)];
        } else {
            [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 0.0, 480.0, 61.0)];
            [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 0, 480, 320-20)];
        }
        
        isShowingLandscapeView = YES;
    }
    else if ((deviceOrientation==UIDeviceOrientationPortrait) &&
             isShowingLandscapeView)
    {
        self.stationsView.hidden=NO;
        self.horizontalPathesScrollView.hidden=NO;
        self.changeViewButton.hidden=NO;
        
        tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([[[delegate cityMap] activePath] count]>0) {
            if (!([[[delegate cityMap] activePath] count]==1 && [[[[delegate cityMap] activePath] objectAtIndex:0] isKindOfClass:[Transfer class]])) {
                [stationsView transitToPathView];

                [self showHorizontalPathesScrollView];
            }
        }
        
        [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 44.0, 320.0, 61.0)];
        
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ([appDelegate isIPHONE5]) {
            [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 40, 320, 568-60)];
        } else {
            [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 40, 320, 480-60)];
        }
        
        
        isShowingLandscapeView = NO;
    }
}

-(void)showTabBarViewController
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
    //    [self presentViewController:controller animated:YES completion:nil];
    [controller release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - Horizontal path views

-(UIButton*)createChangeButton
{
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"switch_to_path.png"];
    UIImage *imgh = [UIImage imageNamed:@"switch_to_path_high.png"];
    [changeButton setImage:img forState:UIControlStateNormal];
    [changeButton setImage:imgh forState:UIControlStateHighlighted];
    [changeButton addTarget:self action:@selector(changeMapToPathView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    CGSize dateSize = [dateString sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    [formatter release];
    
    [changeButton setFrame:CGRectMake(320.0-12.0-dateSize.width-img.size.width , 66 , img.size.width, img.size.height)];
    
    return changeButton;
}

-(void)showHorizontalPathesScrollView
{
    
    if (!self.horizontalPathesScrollView) {
        
        PathScrollView *pathView = [[PathScrollView alloc] initWithFrame:CGRectMake(0.0, 22.0, 260, 40.0)];
        self.horizontalPathesScrollView = pathView;
        self.horizontalPathesScrollView.delegate = self;
        [pathView release];
        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        [self.horizontalPathesScrollView addGestureRecognizer:[singleTap autorelease]];
        
        [(MainView*)self.view addSubview:horizontalPathesScrollView];
        [(MainView*)self.view bringSubviewToFront:horizontalPathesScrollView];
        
        if (IS_IPAD) {
            
        } else {
            //self.changeViewButton = [self createChangeButton];
            [(MainView*)self.view addSubview:self.changeViewButton];
        }
        
    } else {
        
        [self.horizontalPathesScrollView refreshContent];
    }
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isIPHONE5]) {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 66, 320, 568-86)];
    } else {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 66, 320, 480-86)];
    }
    
    if ([self.horizontalPathesScrollView numberOfPages]>1) {
        if ([self helpNeeded]) {
            [self.timer invalidate];
            self.timer = nil;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:horizontalPathesScrollView
                                                        selector:@selector(animateScrollView)
                                                        userInfo:nil
                                                         repeats:NO];
            
        }
    }
}

-(void)requestChangeActivePath:(NSNumber*)pathNumb {
    [self performSelector:@selector(changeActivePath:) withObject:pathNumb afterDelay:0.1];
}

-(BOOL)helpNeeded
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"])
	{
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"]<15) {
            return YES;
        } else {
            return NO;
        }
	} else {
        NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:1 forKey:@"scrollHelp"];
        [prefs synchronize];
        return YES;
    }
}

-(void)animationDidEnd
{
    NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"]+1 forKey:@"scrollHelp"];
    [prefs synchronize];
    
    
    [self.timer invalidate];
    self.timer=nil;
}

-(void)removeHorizontalPathesScrollView
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isIPHONE5]) {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 44, 320, 568-64)];
    } else {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 44, 320, 480-64)];
    }
    
    
    [self.horizontalPathesScrollView removeFromSuperview];
    self.horizontalPathesScrollView=nil;
    
    [self.changeViewButton removeFromSuperview];
}

#pragma mark - Vertical path views

-(void)redrawPathScrollView
{
    NSArray *subviews = [self.pathScrollView subviews];
    for (UIView *v in subviews) {
        [v removeFromSuperview];
    }
    
    [self.pathScrollView drawPathScrollView];
}

-(void)changeActivePath:(NSNumber*)pathNumb
{
    MainView *mainView = (MainView*)[self view];
    [mainView.mapView selectPath:[pathNumb intValue]];
    
    if (self.pathScrollView) {
        [self performSelector:@selector(redrawPathScrollView) withObject:nil afterDelay:0.1];
    }
}

-(IBAction)changeMapToPathView:(id)sender
{
    if (!self.pathScrollView ) {
        
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        VertPathScrollView *scview;
        
        if ([appDelegate isIPHONE5]) {
            scview= [[VertPathScrollView alloc] initWithFrame:CGRectMake(0.0, 66.0, 320.0f, 502.0f)];
        } else {
            scview= [[VertPathScrollView alloc] initWithFrame:CGRectMake(0.0, 66.0, 320.0f, 414.0f)];
        }
        
        self.pathScrollView = scview;
        scview.mainController=self;
        [scview release];
        
        [self.pathScrollView drawPathScrollView];
        
        [(MainView*)self.view addSubview:self.pathScrollView];
        [(MainView*)self.view bringSubviewToFront:pathScrollView];
        [(MainView*)self.view bringSubviewToFront:self.stationsView];
        [(MainView*)self.view bringSubviewToFront:self.horizontalPathesScrollView];

        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
        shadow.frame = CGRectMake(0,66, 320, 61);
        [shadow setIsAccessibilityElement:YES];
        shadow.tag = 2321;
        [(MainView*)self.view addSubview:shadow];
        
        [self.changeViewButton setImage:[UIImage imageNamed:@"pathButton.png"] forState:UIControlStateNormal];
        [self.changeViewButton setImage:[UIImage imageNamed:@"pathButtonPressed.png"] forState:UIControlStateHighlighted];

        [(MainView*)self.view bringSubviewToFront:self.changeViewButton];
        
    } else {
        
        [self removeVerticalPathView];
        
    }
}

-(void)singleTapGestureCaptured:(UITapGestureRecognizer*) sender {
    [self.navigationViewController showHidePhotos:nil];
}


-(void)removeVerticalPathView
{
    [[(MainView*)self.view viewWithTag:2321] removeFromSuperview];
    
    [self.pathScrollView removeFromSuperview];
    self.pathScrollView=nil;
    [self.changeViewButton setImage:[UIImage imageNamed:@"switch_to_path.png"] forState:UIControlStateNormal];
    [self.changeViewButton setImage:[UIImage imageNamed:@"switch_to_path_high.png"] forState:UIControlStateHighlighted];
}

-(void)showiPadLeftPathView
{
    [spltViewController showLeftView];
}

-(void)hideiPadLeftPathView
{
    [spltViewController hideLeftView];
}

#pragma mark - FastAccessTableView

-(void)toggleTap
{
    [self returnFromSelectionFastAccess:nil];
    if (currentSelection==0) {
        [stationsView.firstStation resignFirstResponder];
    } else {
        [stationsView.secondStation resignFirstResponder];
    }
}

-(FastAccessTableViewController*)showTableView
{
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0,44,320,440)];
    blackView.backgroundColor  = [UIColor blackColor];
    blackView.alpha=0.4;
    blackView.tag=554;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTap)];
    [blackView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [(MainView*)self.view insertSubview:blackView belowSubview:stationsView];
    [blackView release];
    
    FastAccessTableViewController *tableViewC=[[[FastAccessTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    tableViewC.view.frame=CGRectMake(0,44,320,200);
    
    if ([appDelegate isIPHONE5]) {
        tableViewC.view.frame=CGRectMake(0,44,320,288);
        [[(MainView*)self.view viewWithTag:554] setFrame:CGRectMake(0,44,320,528)];
    }
    
    tableViewC.tableView.hidden=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:tableViewC selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    tableViewC.tableView.tag=555;
    
    [(MainView*)self.view addSubview:tableViewC.tableView];
    [(MainView*)self.view bringSubviewToFront:tableViewC.tableView];
    
    return tableViewC;
}

-(void)removeTableView
{
    [[(MainView*)self.view viewWithTag:554] removeFromSuperview];
    [[(MainView*)self.view viewWithTag:555] removeFromSuperview];
}

#pragma mark - iPad Livesearch

-(StationListViewController*)showiPadLiveSearchView
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        controller.contentSizeForViewInPopover=CGSizeMake(320, 350);
        [popover setPopoverContentSize:CGSizeMake(320, 370)];
    } else {
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
    }
    
    [popover setPopoverContentSize:controller.view.frame.size];
    
    popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    popover.delegate=self;
    
    CGFloat originx;
    if (self.currentSelection==0) {
        originx = self.stationsView.firstStation.frame.origin.x;
    } else {
        originx = self.stationsView.secondStation.frame.origin.x;
    }
    
    popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
    //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.firstStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(originx+80.0, 30.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
    [controller release];
    
    StationListViewController *stations = [[controller.tabBarController viewControllers] objectAtIndex:0];
    return stations;
}

-(void)showiPadSettingsModalView
{
    if (popover) [popover dismissPopoverAnimated:YES];

    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    controller.delegate=self;
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:controller];
    navcontroller.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentModalViewController:navcontroller animated:YES];
    
    //    navcontroller.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
    //    navcontroller.view.superview.frame = CGRectMake(navcontroller.view.superview.frame.origin.x, navcontroller.view.superview.frame.origin.x, 320, 700);
    //
    //    navcontroller.view.superview.center = self.view.center;
    
    [controller release];
    [navcontroller release];
}

-(void)showiPadPurchases:(int)index
{
    if (popover) [popover dismissPopoverAnimated:YES];
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    controller.delegate=self;
    controller.purchaseIndex = index;
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:controller];
    navcontroller.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentModalViewController:navcontroller animated:YES];
    
    //    navcontroller.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
    //    navcontroller.view.superview.frame = CGRectMake(navcontroller.view.superview.frame.origin.x, navcontroller.view.superview.frame.origin.x, 320, 700);
    //
    //    navcontroller.view.superview.center = self.view.center;
    
    [controller release];
    [navcontroller release];
}

-(void)donePressed
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Choosing stations etc

-(void)languageChanged:(NSNotification*)note
{
    if (self.fromStation) {
        [stationsView setFromStation:self.fromStation];
    }
    
    if (self.toStation) {
        [stationsView setToStation:self.toStation];
    }
}

-(void)returnFromSelection2:(NSArray*)stations
{
    MainView *mainView = (MainView*)self.view;
    
    if ([stations count]>1) {
        // это история и надо ставить обе станции
        self.fromStation = [stations objectAtIndex:0];
        self.toStation = [stations objectAtIndex:1];
        
        if (currentSelection==0) {
            [stationsView setFromStation:self.fromStation];
            [stationsView setToStation:self.toStation];
        } else {
            [stationsView setToStation:self.toStation];
            [stationsView setFromStation:self.fromStation];
        }
        
        
    } else if ([stations count]==1) {
        // это конкретная станция
        if (currentSelection==0) {
            if ([stations objectAtIndex:0]==self.toStation) {
                self.fromStation=nil;
                [stationsView resetFromStation];
            } else {
                self.fromStation = [stations objectAtIndex:0];
                [stationsView setFromStation:self.fromStation];
            }
        } else {
            if ([stations objectAtIndex:0]==self.fromStation) {
                self.toStation=nil;
                [stationsView resetToStation];
            } else {
                self.toStation = [stations objectAtIndex:0];
                [stationsView setToStation:self.toStation];
            }
        }
        
    } else if ([stations count]==0) {
        if (currentSelection==0) {
            self.fromStation=nil;
            [stationsView setFromStation:self.fromStation];
        } else {
            self.toStation=nil;
            [stationsView setToStation:self.toStation];
        }
    }
    
    if ((self.fromStation==nil || self.toStation==nil)) {
        [mainView.mapView clearPath];
        
        if (self.horizontalPathesScrollView) {
            [self removeHorizontalPathesScrollView];
        }
        
        if (self.pathScrollView) {
            [self changeMapToPathView:nil];
        }
        mainView.mapView.stationSelected=false;
        
	} else {
        commonActivityIndicator.delegate = self;
        [commonActivityIndicator showWhileExecuting:@selector(performFindingPath) onTarget:self withObject:nil animated:YES];
	}
    
    if ((self.fromStation==nil && self.toStation==nil)) {
        //[stationsView transitToInitialSize];
    }
}

- (void)clearPath {
    MainView *mainView = (MainView*)self.view;

    [mainView.mapView clearPath];

}

-(void)setStarAtStation:(Station*)station {
    MainView *mainView = (MainView*)self.view;
    [mainView.mapView setStarAtStation:station];
}

-(void)removeStarFromStation:(NSString*)stationName {
    MainView *mainView = (MainView*)self.view;
    [mainView.mapView removeStarFromStation:stationName];
}

- (Station*)nearestStation {
    MainView *view = (MainView*)self.view;
    return view.mapView.nearestStation;
}


- (void) centerMapOnUser {
    MainView *view = self.view;
    [view centerMapOnUser];
}

-(void)performFindingPath
{
    MainView *mainView = (MainView*)self.view;
    [mainView findPathFrom:[fromStation name] To:[toStation name] FirstLine:[[[fromStation lines] index] integerValue] LastLine:[[[toStation lines] index] integerValue]];
}

- (void)hudWasHidden
{
    MainView *mainView = (MainView*)self.view;
    tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([[[delegate cityMap] activePath] count]>0) {
        if (!([[[delegate cityMap] activePath] count]==1 && [[[[delegate cityMap] activePath] objectAtIndex:0] isKindOfClass:[Transfer class]])) {
            if (IS_IPAD) {
                [stationsView transitToPathView];

                [spltViewController refreshPath];
            } else {
                if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                    [stationsView transitToPathView];
                    [self showHorizontalPathesScrollView];
                    if (self.statusViewController.isShown) {
                        [self.statusViewController hideFullSizeView];
                    }
                }
            }
        }
    }
    
    mainView.mapView.stationSelected=false;
}

-(void)returnFromSelection:(NSArray*)stations
{
    if (IS_IPAD) {
        if (popover) [popover dismissPopoverAnimated:YES];
        [self performSelector:@selector(returnFromSelection2:) withObject:stations afterDelay:0.1];
        
    } else {
        [self dismissModalViewControllerAnimated:YES];
        [self performSelector:@selector(returnFromSelection2:) withObject:stations afterDelay:0.1];
    }
}

-(void)returnFromSelectionFastAccess:(NSArray *)stations
{
    [self removeTableView];
    if (stations) {
        if (currentSelection==0) {
            if ([stations objectAtIndex:0]==self.toStation) {
                self.fromStation=nil;
                [stationsView resetFromStation];
            } else {
                [self returnFromSelection:stations];
            }
        } else {
            if ([stations objectAtIndex:0]==self.fromStation) {
                self.toStation=nil;
                [stationsView resetToStation];
            } else {
                [self returnFromSelection:stations];
            }
        }
        
        //      [self returnFromSelection:stations];
    } else {
        if (currentSelection==0) {
            [stationsView setFromStation:self.fromStation];
        } else {
            [stationsView setToStation:self.toStation];
        }
    }
}

-(void)pressedSelectFromStation
{
    currentSelection=FromStation;
    
    if (popover)
        [popover dismissPopoverAnimated:YES];
    
    if (!IS_IPAD)
    {
        [self showTabBarViewController];
    }
    else
    {
        SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
        controller.delegate = self;
        
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
        
        [popover setPopoverContentSize:controller.view.frame.size];
        
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
        //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.firstStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.firstStation.frame.origin.x+80.0, 30.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
        [controller release];
    }
}

-(void)pressedSelectToStation
{
    currentSelection=ToStation;
    
    if (popover)
        [popover dismissPopoverAnimated:YES];
    
    if (!IS_IPAD)
    {
        [self showTabBarViewController];
    }
    else
    {
        SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
        controller.delegate = self;
        
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
        
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.secondStation.frame.origin.x+80.0, 30.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
        [controller release];
    }
}

-(void)resetFromStation
{
    currentSelection=FromStation;
    [stationsView setToStation:self.toStation];
    [self returnFromSelection:[NSArray array]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
}

-(void)resetToStation
{
    currentSelection=ToStation;
    [stationsView setFromStation:self.fromStation];
    [self returnFromSelection:[NSArray array]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
}

- (void)resetBothStationsInASpecialWay {
    [stationsView resetBothStations];

}

-(void)resetBothStations
{
    int tempSelection = currentSelection;
    
    currentSelection=FromStation;
    [stationsView setToStation:nil];
    [stationsView setFromStation:nil];
    
    self.fromStation=nil;
    self.toStation=nil;
    
    [self returnFromSelection2:[NSArray array]];
    
    currentSelection=tempSelection;
    //[stationsView resetBothStations];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
}


@end
