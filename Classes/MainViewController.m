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
#import "SSTheme.h"
#import "SelectingTabBarViewControllerNDiPad.h"
#import "CustomPopoverBackgroundView.h"

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
        [stationsView.fromStationField resignFirstResponder];
    } else {
        [stationsView.toStationField resignFirstResponder];
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
    
    TopTwoStationsView *twoStationsView = nil;
    
    if (IS_IPAD && ![[SSThemeManager sharedTheme] isNewTheme]) {
        twoStationsView = [[TopTwoStationsView alloc] initWithViewHeight:[[SSThemeManager sharedTheme] topToolbarHeight:UIBarMetricsDefault] fieldWidth:189.0f fieldHeight:[[SSThemeManager sharedTheme] toolbarFieldHeight] fieldDelta:[[SSThemeManager sharedTheme] toolbarFieldDelta] deviceHeight:1024.0f deviceWidth:768.0f];
        twoStationsView.delegate=self;
        self.stationsView = twoStationsView;
        [(MainView*)self.view addSubview:twoStationsView];
        [twoStationsView release];
        
    } else if (!IS_IPAD) {
        twoStationsView = [[TopTwoStationsView alloc] initWithViewHeight:[[SSThemeManager sharedTheme] topToolbarHeight:UIBarMetricsDefault] fieldWidth:160.0f  fieldHeight:[[SSThemeManager sharedTheme] toolbarFieldHeight] fieldDelta:[[SSThemeManager sharedTheme] toolbarFieldDelta]  deviceHeight:480.0f deviceWidth:320.f];
        twoStationsView.delegate=self;
        self.stationsView = twoStationsView;
        [(MainView*)self.view addSubview:twoStationsView];
        [twoStationsView release];
    }
    
    
    UISwipeGestureRecognizer *swipeRecognizerD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [swipeRecognizerD setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.stationsView addGestureRecognizer:swipeRecognizerD];
    [swipeRecognizerD release];
    
    [self performSelector:@selector(refreshInApp) withObject:nil afterDelay:0.2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:@"kLangChanged" object:nil];    
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
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
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
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 0, 568, 320)];
            } else {
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 0, 480, 320)];
            }
        } else {
            if ([appDelegate isIPHONE5]) {
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 40, 320, 568-40)];
            } else {
                [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 40, 320, 480-40)];
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
    UIImage *img = [[SSThemeManager sharedTheme] switchButtonImage:UIControlStateNormal];
    UIImage *imgh = [[SSThemeManager sharedTheme] switchButtonImage:UIControlStateHighlighted];
    [changeButton setImage:img forState:UIControlStateNormal];
    [changeButton setImage:imgh forState:UIControlStateHighlighted];
    [changeButton addTarget:self action:@selector(changeMapToPathView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    CGSize dateSize = [dateString sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    [formatter release];
    
    CGFloat buttonX;
    
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        buttonX = 240.0f;
    } else {
        buttonX = 320.0-12.0-dateSize.width-img.size.width;
    }
    
    [changeButton setFrame:CGRectMake(buttonX , [[SSThemeManager sharedTheme] horizontalPathSwitchButtonY] , img.size.width, img.size.height)];
    
    return changeButton;
}

-(void)showHorizontalPathesScrollView
{
    CGFloat topPathHeight = [[SSThemeManager sharedTheme] topToolbarPathHeight:UIBarMetricsDefault];
    CGFloat pathViewHeight = [[SSThemeManager sharedTheme] pathViewHeight:UIBarMetricsDefault];
    
    if (!self.horizontalPathesScrollView) {
        
        CGRect rect = [[SSThemeManager sharedTheme] horizontalPathViewRect];
        PathScrollView *pathView = [[PathScrollView alloc] initWithFrame:rect];
        pathView.tag=6843;
        self.horizontalPathesScrollView = pathView;
        self.horizontalPathesScrollView.delegate = self;
        [pathView release];
        
        [(MainView*)self.view insertSubview:horizontalPathesScrollView belowSubview:self.stationsView];
//        [(MainView*)self.view bringSubviewToFront:horizontalPathesScrollView];
        
        if (!IS_IPAD) {
            self.changeViewButton = [self createChangeButton];
            [(MainView*)self.view addSubview:self.changeViewButton];
        }
        
    } else {
        
        [self.horizontalPathesScrollView refreshContent];
    }
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    float viewDelatY;
    
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        viewDelatY=topPathHeight-10.0f;//40.0+pathViewHeight; // topPathHeight - 10.0;
    } else {
        viewDelatY=topPathHeight+pathViewHeight;
    }
    
    if ([appDelegate isIPHONE5]) {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, viewDelatY, 320, 568-viewDelatY)];
    } else {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, viewDelatY, 320, 480-viewDelatY)];
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
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 44, 320, 568-44)];
    } else {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 44, 320, 480-44)];
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
        
        CGFloat viewStartY = [[SSThemeManager sharedTheme] vertScrollViewStartY];
        
        if ([appDelegate isIPHONE5]) {
            scview= [[VertPathScrollView alloc] initWithFrame:CGRectMake(0.0, viewStartY, 320.0f, 568.0f-viewStartY)]; //66
        } else {
            scview= [[VertPathScrollView alloc] initWithFrame:CGRectMake(0.0, viewStartY, 320.0f, 480.0f-viewStartY)];  // original
        }
        
        self.pathScrollView = scview;
        scview.mainController=self;
        [scview release];
        
        [self.pathScrollView drawPathScrollView];
        
        [(MainView*)self.view addSubview:self.pathScrollView];
        [(MainView*)self.view bringSubviewToFront:pathScrollView];
        [(MainView*)self.view bringSubviewToFront:self.horizontalPathesScrollView];
        [(MainView*)self.view bringSubviewToFront:self.stationsView];

        if (![[SSThemeManager sharedTheme] isNewTheme]) {
            UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
            shadow.frame = CGRectMake(0,66, 320, 61);
            [shadow setIsAccessibilityElement:YES];
            shadow.tag = 2321;
            [(MainView*)self.view addSubview:shadow];
        }
        
        [self.changeViewButton setImage:[[SSThemeManager sharedTheme] switchButtonImage:UIControlStateNormal] forState:UIControlStateNormal];
        [self.changeViewButton setImage:[[SSThemeManager sharedTheme] switchButtonImage:UIControlStateHighlighted] forState:UIControlStateHighlighted];

        //UIImage imageNamed:@"pathButtonPressed.png"
        
        [(MainView*)self.view bringSubviewToFront:self.changeViewButton];
        
    } else {
        
        [self removeVerticalPathView];
        
    }
}

-(void)removeVerticalPathView
{
    [[(MainView*)self.view viewWithTag:2321] removeFromSuperview];
    
    [self.pathScrollView removeFromSuperview];
    self.pathScrollView=nil;
    [self.changeViewButton setImage:[[SSThemeManager sharedTheme] switchButtonImage:UIControlStateNormal]  forState:UIControlStateNormal];
    [self.changeViewButton setImage:[[SSThemeManager sharedTheme] switchButtonImage:UIControlStateHighlighted]  forState:UIControlStateHighlighted];
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
        [stationsView.fromStationField resignFirstResponder];
    } else {
        [stationsView.toStationField resignFirstResponder];
    }
}

-(FastAccessTableViewController*)showTableView
{
    CGFloat startY = [[SSThemeManager sharedTheme] fastAccessTableViewStartY];
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0,startY,320,440)];
    blackView.backgroundColor  = [UIColor blackColor];
    blackView.alpha=0.4;
    blackView.tag=554;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTap)];
    [blackView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    FastAccessTableViewController *tableViewC=[[[FastAccessTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    tableViewC.view.frame=CGRectMake(0,startY,320,200);
    
    if ([appDelegate isIPHONE5]) {
        tableViewC.view.frame=CGRectMake(0,startY,320,288);
        [[(MainView*)self.view viewWithTag:554] setFrame:CGRectMake(0,startY,320,528)];
    }
    
    tableViewC.tableView.hidden=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:tableViewC selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    tableViewC.tableView.tag=555;
    
    [(MainView*)self.view insertSubview:tableViewC.tableView belowSubview:stationsView];
    [(MainView*)self.view insertSubview:blackView belowSubview:tableViewC.tableView];

    [blackView release];
    
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
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        SelectingTabBarViewControllerNDiPad *controller = [[SelectingTabBarViewControllerNDiPad alloc] initWithNibName:@"SelectingTabBarViewControllerNDiPad" bundle:[NSBundle mainBundle]];
        controller.delegate = self;
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            controller.contentSizeForViewInPopover=CGSizeMake(346, 315);
            [popover setPopoverContentSize:CGSizeMake(346, 315)];
        } else {
            controller.contentSizeForViewInPopover=CGSizeMake(346, 524);
            [popover setPopoverContentSize:CGSizeMake(346, 524)];
        }
        
        [popover setPopoverContentSize:controller.view.frame.size];
        
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.delegate=self;
        popover.popoverBackgroundViewClass= [CustomPopoverBackgroundView class];
        
        CGFloat originx;
        if (self.currentSelection==0) {
            originx = self.stationsView.fromStationField.frame.origin.x;
        } else {
            originx = self.stationsView.toStationField.frame.origin.x;
        }
        
//        [popover presentPopoverFromRect:CGRectMake(self.stationsView.fromStationField.frame.origin.x+177.0, 36.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(originx+177.0, 36.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
        [controller release];
        
        StationListViewController *stations = [[controller.tabBarController viewControllers] objectAtIndex:0];

        return stations;
    } else {
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
        popover.popoverBackgroundViewClass= [CustomPopoverBackgroundView class];
        
        CGFloat originx;
        if (self.currentSelection==0) {
            originx = self.stationsView.fromStationField.frame.origin.x;
        } else {
            originx = self.stationsView.toStationField.frame.origin.x;
        }
        
        //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.fromStationField.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(originx+80.0, 30.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
        [controller release];
        
        StationListViewController *stations = [[controller.tabBarController viewControllers] objectAtIndex:0];

        return stations;

    }    
}

-(void)showiPadSettingsModalView
{
    if ([popover isPopoverVisible]) {
        [popover dismissPopoverAnimated:YES];
        [stationsView restoreFieldAfterPopover];
    }
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    controller.delegate=self;
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:controller];
    navcontroller.modalPresentationStyle=UIModalPresentationFormSheet;
    
    id <SSTheme> theme = [SSThemeManager sharedTheme];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[theme highlightColor], UITextAttributeTextColor, [theme navigationTitleFont], UITextAttributeFont, [theme titleShadowColor],UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil];
    [navcontroller.navigationBar setTitleTextAttributes:textTitleOptions];

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
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            SelectingTabBarViewControllerNDiPad *controller = [[SelectingTabBarViewControllerNDiPad  alloc] initWithNibName:@"SelectingTabBarViewControllerNDiPad" bundle:[NSBundle mainBundle]];
            controller.delegate = self;
            
            [popover setPopoverContentSize:CGSizeMake(346, 524)];
            controller.contentSizeForViewInPopover=CGSizeMake(346, 524);
            
            popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
            
            [popover setPopoverContentSize:controller.view.frame.size];
            
            popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
            //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.fromStationField.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.fromStationField.frame.origin.x+self.stationsView.fromStationField.frame.size.width/2.0, 36.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
            [controller release];
            
        } else {
        SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
        controller.delegate = self;
        
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
        
        [popover setPopoverContentSize:controller.view.frame.size];
        
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.popoverBackgroundViewClass= [CustomPopoverBackgroundView class];
        //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.fromStationField.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.fromStationField.frame.origin.x+80.0, 30.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
        [controller release];
        }
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
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            SelectingTabBarViewControllerNDiPad *controller = [[SelectingTabBarViewControllerNDiPad  alloc] initWithNibName:@"SelectingTabBarViewControllerNDiPad" bundle:[NSBundle mainBundle]];
            controller.delegate = self;
            
            [popover setPopoverContentSize:CGSizeMake(346, 524)];
            controller.contentSizeForViewInPopover=CGSizeMake(346, 524);
            
            popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
            
            [popover setPopoverContentSize:controller.view.frame.size];
            
            popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
            //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.fromStationField.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.toStationField.frame.origin.x+20.0, 36.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
            [controller release];
            
        } else {

        SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
        controller.delegate = self;
        
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
        
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.popoverBackgroundViewClass= [CustomPopoverBackgroundView class];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.toStationField.frame.origin.x+80.0, 30.0, 1.0, 1.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
        [controller release];
        }
    }
}

-(void)resetFromStation
{
    currentSelection=FromStation;
    [self returnFromSelection:[NSArray array]];
    [stationsView setToStation:self.toStation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
}

-(void)resetToStation
{
    currentSelection=ToStation;
    [stationsView setFromStation:self.fromStation];
    [self returnFromSelection:[NSArray array]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
}


@end
