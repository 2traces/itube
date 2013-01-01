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
#import "SSTheme.h"

@implementation SelectingTabBarViewController

@synthesize stationButton;
@synthesize linesButton;
@synthesize bookmarkButton;
@synthesize backButton;
@synthesize historyButton;
@synthesize settingsButton;
@synthesize tabBarController;
@synthesize delegate;
@synthesize topImageView, bottomImageView;

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

-(void)awakeFromNib
{
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        [stationButton setImage:nil forState:UIControlStateNormal];
        [stationButton setImage:nil forState:UIControlStateSelected];
        [stationButton setImage:nil forState:UIControlStateHighlighted];

        [linesButton setImage:nil forState:UIControlStateNormal];
        [linesButton setImage:nil forState:UIControlStateSelected];
        [linesButton setImage:nil forState:UIControlStateHighlighted];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self drawTopViewState:0];
    [self drawBottomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:kMapChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kLangChanged object:nil];
    
    StationListViewController *viewController1 = [[[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil] autorelease];
    LineListViewController *viewController2 = [[[LineListViewController alloc] initWithNibName:@"LineListViewController" bundle:nil] autorelease];
    BookmarkViewController *viewController3 = [[[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil] autorelease];
    HistoryViewController *viewController4 = [[[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil] autorelease];
    
    self.tabBarController = [[[CustomTabBar alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:  viewController1, viewController2, viewController3,viewController4, nil];

    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        [self.tabBarController.view setFrame:CGRectMake(0,46,320,424)]; //460-63-39+49 64 было сделал 63 белая полоска, 406 чтобы пропал эффект наезжания внизу
    } else {
        [self.tabBarController.view setFrame:CGRectMake(0,63,320,407)]; //460-63-39+49 64 было сделал 63 белая полоска, 406 чтобы пропал эффект наезжания внизу
    }
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

-(void)drawTopViewState:(int)state
{
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        [stationButton setImage:nil forState:UIControlStateNormal];
        [stationButton setImage:nil forState:UIControlStateSelected];
        [stationButton setImage:nil forState:UIControlStateHighlighted];
        
        [linesButton setImage:nil forState:UIControlStateNormal];
        [linesButton setImage:nil forState:UIControlStateSelected];
        [linesButton setImage:nil forState:UIControlStateHighlighted];
        
        [backButton setImage:nil forState:UIControlStateNormal];
        [backButton setImage:nil forState:UIControlStateSelected];
        [backButton setImage:nil forState:UIControlStateHighlighted];
        
        if (state==0) {
            topImageView.image = [[SSThemeManager sharedTheme] stationsTabBarTopBackgroundStations];
            topImageView.frame=CGRectMake(0, 0, 320, 46);
            backButton.frame=CGRectMake(37, 0, 92, 31);
            stationButton.frame=CGRectMake(116, 9, 95, 31);
            linesButton.frame=CGRectMake(197, 4, 92, 31);
        } else {
            topImageView.image = [[SSThemeManager sharedTheme] stationsTabBarTopBackgroundLines];
            topImageView.frame=CGRectMake(0, 0, 320, 46);
            backButton.frame=CGRectMake(37, 0, 92, 31);
            stationButton.frame=CGRectMake(116, 4, 92, 31);
            linesButton.frame=CGRectMake(191, 9, 95, 31);
        }
        
        [stationButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarStationButtonForState:UIControlStateNormal type:state] forState:UIControlStateNormal];
        [stationButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarStationButtonForState:UIControlStateHighlighted type:state] forState:UIControlStateHighlighted];
        [stationButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarStationButtonForState:UIControlStateSelected type:state] forState:UIControlStateSelected];
        [stationButton setTitle:@"Stations" forState:UIControlStateNormal];
        [stationButton setTitleColor:[[SSThemeManager sharedTheme] mainColor] forState:UIControlStateNormal];
        [stationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [stationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [linesButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarLineButtonForState:UIControlStateNormal type:state] forState:UIControlStateNormal];
        [linesButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarLineButtonForState:UIControlStateHighlighted type:state] forState:UIControlStateHighlighted];
        [linesButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarLineButtonForState:UIControlStateSelected type:state] forState:UIControlStateSelected];
        [linesButton setTitle:@"Lines" forState:UIControlStateNormal];
        [linesButton setTitleColor:[[SSThemeManager sharedTheme] mainColor] forState:UIControlStateNormal];
        [linesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [linesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [backButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBackButtonForState:UIControlStateNormal type:state] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBackButtonForState:UIControlStateHighlighted type:state] forState:UIControlStateHighlighted];
        [backButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBackButtonForState:UIControlStateSelected type:state] forState:UIControlStateSelected];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[[SSThemeManager sharedTheme] mainColor] forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
    }
}

-(void)drawBottomView
{
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        [bookmarkButton setImage:nil forState:UIControlStateNormal];
        [bookmarkButton setImage:nil forState:UIControlStateSelected];
        [bookmarkButton setImage:nil forState:UIControlStateHighlighted];
        
        [historyButton setImage:nil forState:UIControlStateNormal];
        [historyButton setImage:nil forState:UIControlStateSelected];
        [historyButton setImage:nil forState:UIControlStateHighlighted];
        
        [settingsButton setImage:nil forState:UIControlStateNormal];
        [settingsButton setImage:nil forState:UIControlStateSelected];
        [settingsButton setImage:nil forState:UIControlStateHighlighted];
        
        bottomImageView.image = [[SSThemeManager sharedTheme] stationsTabBarBottomBackgroundStations];
//        bottomImageView.frame=CGRectMake(0, 0, 320, 38);
        bookmarkButton.frame=CGRectMake(0, 10, 115, 20);
        historyButton.frame=CGRectMake(125, 10, 85, 20);
        settingsButton.frame=CGRectMake(220, 10, 100, 20);
        
        [bookmarkButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBookmarkButtonForState:UIControlStateNormal] forState:UIControlStateNormal];
        [bookmarkButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBookmarkButtonForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [bookmarkButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBookmarkButtonForState:UIControlStateSelected] forState:UIControlStateSelected];
        [bookmarkButton setTitle:@"Bookmarks" forState:UIControlStateNormal];
        [bookmarkButton setTitleColor:[[SSThemeManager sharedTheme] highlightColor] forState:UIControlStateNormal];
        [bookmarkButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateHighlighted];
        [bookmarkButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateSelected];
        
        [historyButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarHistoryButtonForState:UIControlStateNormal] forState:UIControlStateNormal];
        [historyButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarHistoryButtonForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [historyButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarHistoryButtonForState:UIControlStateSelected] forState:UIControlStateSelected];
        [historyButton setTitle:@"History" forState:UIControlStateNormal];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] highlightColor] forState:UIControlStateNormal];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateHighlighted];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateSelected];
        
        [settingsButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarSettingsButtonForState:UIControlStateNormal] forState:UIControlStateNormal];
        [settingsButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarSettingsButtonForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [settingsButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarSettingsButtonForState:UIControlStateSelected] forState:UIControlStateSelected];
        [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] highlightColor] forState:UIControlStateNormal];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateHighlighted];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateSelected];
        
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
    [self drawTopViewState:0];
    [self setAllButtonsUnselected];
    stationButton.selected=YES;
}

-(IBAction)linesPresses:(id)sender
{
    [self.tabBarController setSelectedIndex:1];
    [self drawTopViewState:1];
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
