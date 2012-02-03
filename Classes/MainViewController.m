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

#define FromStation 0
#define ToStation 1

@implementation MainViewController

@synthesize fromStation;
@synthesize toStation;
@synthesize route;
@synthesize stationsView;
@synthesize currentSelection;
@synthesize scrollView;
@synthesize pathScrollView;

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
    
    NSMutableArray *colorArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
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
    NSMutableArray *timeArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
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

-(NSArray*)dsGetStationsArray
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSMutableArray *stationsArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];

    int currentIndexLine = -1;
    
    NSMutableArray *tempArray;
    
    for (int i=0; i<objectNum; i++) {

        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine==[[[segment start] line] index]) {
                
                [tempArray addObject:[[segment start] name]];
                
                NSLog(@"%@ -- %@",[[segment start] name],[[segment end] name]);
                
            } else {
                
                if (currentIndexLine!=-1) {

                    [stationsArray addObject:tempArray];    
                
                }
                
                tempArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
                
                [tempArray addObject:[[segment start] name]];

                NSLog(@"%@ -- %@",[[segment start] name],[[segment end] name]);

                currentIndexLine=[[[segment start] line] index];
            }
        }
    }
    
    [stationsArray addObject:tempArray];    
    
    return stationsArray;
}

-(NSInteger)dsGetExitForStation:(Station *)station
{
    return arc4random()%4;
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
    
    UIButton *changeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeViewButton setImage:[UIImage imageNamed:@"switch_to_path.png"] forState:UIControlStateNormal];
    [changeViewButton addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    [changeViewButton setFrame:CGRectMake(250 , 66 , 36, 37)];
    [changeViewButton setTag:333];
    [(MainView*)self.view addSubview:changeViewButton];
}

-(IBAction)changeView:(id)sender
{
    
    CGFloat transferHeight = 60.0f;
    CGFloat stationHeight = 40.0f;
    
    if (!self.pathScrollView) {
        
        UIScrollView *scview= [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 66.0, 320.0f, 414.0f)];
        self.pathScrollView = scview;
        [scview release];
        
        NSArray *stations = [self dsGetStationsArray];
        
        int transferNumb = [stations count]-1;
        
        int stationNumbers=0;
        
        for (NSMutableArray *tempStations in stations) {
            stationNumbers+=[tempStations count];
        }
        
        CGFloat viewHeight = (float)(transferNumb+1) * transferHeight + (float) stationNumbers * stationHeight;
        
        self.pathScrollView.contentSize=CGSizeMake(320.0f, viewHeight+50.0);
        self.pathScrollView.bounces=YES;
        self.pathScrollView.delegate = self;
        
        self.pathScrollView.backgroundColor = [UIColor lightGrayColor];
        
        CGFloat currentY = 15.0f;
        
        for (NSMutableArray *tempStations in stations) {
            for (NSString *stationName in tempStations) {
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY, 240.0, 35.0)];
                label.text=stationName;
                if (stationName==[tempStations objectAtIndex:0]) {
                    label.font=[UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
                } else {
                    label.font=[UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
                }
                
                label.backgroundColor=[UIColor clearColor];
                [self.pathScrollView addSubview:label];
                [label release];
                
                currentY+=stationHeight;
            }
            
            currentY+=transferHeight;
        }
        
        PathDrawVertView *drawView = [[PathDrawVertView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, viewHeight+100.0)];
        drawView.tag =20000;
        drawView.delegate=self;
        [self.pathScrollView addSubview:drawView];
        [drawView release];

        
        [(MainView*)self.view addSubview:self.pathScrollView];
        [(MainView*)self.view bringSubviewToFront:pathScrollView];
        [(MainView*)self.view bringSubviewToFront:[(MainView*)self.view viewWithTag:333]]; 
    
    } else {
        [self.pathScrollView removeFromSuperview];
        self.pathScrollView=nil;
    }
}

-(void)removeScrollView
{
    [self.scrollView removeFromSuperview];
    self.scrollView=nil;
    [[(MainView*)self.view viewWithTag:333] removeFromSuperview];
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
        if (self.pathScrollView) {
            [self changeView:nil];
        }
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
