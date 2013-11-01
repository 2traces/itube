//
//  TubeSplitViewController.m
//  tube
//
//  Created by sergey on 04.08.12.
//
//

#import "TubeSplitViewController.h"
#import "tubeAppDelegate.h"
#import "RightiPadPathViewController.h"
#import "SettingsViewController.h"
#import "NavigationViewController.h"

#define constDividerWidth 1.0f
#define constMasterWidth 320.0f
#define constDetailStartPoint (constMasterWidth+constDividerWidth)

static float koefficient = 0.0f;

@implementation TubeSplitViewController

@synthesize pathView;
@synthesize mapView;
@synthesize glViewController, rightPathController;
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
    
//    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
//    navController = [[UINavigationController alloc] initWithRootViewController:delegate.navigationViewController];
//    navController.navigationBarHidden = YES;
    
    isRightShown = NO;
    isListShown = NO;
    
    self.listViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.mapViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.listViewController.view];
    [self.view addSubview:self.mapViewController.view];
    
    self.listViewController.view.layer.cornerRadius = 5;
    self.listViewController.view.layer.masksToBounds = YES;
    
    self.mapViewController.view.layer.cornerRadius = 5;
    self.mapViewController.view.layer.masksToBounds = YES;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.mapViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+20);
        self.listViewController.view.frame = CGRectMake(-self.listViewController.view.frame.size.width, 0, self.listViewController.view.frame.size.width, self.view.frame.size.height+20);
    }
    else {
        self.mapViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.listViewController.view.frame = CGRectMake(-self.listViewController.view.frame.size.width, 0, self.listViewController.view.frame.size.width, self.view.frame.size.height);
    }
    
    [((NavigationViewController*)(self.mapViewController)).listSplitButton addTarget:self action:@selector(hideShowSplitController) forControlEvents:UIControlEventTouchUpInside];
    
//    RightiPadPathViewController *controller = [[RightiPadPathViewController alloc] init];
//    controller.view.frame=CGRectMake(-1320.0, 0.0, 320.0, 1004.0);
//    self.pathView=controller.view;
//    self.rightPathController=controller;
//    [self.view addSubview:self.glViewController.view];
//    [controller release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pathCleared:) name:@"kPathCleared" object:nil];
}

- (void) hideShowSplitController {
    if (isListShown) {
        [self hideLeftView];
    }
    else {
        [self showLeftView];
    }
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
    float leftWidth = size.width - constMasterWidth - constDividerWidth;
    float rightWidth = constMasterWidth;
    if (isRightShown) {
        mapView.frame = CGRectMake(0,
                                   0 - koefficient,
                                   leftWidth,
                                   size.height + koefficient);
        pathView.frame = CGRectMake(leftWidth + constDividerWidth,
                                    0 - koefficient,
                                    rightWidth,
                                    size.height + koefficient);        
        
    } else {
        mapView.frame = CGRectMake(0,
                                   0 - koefficient,
                                   size.width,
                                   size.height + koefficient);
        pathView.frame = CGRectMake(size.width,
                                    0 - koefficient,
                                    rightWidth,
                                    size.height + koefficient);
        
    }
    
}

-(void)showLeftView
{
    if (!isListShown) {
        isListShown = YES;
        CGFloat delta = self.listViewController.view.frame.size.width;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect listFrame = self.listViewController.view.frame;
            CGRect mapFrame = self.mapViewController.view.frame;
            listFrame.origin.x += delta;
            mapFrame.size.width -= delta + 1;
            mapFrame.origin.x += delta + 1;
            self.listViewController.view.frame = listFrame;
            self.mapViewController.view.frame = mapFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
//    if (isRightShown) {
//        [self hideLeftView];
//    } else {
////        if ([self.rightPathController isReadyToShow]) {
//
//            isRightShown=YES;
//            
//            
////            [self.rightPathController prepareToShow];
//            
//            [UIView animateWithDuration:0.5 animations:^{
//                [self layoutSubviews];
//            } completion:^(BOOL finished) {
//            }];
////        }
//    }
}

-(void)hideLeftView
{
    if (isListShown) {
        isListShown = NO;
        CGFloat delta = self.listViewController.view.frame.size.width;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect listFrame = self.listViewController.view.frame;
            CGRect mapFrame = self.mapViewController.view.frame;
            listFrame.origin.x -= delta;
            mapFrame.size.width += delta + 1;
            mapFrame.origin.x -= delta + 1;
            self.listViewController.view.frame = listFrame;
            self.mapViewController.view.frame = mapFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
//    isRightShown=NO;
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        [self layoutSubviews];
//    } completion:^(BOOL finished) {
//    }];
}

-(void)refreshPath
{
    if (!isRightShown) {
        [self showLeftView];
    } else {
//        [self.rightPathController prepareToShow];
    }
}

-(void)pathCleared:(NSNotification*)note
{
    
    isRightShown=NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutSubviews];
        
    }];
}

-(void)pathFound:(NSNotification*)note
{
    
    isRightShown=YES;
    
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
//    [rightPathController refreshStatusInfo];
}

-(void)changeStatusView
{
//    [rightPathController changeStatusView];
}

- (void) viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
    
	[rightPathController viewWillAppear:animated];
	[glViewController viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	
    [super viewDidAppear:animated];
	
    [rightPathController viewDidAppear:animated];
	[glViewController viewDidAppear:animated];
    
    // it's Needed to fix a bug with 20px near the statusbar
     /*
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
        koefficient = 20.0f;
    else
        koefficient = 0.0f;*/ 
}

- (void)viewWillDisappear:(BOOL)animated {
	
    [super viewWillDisappear:animated];
	[rightPathController viewWillDisappear:animated];
	[glViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	
    [super viewDidDisappear:animated];
	[rightPathController viewDidDisappear:animated];
	[glViewController viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   // if (IS_IPAD)
    return interfaceOrientation == UIInterfaceOrientationPortrait;// || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[rightPathController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[glViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //    [self layoutSubviews];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[rightPathController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[glViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self layoutSubviews];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[rightPathController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[glViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[rightPathController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[glViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	[rightPathController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
	[glViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[rightPathController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
	[glViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
}

@end
