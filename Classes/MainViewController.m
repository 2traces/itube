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
    
    [self performSelector:@selector(refreshInApp) withObject:nil afterDelay:0.2];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMapChanged object:nil];
    
    [(MainView*)self.view setCityMap:cm];
    appDelegate.cityMap=cm;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newMap forKey:@"current_map"];
    [defaults setObject:cityName forKey:@"current_city"];
    [defaults synchronize];
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

#pragma mark - datasource methods

-(NSMutableArray*)normalizePath:(NSArray*)path
{
    int count = [path count];
    
    // determing first Station
    
    Station *firstStation;
    
    if (count>0) {
        if ([[path objectAtIndex:0] isKindOfClass:[Segment class]]) {
            Segment *firstSegment = (Segment*)[path objectAtIndex:0];
            Station *someStation = [firstSegment start];
            if ([someStation.name isEqual:[self.fromStation name]] && someStation.line.index == [self.fromStation.lines.index intValue]) {
                firstStation = someStation;
            } else {
                firstStation = [firstSegment end];
            }
        } else {
            Transfer *transfer = (Transfer*)[path objectAtIndex:0];
            NSArray *array = [[transfer stations] allObjects];
            Station *someStation = [array objectAtIndex:0];
            if ([someStation.name isEqual:[self.fromStation name]] && someStation.line.index == [self.fromStation.lines.index intValue]) {
                firstStation = someStation;
            } else {
                firstStation = [array objectAtIndex:1];
            }
        }
    }
    
    NSMutableArray *normalPath = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    Station *threadStart = firstStation;
    
    for (int i=0; i<count; i++) {
        
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *tempSegment = (Segment*)[path objectAtIndex:i];
            
            if ([tempSegment start] != threadStart) {
                
                Segment *newSegment = [[[Segment alloc] initFromStation:[tempSegment end] toStation:[tempSegment start] withDriving:[tempSegment driving]] autorelease];
                [normalPath addObject:newSegment];
                threadStart=[tempSegment start];
                
            } else {
                
                [normalPath addObject:tempSegment];
                threadStart =[tempSegment end];
                
            }
            
        } else {
            
            Transfer *transfer = (Transfer*)[path objectAtIndex:i];
            
            NSArray *array = [[transfer stations] allObjects];
            
            if ([array objectAtIndex:0]==threadStart) {
                threadStart = [array objectAtIndex:1];
            } else {
                threadStart = [array objectAtIndex:0];
            }
            
            [normalPath addObject:transfer];
        }        
    }
    
    return normalPath;
}

// используется только для верхнего бара
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
            transferTime+=[(Transfer*)[path objectAtIndex:i] time];
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
        if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]] && i==0) {
            // начинаем с пересадки
            //          [colorArray addObject:[[self.fromStation lines] color]];
            
        } else if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine!=[[[segment start] line] index]) {
                [colorArray addObject:[[[segment start] line] color]];
                currentIndexLine=[[[segment start] line] index];
            }
            
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]] && i==objectNum-1) {
            // заканчиваем пересадкой
            //            [colorArray addObject:[[self.toStation lines] color]];
        }
    }
    
    return colorArray;
}

-(UIColor*)dsFirstStationSaturatedColor
{
    return [(UIColor*)[[self.fromStation lines] color] saturatedColor];
}

-(UIColor*)dsLastStationSaturatedColor
{
    return [(UIColor*)[[self.toStation lines] color] saturatedColor];    
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
    
    for (int i=0; i<objectNum; i++) {
        
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            tempSegment = (Segment*)[path objectAtIndex:i];
            
        } else {
            
            Transfer *transfer = (Transfer*)[path objectAtIndex:i];
            
            Station *startStation = [tempSegment end];
            
            NSArray *array = [[transfer stations] allObjects];
            Segment *nextSegment = nil;
            Station *endStation;
            // transfer can contain more than two stations
            if(i < objectNum-1 && [[path objectAtIndex:(i+1)] isKindOfClass:[Segment class]]) {
                nextSegment = (Segment*)[path objectAtIndex:(i+1)];
                endStation = [nextSegment start];
            } else {
                if ([array objectAtIndex:0]==startStation) {
                    endStation = [array objectAtIndex:1];
                } else {
                    endStation = [array objectAtIndex:0];
                }
            }
            
            NSInteger aaa = NOWAY;
            if(tempSegment != nil && nextSegment != nil) {
                aaa = [startStation megaTransferWayFrom:[tempSegment start] to:endStation andNextStation:[nextSegment end]];
            } else if(tempSegment != nil) {
                aaa = [startStation megaTransferWayFrom:[tempSegment start] to:endStation];
            } else
                aaa = [startStation transferWayTo:endStation];
            
            [stationsArray addObject:[NSNumber numberWithInteger:aaa]];
        }
        
    }
    
    NSInteger aaa = [[tempSegment end] transferWayFrom:[tempSegment start]];
    
    [stationsArray addObject:[NSNumber numberWithInteger:aaa]];
    
    //    NSLog(@"%@",stationsArray);
    
    return stationsArray;
    
}

-(NSMutableArray*)dsGetEveryStationTime
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSMutableArray *stationsArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    int currentIndexLine = -1;
    
    int time = 0;
    
    NSMutableArray *tempArray;
    
    for (int i=0; i<objectNum; i++) {
        
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine==[[[segment start] line] index]) {
                
                time += [segment driving];
                
                [tempArray addObject:[NSNumber numberWithInt:time]];
                
            } else {
                
                if (currentIndexLine!=-1) {
                    
                    [stationsArray addObject:tempArray];    
                    
                }
                
                tempArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
                
                [tempArray addObject:[NSNumber numberWithInt:time]];
                
                time += [segment driving];
                
                [tempArray addObject:[NSNumber numberWithInt:time]];
                
                currentIndexLine=[[[segment start] line] index];
            }
        }
        
        if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            time+=[(Transfer*)[path objectAtIndex:i] time];  
        }
        
    }
    
    [stationsArray addObject:tempArray];    
    
    return stationsArray;
}

-(NSMutableArray*)dsGetEveryTransferTime
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSMutableArray *stationsArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    for (int i=0; i<objectNum; i++) {
        
        if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            [stationsArray addObject:[NSNumber numberWithInt:[(Transfer*)[path objectAtIndex:i] time]]];  
        }
    }
    
    return stationsArray;
}

-(NSMutableArray*)dsGetDirectionNames
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *pathX = appDelegate.cityMap.activePath;    
    NSMutableArray *path = [self normalizePath:pathX];
    int objectNum = [path count];
    
    NSMutableArray *directionsArray = [[[NSMutableArray alloc] initWithCapacity:objectNum] autorelease];
    int currentIndexLine = -1;
    
    NSString *directionName;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine!=[[[segment start] line] index]) {
                
                NSMutableString *finalStation = [NSMutableString stringWithString:@""];
                
                if ([[segment start] index]<[[segment end] index]) {
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
        }
    }
    
    return directionsArray;
}

-(BOOL)dsIsStartingTransfer
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    
    if ([path count]>0) {
        if ([[path objectAtIndex:0] isKindOfClass:[Transfer class]]) {
            return YES;    
        }
    }
    
    return NO;
}

-(BOOL)dsIsEndingTransfer
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    
    if ([path count]>0) {
        if ([[path lastObject] isKindOfClass:[Transfer class]]) {
            return YES;    
        }
    }
    
    return NO;
}

#pragma mark - horiz and vert path views

-(void)showScrollView
{
    int numberOfPages=1;
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MainView *mainView = (MainView*)[self view];
    NSMutableArray *pathes2 = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[mainView.mapView.foundPaths allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSNumber *pathIndex in keys) {
        [pathes2 addObject:[mainView.mapView.foundPaths objectForKey:pathIndex]];
    }
    
    numberOfPages = [pathes2 count];
    
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
            NSMutableArray *pathWithNumber = [appDelegate.cityMap describePath:[pathes2 objectAtIndex:i]];
            PathBarView *pathView = [[PathBarView alloc] initWithFrame:CGRectMake(i*320.0, 0.0, 320.0, 40) path:pathWithNumber number:i overall:numberOfPages];
            [self.scrollView addSubview:pathView];
            pathView.tag=20000+i;
            [pathView release];
        }
        
        [(MainView*)self.view addSubview:scrollView];
        [(MainView*)self.view bringSubviewToFront:scrollView];
        
        UIButton *changeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"switch_to_path.png"];
        UIImage *imgh = [UIImage imageNamed:@"switch_to_path_high.png"];
        [changeViewButton setImage:img forState:UIControlStateNormal];
        [changeViewButton setImage:imgh forState:UIControlStateHighlighted];
        [changeViewButton addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        CGSize dateSize = [dateString sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
        
        [formatter release];
        
        [changeViewButton setFrame:CGRectMake(320.0-12.0-dateSize.width-img.size.width , 66 , img.size.width, img.size.height)];
        [changeViewButton setTag:333];
        [(MainView*)self.view addSubview:changeViewButton];
    } else {
        
        NSArray *viewArray = [self.scrollView subviews];
        for (PathBarView *view in viewArray) {
            [view removeFromSuperview];
        }
        
        [self.scrollView scrollRectToVisible:CGRectMake(0.0, 26.0, 320.0f, 40.0f) animated:NO];
        
        self.scrollView.contentSize=CGSizeMake(numberOfPages * 320.0f, 40.0);
        
        for (int i=0; i<numberOfPages; i++) {
            NSMutableArray *pathWithNumber = [appDelegate.cityMap describePath:[pathes2 objectAtIndex:i]];
            PathBarView *pathView = [[PathBarView alloc] initWithFrame:CGRectMake(i*320.0, 0.0, 320.0, 40) path:pathWithNumber number:i overall:numberOfPages];
            [self.scrollView addSubview:pathView];
            pathView.tag=20000+i;
            [pathView release];
        }
    }
    
    [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 66, 320, 480-86)];
    [pathes2 release];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)ascrollView{ 
    
    if (ascrollView==self.scrollView) {
        
        int pathNumb = floor(ascrollView.contentOffset.x/320.0);
        [self performSelector:@selector(changeActivePath:) withObject:[NSNumber numberWithInt:pathNumb] afterDelay:0.1];
    }
}

-(void)changeActivePath:(NSNumber*)pathNumb
{
    MainView *mainView = (MainView*)[self view];
    [mainView.mapView selectPath:[pathNumb intValue]];    
    
    if (self.pathScrollView) {
        [self performSelector:@selector(redrawPathScrollView) withObject:nil afterDelay:0.1];
    }
}

-(void)removeScrollView
{
    [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 44, 320, 480-64)];
    
    [self.scrollView removeFromSuperview];
    self.scrollView=nil;
    [[(MainView*)self.view viewWithTag:333] removeFromSuperview];
}

-(void)redrawPathScrollView
{
    NSArray *subviews = [self.pathScrollView subviews];
    for (UIView *v in subviews) {
        [v removeFromSuperview];
    }
    
    [self drawPathScrollView];
}

-(void)drawPathScrollView
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    //    NSArray *path11 = appDelegate.cityMap.activePath;
    
    CGFloat transferHeight = 83.0f;
    CGFloat emptyTransferHeight = 30.0f; //without train picture, without exit information
    CGFloat stationHeight = 20.0f;
    CGFloat finalHeight = 60.0f;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    
    NSMutableArray *stations = [[[NSMutableArray alloc] initWithArray:[self dsGetStationsArray]] autorelease];
    NSArray *stationsTime = [self dsGetEveryStationTime];
    NSMutableArray *exits = [self dsGetExitForStations]; 
    NSArray *transferTime = [self dsGetEveryTransferTime];
    NSMutableArray *directions = [self dsGetDirectionNames];
    
    //    int transferNumb = [stations count]-1;
    
    int trainType = 0;
    int stationType = 0;
    int finalType = 0;
    
    NSMutableArray *points = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    CGFloat viewHeight=0;
    CGFloat segmentHeight;
    CGFloat currentY;
    CGFloat lineStart=17.0;
    
    if ([self dsIsStartingTransfer]) {
        [stations removeObjectAtIndex:0];
        lineStart+=20.0;
    }
    
    if ([self dsIsEndingTransfer]) {
        [stations removeLastObject];
    }
    
    for (NSMutableArray *tempStations in stations) {
        
        //        segmentHeight=0;
        trainType=0;
        finalType=0;
        stationType=0;
        
        int lineStationCount=[tempStations count];
        if (lineStationCount>=4) {
            trainType++;
            stationType=lineStationCount-3;
            finalType++;
        } else if (lineStationCount>=3) {
            trainType++;
            finalType++;
        } else if (lineStationCount>=2) {
            trainType++;
        }
        
        CGFloat tempTH = 0.0f;
        
        if ([[exits objectAtIndex:[stations indexOfObject:tempStations]] intValue]!=0) {
            tempTH = transferHeight;
        } else {
            tempTH = emptyTransferHeight;
        }
        
        NSString *directionName = [directions objectAtIndex:[stations indexOfObject:tempStations]];
        
        CGSize max = CGSizeMake(235, 500);
        CGSize expected = [directionName sizeWithFont:[UIFont fontWithName:@"MyriadPr-Italic" size:14.0] constrainedToSize:max lineBreakMode:UILineBreakModeWordWrap]; 
        
        tempTH+=expected.height+10.0;
        
        segmentHeight =  (float)trainType * tempTH +(float)finalType*finalHeight + (float)stationType * stationHeight;    
        [points addObject:[NSNumber numberWithFloat:segmentHeight]];
        
        viewHeight += segmentHeight;
    }
    
    self.pathScrollView.contentSize=CGSizeMake(320.0f, viewHeight+100.0);
    self.pathScrollView.bounces=YES;
    self.pathScrollView.delegate = self;
    
    self.pathScrollView.backgroundColor = [UIColor whiteColor];
    
    int segmentsCount = [stations count];
    
    int time=0;
    
    // первый и последний лейбл станции
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40.0, lineStart-5.0, 235.0, 22.0)];
    label1.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
    label1.text= [[stations objectAtIndex:0] objectAtIndex:0];
    label1.backgroundColor=[UIColor clearColor];
    [self.pathScrollView addSubview:label1];
    [label1 release];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(40.0, lineStart+viewHeight-5.0, 235.0, 22.0)];
    label2.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
    label2.text= [[stations lastObject] lastObject];
    label2.backgroundColor=[UIColor clearColor];
    [self.pathScrollView addSubview:label2];
    [label2 release];
    
    // -------
    
    // первый и последний лебл даты прибытия станций
    NSString *dateString1;
    if([appDelegate.cityMap.pathTimesList count] > 0) dateString1 = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList objectAtIndex:0]];
    else {
        time= [[[stationsTime objectAtIndex:0] objectAtIndex:0] intValue];
        dateString1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]];
    }
    CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, lineStart-7.0, dateSize1.width, 25.0)];
    dateLabel1.text = dateString1;
    dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
    dateLabel1.backgroundColor = [UIColor clearColor];
    dateLabel1.textColor = [UIColor darkGrayColor];
    [self.pathScrollView addSubview:dateLabel1];
    [dateLabel1 release];
    
    
    NSString *dateString2;
    if([appDelegate.cityMap.pathTimesList count] > 1) dateString2 = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList lastObject]];
    else {
        time= [[[stationsTime lastObject] lastObject] intValue];
        
        if ([self dsIsEndingTransfer]) {
            time+=[[transferTime lastObject] intValue];
        }
        dateString2 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]];
    }
    CGSize dateSize2 = [dateString2 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    UILabel *dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize2.width, lineStart+viewHeight-7.0, dateSize2.width, 25.0)];
    dateLabel2.text = dateString2;
    dateLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
    dateLabel2.backgroundColor = [UIColor clearColor];
    dateLabel2.textColor = [UIColor darkGrayColor];
    [self.pathScrollView addSubview:dateLabel2];
    [dateLabel2 release];
    
    // точки станций
    
    int endCount=segmentsCount;
    int start = 0;
    
    int stationCounter = 1;
    
    for (int j=start;j<endCount;j++) {
        
        if (j==0 ) {
            currentY=lineStart;
        } else {
            currentY=0;
            
            NSArray *array = [points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, j)]];
            
            for (NSNumber *segmentH in array) {
                currentY+=[segmentH floatValue];
            }
            
            currentY+=lineStart;
        }
        
        int exitNumb = [[exits objectAtIndex:j-start] intValue];
        
        UILabel *directionLabel;
        
        if (exitNumb!=0) {
            NSString *trainName = [NSString stringWithFormat:@"%@/train%d.png",appDelegate.cityMap.pathToMap,exitNumb];
            UIImage *trainImage = [UIImage imageWithContentsOfFile:trainName];
            
            UIImageView *trainSubview = [[UIImageView alloc] initWithImage:trainImage];
            
            trainSubview.frame = CGRectMake(27, currentY+20.0, trainImage.size.width, trainImage.size.height); // было 37
            [self.pathScrollView addSubview:trainSubview];
            [trainSubview release];
            
            currentY+=transferHeight;
        } else {
            currentY+=emptyTransferHeight;
        }
        
        // ----
        
        directionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY, 235.0, 22.0)];
        
        directionLabel.font=[UIFont fontWithName:@"MyriadPr-Italic" size:14.0];
        
        directionLabel.lineBreakMode = UILineBreakModeWordWrap;
        directionLabel.numberOfLines = 0;
        
        NSString *directionName = [directions objectAtIndex:j];
        
        CGRect currentFrame = directionLabel.frame;
        CGSize max = CGSizeMake(directionLabel.frame.size.width, 500);
        CGSize expected = [directionName sizeWithFont:directionLabel.font constrainedToSize:max lineBreakMode:directionLabel.lineBreakMode]; 
        currentFrame.size.height = expected.height;
        directionLabel.frame = currentFrame;
        
        directionLabel.text=directionName;
        directionLabel.backgroundColor=[UIColor clearColor];
        [self.pathScrollView addSubview:directionLabel];
        [directionLabel release];
        
        currentY+=expected.height+10;
        
        // ----
        
        for (int jj=1;jj<[[stations objectAtIndex:j] count]-1;jj++) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY, 235.0, 22.0)];
            
            label.font=[UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
            
            NSString *stationName = [[stations objectAtIndex:j] objectAtIndex:jj];
            
            label.text=stationName;
            label.backgroundColor=[UIColor clearColor];
            [self.pathScrollView addSubview:label];
            [label release];
            
            // -------
            
            time = [[[stationsTime objectAtIndex:j-start] objectAtIndex:jj] intValue];
            
            NSString *dateString;
            if([appDelegate.cityMap.pathTimesList count] > stationCounter)
                dateString = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList objectAtIndex:stationCounter]];
            else 
                dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]];
            
            CGSize dateSize = [dateString sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize.width, currentY, dateSize.width, 25.0)];
            
            dateLabel.textAlignment = UITextAlignmentRight;
            dateLabel.text = dateString;
            dateLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.textColor = [UIColor darkGrayColor];
            [self.pathScrollView addSubview:dateLabel];
            [dateLabel release];
            
            // -------
            
            currentY+=stationHeight;
            
            stationCounter ++;
        }
        
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
        
        int time1 = [[[stationsTime objectAtIndex:i] lastObject] intValue];            
        int time2 = time1+[[transferTime objectAtIndex:i] intValue];
        
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
        
        // -------
        
        
        if ([stationName1 isEqualToString:stationName2]) {
            
            NSString *dateString1;
            if([appDelegate.cityMap.pathTimesList count] > i)  {
                int real_index=0; 
                
                for (int kk=0; kk<=i; kk++) {
                    real_index += [[stationsTime objectAtIndex:kk] count];
                }
                
                dateString1 = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList objectAtIndex:real_index]];
            }   else {  
                dateString1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time1*60.0]];
            }
            CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-8.0, dateSize1.width, 25.0)];
            dateLabel1.text = dateString1;
            dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel1.backgroundColor = [UIColor clearColor];
            dateLabel1.textColor = [UIColor darkGrayColor];
            [self.pathScrollView addSubview:dateLabel1];
            [dateLabel1 release];
            
        } else {
            
            NSString *dateString1;
            if([appDelegate.cityMap.pathTimesList count] > i)
                dateString1 = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList objectAtIndex:i]];
            else 
                dateString1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time1*60.0]];
            CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-16.0, dateSize1.width, 25.0)];
            dateLabel1.text = dateString1;
            dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel1.backgroundColor = [UIColor clearColor];
            dateLabel1.textColor = [UIColor darkGrayColor];
            [self.pathScrollView addSubview:dateLabel1];
            [dateLabel1 release];
            
            
            NSString *dateString2;
            if([appDelegate.cityMap.pathTimesList count] > i+1)
                dateString2 = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList objectAtIndex:i+1]];
            else
                dateString2 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time2*60.0]];
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
    
    [formatter release];
}

-(IBAction)changeView:(id)sender
{
    if (!self.pathScrollView ) {
        
        UIScrollView *scview= [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 66.0, 320.0f, 414.0f)];
        self.pathScrollView = scview;
        [scview release];
        
        [self drawPathScrollView];
        
        [(MainView*)self.view addSubview:self.pathScrollView];
        [(MainView*)self.view bringSubviewToFront:pathScrollView];
        [(MainView*)self.view bringSubviewToFront:self.stationsView]; 
        [(MainView*)self.view bringSubviewToFront:self.scrollView]; 
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

#pragma mark - choosing stations etc

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
        //       [self.stationsView transitToRouteState]; // with Station1 Station2
        //     [self.routeScrollView appear];
        
        
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
        
        if (self.scrollView) {
            [self removeScrollView];
        }
        
        if (self.pathScrollView) {
            [self changeView:nil];
        }
	} else {
        [mainView findPathFrom:[fromStation name] To:[toStation name] FirstLine:[[[fromStation lines] index] integerValue] LastLine:[[[toStation lines] index] integerValue]];
        if ([[[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] activePath] count]>0) {
            if (!([[[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] activePath] count]==1 && [[[[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] activePath] objectAtIndex:0] isKindOfClass:[Transfer class]])) {
                [stationsView transitToPathView];
                [self showScrollView];
            }
        }
	}
    
	mainView.mapView.stationSelected=false;
    
    //    MHelper *helper = [MHelper sharedHelper];
    //    [helper saveBookmarkFile];
    //    [helper saveHistoryFile];
    //    [self dismissModalViewControllerAnimated:YES];
}

-(void)returnFromSelection:(NSArray*)stations
{
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(returnFromSelection2:) withObject:stations afterDelay:0.1];
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
