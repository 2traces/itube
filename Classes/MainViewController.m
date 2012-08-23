//
//  MainViewController.m
//  tube
//
//  Created by Alex 1 on 9/24/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "SelectingTabBarViewController.h"
#import "ManagedObjects.h"
#import "TopTwoStationsView.h"
#import "FastAccessTableViewController.h"
#import "tubeAppDelegate.h"
#import "PathBarView.h"
#import "PathDrawView.h"
#import "PathDrawVertView.h"
#import "TubeAppIAPHelper.h"
#import "UIColor-enhanced.h"
#import "LeftiPadPathViewController.h"

#define FromStation 0
#define ToStation 1

@implementation MainViewController

@synthesize fromStation;
@synthesize toStation;
@synthesize route;
@synthesize stationsView;
@synthesize currentSelection;
@synthesize horizontalPathesScrollView;
@synthesize pathScrollView;
@synthesize timer;
@synthesize spltViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	DLog(@"initWithNibName");
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Stop holding onto the popover
    popover = nil;
    [self returnFromSelectionFastAccess:nil];
    
    if (currentSelection==0) {
        [stationsView.firstStation resignFirstResponder];
    } else {
        [stationsView.secondStation resignFirstResponder];
    }

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [(MainView*)self.view viewInit:self];
    
    TopTwoStationsView *twoStationsView = [[TopTwoStationsView alloc] init];
    self.stationsView = twoStationsView;
    [(MainView*)self.view addSubview:twoStationsView];
    [twoStationsView release];
    
    [self performSelector:@selector(refreshInApp) withObject:nil afterDelay:0.2];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:@"kLangChanged" object:nil];
}

-(void)refreshInApp
{
    [[TubeAppIAPHelper sharedHelper] requestProducts];
}

-(void)changeMapTo:(NSString*)newMap andCity:(NSString*)cityName
{
    [stationsView resetBothStations];
    
    MHelper *helper = [MHelper sharedHelper];
    [helper saveBookmarkFile];
    [helper saveHistoryFile];
    
    [[MHelper sharedHelper] clearContent];
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    // FIXME !!! some classes don't release city map
    [(MainView*)self.view setCityMap:nil];
    [appDelegate.cityMap release];
    appDelegate.cityMap = nil;
    
    CityMap *cm = [[[CityMap alloc] init] autorelease];
    [cm loadMap:newMap];
    
    [(MainView*)self.view setCityMap:cm];
    appDelegate.cityMap=cm;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMapChanged object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newMap forKey:@"current_map"];
    [defaults setObject:cityName forKey:@"current_city"];
    [defaults synchronize];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if (IS_IPAD) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 66, 480, 320-86)];
    } else {
        [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 66, 320, 480-86)];
    }
}

-(void)showTabBarViewController
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - Horizontal path views

-(UIButton*)createChangeButton
{
    UIButton *changeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"switch_to_path.png"];
    UIImage *imgh = [UIImage imageNamed:@"switch_to_path_high.png"];
    [changeViewButton setImage:img forState:UIControlStateNormal];
    [changeViewButton setImage:imgh forState:UIControlStateHighlighted];
    [changeViewButton addTarget:self action:@selector(changeMapToPathView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    CGSize dateSize = [dateString sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    [formatter release];
    
    [changeViewButton setFrame:CGRectMake(320.0-12.0-dateSize.width-img.size.width , 66 , img.size.width, img.size.height)];
    [changeViewButton setTag:333];
    
    return changeViewButton;
}

-(void)showHorizontalPathesScrollView
{
    
    if (!self.horizontalPathesScrollView) {
        
        PathScrollView *pathView = [[PathScrollView alloc] initWithFrame:CGRectMake(0.0, 26.0, 320.0, 40.0)];
        self.horizontalPathesScrollView = pathView;
        self.horizontalPathesScrollView.delegate = self;
        [pathView release];
        
        [(MainView*)self.view addSubview:horizontalPathesScrollView];
        [(MainView*)self.view bringSubviewToFront:horizontalPathesScrollView];
        
        if (IS_IPAD) {
            
        } else {
            UIButton *changeViewButton = [self createChangeButton];
            [(MainView*)self.view addSubview:changeViewButton];
        }
        
    } else {
        
        [self.horizontalPathesScrollView refreshContent];
    }
    
    [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 66, 320, 480-86)];
    
    if ([self.horizontalPathesScrollView numberOfPages]>1) {
        if ([self helpNeeded]) {
            [self.timer invalidate];
            self.timer = nil;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:horizontalPathesScrollView
                                                        selector:@selector(animateScrollView)
                                                        userInfo:nil
                                                         repeats:NO];
            
        }
    }
}

-(void)requestChangeActivePath:(NSNumber*)pathNumb {
    [self performSelector:@selector(changeActivePath:) withObject:pathNumb afterDelay:0.1];
}

-(BOOL)helpNeeded
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"])
	{
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"]<15) {
            return YES;
        } else {
            return NO;
        }
	} else {
        NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:1 forKey:@"scrollHelp"];
        [prefs synchronize];
        return YES;
    }
}

-(void)animationDidEnd
{
    NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"scrollHelp"]+1 forKey:@"scrollHelp"];
    [prefs synchronize];

    
    [self.timer invalidate];
    self.timer=nil;
}

-(void)removeHorizontalPathesScrollView
{
    [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 44, 320, 480-64)];
    
    [self.horizontalPathesScrollView removeFromSuperview];
    self.horizontalPathesScrollView=nil;
    
    [[(MainView*)self.view viewWithTag:333] removeFromSuperview];
}

#pragma mark - Vertical path views

-(void)redrawPathScrollView
{
    NSArray *subviews = [self.pathScrollView subviews];
    for (UIView *v in subviews) {
        [v removeFromSuperview];
    }
    
    [self.pathScrollView drawPathScrollView];
}

-(void)changeActivePath:(NSNumber*)pathNumb
{
    MainView *mainView = (MainView*)[self view];
    [mainView.mapView selectPath:[pathNumb intValue]];
    
    if (self.pathScrollView) {
        [self performSelector:@selector(redrawPathScrollView) withObject:nil afterDelay:0.1];
    }
}

-(IBAction)changeMapToPathView:(id)sender
{
    if (!self.pathScrollView ) {
        
        VertPathScrollView *scview= [[VertPathScrollView alloc] initWithFrame:CGRectMake(0.0, 66.0, 320.0f, 414.0f)];
        self.pathScrollView = scview;
        scview.mainController=self;
        [scview release];
        
        [self.pathScrollView drawPathScrollView];
        
        [(MainView*)self.view addSubview:self.pathScrollView];
        [(MainView*)self.view bringSubviewToFront:pathScrollView];
        [(MainView*)self.view bringSubviewToFront:self.stationsView];
        [(MainView*)self.view bringSubviewToFront:self.horizontalPathesScrollView];
        [(MainView*)self.view bringSubviewToFront:[(MainView*)self.view viewWithTag:333]];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
        shadow.frame = CGRectMake(0,66, 320, 61);
        [shadow setIsAccessibilityElement:YES];
        shadow.tag = 2321;
        [(MainView*)self.view addSubview:shadow];
        
        [(UIButton*)[(MainView*)self.view viewWithTag:333] setImage:[UIImage imageNamed:@"switch_to_map.png"] forState:UIControlStateNormal];
        [(UIButton*)[(MainView*)self.view viewWithTag:333] setImage:[UIImage imageNamed:@"switch_to_map_high.png"] forState:UIControlStateHighlighted];
        
    } else {
        
        [[(MainView*)self.view viewWithTag:2321] removeFromSuperview];
        
        [self.pathScrollView removeFromSuperview];
        self.pathScrollView=nil;
        [(UIButton*)[(MainView*)self.view viewWithTag:333] setImage:[UIImage imageNamed:@"switch_to_path.png"] forState:UIControlStateNormal];
        [(UIButton*)[(MainView*)self.view viewWithTag:333] setImage:[UIImage imageNamed:@"switch_to_path_high.png"] forState:UIControlStateHighlighted];
    }
}

-(void)showiPadLeftPathView
{
    [spltViewController showLeftView];
}

-(void)hideiPadLeftPathView
{
    [spltViewController hideLeftView];
}

#pragma mark - FastAccessTableView

-(void)toggleTap
{
    [self returnFromSelectionFastAccess:nil];
    if (currentSelection==0) {
        [stationsView.firstStation resignFirstResponder];
    } else {
        [stationsView.secondStation resignFirstResponder];
    }
}

-(FastAccessTableViewController*)showTableView
{
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0,44,320,440)];
    blackView.backgroundColor  = [UIColor blackColor];
    blackView.alpha=0.4;
    blackView.tag=554;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTap)];
    [blackView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [(MainView*)self.view addSubview:blackView];
    [blackView release];
    
    FastAccessTableViewController *tableViewC=[[[FastAccessTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    tableViewC.view.frame=CGRectMake(0,44,320,200);
    
    tableViewC.tableView.hidden=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:tableViewC selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    tableViewC.tableView.tag=555;
    
    [(MainView*)self.view addSubview:tableViewC.tableView];
    [(MainView*)self.view bringSubviewToFront:tableViewC.tableView];
    
    return tableViewC;
}

-(void)removeTableView
{
    [[(MainView*)self.view viewWithTag:554] removeFromSuperview];
    [[(MainView*)self.view viewWithTag:555] removeFromSuperview];
}

#pragma mark - iPad Livesearch

-(StationListViewController*)showiPadLiveSearchView
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    
    [popover setPopoverContentSize:CGSizeMake(320, 480)];
    controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
    
    [popover setPopoverContentSize:controller.view.frame.size];
    
    popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    popover.delegate=self;
    
    CGFloat originx;
    if (self.currentSelection==0) {
        originx = self.stationsView.firstStation.frame.origin.x;
    } else {
        originx = self.stationsView.secondStation.frame.origin.x;
    }
    
    [popover presentPopoverFromRect:CGRectMake(originx+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [controller release];
    
    StationListViewController *stations = [[controller.tabBarController viewControllers] objectAtIndex:0];
    return stations;
}

-(void)showiPadSettingsModalView
{
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    controller.delegate=self;
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:controller];
    navcontroller.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentModalViewController:navcontroller animated:YES];
    
//    navcontroller.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
//    navcontroller.view.superview.frame = CGRectMake(navcontroller.view.superview.frame.origin.x, navcontroller.view.superview.frame.origin.x, 320, 700);
//    
//    navcontroller.view.superview.center = self.view.center;
    
    [controller release];
    [navcontroller release];
}

-(void)donePressed
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Choosing stations etc

-(void)languageChanged:(NSNotification*)note
{
    if (self.fromStation) {
        [stationsView setFromStation:self.fromStation];
    }
    
    if (self.toStation) {
        [stationsView setToStation:self.toStation];
    }
}

-(void)returnFromSelection2:(NSArray*)stations
{
    MainView *mainView = (MainView*)self.view;
    
    if ([stations count]>1) {
        // это история и надо ставить обе станции
        self.fromStation = [stations objectAtIndex:0];
        self.toStation = [stations objectAtIndex:1];
        
        if (currentSelection==0) {
            [stationsView setFromStation:self.fromStation];
            [stationsView setToStation:self.toStation];
        } else {
            [stationsView setToStation:self.toStation];
            [stationsView setFromStation:self.fromStation];
        }
        
        
    } else if ([stations count]==1) {
        // это конкретная станция
        if (currentSelection==0) {
            if ([stations objectAtIndex:0]==self.toStation) {
                self.fromStation=nil;
                [stationsView resetFromStation];
            } else {
                self.fromStation = [stations objectAtIndex:0];
                [stationsView setFromStation:self.fromStation];
            }
        } else {
            if ([stations objectAtIndex:0]==self.fromStation) {
                self.toStation=nil;
                [stationsView resetToStation];
            } else {
                self.toStation = [stations objectAtIndex:0];
                [stationsView setToStation:self.toStation];
            }
        }
        
    } else if ([stations count]==0) {
        if (currentSelection==0) {
            self.fromStation=nil;
            [stationsView setFromStation:self.fromStation];
        } else {
            self.toStation=nil;
            [stationsView setToStation:self.toStation];
        }
    }
    
    if ((self.fromStation==nil || self.toStation==nil)) {
        [mainView.mapView clearPath];
        
        if (self.horizontalPathesScrollView) {
            [self removeHorizontalPathesScrollView];
        }
        
        if (self.pathScrollView) {
            [self changeMapToPathView:nil];
        }
        mainView.mapView.stationSelected=false;
	} else {
        commonActivityIndicator.delegate = self;
        [commonActivityIndicator showWhileExecuting:@selector(performFindingPath) onTarget:self withObject:nil animated:YES];
	}
    
}

-(void)performFindingPath
{
    MainView *mainView = (MainView*)self.view;
    [mainView findPathFrom:[fromStation name] To:[toStation name] FirstLine:[[[fromStation lines] index] integerValue] LastLine:[[[toStation lines] index] integerValue]];
}

- (void)hudWasHidden
{
    MainView *mainView = (MainView*)self.view;
    tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([[[delegate cityMap] activePath] count]>0) {
        if (!([[[delegate cityMap] activePath] count]==1 && [[[[delegate cityMap] activePath] objectAtIndex:0] isKindOfClass:[Transfer class]])) {
            [stationsView transitToPathView];
            if (IS_IPAD) {
                [spltViewController refreshPath];
            } else {
                [self showHorizontalPathesScrollView];
            }
        }
    }
    mainView.mapView.stationSelected=false;
}

-(void)returnFromSelection:(NSArray*)stations
{
    if (IS_IPAD) {
        if (popover) [popover dismissPopoverAnimated:YES];
        [self performSelector:@selector(returnFromSelection2:) withObject:stations afterDelay:0.1];
        
    } else {
        [self dismissModalViewControllerAnimated:YES];
        [self performSelector:@selector(returnFromSelection2:) withObject:stations afterDelay:0.1];
    }
}

-(void)returnFromSelectionFastAccess:(NSArray *)stations
{
    [self removeTableView];
    if (stations) {
        if (currentSelection==0) {
            if ([stations objectAtIndex:0]==self.toStation) {
                self.fromStation=nil;
                [stationsView resetFromStation];
            } else {
                [self returnFromSelection:stations];
            }
        } else {
            if ([stations objectAtIndex:0]==self.fromStation) {
                self.toStation=nil;
                [stationsView resetToStation];
            } else {
                [self returnFromSelection:stations];
            }
        }
        
        //      [self returnFromSelection:stations];
    } else {
        if (currentSelection==0) {
            [stationsView setFromStation:self.fromStation];
        } else {
            [stationsView setToStation:self.toStation];
        }
    }
}

-(void)pressedSelectFromStation
{
    currentSelection=FromStation;

    if (popover)
        [popover dismissPopoverAnimated:YES];
    
    if (!IS_IPAD)
    {
        [self showTabBarViewController];
    }
    else
    {
        SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
        controller.delegate = self;
        
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
        
        [popover setPopoverContentSize:controller.view.frame.size];
        
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popover presentPopoverFromRect:CGRectMake(self.stationsView.firstStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [controller release];
    }
}

-(void)pressedSelectToStation
{
    currentSelection=ToStation;

    if (popover)
        [popover dismissPopoverAnimated:YES];

    if (!IS_IPAD)
    {
        [self showTabBarViewController];
    }
    else
    {
        SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
        controller.delegate = self;
        
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
            
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popover presentPopoverFromRect:CGRectMake(self.stationsView.secondStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [controller release];
    }
}

-(void)resetFromStation
{
    currentSelection=FromStation;
    [stationsView setToStation:self.toStation];
    [self returnFromSelection:[NSArray array]];
}

-(void)resetToStation
{
    currentSelection=ToStation;
    [stationsView setFromStation:self.fromStation];
    [self returnFromSelection:[NSArray array]];
}

-(void)resetBothStations
{
    int tempSelection = currentSelection;
    
    currentSelection=FromStation;
    [stationsView setToStation:nil];
    [stationsView setFromStation:nil];
    
    self.fromStation=nil;
    self.toStation=nil;
    
    [self returnFromSelection2:[NSArray array]];
    
    currentSelection=tempSelection;
}


@end
