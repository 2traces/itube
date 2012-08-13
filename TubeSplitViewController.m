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

@interface TubeSplitViewController ()

@end

@implementation TubeSplitViewController

@synthesize pathView;
@synthesize mapView;
@synthesize mainViewController;

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

    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    MainView *vvv = (MainView*)[delegate.mainViewController view];
    delegate.mainViewController.spltViewController=self;
    vvv.frame = CGRectMake(0.0, 20.0, 768.0, 1004.0);
    [[vvv containerView] setFrame:CGRectMake(0.0, 0.0, 768.0, 1004)];
    self.mapView = vvv;
    [self.view addSubview:vvv];
    
    LeftiPadPathViewController *controller = [[LeftiPadPathViewController alloc] init];
    controller.view.frame=CGRectMake(-300.0, 100.0, 200.0, 300.0);
    self.pathView=controller.view;
    [self.view addSubview:controller.view];

}

-(void)showLeftView
{
    self.pathView.frame=CGRectMake(0.0, 20.0, 320.0, 1024.0);
    self.mapView.frame=CGRectMake(320.0, 20.0, 768.0-320.0, 1004.0);
    [[(MainView*)self.mapView containerView] setFrame:CGRectMake(0.0, 0.0, 768.0-320.0, 1004.0)];
    [mainViewController.stationsView setFrame:CGRectMake(0, 0, 768-320, 44)];
    [mainViewController.stationsView adjustSubviews];
    [[(MainView*)self.mapView mapView] adjustMap];


//    [[(MainView*)self.mainViewController.view containerView] setFrame:CGRectMake(0.0, 44.0, 768.0-320.0, 1004.0-44.0)];

//    [self.view bringSubviewToFront:self.pathView];
}

-(void)hideLeftView
{
    self.pathView.frame=CGRectMake(-300.0, 100.0, 200.0, 300.0);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    switch ([UIDevice currentDevice].orientation)
    {
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight: {
        [self.mapView setFrame:CGRectMake(0, 0, 1024, 768-20)];
        [[(MainView*)self.mapView containerView] setFrame:CGRectMake(0.0, 0.0, 1024, 768-20)];
        [mainViewController.stationsView setFrame:CGRectMake(0, 0, 1024, 44)];
        [mainViewController.stationsView adjustSubviews];
        break;
    }
    case UIInterfaceOrientationPortrait:
    case UIInterfaceOrientationPortraitUpsideDown: {
        [self.mapView setFrame:CGRectMake(0, 0, 768, 1024-29)];
        [[(MainView*)self.mapView containerView] setFrame:CGRectMake(0.0, 0.0, 768, 1024-20)];
        [mainViewController.stationsView setFrame:CGRectMake(0, 0, 768, 44)];
        [mainViewController.stationsView adjustSubviews];
        break;
    } default:
        break;
    }
}

@end
