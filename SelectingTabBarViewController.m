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
#import "SettingsNavController.h"
#import "BookmarkViewController.h"
#import "GalleryViewController.h"
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
        [self initGallery];
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

- (void)initGallery {
    galleryViewController = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:nil];
    [galleryViewController view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:kMapChanged object:nil];
    
    LineListViewController *viewController1 = [[[LineListViewController alloc] initWithNibName:@"LineListViewController" bundle:nil] autorelease];
    GalleryViewController *viewController2 = galleryViewController;
    BookmarkViewController *viewController3 = [[[BookmarkViewController alloc] initWithNibName:@"BookmarkViewController" bundle:nil] autorelease];
    HistoryViewController *viewController4 = [[[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil] autorelease];
    
    self.tabBarController = [[[CustomTabBar alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:  viewController1, viewController2, viewController3,viewController4, nil];

    [self.tabBarController.view setFrame:CGRectMake(0,63,320,407)]; //460-63-39+49 64 было сделал 63 белая полоска, 406 чтобы пропал эффект наезжания внизу
    [self.view addSubview:self.tabBarController.view];
    [self.tabBarController viewWillAppear:YES];
    [self.view bringSubviewToFront:[self.view viewWithTag:333]];
    
    stationButton.selected=YES;
    
    //As we use this controller's view without any holding reference to the controller itself, we need
    //to perform [self retain] and [self autorelease] (further in the code), as an exceptional way to
    //manage memory of this controller. I am aware that this is not a good practice, however, this was the easiest 
    //way to replace presentModalViewController with addSubview to be able to show the view half-screen.
    //[self retain];
}

-(void)mapChanged:(NSNotification*)note
{
    LineListViewController *viewController1 = [[[LineListViewController alloc] initWithNibName:@"LineListViewController" bundle:nil] autorelease];
    GalleryViewController *viewController2 = [[[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:nil] autorelease];
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

-(void)setAllButtonsUnselected
{
    stationButton.selected=NO;
    linesButton.selected=NO;
    bookmarkButton.selected=NO;
    historyButton.selected=NO;
    [UIView animateWithDuration:0.5f animations:^(void){
        [self.view setFrame:CGRectMake(0,0,320,460)]; 
    }];
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

    
    [UIView animateWithDuration:0.5f animations:^(void){
        [self.view setFrame:CGRectMake(0,0,320,291)]; 


    } completion:^(BOOL finished){
        if (finished) {
        }
    }];
    


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
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(IBAction)backPressed:(id)sender
{
    //[self dismissModalViewControllerAnimated:YES];
    
    CGRect frame = self.view.frame;
    frame.origin.y = self.view.superview.frame.size.height;

    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    self.view.frame = frame;
    
    [UIView commitAnimations];
    
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController returnFromSelection:[NSArray array]];
}

- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    [self.view removeFromSuperview];
    //we did call [self retain] previously, so are eligible to autorelease self
    //[self autorelease];
}

-(void) dealloc {
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
