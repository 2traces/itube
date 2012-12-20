//
//  VertPathScrollView.m
//  tube
//
//  Created by Sergey Mingalev on 01.08.12.
//
//

#import "VertPathScrollView.h"
#import "CityMap.h"
#import "Classes/tubeAppDelegate.h"
#import "UIColor-enhanced.h"
#import "SSTheme.h"

@implementation VertPathScrollView

@synthesize mainController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *image = [[SSThemeManager sharedTheme] vertScrollViewBackground];
        if (image) {
            self.backgroundColor = [UIColor colorWithPatternImage:image];
        } else {
            self.backgroundColor = [UIColor whiteColor];
        }
    }
    return self;
}

#pragma mark - datasource methods

-(NSMutableArray*)normalizePath:(NSArray*)path
{
    int count = [path count];
    
    // determing first Station
    
    Station *firstStation = nil;

    if (count>0) {
        if ([[path objectAtIndex:0] isKindOfClass:[Segment class]]) {
            Segment *firstSegment = (Segment*)[path objectAtIndex:0];
            Station *someStation = [firstSegment start];
            if ([someStation.name isEqual:[mainController.fromStation name]] &&
                (someStation.line.index == [mainController.fromStation.lines.index intValue] || firstStation == nil)) {
                firstStation = someStation;
            } else {
                firstStation = [firstSegment end];
            }
        } else {
            Transfer *transfer = (Transfer*)[path objectAtIndex:0];
            NSArray *array = [[transfer stations] allObjects];
            Station *someStation = [array objectAtIndex:0];
            if ([someStation.name isEqual:[mainController.fromStation name]] && someStation.line.index == [mainController.fromStation.lines.index intValue]) {
                firstStation = someStation;
            } else {
                firstStation = [array objectAtIndex:1];
            }
        }
    }
    
    NSMutableArray *normalPath = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    Station *threadStart = firstStation;
    NSArray *threadStartArray = nil;
    
    for (int i=0; i<count; i++) {
        
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *tempSegment = (Segment*)[path objectAtIndex:i];
            
            if ([tempSegment start] == threadStart || [threadStartArray containsObject:[tempSegment start]]) {
                
                [normalPath addObject:tempSegment];
                threadStart = [tempSegment end];
                
            } else {
                
                Segment *newSegment = [[[Segment alloc] initFromStation:[tempSegment end] toStation:[tempSegment start] withDriving:[tempSegment driving]] autorelease];
                [normalPath addObject:newSegment];
                threadStart=[tempSegment start];
                
            }
            [threadStartArray release];
            threadStartArray = nil;
            
        } else {
            
            Transfer *transfer = (Transfer*)[path objectAtIndex:i];
            
            threadStartArray = [[[transfer stations] allObjects] retain];
            threadStart = nil;
            
            [normalPath addObject:transfer];
        }
    }
    [threadStartArray release];
    
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
            //          [colorArray addObject:[[mainController.fromStation lines] color]];
            
        } else if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine!=[[[segment start] line] index]) {
                [colorArray addObject:[[[segment start] line] color]];
                currentIndexLine=[[[segment start] line] index];
            }
            
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]] && i==objectNum-1) {
            // заканчиваем пересадкой
            //            [colorArray addObject:[[mainController.toStation lines] color]];
        }
    }
    
    return colorArray;
}

-(UIColor*)dsFirstStationSaturatedColor
{
    return [(UIColor*)[[mainController.fromStation lines] color] saturatedColor];
}

-(UIColor*)dsLastStationSaturatedColor
{
    return [(UIColor*)[[mainController.toStation lines] color] saturatedColor];
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
        }
        if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            
            if (i==0) {
                tempArray = [NSMutableArray array];
                [tempArray addObject:[formatter stringFromDate:[times objectAtIndex:a]]];
                currentIndexLine=-2;
                a++;
            }
            
            if (i==objectNum-1) {
                [stationsArray addObject:tempArray];
                tempArray = [NSMutableArray array];
                [tempArray addObject:[formatter stringFromDate:[times objectAtIndex:a]]];
                a++;
            }
        }
    }
    
    [stationsArray addObject:tempArray];
    
    [formatter release];
    
    return stationsArray;
}

-(NSMutableArray*)dsGetEveryStationTime
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *path = appDelegate.cityMap.activePath;
    int objectNum = [path count];
    
    NSMutableArray *stationsArray = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    
    int currentIndexLine = -1;
    
    int time = 0;
    
    NSMutableArray *tempArray;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            Segment *segment = (Segment*)[path objectAtIndex:i];
            if (currentIndexLine==[[[segment start] line] index]) {
                time += [segment driving];
                [tempArray addObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]]];
            } else {
                if (currentIndexLine!=-1) {
                    [stationsArray addObject:tempArray];
                }
                tempArray = [NSMutableArray array];
                [tempArray addObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]]];
                time += [segment driving];
                [tempArray addObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]]];
                currentIndexLine=[[[segment start] line] index];
            }
        }
        if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            
            if (i==0) {
                tempArray = [NSMutableArray array];
                [tempArray addObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]]];
                currentIndexLine=-2;
            }
            
            time+=[(Transfer*)[path objectAtIndex:i] time];
            
            if (i==objectNum-1) {
                [stationsArray addObject:tempArray];
                tempArray = [NSMutableArray array];
                [tempArray addObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time*60.0]]];
            }
        }
    }
    
    [stationsArray addObject:tempArray];
    
    [formatter release];
    
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

-(NSArray*)dsGetDirectionNames
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *pathX = appDelegate.cityMap.activePath;
    NSMutableArray *path = [self normalizePath:pathX];
    int objectNum = [path count];
    
    NSMutableArray *directionsArray = [[[NSMutableArray alloc] initWithCapacity:objectNum] autorelease];
    int currentIndexLine = -1;
    
    NSString *directionName;
    
    for (int i=objectNum-1; i>=0; i--) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            
            Segment *segment = (Segment*)[path objectAtIndex:i];
            
            if (currentIndexLine!=[[[segment start] line] index]) {
                
                NSMutableString *finalStation = [NSMutableString stringWithString:@""];
                
                if([[segment start] checkForwardWay:[segment end]]) {
                    for (Station *station in [[segment end] lastStations]) {
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
    
    return [[directionsArray reverseObjectEnumerator] allObjects];
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

-(void)drawPathScrollView
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // константы нужные для рисования экрана - они регулируют высоту секторов
    CGFloat transferHeight = 83.0f;
    CGFloat emptyTransferHeight = 30.0f; //without train picture, without exit information
    CGFloat stationHeight = 20.0f;
    CGFloat finalHeight = 60.0f;
    
    // получаем все стартовые данные для начала рисования
    NSMutableArray *stations = [[[NSMutableArray alloc] initWithArray:[self dsGetStationsArray]] autorelease];  // список станций - массив массивов
    NSMutableArray *exits = [self dsGetExitForStations];  // выходы со станций - массив
    NSArray *directions = [self dsGetDirectionNames]; // направления движения
    
    NSArray *stationsTime;
    
    if ([appDelegate.cityMap.pathTimesList count] > 0) {
        stationsTime = [self dsGetEveryStationTimeScheduled]; // времена прохода станций при условии наличия расписания - массив массивов
    } else {
        stationsTime = [self dsGetEveryStationTime]; // времена прохода станций при условии отсутствия расписания - массив массивов
    }
    
    NSMutableArray *exitsVenice;
    
    if ([[appDelegate nameCurrentMap] isEqual:@"venice"]) {
        exitsVenice = [self dsGetVeniceExitForStations];
    }
    
    int trainType = 0;
    int stationType = 0;
    int finalType = 0;
    
    NSMutableArray *points = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    CGFloat viewHeight=0;
    CGFloat segmentHeight;
    CGFloat currentY;
    CGFloat lineStart=17.0;
    
    if (IS_IPAD) {
        lineStart=57.0;
    }
    
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        lineStart=75.0f;
    }
    
    if ([self dsIsStartingTransfer]) {
        [stations removeObjectAtIndex:0];
        lineStart+=20.0;
    }
    
    if ([self dsIsEndingTransfer]) {
        [stations removeLastObject];
    }
    
    for (NSMutableArray *tempStations in stations) {
        
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
    
//    if (IS_IPAD) {
        self.contentSize=CGSizeMake(320.0f, viewHeight+200.0);
//    } else {
//        self.contentSize=CGSizeMake(320.0f, viewHeight+100.0);
//    }
    
    self.bounces=YES;
    self.delegate = self;
//    self.backgroundColor = [UIColor whiteColor];
    
    [self scrollRectToVisible:CGRectMake(0.0, 0.0, 320.0, 300.0) animated:YES];
    
    int segmentsCount = [stations count];
    
    // первый и последний лейбл станции
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40.0, lineStart-5.0, 235.0, 22.0)];
    label1.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
    label1.text= [[stations objectAtIndex:0] objectAtIndex:0];
    label1.backgroundColor=[UIColor clearColor];
    [self addSubview:label1];
    [label1 release];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(40.0, lineStart+viewHeight-5.0, 235.0, 22.0)];
    label2.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
    label2.text= [[stations lastObject] lastObject];
    label2.backgroundColor=[UIColor clearColor];
    [self addSubview:label2];
    [label2 release];
    
    // -------
    
    // первый и последний лебл даты прибытия станций
    NSString *dateString1 = [[stationsTime objectAtIndex:0] objectAtIndex:0];
    CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, lineStart-7.0, dateSize1.width, 25.0)];
    dateLabel1.text = dateString1;
    dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
    dateLabel1.backgroundColor = [UIColor clearColor];
    dateLabel1.textColor = [UIColor darkGrayColor];
    [self addSubview:dateLabel1];
    [dateLabel1 release];
    
    
    NSString *dateString2 = [[stationsTime lastObject] lastObject];
    CGSize dateSize2 = [dateString2 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
    UILabel *dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize2.width, lineStart+viewHeight-7.0, dateSize2.width, 25.0)];
    dateLabel2.text = dateString2;
    dateLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
    dateLabel2.backgroundColor = [UIColor clearColor];
    dateLabel2.textColor = [UIColor darkGrayColor];
    [self addSubview:dateLabel2];
    [dateLabel2 release];
    
    NSMutableArray *fixedStationsTime = [NSMutableArray arrayWithArray:stationsTime];
    
    if ([self dsIsStartingTransfer]) {
        [fixedStationsTime removeObjectAtIndex:0];
    }
    
    if ([self dsIsEndingTransfer]) {
        [fixedStationsTime removeLastObject];
    }
    
    // точки станций
    
    int endCount=segmentsCount;
    int start = 0;
    
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
            [self addSubview:trainSubview];
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
        [self addSubview:directionLabel];
        [directionLabel release];
        
        currentY+=expected.height+10;
        
        // ----
        
        for (int jj=1;jj<[[stations objectAtIndex:j] count]-1;jj++) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY, 235.0, 22.0)];
            
            label.font=[UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
            
            NSString *stationName = [[stations objectAtIndex:j] objectAtIndex:jj];
            
            label.text=stationName;
            label.backgroundColor=[UIColor clearColor];
            [self addSubview:label];
            [label release];
            
            // -------
            
            NSString *dateString = [[fixedStationsTime objectAtIndex:j-start] objectAtIndex:jj];
            
            CGSize dateSize = [dateString sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize.width, currentY, dateSize.width, 25.0)];
            
            dateLabel.textAlignment = UITextAlignmentRight;
            dateLabel.text = dateString;
            dateLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.textColor = [UIColor darkGrayColor];
            [self addSubview:dateLabel];
            [dateLabel release];
            
            // -------
            
            currentY+=stationHeight;
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
        
        if ([stationName1 isEqualToString:stationName2]) {
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40.0, currentY-6.0, 235, 22.0)];
            label1.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
            label1.text=stationName1;
            label1.backgroundColor=[UIColor clearColor];
            [self addSubview:label1];
            [label1 release];
            
            
        } else {
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:rect1];
            label1.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
            label1.text=stationName1;
            label1.backgroundColor=[UIColor clearColor];
            [self addSubview:label1];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:rect2];
            label2.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
            label2.text=stationName2;
            label2.backgroundColor=[UIColor clearColor];
            [self addSubview:label2];
            [label2 release];
            
        }
        
        if ([stationName1 isEqualToString:stationName2]) {
            
            NSString *dateString1 = [[fixedStationsTime objectAtIndex:i] lastObject];
            CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-8.0, dateSize1.width, 25.0)];
            dateLabel1.text = dateString1;
            dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel1.backgroundColor = [UIColor clearColor];
            dateLabel1.textColor = [UIColor darkGrayColor];
            [self addSubview:dateLabel1];
            [dateLabel1 release];
            
        } else {
            
            NSString *dateString1=[[fixedStationsTime objectAtIndex:i] lastObject];
            CGSize dateSize1 = [dateString1 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize1.width, currentY-16.0, dateSize1.width, 25.0)];
            dateLabel1.text = dateString1;
            dateLabel1.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel1.backgroundColor = [UIColor clearColor];
            dateLabel1.textColor = [UIColor darkGrayColor];
            [self addSubview:dateLabel1];
            [dateLabel1 release];
            
            
            NSString *dateString2 = [[fixedStationsTime objectAtIndex:i+1] objectAtIndex:0];
            CGSize dateSize2 = [dateString2 sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
            UILabel *dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(320.0-10.0-dateSize2.width, currentY+8.0, dateSize2.width, 25.0)];
            dateLabel2.text = dateString2;
            dateLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0];
            dateLabel2.backgroundColor = [UIColor clearColor];
            dateLabel2.textColor = [UIColor darkGrayColor];
            [self addSubview:dateLabel2];
            [dateLabel2 release];
            
        }
    }
    
    
    PathDrawVertView *drawView = [[PathDrawVertView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, viewHeight+100.0)];
//    drawView.tag =20000;
    drawView.delegate=self;
    [self addSubview:drawView];
    [drawView release];
    
//    if (IS_IPAD) {
        UIButton *sendToFriend = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"sendToFriend.png"];
        [sendToFriend  setImage:img forState:UIControlStateNormal];
        [sendToFriend  setImage:[UIImage imageNamed:@"sendToFriendPressed.png"] forState:UIControlStateHighlighted];
        [sendToFriend  addTarget:self action:@selector(sendToFriendMail:) forControlEvents:UIControlEventTouchUpInside];
        [sendToFriend  setFrame:CGRectMake(40 , viewHeight + lineStart +35 , img.size.width, img.size.height)];
        [self addSubview:sendToFriend];

        UIButton *wrongPath = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img2 = [UIImage imageNamed:@"wrongPath.png"];
        [wrongPath  setImage:img2 forState:UIControlStateNormal];
        [wrongPath  setImage:[UIImage imageNamed:@"wrongPathPressed.png"] forState:UIControlStateHighlighted];
        [wrongPath  addTarget:self action:@selector(wrongPathMail:) forControlEvents:UIControlEventTouchUpInside];
        [wrongPath  setFrame:CGRectMake(40 , viewHeight +lineStart+ 71, img2.size.width, img2.size.height)];
        [self addSubview:wrongPath];
//    }
}

-(IBAction)sendToFriendMail:(id)sender
{
    NSString *body = [self generateMessageBodyPath];
    [self showMailComposer:nil subject:@"Look at this path" body:body];
}

-(IBAction)wrongPathMail:(id)sender
{
    NSString *body = [self generateMessageBodyPath];
    [self showMailComposer:nil subject:@"Wrong path" body:body];
}

-(NSString*)generateMessageBodyPath
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // получаем все стартовые данные для начала рисования
    NSMutableArray *stations = [[[NSMutableArray alloc] initWithArray:[self dsGetStationsArray]] autorelease];  // список станций - массив массивов
    NSMutableArray *exits = [self dsGetExitForStations];  // выходы со станций - массив
    NSArray *directions = [self dsGetDirectionNames]; // направления движения
    
    NSMutableArray *stationsTime;
    
    if ([appDelegate.cityMap.pathTimesList count] > 0) {
        stationsTime = [NSMutableArray arrayWithArray:[self dsGetEveryStationTimeScheduled]]; // времена прохода станций при условии наличия расписания - массив массивов
    } else {
        stationsTime = [NSMutableArray arrayWithArray:[self dsGetEveryStationTime]]; // времена прохода станций при условии отсутствия расписания - массив массивов
    }
    
    NSMutableArray *exitsVenice;
    
    if ([[appDelegate nameCurrentMap] isEqual:@"venice"]) {
        exitsVenice = [self dsGetVeniceExitForStations];
    }
    
    if ([self dsIsStartingTransfer]) {
        [stations removeObjectAtIndex:0];
        [stationsTime removeObjectAtIndex:0];
    }
    
    if ([self dsIsEndingTransfer]) {
        [stations removeLastObject];
        [stationsTime removeObjectAtIndex:0];
    }
    
    int segmentsCount = [stations count];
    int endCount=segmentsCount;
    int start = 0;
    
    NSString *body;
    
    body = @"<html><table width=\"350\">";
    
    NSString *lastStation = nil;
    
    for (int j=start;j<endCount;j++) {
        
        // print station name, if something before - check for identical station before
        NSString *stationNameFirst = [[stations objectAtIndex:j] firstObject];
        NSString *dateStringFirst = [[stationsTime objectAtIndex:j-start] firstObject];
        if (![stationNameFirst isEqualToString:lastStation]) {
            body = [body stringByAppendingFormat:@"<TR><TD width=\"70%%\"><b>%@</b></TD><TD><b>%@</b></TD></TR>",stationNameFirst,dateStringFirst];
//            NSLog(@"Start Station %@ - %@",stationNameFirst, dateStringFirst);
        }
        
        // print train
        int exitNumb = [[exits objectAtIndex:j-start] intValue];
        if (exitNumb!=0) {
            NSString *trainName = [NSString stringWithFormat:@"http:/findmystation.info/maps/%@/train%d.png",appDelegate.cityMap.thisMapName,exitNumb];
            NSString *kk = @"\"";
            body = [body stringByAppendingFormat:@"<TR><TD colspan=\"2\"><img src=%@%@%@ alt=%@%@%@></TD></TR>",kk,trainName,kk,kk,@"train",kk];
//            NSLog(@"%@",trainName);
        } else {
            
        }

        // print direction
        NSString *directionName = [directions objectAtIndex:j];
        body = [body stringByAppendingFormat:@"<TR><TD colspan=\"2\"><i>%@</i></TD></TR>",directionName];
//        NSLog(@"%@",directionName);
        
        
        // print stations
        for (int jj=1;jj<[[stations objectAtIndex:j] count]-1;jj++) {
            NSString *stationName = [[stations objectAtIndex:j] objectAtIndex:jj];
            NSString *dateString = [[stationsTime objectAtIndex:j-start] objectAtIndex:jj];
            body = [body stringByAppendingFormat:@"<TR><TD>%@</TD><TD>%@</TD></TR>",stationName,dateString];
//            NSLog(@"%@ - %@",stationName, dateString);
        }
        
        // if last in segment - bold it
        
        NSString *stationNameLast = [[stations objectAtIndex:j] lastObject];
        NSString *dateStringLast = [[stationsTime objectAtIndex:j-start] lastObject];
        body = [body stringByAppendingFormat:@"<TR><TD><b>%@</b></TD><TD><b>%@</b></TD></TR>",stationNameLast,dateStringLast];
//        NSLog(@"Last Station %@ - %@",stationNameLast, dateStringLast);
        lastStation=stationNameLast;
        
    }
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppStoreURL"];
    NSString *iconURLString = [NSString stringWithFormat:@"<img src=\"%@\" alt=\"appIcon\">",[NSString stringWithFormat:@"http:/findmystation.info/maps/%@/icon.png",appDelegate.cityMap.thisMapName]];
    
    body = [body stringByAppendingFormat:@"</table><p>Sent from <a href=\"%@\">%@ ver. %@</a><p>%@<p></html>",appURL,appName,appVersion,iconURLString];
    
    return body;
}

-(IBAction)showMailComposer:(id)sender subject:(NSString*)subject body:(NSString*)mybody
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        // Test to ensure that device is configured for sending emails.
        if ([mailClass canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:subject];
            [picker setMessageBody:mybody isHTML:YES];
            [picker setToRecipients:[NSArray arrayWithObject:[NSString stringWithFormat:@"fusio@yandex.ru"]]];
            [appDelegate.mainViewController presentModalViewController:picker animated:YES];
            [picker release];
        } else {
            // Device is not configured for sending emails, so notify user.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't send email" message:@"This device not configured to send emails" delegate:self cancelButtonTitle:@"Ok, I will try later" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    }
}

// Dismisses the Mail composer when the user taps Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSString *resultTitle = nil; NSString *resultMsg = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            resultTitle = @"Email cancelled";
            resultMsg = @"You cancelled you email"; break;
        case MFMailComposeResultSaved:
            resultTitle = @"Email saved";
            resultMsg = @"Your draft email was saved"; break;
        case MFMailComposeResultSent: resultTitle = @"Email sent";
            resultMsg = @"Your email was sent successfully";
            break;
        case MFMailComposeResultFailed:
            resultTitle = @"Email failed";
            resultMsg = @"Your email was failed"; break;
        default:
            resultTitle = @"Email was not sent";
            resultMsg = @"Your email was not sent"; break;
    }
    // Notifies user of any Mail Composer errors received with an Alert View dialog.
    UIAlertView *mailAlertView = [[UIAlertView alloc] initWithTitle:resultTitle message:resultMsg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [mailAlertView show];
    [mailAlertView release];
    [resultTitle release];
    [resultMsg release];
    
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.mainViewController dismissModalViewControllerAnimated:YES];
}


-(void)dealloc
{
    [mainController release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
