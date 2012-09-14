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

#define constDividerWidth 1.0f
#define constMasterWidth 320.0f
#define constDetailStartPoint (constMasterWidth+constDividerWidth)

static float koefficient = 0.0f;

@implementation TubeSplitViewController

@synthesize pathView;
@synthesize mapView;
@synthesize mainViewController;
@synthesize leftPathController;

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
    MainView *vvv = (MainView*)[delegate.mainViewController view];
    delegate.mainViewController.spltViewController=self;
    vvv.frame = CGRectMake(0.0, 0.0, 768.0, 1004.0);
    [[vvv containerView] setFrame:CGRectMake(0.0, 0.0, 768.0, 1004)];
    self.mapView = vvv;
    [self.view addSubview:vvv];
    
    LeftiPadPathViewController *controller = [[LeftiPadPathViewController alloc] init];
    controller.view.frame=CGRectMake(-320.0, 0.0, 200.0, 1004.0);
    self.pathView=controller.view;
    self.leftPathController=controller;
    [self.view addSubview:controller.view];
    [controller release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathCleared:) name:@"kPathCleared" object:nil];
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
        
        [[(MainView*)self.mapView containerView] setFrame:CGRectMake(0.0, 0.0, size.width - constDetailStartPoint,size.height + koefficient)];
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
        
        [[(MainView*)self.mapView containerView] setFrame:CGRectMake(0.0, 0.0, size.width ,size.height + koefficient)];
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
    
    [self.leftPathController.pathScrollView setFrame:CGRectMake(0.0, 44.0, 320.0, size.height-44.0)];
}

-(void)showLeftView
{
    if (isLeftShown) {
        [self hideLeftView];
    } else {
        
        isLeftShown=YES;
        
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        if ([[[appDelegate cityMap] activePath] count]>0) {
            [self.leftPathController showHorizontalPathesScrollView];
            [self.leftPathController showVerticalPathScrollView];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutSubviews];
        } completion:^(BOOL finished) {
 //           [self adjustMapView];
        }];
    }
}

-(void)hideLeftView
{
    isLeftShown=NO;

    [UIView animateWithDuration:0.5 animations:^{
        [self layoutSubviews];
    } completion:^(BOOL finished) {
//    [self adjustMapView];
    }];
}

-(void)refreshPath
{
    [self.leftPathController.horizontalPathesScrollView refreshContent];
    [self.leftPathController redrawPathScrollView];
    if (!isLeftShown) {
        [self showLeftView];
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




//- (void) viewDidLoad {
//    [super viewDidLoad];
//
//    pathView = ;
//    mapView = ;
//
//}

//- (void) viewDidUnload {
//
//    [pathView release], pathView = nil;
//    [mapView release], mapView = nil;
//}

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
    if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        koefficient = 20.0f;
    else
        koefficient = 0.0f;
    
    //    [self layoutSubviews];
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
