//
//  PathDrawView.m
//  tube
//
//  Created by sergey on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathDrawView.h"
#import "ManagedObjects.h"
#import "UIColor-enhanced.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "CityMap.h"

@implementation PathDrawView

@synthesize pathInfo;
@synthesize travelTime;
@synthesize delegate;
@synthesize apath,zpath;

- (id)initWithFrame:(CGRect)frame path:(NSMutableArray*)thisPath
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.zpath=thisPath;
//        tubeAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
//        self.apath = [appdelegate.cityMap describePath:self.zpath];
        self.apath = thisPath;
    }
    return self;
}

/*
-(void) describePath:(NSArray*)pathMap {
    [self.apath removeAllObjects];
	int count_ = [pathMap count];
    
    Station *prevStation = nil;
	for (int i=0; i< count_; i++) {
        GraphNode *n1 = [pathMap objectAtIndex:i];
        Line* l = [mapLines objectAtIndex:n1.line-1];
        Station *s = [l getStation:n1.name];
        
        if(i == count_ - 1) {

        } else {
            GraphNode *n2 = [pathMap objectAtIndex:i+1];
            
            if (n1.line==n2.line) {
                [self.apath addObject:[l activateSegmentFrom:n1.name to:n2.name]];
            } 
            
            if(n1.line != n2.line) {
                [self.apath addObject:s.transfer];
            }
        }

        prevStation = s;
	
    }
}
*/

#pragma mark - datasource methods

-(NSArray*)dsGetLinesColorArray
{
    NSArray *path = self.apath;
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
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [(UIColor*)[[appDelegate.mainViewController.fromStation lines] color] saturatedColor];
}

-(UIColor*)dsLastStationSaturatedColor
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [(UIColor*)[[appDelegate.mainViewController.toStation lines] color] saturatedColor];
}


-(NSArray*)dsGetLinesTimeArray
{
    NSArray *path = self.apath;
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

-(BOOL)dsIsStartingTransfer
{
    NSArray *path = self.apath;
    
    if ([path count]>0) {
        if ([[path objectAtIndex:0] isKindOfClass:[Transfer class]]) {
            return YES;    
        }
    }
    
    return NO;
}

-(BOOL)dsIsEndingTransfer
{
    NSArray *path = self.apath;
    
    if ([path count]>0) {
        if ([[path lastObject] isKindOfClass:[Transfer class]]) {
            return YES;    
        }
    }
    
    return NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat overallLineWidth = 201.0f;
    CGFloat lineStart = 44.0f;
    CGFloat y = 29.0f+rect.origin.y;
    CGFloat lineH=6.0;
    CGFloat firstAndLastR=9.0;
    CGFloat middleR=9.0;
    
    CGFloat x, segmentLenght;
    
    x=lineStart;
    
    NSArray *colorArray = [self dsGetLinesColorArray];
    NSArray *timeArray = [self dsGetLinesTimeArray];
    
    for (UIColor *color1 in colorArray) {
        [color1 saturatedColor]; 
    }
    
    points = [[NSMutableArray alloc] initWithCapacity:1];
    
    travelTime=0;
    
    for (NSNumber *segTime in timeArray) {
        travelTime+=[segTime integerValue];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // рисуем линию
    
    for (int i=0;i<[timeArray count];i++) {
        
        segmentLenght = [[timeArray objectAtIndex:i] floatValue]/(float)travelTime*overallLineWidth;
        
        UIColor *lineColor = [colorArray objectAtIndex:i];
        
        CGContextSetStrokeColorWithColor(c, [lineColor CGColor]);
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, lineH);
        CGContextMoveToPoint(c, x, y);
        CGContextAddLineToPoint(c, x+segmentLenght, y);
        CGContextStrokePath(c);
        
        x+=segmentLenght;
        
        [points addObject:[NSNumber numberWithFloat:x]];
        
    }
    
    // shadow line
    UIColor *lineColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    
    CGContextSetStrokeColorWithColor(c, [lineColor CGColor]);
    CGContextBeginPath(c);
    CGContextSetLineWidth(c, 1.0);
    CGContextMoveToPoint(c, lineStart+1.0, y+lineH/2.0);
    CGContextAddLineToPoint(c, lineStart+overallLineWidth-1.0, y+lineH/2.0);
    CGContextStrokePath(c);
    
    y=y-0.5; 
    
    // ставим начальные и конечные точки или пересадки
    
    if ([self dsIsStartingTransfer]) {

        UIImage *img= [UIImage imageNamed:@"scepka_horiz.png"];
        
        CGRect scepkaRect = CGRectMake(lineStart-firstAndLastR/2.0, y-img.size.height/2.0 + 0.5, img.size.width, img.size.height);
        [img drawInRect:scepkaRect];
        
        CGFloat origin1=(img.size.width-2*middleR)/4.0;
        CGFloat origin2=origin1+img.size.width/2.0;
        
        CGRect circleRect1 = CGRectMake(scepkaRect.origin.x + origin1 + 1.0, y - middleR/2.0, middleR, middleR); //+1.0 for krasota )
        CGRect circleRect2 = CGRectMake(scepkaRect.origin.x + origin2 - 1.0, y - middleR/2.0, middleR, middleR);
        
        [self drawCircleInRect:circleRect1 color:[self dsFirstStationSaturatedColor] context:c];
        [self drawCircleInRect:circleRect2 color:[colorArray objectAtIndex:0] context:c];
        
  
    } else {
        //first point
        CGRect firstCircleRect = CGRectMake(lineStart-firstAndLastR/2.0, y-firstAndLastR/2.0, firstAndLastR, firstAndLastR);
        
        [self drawCircleInRect:firstCircleRect color:[colorArray objectAtIndex:0] context:c];        
    }
    
    if ([self dsIsEndingTransfer]) {
        
        UIImage *img= [UIImage imageNamed:@"scepka_horiz.png"];
        
        CGRect scepkaRect = CGRectMake(overallLineWidth+lineStart - img.size.width+firstAndLastR/2.0, y-img.size.height/2.0 + 0.5, img.size.width, img.size.height);
        [img drawInRect:scepkaRect];
        
        CGFloat origin1=(img.size.width-2*middleR)/4.0;
        CGFloat origin2=origin1+img.size.width/2.0;
        
        CGRect circleRect1 = CGRectMake(scepkaRect.origin.x + origin1 + 1.0, y - middleR/2.0, middleR, middleR); //+1.0 for krasota )
        CGRect circleRect2 = CGRectMake(scepkaRect.origin.x + origin2 - 1.0, y - middleR/2.0, middleR, middleR);
        
        [self drawCircleInRect:circleRect1 color:[colorArray lastObject] context:c];
        [self drawCircleInRect:circleRect2 color:[self dsLastStationSaturatedColor] context:c];
        
    } else {
        // last point
        CGRect lastCircleRect = CGRectMake(overallLineWidth+lineStart - firstAndLastR/2.0 , y-firstAndLastR/2.0, firstAndLastR, firstAndLastR);
        
        [self drawCircleInRect:lastCircleRect color:[colorArray lastObject] context:c];
    }
    
    // ставим промежуточные пересадки
    
    int transfers = [timeArray count]-1;

    for (int i=0;i<transfers;i++)
    {        
        UIImage *img= [UIImage imageNamed:@"scepka_horiz.png"];
 
        CGRect scepkaRect = CGRectMake([[points objectAtIndex:i] floatValue]-img.size.width/2.0, y-img.size.height/2.0 + 0.5, img.size.width, img.size.height);
        [img drawInRect:scepkaRect];
        
        CGFloat origin1=(img.size.width-2*middleR)/4.0;
        CGFloat origin2=origin1+img.size.width/2.0;
                
        CGRect circleRect1 = CGRectMake(scepkaRect.origin.x + origin1 + 1.0, y - middleR/2.0, middleR, middleR); //+1.0 for krasota )
        CGRect circleRect2 = CGRectMake(scepkaRect.origin.x + origin2 - 1.0, y - middleR/2.0, middleR, middleR);

        [self drawCircleInRect:circleRect1 color:[colorArray objectAtIndex:i] context:c];
        [self drawCircleInRect:circleRect2 color:[colorArray objectAtIndex:i+1] context:c];
    } 
}

-(void) drawCircleInRect:(CGRect)circleRect color:(UIColor*)color context:(CGContextRef)c
{
    const CGFloat* components = CGColorGetComponents([color CGColor]);
    CGContextSetRGBStrokeColor(c, components[0],components[1], components[2],  CGColorGetAlpha([color CGColor])); 
    CGContextSetRGBFillColor(c, components[0],components[1], components[2],  CGColorGetAlpha([color CGColor]));  
    CGContextSetLineWidth(c, 0.0);
    CGContextFillEllipseInRect(c, circleRect);
    CGContextStrokeEllipseInRect(c, circleRect);

    UIImage *bevelImg = [UIImage imageNamed:@"bevel.png"];
    [bevelImg drawInRect:circleRect]; 

}

@end
