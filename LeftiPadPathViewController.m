//
//  LeftiPadPathViewController.m
//  tube
//
//  Created by Sergey Mingalev on 13.08.12.
//
//

#import "LeftiPadPathViewController.h"
#import "Classes/tubeAppDelegate.h"
#import "CityMap.h"
#import "Classes/MainView.h"
#import "MapView.h"
#import "SSTheme.h"
#import "TubeSplitViewController.h"
#import "TopTwoStationsView.h"

@implementation LeftiPadPathViewController

@synthesize horizontalPathesScrollView;
@synthesize timer;
@synthesize pathScrollView;
@synthesize statusViewController;
@synthesize switchButton;
@synthesize toolbar;
@synthesize statusLabel;
@synthesize statusShadowView;

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
    
    isPathExists=NO;
    isStatusAvailable=NO;
    
    self.toolbar = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)] autorelease];
    [self.toolbar setImage:[[UIImage imageNamed:@"toolbar_bg1.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0]];
    [self.toolbar setUserInteractionEnabled:YES];
    self.toolbar.autoresizesSubviews = YES;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.toolbar];
    
    self.statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(90, 6, 300, 40)] autorelease];
    self.statusLabel.backgroundColor=[UIColor clearColor];
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:22.0];
    self.statusLabel.text = NSLocalizedString(@"CurrentStatus", @"CurrentStatus");
    [self.view addSubview:self.statusLabel];
    self.statusLabel.hidden=YES;
    
    [self addStatusView];
    
    self.switchButton = [self createSwitchButton];
    [self.view addSubview:switchButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addStatusView
{
    StatusViewController *statusView = [[StatusViewController alloc] init];
    [self.view addSubview:statusView.view];
    self.statusViewController =statusView;
    self.statusViewController.infoURL=[self getStatusInfoURL];
    [self.statusViewController recieveStatusInfo];
    self.statusViewController.view.tag=20312;
    [statusView release];
}

-(void)removeStatusView
{
    [self.statusViewController.view removeFromSuperview];
    self.statusViewController=nil;
}

-(void)changeStatusView
{
    [self removeStatusView];
    [self addStatusView];
}

-(NSString*)getStatusInfoURL
{
    NSString *url;
    
    url = nil;
    
    NSString *mainURL=nil;
    NSString *altURL=nil;
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *mapIDs = [dict allKeys];
    for (NSString* mapID in mapIDs) {
        NSDictionary *map = [dict objectForKey:mapID];
        if ([[map objectForKey:@"filename"] isEqual:currentMap]) {
            if ([map objectForKey:@"statusURL"]) {
                mainURL = [NSString stringWithString:[map objectForKey:@"statusURL"]];
            }
            if ([map objectForKey:@"altStatusURL"]) {
                altURL = [NSString stringWithString:[map objectForKey:@"altStatusURL"]];
            }
        }
    }
    
    [dict release];
    
    if (!altURL) {
        url=mainURL;
    } else {
        NSString *composedLocalURL = [NSString stringWithFormat:@"http://metro.dim0xff.com/%@/data_%@.txt",[[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName],[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
        //        NSLog(@"%@",composedLocalURL);
        if ([mainURL isEqualToString:composedLocalURL]) {
            url = mainURL;
        } else {
            url = altURL;
        }
    }
    
    return url;
}

-(BOOL)isReadyToShow
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([[[appDelegate cityMap] activePath] count]>0) {
        isPathExists=YES;
    } else {
        isPathExists=NO;
    }
    
    if ([self.statusViewController isNewMapAvailable] || [self.statusViewController isStatusRecieved]) {
        isStatusAvailable=YES;
    } else {
        isStatusAvailable=NO;
    }
    
    if (isPathExists || isStatusAvailable) {
        return YES;
    }
    
    return NO;
}

-(void)prepareToShow
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([[[appDelegate cityMap] activePath] count]>0) {
        [self showHorizontalPathesScrollView];
        [self showVerticalPathScrollView];
        isPathExists=YES;
    } else {
        isPathExists=NO;
    }
    
    [self.statusViewController layoutSubviews];
    
    [self layoutSubviews];
}

-(void)refreshUITextView
{
    [self.statusViewController fixTextView:self.interfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.statusViewController rotateTextViewFromOrientation:fromInterfaceOrientation];
}


-(void)layoutSubviews
{
    if (isStatusAvailable==YES && isPathExists==NO) {
        // show only status
        self.statusViewController.view.hidden=NO;
        self.statusLabel.hidden=NO;
        self.horizontalPathesScrollView.hidden=YES;
        self.pathScrollView.hidden=YES;
        self.switchButton.hidden=YES;
        self.statusShadowView.hidden=YES;
        [[self.statusViewController shadowView] setHidden:NO];
    } else if (isStatusAvailable==NO && isPathExists==YES) {
        // show only path
        self.statusViewController.view.hidden=YES;
        self.pathScrollView.hidden=NO;
        self.switchButton.hidden=YES;
        self.horizontalPathesScrollView.hidden=NO;
        self.statusLabel.hidden=YES;
        self.statusShadowView.hidden=NO;
        [[self.statusViewController shadowView] setHidden:YES];
    } else if (isStatusAvailable==YES && isPathExists==YES) {
        //show both status and path
        self.statusViewController.view.hidden=NO;
        self.pathScrollView.hidden=NO;
        self.switchButton.hidden=NO;
        
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            [self.switchButton setImage:[UIImage imageNamed:@"newdes_ipad_left_buttonZ"] forState:UIControlStateNormal];
            [self.switchButton setImage:[UIImage imageNamed:@"newdes_ipad_left_buttonZ_pressed"] forState:UIControlStateHighlighted];
        } else {
            [self.switchButton setImage:[UIImage imageNamed:@"statusButton.png"] forState:UIControlStateNormal];
            [self.switchButton setImage:[UIImage imageNamed:@"statusButtonPressed.png"] forState:UIControlStateHighlighted];
        }
        
        self.horizontalPathesScrollView.hidden=NO;
        self.statusLabel.hidden=NO;
        self.statusShadowView.hidden=NO;
        [[self.statusViewController shadowView] setHidden:YES];
        
        // arrange views
        [self.view sendSubviewToBack:self.statusViewController.view];
        [self.view sendSubviewToBack:self.horizontalPathesScrollView];
        [self.view sendSubviewToBack:self.statusLabel];
        [self.view sendSubviewToBack:self.toolbar];
        [self.view bringSubviewToFront:self.pathScrollView];
        [self.view bringSubviewToFront:self.statusShadowView];
        [self.view bringSubviewToFront:self.switchButton];
    }
}

#pragma mark - Horizontal path views

-(void)showHorizontalPathesScrollView
{
    
    if (!self.horizontalPathesScrollView) {
        
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            PathScrollView *pathView = [[PathScrollView alloc] initWithFrame:CGRectMake(60.0, 10.0, 260.0, 90.0)];
            self.horizontalPathesScrollView = pathView;
            self.horizontalPathesScrollView.delegate = self;
            
            [pathView release];
            
            tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate.tubeSplitViewController.topStationsView addSubview:horizontalPathesScrollView];
        } else {
            PathScrollView *pathView = [[PathScrollView alloc] initWithFrame:CGRectMake(0.0, 4.0, 320.0, 40.0)];
            self.horizontalPathesScrollView = pathView;
            self.horizontalPathesScrollView.delegate = self;
            [pathView release];
            
            [self.view addSubview:horizontalPathesScrollView];
            [self.view bringSubviewToFront:horizontalPathesScrollView];
        }
        
        
    } else {
        
        [self.horizontalPathesScrollView refreshContent];
    }
    
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
    [self.horizontalPathesScrollView removeFromSuperview];
    self.horizontalPathesScrollView=nil;
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
    
    tubeAppDelegate *delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
    MainView *mainView = (MainView*)[delegate.mainViewController view];
    [mainView.mapView selectPath:[pathNumb intValue]];
    
    if (self.pathScrollView) {
        [self performSelector:@selector(redrawPathScrollView) withObject:nil afterDelay:0.1];
    }
}

-(void)showVerticalPathScrollView
{
    if (!self.pathScrollView ) {
        
        VertPathScrollView *scview= [[VertPathScrollView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0f, self.view.frame.size.height-44.0)];
        
        //        if ([[SSThemeManager sharedTheme] isNewTheme]) {
        //            scview.frame=CGRectMake(0.0, 44.0, 320.0f, self.view.frame.size.height-44.0-20.0);
        //            scview.layer.cornerRadius=5.0;
        //            scview.layer.shadowColor=[[UIColor blackColor] CGColor];
        //            scview.layer.shadowOpacity = 0.8;
        //            scview.layer.shadowRadius = 2;
        //            scview.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        //        }
        
        self.pathScrollView = scview;
        self.pathScrollView.tag=20313;
        tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        scview.mainController=delegate.mainViewController;
        [scview release];
        
        [self.pathScrollView drawPathScrollView];
        [self.view addSubview:self.pathScrollView];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
        shadow.frame = CGRectMake(0, 44, self.view.frame.size.width, 61);
        [shadow setIsAccessibilityElement:YES];
        self.statusShadowView=shadow;
        [self.view addSubview:shadow];
    } else {
        [self redrawPathScrollView];
    }
}

-(UIButton*)createSwitchButton
{
    UIButton *changeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img;
    UIImage *imgHigh;
    
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        img =  [UIImage imageNamed:@"newdes_ipad_left_buttonZ"];
        imgHigh = [UIImage imageNamed:@"newdes_ipad_left_buttonZ_pressed"];
        [changeViewButton setFrame:CGRectMake(253, 75 , img.size.width, img.size.height)];
    } else {
        img =  [UIImage imageNamed:@"statusButton.png"];
        imgHigh = [UIImage imageNamed:@"statusButtonPressed.png"];
        [changeViewButton setFrame:CGRectMake(34, 44 , img.size.width, img.size.height)];
    }
    
    [changeViewButton setImage:img forState:UIControlStateNormal];
    [changeViewButton setImage:imgHigh forState:UIControlStateHighlighted];
    [changeViewButton addTarget:self action:@selector(changeMapToPathView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return changeViewButton;
}

-(IBAction)changeMapToPathView:(id)sender
{
    NSInteger indexStatusView = [self.view.subviews indexOfObject:[self.view viewWithTag:20312]];
    NSInteger indexPathView = [self.view.subviews indexOfObject:[self.view viewWithTag:20313]];
    [self.view exchangeSubviewAtIndex:indexPathView withSubviewAtIndex:indexStatusView];
    
    UIImage *img;
    UIImage *imgHigh;
    
    if (indexPathView>indexStatusView) {
        self.horizontalPathesScrollView.hidden=YES;
        self.statusShadowView.hidden=YES;
        self.statusLabel.hidden=NO;
        [[self.statusViewController shadowView] setHidden:NO];
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            img =  [UIImage imageNamed:@"newdes_ipad_left_buttonM"];
            imgHigh = [UIImage imageNamed:@"newdes_ipad_left_buttonM_pressed"];
        } else {
            img =  [UIImage imageNamed:@"pathButton.png"];
            imgHigh = [UIImage imageNamed:@"pathButtonPressed.png"];
        }
        
        [self.switchButton setImage:img forState:UIControlStateNormal];
        [self.switchButton setImage:imgHigh forState:UIControlStateHighlighted];
        
    } else {
        self.horizontalPathesScrollView.hidden=NO;
        self.statusShadowView.hidden=NO;
        self.statusLabel.hidden=YES;
        [[self.statusViewController shadowView] setHidden:YES];
        
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            img =  [UIImage imageNamed:@"newdes_ipad_left_buttonZ"];
            imgHigh = [UIImage imageNamed:@"newdes_ipad_left_buttonZ_pressed"];
        } else {
            img =  [UIImage imageNamed:@"statusButton.png"];
            imgHigh = [UIImage imageNamed:@"statusButtonPressed.png"];
        }
        
        [self.switchButton setImage:img forState:UIControlStateNormal];
        [self.switchButton setImage:imgHigh forState:UIControlStateHighlighted];
    }
}

-(void)refreshStatusInfo
{
    [self.statusViewController refreshStatusInfo];
}

-(void)dealloc
{
    [horizontalPathesScrollView release];
    [timer release];
    [pathScrollView release];
    [statusShadowView release];
    [statusViewController release];
    [switchButton release];
    [toolbar release];
    [statusLabel release];
    
    [super dealloc];
}
@end
