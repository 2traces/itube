//
//  SelectingTabBarViewController.m
//  tube
//
//  Created by sergey on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectingTabBarViewController.h"
#import "StationListViewController.h"
#import "LineListViewController.h"
#import "SettingsViewController.h"
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
    // Do any additional setup after loading the view from its nib.
    
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
}

-(void)viewDidAppear:(BOOL)animated
{
    /*
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Choose a station";
    hud.labelFont = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0f];

    if (!appDelegate.mainViewController.currentSelection) {
        hud.detailsLabelText = @"of departure";
    } else {
        hud.detailsLabelText = @"of arrival";
    }
    hud.detailsLabelFont = [UIFont fontWithName:@"MyriadPro-Regular" size:20.0f];
    hud.opacity=0.7;
    hud.customView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	hud.mode = MBProgressHUDModeCustomView;

    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:1.0];
     */
}

-(void)dismissHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
//    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
//    [self presentModalViewController:controller animated:YES];
//    [controller release];
}

-(IBAction)backPressed:(id)sender
{
//    MHelper *helper = [MHelper sharedHelper];
//    [helper saveBookmarkFile];
//    [helper saveHistoryFile];
    [self dismissModalViewControllerAnimated:YES];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController returnFromSelection:[NSArray array]];
}


-(void) dealloc {
    [stationButton release];
    [linesButton release];
    [bookmarkButton release];
    [backButton release];
    [tabBarController release];
    [super dealloc];
}

@end
