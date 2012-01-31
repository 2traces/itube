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

#define FromStation 0
#define ToStation 1

@implementation MainViewController

@synthesize fromStation;
@synthesize toStation;
@synthesize route;
@synthesize stationsView;
@synthesize currentSelection;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	DLog(@"initWithNibName");
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [(MainView*)self.view viewInit:self];
    
    TopTwoStationsView *twoStationsView = [[TopTwoStationsView alloc] initWithFrame:CGRectMake(0,0,320,44)];
    self.stationsView = twoStationsView;
    [(MainView*)self.view addSubview:twoStationsView];
    [twoStationsView release];
}

-(NSInteger)getTravelTime
{
    /*
     @interface Segment : NSObject {
     @private
     Station *start;
     Station *end;
     int driving;
     NSMutableArray* splinePoints;
     CGRect boundingBox;
     BOOL active;
     CGMutablePathRef path;
     }
     @property (nonatomic, readonly) Station* start;
     @property (nonatomic, readonly) Station* end;
     @property (nonatomic, readonly) int driving;
     @property (nonatomic, readonly) CGRect boundingBox;
     @property (nonatomic, assign) BOOL active;
     
     -(id)initFromStation:(Station*)from toStation:(Station*)to withDriving:(int)dr;
     -(void)appendPoint:(CGPoint)p;
     -(void)calcSpline;
     -(void)draw:(CGContextRef)context;
     -(void)predraw;
     @end

     @interface Transfer : NSObject {
     @private
     NSMutableSet* stations;
     CGFloat time;
     CGRect boundingBox;
     CGLayerRef transferLayer;
     BOOL active;
     }
     @property (nonatomic, readonly) NSMutableSet* stations;
     @property (nonatomic, assign) CGFloat time;
     @property (nonatomic, readonly) CGRect boundingBox;
     @property (nonatomic, assign) BOOL active;
     
     -(void) addStation:(Station*)station;
     -(void) draw:(CGContextRef)context;
     -(void) predraw:(CGContextRef)context;
     @end

     */
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSInteger time=0;
    NSInteger lineTime=0;
    NSMutableDictionary *pathDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    int currentIndexLine = -1;
    int numberOfTransfers = 0;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {

            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine==[[[segment start] line] index]) {
                lineTime+=[segment driving];
            } else {
                lineTime=[segment driving];
                currentIndexLine=[[[segment start] line] index];
            }
            
            [pathDict setObject:[NSNumber numberWithInteger:lineTime] forKey:[NSNumber numberWithInt:[[[segment start] line] index]]];    
            
            time+=[segment driving];
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            numberOfTransfers+=1;
            time+=[[path objectAtIndex:i] time];
        }
    }
    
    NSLog(@"number of transfers - %d",numberOfTransfers);
    NSLog(@"%@",pathDict);
    
    return time;
}

-(NSMutableDictionary*)getLineSegments
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSInteger transferTime=0;
    NSInteger lineTime=0;
    NSMutableDictionary *pathDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    int currentIndexLine = -1;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine==[[[segment start] line] index]) {
                lineTime+=[segment driving];
            } else {
                lineTime=[segment driving];
                currentIndexLine=[[[segment start] line] index];
            }
            
            [pathDict setObject:[NSNumber numberWithInteger:lineTime] forKey:[NSNumber numberWithInt:[[[segment start] line] index]]];    
            
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {

            transferTime+=[[path objectAtIndex:i] time];
            [pathDict setObject:[NSNumber numberWithInteger:transferTime] forKey:[NSNumber numberWithInt:-1]];    
        }
    }
    
    return pathDict;
}


-(NSString*)getArrivalTimeFromNow:(NSInteger)time
{
    
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceNow:time*60.0]; 
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    
    NSString *arrivalTime = [formatter stringFromDate:newDate];
    
    [formatter release];
    
    return arrivalTime;
}

-(NSInteger) getOverallTravelAndTransferTimeFromPath:(NSMutableDictionary*)pathInfo
{
    NSInteger travelTime;
    
    travelTime=0;
    
    for (NSNumber *key in [pathInfo allKeys]) {
        travelTime+=[[pathInfo objectForKey:key] integerValue];
    }
    
    return travelTime;
}

-(NSInteger) getTravelTimeFromPath:(NSMutableDictionary*)pathInfo
{
    NSInteger travelTime;
    
    travelTime=0;
    
    for (NSNumber *key in [pathInfo allKeys]) {
        if ([key intValue]!=-1) {
            travelTime+=[[pathInfo objectForKey:key] integerValue];
        }
    }
    
    return travelTime;
}

-(NSInteger)dsGetTravelTime
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSInteger transferTime=0;
    NSInteger lineTime=0;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            Segment *segment = (Segment*)[path objectAtIndex:i];
            lineTime+=[segment driving];
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            transferTime+=[[path objectAtIndex:i] time];
        }
    }
    
    return lineTime+transferTime;
}

-(NSArray*)dsGetLinesColorArray
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithCapacity:1];
    int currentIndexLine = -1;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine!=[[[segment start] line] index]) {
                [colorArray addObject:[[[segment start] line] color]];
                currentIndexLine=[[[segment start] line] index];
            }
        } 
    }
    
    return colorArray;
}

-(NSArray*)dsGetLinesTimeArray
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSInteger lineTime=0;
    NSMutableArray *timeArray = [[NSMutableArray alloc] initWithCapacity:1];
    int currentIndexLine = -1;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine==[[[segment start] line] index]) {
                
                lineTime+=[segment driving];
            
            } else {

                if (currentIndexLine!=-1) {
                    [timeArray addObject:[NSNumber numberWithInteger:lineTime]];    
                }
                
                lineTime=[segment driving];
                currentIndexLine=[[[segment start] line] index];
            }
        }
    }
    
    [timeArray addObject:[NSNumber numberWithInteger:lineTime]];    
    
    return timeArray;
}

-(void)showScrollView
{
    int numberOfPages=1;

    if (!self.scrollView) {
        
        UIScrollView *scview= [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 26.0, 320.0f, 40.0f)];
        self.scrollView = scview;
        [scview release];
        
        self.scrollView.contentSize=CGSizeMake(numberOfPages * 320.0f, 40.0);
        self.scrollView.pagingEnabled = YES; 
        self.scrollView.bounces=NO;
        self.scrollView.showsVerticalScrollIndicator=NO;
        self.scrollView.showsHorizontalScrollIndicator=NO;
        self.scrollView.delegate = self;
        
        for (int i=0; i<numberOfPages; i++) {
            PathBarView *pathView = [[PathBarView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40)];
            [self.scrollView addSubview:pathView];
            pathView.tag=20000;
            [pathView release];
         }
        
        [(MainView*)self.view addSubview:scrollView];
        [(MainView*)self.view bringSubviewToFront:scrollView];
    } 
        
    for (int i=0; i<numberOfPages; i++) {
        
        NSInteger travelTime = [self dsGetTravelTime];
 
        [(UILabel*)[self.scrollView viewWithTag:6000+i] setText:[NSString stringWithFormat:@"%d minutes",travelTime]];
        [(UILabel*)[self.scrollView viewWithTag:7000+i] setText:[NSString stringWithFormat:@"%@",[self getArrivalTimeFromNow:travelTime]]];
        
        [(PathDrawView*)[self.scrollView viewWithTag:10000+i] setDelegate:self];
        [[self.scrollView viewWithTag:10000+i] setNeedsDisplay];
    }
}

-(void)removeScrollView
{
    [self.scrollView removeFromSuperview];
    self.scrollView=nil;
}

-(FastAccessTableViewController*)showTableView
{
    FastAccessTableViewController *tableViewC=[[[FastAccessTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    tableViewC.view.frame=CGRectMake(0,44,320,200);
    
    [[NSNotificationCenter defaultCenter] addObserver:tableViewC selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    tableViewC.tableView.tag=555;
    [(MainView*)self.view addSubview:tableViewC.tableView];
    [(MainView*)self.view bringSubviewToFront:tableViewC.tableView];
    
    return tableViewC;
}

-(void)removeTableView
{
    [[(MainView*)self.view viewWithTag:555] removeFromSuperview];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

-(void)showTabBarViewController
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(void)transitToRouteState
{
    
}

-(void)returnFromSelection:(NSArray*)stations
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
        //       [self.stationsView transitToRouteState]; // with Station1 Station2
        //     [self.routeScrollView appear];
        
        
    } else if ([stations count]==1) {
        // это конкретная станция
        if (currentSelection==0) {
            if ([stations objectAtIndex:0]==self.toStation) {
                self.fromStation=nil;
            } else {
                self.fromStation = [stations objectAtIndex:0];
            }
            
            [stationsView setFromStation:self.fromStation];
        } else {
            if ([stations objectAtIndex:0]==self.fromStation) {
                self.toStation=nil;
            } else {
                self.toStation = [stations objectAtIndex:0];
            }
            
            [stationsView setToStation:self.toStation];
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
        [self removeScrollView];
	} else {
        [mainView findPathFrom:[fromStation name] To:[toStation name] FirstLine:[[[fromStation lines] index] integerValue] LastLine:[[[toStation lines] index] integerValue]];
        [stationsView transitToPathView];
        [self showScrollView];
	}
    
	mainView.mapView.stationSelected=false;
    
    MHelper *helper = [MHelper sharedHelper];
    [helper saveBookmarkFile];
    [helper saveHistoryFile];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)returnFromSelectionFastAccess:(NSArray *)stations
{
    [self removeTableView];
    if (stations) {
        [self returnFromSelection:stations];
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
    [self showTabBarViewController];
}

-(void)pressedSelectToStation
{
    currentSelection=ToStation;
    [self showTabBarViewController];
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


@end
