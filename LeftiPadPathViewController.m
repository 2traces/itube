//
//  LeftiPadPathViewController.m
//  tube
//
//  Created by sergey on 13.08.12.
//
//

#import "LeftiPadPathViewController.h"
#import "Classes/tubeAppDelegate.h"
#import "CityMap.h"
#import "Classes/MainView.h"
#import "MapView.h"

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
    
	// Do any additional setup after loading the view.
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
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *mapIDs = [dict allKeys];
    for (NSString* mapID in mapIDs) {
        NSDictionary *map = [dict objectForKey:mapID];
        if ([[map objectForKey:@"filename"] isEqual:currentMap]) {
            if ([map objectForKey:@"statusURL"]) {
                url = [NSString stringWithString:[map objectForKey:@"statusURL"]];
            }
        }
    }
    
    [dict release];
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
    [self.statusViewController fixTextView];
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
        [self.switchButton setImage:[UIImage imageNamed:@"statusButton.png"] forState:UIControlStateNormal];
        [self.switchButton setImage:[UIImage imageNamed:@"statusButtonPressed.png"] forState:UIControlStateHighlighted];
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
        
        PathScrollView *pathView = [[PathScrollView alloc] initWithFrame:CGRectMake(0.0, 4.0, 320.0, 40.0)];
        self.horizontalPathesScrollView = pathView;
        self.horizontalPathesScrollView.delegate = self;
        [pathView release];
        
        [self.view addSubview:horizontalPathesScrollView];
        [self.view bringSubviewToFront:horizontalPathesScrollView];
        
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
        self.pathScrollView = scview;
        tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
        scview.mainController=delegate.mainViewController;
        [scview release];
        
        [self.pathScrollView drawPathScrollView];
        [self.view addSubview:self.pathScrollView];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
        shadow.frame = CGRectMake(0, 44, 320, 61);
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
    UIImage *img = [UIImage imageNamed:@"statusButton.png"];
    [changeViewButton setImage:img forState:UIControlStateNormal];
    [changeViewButton setImage:[UIImage imageNamed:@"statusButtonPressed.png"] forState:UIControlStateHighlighted];
    [changeViewButton addTarget:self action:@selector(changeMapToPathView:) forControlEvents:UIControlEventTouchUpInside];
    
    [changeViewButton setFrame:CGRectMake(34 , 44 , img.size.width, img.size.height)];
    
    return changeViewButton;
}

-(IBAction)changeMapToPathView:(id)sender
{
    [self.view exchangeSubviewAtIndex:3 withSubviewAtIndex:4];
    if ([self.view.subviews objectAtIndex:4]==self.statusViewController.view) {
        self.horizontalPathesScrollView.hidden=YES;
        self.statusShadowView.hidden=YES;
        self.statusLabel.hidden=NO;
        [[self.statusViewController shadowView] setHidden:NO];
        [self.switchButton setImage:[UIImage imageNamed:@"pathButton.png"] forState:UIControlStateNormal];
        [self.switchButton setImage:[UIImage imageNamed:@"pathButtonPressed.png"] forState:UIControlStateHighlighted];

    } else {
        self.horizontalPathesScrollView.hidden=NO;
        self.statusShadowView.hidden=NO;
        self.statusLabel.hidden=YES;
        [[self.statusViewController shadowView] setHidden:YES];
        [self.switchButton setImage:[UIImage imageNamed:@"statusButton.png"] forState:UIControlStateNormal];
        [self.switchButton setImage:[UIImage imageNamed:@"statusButtonPressed.png"] forState:UIControlStateHighlighted];

        
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
