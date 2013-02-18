//
//  TubeSplitViewController.m
//  tube
//
//  Created by sergey on 04.08.12.
//
//

#import "TubeSplitViewController.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "MainView.h"
#import "TopTwoStationsView.h"
#import "LeftiPadPathViewController.h"
#import "CityMap.h"
#import "SettingsViewController.h"
#import "PhotosViewController.h"

#define constDividerWidth 1.0f
#define constMasterWidth 320.0f
#define constDetailStartPoint (constMasterWidth+constDividerWidth)

static float koefficient = 0.0f;

@implementation TubeSplitViewController

@synthesize pathView;
@synthesize mapView;
@synthesize mainViewController;
@synthesize leftPathController;
@synthesize navigationController = navController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.frame = CGRectMake(0.0, 20.0, 768.0, 1004.0);
    
    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    MainView *mainView = (MainView*)[delegate.mainViewController view];
    delegate.mainViewController.spltViewController = self;
    
    mainViewController = delegate.mainViewController;
    
    navController = [[UINavigationController alloc] initWithRootViewController:delegate.navigationViewController];
    navController.navigationBarHidden = YES;
    [self addChildViewController:navController];

   // self.view.frame = mainViewController.view.frame = navController.view.frame = [UIScreen mainScreen].applicationFrame;
    
    isLeftShown = NO;
    //mainView.frame = CGRectMake(0.0, 0.0, 768.0, 1004.0-44.0);
    //[[mainView containerView] setFrame:CGRectMake(0.0, 44.0, 768.0, 1004-44.0)];
    self.mapView = mainView;
    [self.view addSubview:[navController view]];
    
    LeftiPadPathViewController *controller = [[LeftiPadPathViewController alloc] init];
    controller.view.frame=CGRectMake(-1320.0, 0.0, 320.0, 1004.0);
    self.pathView=controller.view;
    self.leftPathController=controller;
    [self.view addSubview:controller.view];
    [controller release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathCleared:) name:@"kPathCleared" object:nil];
}

-(void) dealloc
{
    [navController release];
    [super dealloc];
}

- (CGSize) sizeRotated {
    
	UIScreen *screen = [UIScreen mainScreen];
	CGRect bounds = screen.bounds;
	CGRect appFrame = screen.applicationFrame;
	CGSize size = bounds.size;
	
	float statusBarHeight = MAX((bounds.size.width - appFrame.size.width), (bounds.size.height - appFrame.size.height));
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
	{
		size.width = bounds.size.height;
		size.height = bounds.size.width;
	}
	
	size.height = size.height -statusBarHeight -self.tabBarController.tabBar.frame.size.height;
	return size;
}

- (void) layoutSubviews {
    
	CGSize size = [self sizeRotated];
    
    if (isLeftShown) {
        pathView.frame = CGRectMake(0,
                                    0 - koefficient,
                                    constMasterWidth,
                                    size.height + koefficient);
        mapView.frame = CGRectMake(constDetailStartPoint,
                                   0 - koefficient,
                                   size.width - constDetailStartPoint,
                                   size.height + koefficient);
        
        [[(MainView*)self.mapView containerView] setFrame:CGRectMake(0.0, 44.0, size.width - constDetailStartPoint,size.height + koefficient - 44.0)];
        [mainViewController.stationsView setFrame:CGRectMake(0, 0, size.width - constDetailStartPoint, 44)];
        
    } else {
        pathView.frame = CGRectMake(-constMasterWidth,
                                    0 - koefficient,
                                    constMasterWidth,
                                    size.height + koefficient);
        mapView.frame = CGRectMake(0,
                                   0 - koefficient,
                                   size.width,
                                   size.height + koefficient);
        
        [[(MainView*)self.mapView containerView] setFrame:CGRectMake(0.0, 44.0, size.width ,size.height + koefficient - 44.0)];
        [mainViewController.stationsView setFrame:CGRectMake(0, 0, size.width, 44)];
        
    }
    
    [mainViewController.stationsView adjustSubviews:self.interfaceOrientation];
    
}

-(void)adjustMapView
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appDelegate.cityMap.activeExtent.size.width!=0) {
        [[(MainView*)self.mapView mapView] adjustMap];
    }
}

-(void)adjustPathView
{
    CGSize size = [self sizeRotated];
    
    if (isLeftShown)
    [self.leftPathController.pathScrollView setFrame:CGRectMake(0.0, 44.0, 320.0, size.height-44.0)];
}

-(void)showLeftView
{
    if (isLeftShown) {
        [self hideLeftView];
    } else {
        if ([self.leftPathController isReadyToShow]) {

            isLeftShown=YES;
            
            PhotosViewController * photos = mainViewController.navigationViewController.photosController;
            photos.placeNamePanel.hidden = YES;
            photos.distanceContainer.hidden = YES;
            
            CGSize size = [self sizeRotated];
            CGRect rect = photos.panelView.frame;
            [photos.panelView setFrame:CGRectMake(constDetailStartPoint, rect.origin.y, size.width - constDetailStartPoint, rect.size.height)];

            [self.leftPathController prepareToShow];
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutSubviews];
            } completion:^(BOOL finished) {
                //           [self adjustMapView]; //выключили изза производительности
              //  [leftPathController refreshUITextView]; //fixing ios bug
            }];
        }
    }
}

-(void)hideLeftView
{
    isLeftShown=NO;
    
    CGSize size = [self sizeRotated];

    PhotosViewController * photos = mainViewController.navigationViewController.photosController;
    CGRect rect = photos.panelView.frame;
    [photos.panelView setFrame:CGRectMake(rect.origin.x, rect.origin.y, size.width, rect.size.height)];

    
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        //    [self adjustMapView]; //выключили изза производительности
    }];
}

-(void)refreshPath
{
    if (!isLeftShown) {
        [self showLeftView];
    } else {
        [self.leftPathController prepareToShow];
    }
}

-(void)pathCleared:(NSNotification*)note
{
    
    isLeftShown=NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutSubviews];
        
    }];
}

-(void)pathFound:(NSNotification*)note
{
    
    isLeftShown=YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutSubviews];
        
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)refreshStatusInfo
{
    [leftPathController refreshStatusInfo];
}

-(void)changeStatusView
{
    [leftPathController changeStatusView];
}

- (void) viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
    
	[leftPathController viewWillAppear:animated];
	[mainViewController viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	
    [super viewDidAppear:animated];
	
    [leftPathController viewDidAppear:animated];
	[mainViewController viewDidAppear:animated];
    
    // it's Needed to fix a bug with 20px near the statusbar
     /*
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
        koefficient = 20.0f;
    else
        koefficient = 0.0f;*/ 
}

- (void)viewWillDisappear:(BOOL)animated {
	
    [super viewWillDisappear:animated];
	[leftPathController viewWillDisappear:animated];
	[mainViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	
    [super viewDidDisappear:animated];
	[leftPathController viewDidDisappear:animated];
	[mainViewController viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[leftPathController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[mainViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //    [self layoutSubviews];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[leftPathController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[mainViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self layoutSubviews];
    [self adjustMapView];
    [self adjustPathView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[leftPathController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[mainViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[leftPathController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[mainViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	[leftPathController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
	[mainViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[leftPathController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
	[mainViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
}

@end
