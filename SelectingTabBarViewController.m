//
//  SelectingTabBarViewController.m
//  tube
//
//  Created by Sergey Mingalev on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectingTabBarViewController.h"
#import "StationListViewController.h"
#import "LineListViewController.h"
#import "SettingsViewController.h"
#import "SettingsNavController.h"
#import "BookmarkViewController.h"
#import "HistoryViewController.h"
#import "CustomTabBar.h"
#import "ManagedObjects.h"
#import "MBProgressHUD.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"

@implementation SelectingTabBarViewController

@synthesize stationButton;
@synthesize linesButton;
@synthesize bookmarkButton;
@synthesize backButton;
@synthesize historyButton;
@synthesize settingsButton;
@synthesize tabBarController;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:kMapChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kLangChanged object:nil];
    
    StationListViewController *viewController1 = [[[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil] autorelease];
    LineListViewController *viewController2 = [[[LineListViewController alloc] initWithNibName:@"LineListViewController" bundle:nil] autorelease];
    BookmarkViewController *viewController3 = [[[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil] autorelease];
    HistoryViewController *viewController4 = [[[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil] autorelease];
    
    self.tabBarController = [[[CustomTabBar alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:  viewController1, viewController2, viewController3,viewController4, nil];

    [self.tabBarController.view setFrame:CGRectMake(0,63,320,407)]; //460-63-39+49 64 было сделал 63 белая полоска, 406 чтобы пропал эффект наезжания внизу
    
    [self.view addSubview:self.tabBarController.view];
    [self.tabBarController viewWillAppear:YES];
    [self.view bringSubviewToFront:[self.view viewWithTag:333]];
    
    stationButton.selected=YES;
    
    if (IS_IPAD) {
        backButton.hidden=YES;
        CGFloat stationW = stationButton.frame.size.width;
        CGFloat linesW = linesButton.frame.size.width;
        CGFloat originX = (320 - stationW - linesW) /3.0;
        stationButton.frame=CGRectMake(originX, stationButton.frame.origin.y, stationButton.frame.size.width, stationButton.frame.size.height);
        linesButton.frame=CGRectMake(2*originX+stationButton.frame.size.width, linesButton.frame.origin.y, linesButton.frame.size.width, linesButton.frame.size.height);
    }
}

-(void)mapChanged:(NSNotification*)note
{
    StationListViewController *viewController1 = [[[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil] autorelease];
    LineListViewController *viewController2 = [[[LineListViewController alloc] initWithNibName:@"LineListViewController" bundle:nil] autorelease];
    BookmarkViewController *viewController3 = [[[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil] autorelease];
    HistoryViewController *viewController4 = [[[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil] autorelease];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:  viewController1, viewController2, viewController3,viewController4, nil];
}

-(void)languageChanged:(NSNotification*)note
{
    StationListViewController *viewController1 = [[[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil] autorelease];
    LineListViewController *viewController2 = [[[LineListViewController alloc] initWithNibName:@"LineListViewController" bundle:nil] autorelease];
    BookmarkViewController *viewController3 = [[[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil] autorelease];
    HistoryViewController *viewController4 = [[[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil] autorelease];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:  viewController1, viewController2, viewController3,viewController4, nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskPortrait;
    return 1 << UIInterfaceOrientationPortrait;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)setAllButtonsUnselected
{
    stationButton.selected=NO;
    linesButton.selected=NO;
    bookmarkButton.selected=NO;
    historyButton.selected=NO;
}

-(IBAction)stationsPressed:(id)sender
{
    [self.tabBarController setSelectedIndex:0];
    [self setAllButtonsUnselected];
    stationButton.selected=YES;
}

-(IBAction)linesPresses:(id)sender
{
    [self.tabBarController setSelectedIndex:1];
    [self setAllButtonsUnselected];
    linesButton.selected=YES;
}

-(IBAction)bookmarkPressed:(id)sender
{
    [self.tabBarController setSelectedIndex:2];
    [self setAllButtonsUnselected];
    bookmarkButton.selected=YES;
}

-(IBAction)historyPressed:(id)sender
{
    [self.tabBarController setSelectedIndex:3];
    [self setAllButtonsUnselected];
    historyButton.selected=YES;
}

-(IBAction)settingsPressed:(id)sender
{
    if (IS_IPAD) {
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.mainViewController showiPadSettingsModalView];
    } else {
        SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
}

-(IBAction)backPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController returnFromSelection:[NSArray array]];
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMapChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLangChanged object:nil];
    
    [stationButton release];
    [linesButton release];
    [bookmarkButton release];
    [backButton release];
    [tabBarController release];
    [historyButton release];
    delegate=nil;
    [super dealloc];
}

@end
