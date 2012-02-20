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

    [self.stationsView.layer setShadowRadius:15.f];
    [self.stationsView.layer setShadowOffset:CGSizeMake(0, 10)];
    [self.stationsView.layer setShadowOpacity:0.5f];

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
        if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]] && i==0) {
                // начинаем с пересадки
            [colorArray addObject:[[self.fromStation lines] color]];
            
        } else if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine!=[[[segment start] line] index]) {
                [colorArray addObject:[[[segment start] line] color]];
                currentIndexLine=[[[segment start] line] index];
            }
            
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]] && i==objectNum-1) {
            // заканчиваем пересадкой
            [colorArray addObject:[[self.toStation lines] color]];
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

    /*
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
     
    */ 
    
    return stationsArray;
}

-(NSInteger)dsGetExitForStation:(Station *)station
{
    int ddd = arc4random()%2;
    
    return ddd+1;
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
            time+=[[path objectAtIndex:i] time];  
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
            [stationsArray addObject:[NSNumber numberWithInt:[[path objectAtIndex:i] time]]];  
        }
    }
    
    return stationsArray;
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
        
        UIButton *changeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"switch_to_path.png"];
        [changeViewButton setImage:img forState:UIControlStateNormal];
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
    } 
        
    for (int i=0; i<numberOfPages; i++) {
        
        NSInteger travelTime = [self dsGetTravelTime];
 
        [(UILabel*)[self.scrollView viewWithTag:6000+i] setText:[NSString stringWithFormat:@"%d minutes",travelTime]];        
        
        NSString *arrivalTime = [self getArrivalTimeFromNow:travelTime];
        CGSize atSize = [arrivalTime sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:13.0]];
        CGRect labelRect = [(UILabel*)[self.scrollView viewWithTag:7000+i] frame];
        CGFloat labelStart = 310.0-atSize.width-2.0;
        [(UILabel*)[self.scrollView viewWithTag:7000+i] setFrame:CGRectMake(labelStart, labelRect.origin.y, atSize.width+2.0, labelRect.size.height)];
        [(UILabel*)[self.scrollView viewWithTag:7000+i] setText:[NSString stringWithFormat:@"%@",arrivalTime]];
        
        CGRect flagRect = [(UILabel*)[self.scrollView viewWithTag:6500+i] frame];
        [(UIImageView*)[self.scrollView viewWithTag:6500+i] setFrame:CGRectMake(labelStart-flagRect.size.width-2.0, flagRect.origin.y, flagRect.size.width, flagRect.size.height)];
         
         
        [(PathDrawView*)[self.scrollView viewWithTag:10000+i] setDelegate:self];
        [[self.scrollView viewWithTag:10000+i] setNeedsDisplay];
    }
    [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 66, 320, 480-86)];
    
    [self.stationsView.layer setShadowRadius:15.f];
    [self.stationsView.layer setShadowOffset:CGSizeMake(0, 42)]; //41
    [self.stationsView.layer setShadowOpacity:0.5f];
}

-(void)removeScrollView
{
    [[(MainView*)self.view containerView] setFrame:CGRectMake(0, 44, 320, 480-64)];

    [self.stationsView.layer setShadowRadius:15.f];
    [self.stationsView.layer setShadowOffset:CGSizeMake(0, 10)];
    [self.stationsView.layer setShadowOpacity:0.5f];
    
    [self.scrollView removeFromSuperview];
    self.scrollView=nil;
    [[(MainView*)self.view viewWithTag:333] removeFromSuperview];
}

-(IBAction)changeView:(id)sender
{
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path11 = appDelegate.cityMap.activePath;
    
//    NSArray *stations11 = [self dsGetStationsArray];
//    NSArray *stationsTime11 = [self dsGetEveryStationTime];
//    NSArray *colorArray11 = [self   dsGetLinesColorArray];
//    NSArray *a11 = [self dsGetEveryTransferTime];
//    NSArray *b11 = [self dsGetLinesTimeArray];
//    NSInteger c11 = [self dsGetTravelTime];   
    
//    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGFloat transferHeight = 85.0f;
    CGFloat stationHeight = 20.0f;
    CGFloat finalHeight = 60.0f;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];

    
    if (!self.pathScrollView && [[path11 objectAtIndex:0] isKindOfClass:[Segment class]] && [[path11 lastObject] isKindOfClass:[Segment class]] ) {
        
        UIScrollView *scview= [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 66.0, 320.0f, 414.0f)];
        self.pathScrollView = scview;
        [scview release];
        
        NSArray *stations = [self dsGetStationsArray];
        NSArray *stationsTime = [self dsGetEveryStationTime];
        
        int transferNumb = [stations count]-1;

        int trainType = 0;
        int stationType = 0;
        int finalType = 0;
        
        NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:1];
        
        CGFloat viewHeight=0;
        CGFloat segmentHeight;
        
        for (NSMutableArray *tempStations in stations) {
            
            segmentHeight=0;
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
            
            segmentHeight =  (float)trainType * transferHeight +(float)finalType*finalHeight + (float)stationType * stationHeight;    
            [points addObject:[NSNumber numberWithFloat:segmentHeight]];
            
            viewHeight += segmentHeight;
        }

        self.pathScrollView.contentSize=CGSizeMake(320.0f, viewHeight+50.0);
        self.pathScrollView.bounces=YES;
        self.pathScrollView.delegate = self;
        
        self.pathScrollView.backgroundColor = [UIColor whiteColor];
//        UIImageView *bgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vert_path_bg.png"]];
//        bgview.frame = CGRectMake(0.0, 0.0, 320.0, 40.0);
//        [self.pathScrollView addSubview:bgview];
//        [bgview release];
        
        CGFloat currentY;
        CGFloat lineStart=17.0;
        
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
        time= [[[stationsTime objectAtIndex:0] objectAtIndex:0] intValue];
        NSString *dateString1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]];
        CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
        UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, lineStart-7.0, dateSize1.width, 25.0)];
        dateLabel1.text = dateString1;
        dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
        dateLabel1.backgroundColor = [UIColor clearColor];
        dateLabel1.textColor = [UIColor darkGrayColor];
        [self.pathScrollView addSubview:dateLabel1];
        [dateLabel1 release];
        
        
        time= [[[stationsTime lastObject] lastObject] intValue];
        NSString *dateString2 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]];
        CGSize dateSize2 = [dateString2 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
        UILabel *dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize2.width, lineStart+viewHeight-7.0, dateSize2.width, 25.0)];
        dateLabel2.text = dateString2;
        dateLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
        dateLabel2.backgroundColor = [UIColor clearColor];
        dateLabel2.textColor = [UIColor darkGrayColor];
        [self.pathScrollView addSubview:dateLabel2];
        [dateLabel2 release];
        
        // точки станций
        for (int j=0;j<segmentsCount;j++) {
            
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
            
            int exitNumb = [self dsGetExitForStation:nil];
            //           NSString *fileName = [NSString stringWithFormat:@"train_%@_%d.png",appDelegate.cityMap.thisMapName,exitNumb];
            
            NSString *fileName = [NSString stringWithFormat:@"train_paris_%d.png",exitNumb];
            UIImage *trainImage = [UIImage imageNamed:fileName];
            
            UIImageView *trainSubview = [[UIImageView alloc] initWithImage:trainImage];
            
            trainSubview.frame = CGRectMake(37, currentY+30.0, trainImage.size.width, trainImage.size.height);
            [self.pathScrollView addSubview:trainSubview];
            [trainSubview release];
            
            currentY+=transferHeight;

            
            for (int jj=1;jj<[[stations objectAtIndex:j] count]-1;jj++) {
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY, 235.0, 22.0)];

                label.font=[UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
                
                NSString *stationName = [[stations objectAtIndex:j] objectAtIndex:jj];

                label.text=stationName;
                label.backgroundColor=[UIColor clearColor];
                [self.pathScrollView addSubview:label];
                [label release];
                
                // -------
                
                time = [[[stationsTime objectAtIndex:j] objectAtIndex:jj] intValue];

                NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]];
                
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
                
                
            }
            
            
        }
        
        for (int i=0;i<transferNumb;i++)
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
            
   //         int time1 = [[[stationsTime objectAtIndex:i] lastObject] intValue];            
   //         int time2 = [[[stationsTime objectAtIndex:i+1] objectAtIndex:0] intValue]; // tut crash

            int time1=0;
            int time2=0;
            
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
                
                NSString *dateString1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time1*60.0]];
                CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
                UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-8.0, dateSize1.width, 25.0)];
                dateLabel1.text = dateString1;
                dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
                dateLabel1.backgroundColor = [UIColor clearColor];
                dateLabel1.textColor = [UIColor darkGrayColor];
                [self.pathScrollView addSubview:dateLabel1];
                [dateLabel1 release];
                
            } else {
                
                NSString *dateString1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time1*60.0]];
                CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
                UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-16.0, dateSize1.width, 25.0)];
                dateLabel1.text = dateString1;
                dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
                dateLabel1.backgroundColor = [UIColor clearColor];
                dateLabel1.textColor = [UIColor darkGrayColor];
                [self.pathScrollView addSubview:dateLabel1];
                [dateLabel1 release];
                
                
                NSString *dateString2 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time2*60.0]];
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
        
        
        
        
/*        for (int j=0;j<segmentsCount;j++) {
            
            NSArray *tempStations = [stations objectAtIndex:j];
            
            int segStationsCount = [tempStations count];
            
            for (int k=0;k<segStationsCount;k++) {
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY, 235.0, 25.0)];
                
                NSString *stationName = [tempStations objectAtIndex:k];

                label.text=stationName;
                if (k==0) {
                    label.font=[UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
                } else {
                    label.font=[UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
                }
                
                label.backgroundColor=[UIColor clearColor];
                [self.pathScrollView addSubview:label];
                [label release];
                
                // -------
                
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(275.0, currentY, 240.0, 25.0)];
                
                NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]];
                
                dateLabel.text = dateString;
                dateLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
                dateLabel.backgroundColor = [UIColor clearColor];
                dateLabel.textColor = [UIColor darkGrayColor];
                [self.pathScrollView addSubview:dateLabel];
                [dateLabel release];
                
                // -------
                
                if (k==0) {
                    
                    int exitNumb = [self dsGetExitForStation:nil];
         //           NSString *fileName = [NSString stringWithFormat:@"train_%@_%d.png",appDelegate.cityMap.thisMapName,exitNumb];
                    
                    NSString *fileName = [NSString stringWithFormat:@"train_paris_%d.png",exitNumb];
                    
                    UIImageView *trainSubview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
                    trainSubview.frame = CGRectMake(20.0, currentY+20.0, 260, 47);
                    [self.pathScrollView addSubview:trainSubview];
                    [trainSubview release];
                    
                    currentY+=transferHeight;

                    
                } else {
                    
                    currentY+=stationHeight;
                }
                
      //          time += [[[stationsTime objectAtIndex:j] objectAtIndex:k] intValue];
            }
            
            currentY+=stationHeight;
           
            if (j<segmentsCount-1) {
     //           time += [[transferTime objectAtIndex:j] intValue];
            }
            
        }
 */

        PathDrawVertView *drawView = [[PathDrawVertView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, viewHeight+100.0)];
        drawView.tag =20000;
        drawView.delegate=self;
        [self.pathScrollView addSubview:drawView];
        [drawView release];

        
        [(MainView*)self.view addSubview:self.pathScrollView];
        [(MainView*)self.view bringSubviewToFront:pathScrollView];
        [(MainView*)self.view bringSubviewToFront:self.stationsView]; 
        [(MainView*)self.view bringSubviewToFront:self.scrollView]; 
        [(MainView*)self.view bringSubviewToFront:[(MainView*)self.view viewWithTag:333]]; 

        
        
        [(UIButton*)[(MainView*)self.view viewWithTag:333] setImage:[UIImage imageNamed:@"switch_to_map.png"] forState:UIControlStateNormal];
        
        [formatter release];
    
    } else {
        [self.pathScrollView removeFromSuperview];
        self.pathScrollView=nil;
        [(UIButton*)[(MainView*)self.view viewWithTag:333] setImage:[UIImage imageNamed:@"switch_to_path.png"] forState:UIControlStateNormal];
        

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
                //self.fromStation=nil;
                [stationsView resetFromStation];
            } else {
                self.fromStation = [stations objectAtIndex:0];
                [stationsView setFromStation:self.fromStation];
            }
        } else {
            if ([stations objectAtIndex:0]==self.fromStation) {
                //self.toStation=nil;
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
        [stationsView transitToPathView];
        [self showScrollView];
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
