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
#import "CustomPopoverBackgroundView.h"
#import "StatusViewController.h"

#define FromStation 0
#define ToStation 1

@interface UIPopoverController(removeInnerShadow)

- (void)removeInnerShadow;
- (void)presentPopoverWithoutInnerShadowFromRect:(CGRect)rect
                                          inView:(UIView *)view
                        permittedArrowDirections:(UIPopoverArrowDirection)direction
                                        animated:(BOOL)animated;

- (void)presentPopoverWithoutInnerShadowFromBarButtonItem:(UIBarButtonItem *)item
                                 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                                                 animated:(BOOL)animated;

@end

@implementation UIPopoverController(removeInnerShadow)

- (void)presentPopoverWithoutInnerShadowFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)direction animated:(BOOL)animated
{
    [self presentPopoverFromRect:rect inView:view permittedArrowDirections:direction animated:animated];
    [self removeInnerShadow];
}

- (void)presentPopoverWithoutInnerShadowFromBarButtonItem:(UIBarButtonItem *)item
                                 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                                                 animated:(BOOL)animated
{
    [self presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
    [self removeInnerShadow];
}

- (void)removeInnerShadow
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    for (UIView *windowSubView in window.subviews)
    {
        if ([NSStringFromClass([windowSubView class]) isEqualToString:@"UIDimmingView"])
        {
            for (UIView *dimmingViewSubviews in windowSubView.subviews)
            {
                for (UIView *popoverSubview in dimmingViewSubviews.subviews)
                {
                    if([NSStringFromClass([popoverSubview class]) isEqualToString:@"UIView"])
                    {
                        for (UIView *subviewA in popoverSubview.subviews)
                        {
                            if ([NSStringFromClass([subviewA class]) isEqualToString:@"UILayoutContainerView"])
                            {
                                subviewA.layer.cornerRadius = 7;
                                subviewA.layer.borderColor = [UIColor grayColor].CGColor;
                                subviewA.layer.borderWidth = 0.0f;
                            }
                            
                            for (UIView *subviewB in subviewA.subviews)
                            {
                                if ([NSStringFromClass([subviewB class]) isEqualToString:@"UIImageView"] )
                                {
                                    [subviewB removeFromSuperview];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@end

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
@synthesize statusViewController;
@synthesize changeViewButton;

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
    
    if (!IS_IPAD) {
        NSString *url = [self getStatusInfoURL];
        if (url) {
            [self addStatusView:url];
        }
    }
    
    TopTwoStationsView *twoStationsView = [[TopTwoStationsView alloc] init];
    self.stationsView = twoStationsView;
    [(MainView*)self.view addSubview:twoStationsView];
    [twoStationsView release];
    
    UISwipeGestureRecognizer *swipeRecognizerD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [swipeRecognizerD setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.stationsView addGestureRecognizer:swipeRecognizerD];
    [swipeRecognizerD release];
    
    [self performSelector:@selector(refreshInApp) withObject:nil afterDelay:0.2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:@"kLangChanged" object:nil];
    
}

// --- status lines

-(NSString*)getStatusInfoURL
{
    NSString *url;
    
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

-(void)addStatusView:(NSString*)url
{
    StatusViewController *statusView = [[StatusViewController alloc] init];
    [(MainView*)self.view addSubview:statusView.view];
    self.statusViewController =statusView;
    self.statusViewController.infoURL=url;
    [self.statusViewController recieveStatusInfo];
    [statusView release];    
}

-(void)handleSwipeDown:(UISwipeGestureRecognizer*)recognizer
{
    if (!self.horizontalPathesScrollView && self.statusViewController) {
        [StatusViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInitialSizeView) object:nil];
        [self.statusViewController showFullSizeView];
    }
}

// --- status lines

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
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

//- (BOOL)shouldAutorotate {
//        return YES;
//}
//
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
//}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (IS_IPAD) {

    } else {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            self.stationsView.hidden=NO;
            self.horizontalPathesScrollView.hidden=NO;
            self.changeViewButton.hidden=NO;
            
            tubeAppDelegate * delegate = (tubeAppDelegate*)[[UIApplication sharedApplication] delegate];
            if ([[[delegate cityMap] activePath] count]>0) {
                if (!([[[delegate cityMap] activePath] count]==1 && [[[[delegate cityMap] activePath] objectAtIndex:0] isKindOfClass:[Transfer class]])) {
                    if (!IS_IPAD) {
                        [stationsView transitToPathView];
                        [self showHorizontalPathesScrollView];
                    }
                }
            }
        }
    }
    
    [timeArray addObject:[NSNumber numberWithInteger:lineTime]];    
    
    return timeArray;
}

-(NSArray*)dsGetStationsArray
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.pathStationsList;
    
    int objectNum = [path count];
    
    NSMutableArray *stationsArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    NSMutableArray *tempArray= [[[NSMutableArray alloc] init] autorelease];
    
    for (int i=0; i<objectNum; i++) {
        
        if ([(NSString*)[path objectAtIndex:i] isEqual:@"---"]) {
            
            [stationsArray addObject:tempArray];
            
            tempArray = [[[NSMutableArray alloc] init] autorelease];
            
        } else {
            
            [tempArray addObject:[path objectAtIndex:i]];
        }
    }
    
    [stationsArray addObject:tempArray]; 
    
    return stationsArray;
}


-(NSMutableArray*)dsGetExitForStations
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *pathX = appDelegate.cityMap.activePath;
    
    NSMutableArray *path = [self normalizePath:pathX];
    
    NSMutableArray *stationsArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    if ([[path objectAtIndex:0] isKindOfClass:[Transfer class]]) {
        [path removeObjectAtIndex:0];
    }
    
    int objectNum = [path count];
    
    Segment *tempSegment = nil;
    
//    if([[path objectAtIndex:0] isKindOfClass:[Segment class]]) {
//        tempSegment = [path objectAtIndex:0];
//        NSInteger aaa = [[tempSegment start] transferWayTo:[tempSegment end]];
//        [stationsArray addObject:[NSNumber numberWithInteger:aaa]];
//    }
    
    for (int i=0; i<objectNum; i++) {
        
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            tempSegment = (Segment*)[path objectAtIndex:i];
            
            [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 44.0, 320.0, 61.0)];
                
        } else {
            
            Transfer *transfer = (Transfer*)[path objectAtIndex:i];
            
            Station *s0, *s1, *s2, *s3;
            
            //Station *startStation = [tempSegment end];
            if([transfer.stations containsObject:tempSegment.end]) {
                s0 = tempSegment.start;
                s1 = tempSegment.end;
            } else {
                s0 = tempSegment.end;
                s1 = tempSegment.start;
            }
            
            NSArray *array = [[transfer stations] allObjects];
            Segment *nextSegment = nil;
            //Station *endStation;
            // transfer can contain more than two stations
            if(i < objectNum-1 && [[path objectAtIndex:(i+1)] isKindOfClass:[Segment class]]) {
                nextSegment = (Segment*)[path objectAtIndex:(i+1)];
                if([transfer.stations containsObject:nextSegment.start]) {
                    s2 = nextSegment.start;
                    s3 = nextSegment.end;
                } else {
                    s2 = nextSegment.end;
                    s3 = nextSegment.start;
                }
                //endStation = [nextSegment start];
            } else {
                if ([array objectAtIndex:0]==s1) {
                    s2 = [array objectAtIndex:1];
                } else {
                    s2 = [array objectAtIndex:0];
                }
            }
            
            NSInteger aaa = NOWAY;
            if(tempSegment != nil && nextSegment != nil) {
                aaa = [s1 megaTransferWayFrom:s0 to:s2 andNextStation:s3];
            } else if(tempSegment != nil) {
                aaa = [s1 megaTransferWayFrom:s0 to:s2];
            } else
                aaa = [s1 transferWayTo:s2];
            
            [stationsArray addObject:[NSNumber numberWithInteger:aaa]];
        }
        
    }
    
    NSInteger aaa = [[tempSegment start] transferWayTo:[tempSegment end]];
    [stationsArray addObject:[NSNumber numberWithInteger:aaa]];

    //NSInteger aaa = [[tempSegment end] transferWayFrom:[tempSegment start]];
    
    //[stationsArray addObject:[NSNumber numberWithInteger:aaa]];
    
    //    NSLog(@"%@",stationsArray);
    
    return stationsArray;
    
}

-(NSMutableArray*)dsGetVeniceExitForStations
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *pathX = appDelegate.cityMap.activePath;
    NSArray *exits = appDelegate.cityMap.pathDocksList;
    
    NSMutableArray *stationsArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
//    for (int i=0; i<[pathX count]; i++) {
//        
//        if ([[pathX objectAtIndex:i] isKindOfClass:[Transfer class]]) {
//            [stationsArray addObject:[exits objectAtIndex:i]];
//        } 
//    }
    
    return stationsArray;
}

-(NSMutableArray*)dsGetEveryStationTimeScheduled
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSArray *times = appDelegate.cityMap.pathTimesList;
    
    NSMutableArray *stationsArray = [NSMutableArray array];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    
    int currentIndexLine = -1;
    
    int a=0;
    
    NSMutableArray *tempArray;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            Segment *segment = (Segment*)[path objectAtIndex:i];
            if (currentIndexLine==[[[segment start] line] index]) {
                [tempArray addObject:[formatter stringFromDate:[times objectAtIndex:a]]];
                a++;
            } else {
                if (currentIndexLine!=-1) {
                    [stationsArray addObject:tempArray]; 
                }
                tempArray = [NSMutableArray array];
                [tempArray addObject:[formatter stringFromDate:[times objectAtIndex:a]]];
                a++;
                [tempArray addObject:[formatter stringFromDate:[times objectAtIndex:a]]];
                a++;
                currentIndexLine=[[[segment start] line] index];
            }
            
            if (self.statusViewController.isShown) {
                [self.statusViewController hideFullSizeView];
            }
            
            [(MainView*)self.view changeShadowFrameToRect:CGRectMake(0.0, 0.0, 480.0, 61.0)];
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (IS_IPAD) {
        if (popover) [popover dismissPopoverAnimated:YES];
    } else {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 0, 480, 320-20)];
        } else {
            [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 40, 320, 480-60)];
        }
    }
}

-(void)showTabBarViewController
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(NSMutableArray*)dsGetDirectionNames
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *stn1 = self.fromStation.name, *stn2 = nil;
    NSArray *path = appDelegate.cityMap.activePath;    
    //NSMutableArray *path = [self normalizePath:pathX];
    int objectNum = [path count];
    
    NSMutableArray *directionsArray = [[[NSMutableArray alloc] initWithCapacity:objectNum] autorelease];
    int currentIndexLine = -1;
    
    NSString *directionName;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            BOOL forward = NO;
            if([segment.start.name isEqualToString:stn1]) {
                stn2 = segment.end.name;
                forward = YES;
            } else {
                stn2 = segment.start.name;
                forward = NO;
            }
            
            if (currentIndexLine!=[[[segment start] line] index]) {
                
                NSMutableString *finalStation = [NSMutableString stringWithString:@""];
                
                //if([[segment start] checkForwardWay:[segment end]]) {
                if(forward) {
                    for (Station *station in [[segment start] lastStations]) {
                        if ([finalStation isEqual:@""]) {
                            [finalStation appendFormat:@"%@",[station name]];
                        } else {
                            [finalStation appendFormat:@", %@",[station name]];
                        }
                    }
                } else {
                    for (Station *station in [[segment start] firstStations]) {
                        if ([finalStation isEqual:@""]) {
                            [finalStation appendFormat:@"%@",[station name]];
                        } else {
                            [finalStation appendFormat:@", %@",[station name]];
                        }
                    }
                }
                
                directionName=[NSString stringWithFormat:@"%@, direction %@",[[[segment start] line] name],finalStation];
                [directionsArray addObject:directionName];  
                currentIndexLine=[[[segment start] line] index];
            }
            stn1 = stn2;
        }
    }
    
    return directionsArray;
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
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"switch_to_path.png"];
    UIImage *imgh = [UIImage imageNamed:@"switch_to_path_high.png"];
    [changeButton setImage:img forState:UIControlStateNormal];
    [changeButton setImage:imgh forState:UIControlStateHighlighted];
    [changeButton addTarget:self action:@selector(changeMapToPathView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    CGSize dateSize = [dateString sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    [formatter release];
    
    [changeButton setFrame:CGRectMake(320.0-12.0-dateSize.width-img.size.width , 66 , img.size.width, img.size.height)];
    
    return changeButton;
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
            self.changeViewButton = [self createChangeButton];
            [(MainView*)self.view addSubview:self.changeViewButton];
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
    
    [self.changeViewButton removeFromSuperview];
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
    
    NSArray *timeArray = [self dsGetLinesTimeArray];
    
    for (int i=0;i<[timeArray count]-1;i++)
    {
        currentY=0;
        
        NSArray *array = [points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, i+1)]];
        
        for (NSNumber *segmentH in array) {
            currentY+=[segmentH floatValue];
        }
        
        currentY+=lineStart;
        
        CGRect rect1 = CGRectMake(40.0, currentY-16.0, 235, 22.0);
        CGRect rect2 = CGRectMake(40.0, currentY+8.0, 235, 22.0);
        
        NSString *stationName1 = [[stations objectAtIndex:i] lastObject];            
        NSString *stationName2 = [[stations objectAtIndex:i+1] objectAtIndex:0];
        
        if ([stationName1 isEqualToString:stationName2]) {
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY-6.0, 235, 22.0)];
            label1.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
            label1.text=stationName1;
            label1.backgroundColor=[UIColor clearColor];
            [self.pathScrollView addSubview:label1];
            [label1 release];
            
            
        } else {
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:rect1];
            label1.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
            label1.text=stationName1;
            label1.backgroundColor=[UIColor clearColor];
            [self.pathScrollView addSubview:label1];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:rect2];
            label2.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
            label2.text=stationName2;
            label2.backgroundColor=[UIColor clearColor];
            [self.pathScrollView addSubview:label2];
            [label2 release];
            
        }
        
        if ([stationName1 isEqualToString:stationName2] && [appDelegate.cityMap.pathTimesList count] == 0) {
            
            NSString *dateString1 = [[fixedStationsTime objectAtIndex:i] lastObject];
            CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-8.0, dateSize1.width, 25.0)];
            dateLabel1.text = dateString1;
            dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel1.backgroundColor = [UIColor clearColor];
            dateLabel1.textColor = [UIColor darkGrayColor];
            [self.pathScrollView addSubview:dateLabel1];
            [dateLabel1 release];
            
        } else {
            
            NSString *dateString1=[[fixedStationsTime objectAtIndex:i] lastObject];
            CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-16.0, dateSize1.width, 25.0)];
            dateLabel1.text = dateString1;
            dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel1.backgroundColor = [UIColor clearColor];
            dateLabel1.textColor = [UIColor darkGrayColor];
            [self.pathScrollView addSubview:dateLabel1];
            [dateLabel1 release];
            
            
            NSString *dateString2 = [[fixedStationsTime objectAtIndex:i+1] objectAtIndex:0];
            CGSize dateSize2 = [dateString2 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize2.width, currentY+8.0, dateSize2.width, 25.0)];
            dateLabel2.text = dateString2;
            dateLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel2.backgroundColor = [UIColor clearColor];
            dateLabel2.textColor = [UIColor darkGrayColor];
            [self.pathScrollView addSubview:dateLabel2];
            [dateLabel2 release];
            
        }
    } 
    
    
    PathDrawVertView *drawView = [[PathDrawVertView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, viewHeight+100.0)];
    drawView.tag =20000;
    drawView.delegate=self;
    [self.pathScrollView addSubview:drawView];
    [drawView release];
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
        [(MainView*)self.view bringSubviewToFront:self.changeViewButton];
        
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainscreen_shadow"]] autorelease];
        shadow.frame = CGRectMake(0,66, 320, 61);
        [shadow setIsAccessibilityElement:YES];
        shadow.tag = 2321;
        [(MainView*)self.view addSubview:shadow];
        
        [self.changeViewButton setImage:[UIImage imageNamed:@"switch_to_map.png"] forState:UIControlStateNormal];
        [self.changeViewButton setImage:[UIImage imageNamed:@"switch_to_map_high.png"] forState:UIControlStateHighlighted];
        
    } else {
        
        [self removeVerticalPathView];
        
    }
}

-(void)removeVerticalPathView
{
    [[(MainView*)self.view viewWithTag:2321] removeFromSuperview];
    
    [self.pathScrollView removeFromSuperview];
    self.pathScrollView=nil;
    [self.changeViewButton setImage:[UIImage imageNamed:@"switch_to_path.png"] forState:UIControlStateNormal];
    [self.changeViewButton setImage:[UIImage imageNamed:@"switch_to_path_high.png"] forState:UIControlStateHighlighted];
}

-(void)showiPadLeftPathView
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
//    if (appDelegate.cityMap.activeExtent.size.width!=0) {
        [spltViewController showLeftView];
//    }
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
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        controller.contentSizeForViewInPopover=CGSizeMake(320, 200);
        [popover setPopoverContentSize:CGSizeMake(320, 220)];
    } else {
        controller.contentSizeForViewInPopover=CGSizeMake(320, 460);
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
    }
    
    [popover setPopoverContentSize:controller.view.frame.size];
    
    popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    popover.delegate=self;
    
    CGFloat originx;
    if (self.currentSelection==0) {
        originx = self.stationsView.firstStation.frame.origin.x;
    } else {
        originx = self.stationsView.secondStation.frame.origin.x;
    }
    
    popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
    //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.firstStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(originx+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
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
            if (IS_IPAD) {
                [stationsView transitToPathView];
                [spltViewController refreshPath];
            } else {
                if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                    [stationsView transitToPathView];
                    [self showHorizontalPathesScrollView];
                    if (self.statusViewController.isShown) {
                        [self.statusViewController hideFullSizeView];
                    }
                }
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
        popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
        //        [popover presentPopoverFromRect:CGRectMake(self.stationsView.firstStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.firstStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
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
        popover.popoverBackgroundViewClass = [CustomPopoverBackgroundView class];
        [popover presentPopoverWithoutInnerShadowFromRect:CGRectMake(self.stationsView.secondStation.frame.origin.x+80.0, 30.0, 0.0, 0.0) inView:self.stationsView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];;
        [controller release];
    }
}

-(void)resetFromStation
{
    currentSelection=FromStation;
    [stationsView setToStation:self.toStation];
    [self returnFromSelection:[NSArray array]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
}

-(void)resetToStation
{
    currentSelection=ToStation;
    [stationsView setFromStation:self.fromStation];
    [self returnFromSelection:[NSArray array]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPathCleared" object:nil];
}


@end
