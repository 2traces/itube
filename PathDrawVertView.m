//
//  PathDrawVertView.m
//  tube
//
//  Created by sergey on 02.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathDrawVertView.h"
#import "PathDrawView.h"

@implementation PathDrawVertView

@synthesize pathInfo;
@synthesize travelTime;
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat segmentLenght;
    CGFloat lineStart = 20.0f;
    CGFloat x=20.0f;
    
    CGFloat transferHeight = 90.0f;
    CGFloat stationHeight = 20.0f;
    CGFloat finalHeight = 60.0f;
    
    NSArray *stations = [delegate dsGetStationsArray];
    
    int transferNumb = [stations count]-1;
    
    int trainType = 0;
    int stationType = 0;
    int finalType = 0;
    
    points = [[NSMutableArray alloc] initWithCapacity:1];
    
    
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
    
    
    NSArray *colorArray = [delegate dsGetLinesColorArray];
//    NSArray *timeArray = [delegate dsGetLinesTimeArray];
    

    /*
    travelTime=0;
    
    for (NSNumber *segTime in timeArray) {
        travelTime+=[segTime integerValue];
    }
    */
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat currentY = lineStart;
    
    int segmentsCount = [points count];
    
    for  (int i=0;i<segmentsCount;i++) {

        segmentLenght = [[points objectAtIndex:i] floatValue]; 
            
        UIColor *lineColor = [colorArray objectAtIndex:i];
        
        CGContextSetStrokeColorWithColor(c, [lineColor CGColor]);
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, 6.0);
        CGContextMoveToPoint(c, x, currentY);
        CGContextAddLineToPoint(c, x, currentY+segmentLenght);
        CGContextStrokePath(c);
        
        currentY+=segmentLenght;
        
//        [points addObject:[NSNumber numberWithFloat:currentY]];
        
    }
    
    // first point
    CGRect firstRect = CGRectMake(x,lineStart,8,8);
    CGRect firstCircleRect = CGRectMake(firstRect.origin.x-7.0, firstRect.origin.y, 14, 14);
    
    [self drawCircleInRect:firstCircleRect color:[colorArray objectAtIndex:0] context:c];
    
    // last point
    CGRect lastRect = CGRectMake(x,lineStart+viewHeight,6,6);
    CGRect lastCircleRect = CGRectMake(lastRect.origin.x-7.0 , lastRect.origin.y, 14, 14);
    
    [self drawCircleInRect:lastCircleRect color:[colorArray lastObject] context:c];
    

    // точки станций
    for (int j=0;j<segmentsCount;j++) {
        
        if (j==0 ) {
            currentY=lineStart+transferHeight;
        } else {
            currentY=0;
            
            NSArray *array = [points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, j)]];
            
            
            for (NSNumber *segmentH in array) {
                currentY+=[segmentH floatValue];
            }
            
            currentY+=transferHeight+lineStart;
        }

        for (int jj=0;jj<[[stations objectAtIndex:j] count]-2;jj++) {
 
                CGRect firstRect1 = CGRectMake(x,currentY,8,8);
                CGRect firstCircleRect1 = CGRectMake(firstRect1.origin.x-5.0, firstRect1.origin.y, 10, 10);
                
                [self drawCircleInRect:firstCircleRect1 color:[colorArray objectAtIndex:j] context:c];
                
                currentY+=stationHeight;
            
        }
    }
    
    
    for (int i=0;i<transferNumb;i++)
    {
        UIImage *img= [UIImage imageNamed:@"scepka_vertic.png"];
        
        currentY=0;
            
        NSArray *array = [points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, i+1)]];
            
        for (NSNumber *segmentH in array) {
            currentY+=[segmentH floatValue];
        }
            
        currentY+=lineStart;
    
        [img drawInRect:CGRectMake(x-img.size.width/2, currentY-img.size.height/2, img.size.width, img.size.height)];
        
        CGRect allRect = CGRectMake(x-img.size.width/2, currentY-img.size.height/2, img.size.width, img.size.height);
        CGRect circleRect = CGRectMake(allRect.origin.x + 6, allRect.origin.y + 6, 12, 12);
        
        [self drawCircleInRect:circleRect color:[colorArray objectAtIndex:i] context:c];
        
        
        CGRect allRect2 = CGRectMake(x-img.size.width/2, currentY, img.size.width, img.size.height);
        CGRect circleRect2 = CGRectMake(allRect2.origin.x + 6, allRect2.origin.y + 4, 12, 12);
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
