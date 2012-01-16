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

@implementation SelectingTabBarViewController

@synthesize stationButton;
@synthesize linesButton;
@synthesize bookmarkButton;
@synthesize backButton;
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

    [self.tabBarController.view setFrame:CGRectMake(0,63,320,407)]; //460-63-39+49 64 было сделал 63 белая полоска
    [self.view addSubview:self.tabBarController.view];
    [self.tabBarController viewWillAppear:YES];
    [self.view bringSubviewToFront:[self.view viewWithTag:333]];
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

-(IBAction)stationsPressed:(id)sender
{
    [self.tabBarController setSelectedIndex:0];
}

-(IBAction)linesPresses:(id)sender
{
    [self.tabBarController setSelectedIndex:1];
}

-(IBAction)bookmarkPressed:(id)sender
{
    [self.tabBarController setSelectedIndex:2];
}

-(IBAction)historyPressed:(id)sender
{
    [self.tabBarController setSelectedIndex:3];
}

-(IBAction)settingsPressed:(id)sender
{
    
}

-(IBAction)backPressed:(id)sender
{
    MHelper *helper = [MHelper sharedHelper];
    [helper saveBookmarkFile];
    [helper saveHistoryFile];
    [self dismissModalViewControllerAnimated:YES];
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
