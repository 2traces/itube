//
//  SelectingTabBarViewController.m
//  tube
//
//  Created by Sergey Mingalev on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectingTabBarViewControllerNDiPad.h"
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

@implementation SelectingTabBarViewControllerNDiPad

@synthesize stationButton;
@synthesize linesButton;
@synthesize bookmarkButton;
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

    [self.tabBarController.view setFrame:CGRectMake(12,70,317,440)]; //460-63-39+49 64 было сделал 63 белая полоска, 406 чтобы пропал
    [self.view addSubview:self.tabBarController.view];
    [self.tabBarController viewWillAppear:YES];
    [self.view bringSubviewToFront:[self.view viewWithTag:333]];
    
    stationButton.selected=YES;
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
        
        if (state==0) {
            stationButton.frame=CGRectMake(75, 18, 95, 28);
            linesButton.frame=CGRectMake(175, 18, 95, 28);
            [self.view bringSubviewToFront:stationButton];
        } else {
            stationButton.frame=CGRectMake(75, 18, 95, 28);
            linesButton.frame=CGRectMake(175, 18, 95, 28);
            [self.view bringSubviewToFront:linesButton];
        }
        
        [stationButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarStationButtonForState:UIControlStateNormal type:state] forState:UIControlStateNormal];
        [stationButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarStationButtonForState:UIControlStateHighlighted type:state] forState:UIControlStateHighlighted];
        [stationButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarStationButtonForState:UIControlStateSelected type:state] forState:UIControlStateSelected];
        
        [stationButton setTitle:NSLocalizedString(@"StationsStations", @"StationsStations") forState:UIControlStateNormal];
        
        [stationButton setTitleColor:[[SSThemeManager sharedTheme] stationsTopButtonsColor] forState:UIControlStateNormal];
        [stationButton setTitleColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedColor] forState:UIControlStateHighlighted];
        [stationButton setTitleColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedColor] forState:UIControlStateSelected];
        
        [[stationButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:16.0]];
        [stationButton setTitleEdgeInsets:UIEdgeInsetsMake(6, 0, 0, 0)];

        [[stationButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [stationButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsTopButtonsShadowColor] forState:UIControlStateNormal];
        [stationButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedShadowColor] forState:UIControlStateHighlighted];
        [stationButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedShadowColor] forState:UIControlStateSelected];

        
        [linesButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarLineButtonForState:UIControlStateNormal type:state] forState:UIControlStateNormal];
        [linesButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarLineButtonForState:UIControlStateHighlighted type:state] forState:UIControlStateHighlighted];
        [linesButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarLineButtonForState:UIControlStateSelected type:state] forState:UIControlStateSelected];

        [linesButton setTitle:NSLocalizedString(@"StationsLines", @"StationsLines") forState:UIControlStateNormal];
        
        [linesButton setTitleColor:[[SSThemeManager sharedTheme] stationsTopButtonsColor] forState:UIControlStateNormal];
        [linesButton setTitleColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedColor] forState:UIControlStateHighlighted];
        [linesButton setTitleColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedColor] forState:UIControlStateSelected];
        
        [[linesButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:16.0]];
        [linesButton setTitleEdgeInsets:UIEdgeInsetsMake(6, 0, 0, 0)];
        [[linesButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [linesButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsTopButtonsShadowColor] forState:UIControlStateNormal];
        [linesButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedShadowColor] forState:UIControlStateHighlighted];
        [linesButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsTopButtonsPressedShadowColor] forState:UIControlStateSelected];
        
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
        
        [self placeButtons];
        
        [bookmarkButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBookmarkButtonForState:UIControlStateNormal] forState:UIControlStateNormal];
        [bookmarkButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBookmarkButtonForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [bookmarkButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarBookmarkButtonForState:UIControlStateSelected] forState:UIControlStateSelected];
        [bookmarkButton setTitle:NSLocalizedString(@"StationsBookmarks", @"StationsBookmarks") forState:UIControlStateNormal];

        [bookmarkButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsColor] forState:UIControlStateNormal];
        [bookmarkButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedColor] forState:UIControlStateHighlighted];
        [bookmarkButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedColor] forState:UIControlStateSelected];
        
        [[bookmarkButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:14.0]];
        [[bookmarkButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [bookmarkButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsShadowColor] forState:UIControlStateNormal];
        [bookmarkButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedShadowColor] forState:UIControlStateHighlighted];
        [bookmarkButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedShadowColor] forState:UIControlStateSelected];
        
        [historyButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarHistoryButtonForState:UIControlStateNormal] forState:UIControlStateNormal];
        [historyButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarHistoryButtonForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [historyButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarHistoryButtonForState:UIControlStateSelected] forState:UIControlStateSelected];
        [historyButton setTitle:NSLocalizedString(@"StationsHistory", @"StationsHistory") forState:UIControlStateNormal];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] highlightColor] forState:UIControlStateNormal];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateHighlighted];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateSelected];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsColor] forState:UIControlStateNormal];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedColor] forState:UIControlStateHighlighted];
        [historyButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedColor] forState:UIControlStateSelected];
        
        [[historyButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:14.0]];
//        [historyButton setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
        [[historyButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [historyButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsShadowColor] forState:UIControlStateNormal];
        [historyButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedShadowColor] forState:UIControlStateHighlighted];
        [historyButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedShadowColor] forState:UIControlStateSelected];
        
        [settingsButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarSettingsButtonForState:UIControlStateNormal] forState:UIControlStateNormal];
        [settingsButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarSettingsButtonForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [settingsButton setBackgroundImage:[[SSThemeManager sharedTheme] stationsTabBarSettingsButtonForState:UIControlStateSelected] forState:UIControlStateSelected];
        [settingsButton setTitle:NSLocalizedString(@"StationsSettings", @"StationsSettings") forState:UIControlStateNormal];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] highlightColor] forState:UIControlStateNormal];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateHighlighted];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] titleShadowColor] forState:UIControlStateSelected];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsColor] forState:UIControlStateNormal];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedColor] forState:UIControlStateHighlighted];
        [settingsButton setTitleColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedColor] forState:UIControlStateSelected];
        
        [[settingsButton titleLabel] setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:14.0]];
        [[settingsButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
//        [settingsButton setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
        [settingsButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsShadowColor] forState:UIControlStateNormal];
        [settingsButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedShadowColor] forState:UIControlStateHighlighted];
        [settingsButton setTitleShadowColor:[[SSThemeManager sharedTheme] stationsBottomButtonsPressedShadowColor] forState:UIControlStateSelected];
        
    }
}

-(void)placeButtons
{
    CGSize bsize;
    CGSize ssize;
    CGSize hsize;
    
    bsize = [NSLocalizedString(@"StationsBookmarks", @"StationsBookmarks") sizeWithFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:14.0]];
    hsize = [NSLocalizedString(@"StationsHistory", @"StationsHistory") sizeWithFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:14.0]];
    ssize = [NSLocalizedString(@"StationsSettings", @"StationsSettings") sizeWithFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:14.0]];
    
    CGFloat signWidth = 30.0;
    
    CGFloat fff=(self.view.frame.size.width-40.0-(bsize.width+hsize.width+ssize.width+3*signWidth))/2.0;
    
    bookmarkButton.frame=CGRectMake(20, 5, bsize.width+signWidth, 25);
    historyButton.frame=CGRectMake(20+bsize.width+signWidth+fff, 5, hsize.width+signWidth, 25);
    settingsButton.frame=CGRectMake(self.view.frame.size.width-20.0-ssize.width-signWidth, 5, ssize.width+signWidth, 25);

    [bookmarkButton setTitleEdgeInsets:UIEdgeInsetsMake(5, signWidth/2.0, 0, 0)];
    [historyButton setTitleEdgeInsets:UIEdgeInsetsMake(5, signWidth/2.0, 0, 0)];
    [settingsButton setTitleEdgeInsets:UIEdgeInsetsMake(5, signWidth/2.0, 0, 0)];
    
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
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.mainViewController showiPadSettingsModalView];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMapChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLangChanged object:nil];
    
    [stationButton release];
    [linesButton release];
    [bookmarkButton release];
    [tabBarController release];
    [historyButton release];
    delegate=nil;
    [super dealloc];
}

@end
