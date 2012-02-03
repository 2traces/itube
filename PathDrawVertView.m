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
    
    CGFloat transferHeight = 60.0f;
    CGFloat stationHeight = 40.0f;
    
    NSArray *stations = [delegate dsGetStationsArray];
    
    int transferNumb = [stations count]-1;
    
    int stationNumbers=0;
    
    for (NSMutableArray *tempStations in stations) {
        stationNumbers+=[tempStations count];
    }
    
    CGFloat viewHeight =  (float)(transferNumb +1) * transferHeight + (float) stationNumbers * stationHeight;    
    
    NSArray *colorArray = [delegate dsGetLinesColorArray];
    NSArray *timeArray = [delegate dsGetLinesTimeArray];
    
    points = [[NSMutableArray alloc] initWithCapacity:1];
    
    travelTime=0;
    
    for (NSNumber *segTime in timeArray) {
        travelTime+=[segTime integerValue];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat currentY = lineStart;
    
    int segmentsCount = [stations count];
    
    for  (int i=0;i<segmentsCount;i++) {

        segmentLenght = [[stations objectAtIndex:i] count]*stationHeight+transferHeight; 
            
        UIColor *lineColor = [colorArray objectAtIndex:i];
        
        CGContextSetStrokeColorWithColor(c, [lineColor CGColor]);
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, 8.0);
        CGContextMoveToPoint(c, x, currentY);
        CGContextAddLineToPoint(c, x, currentY+segmentLenght);
        CGContextStrokePath(c);
        
        currentY+=segmentLenght;
        
        [points addObject:[NSNumber numberWithFloat:currentY]];
        
    }
    
    // first point
    CGRect firstRect = CGRectMake(x,lineStart,8,8);
    CGRect firstCircleRect = CGRectMake(firstRect.origin.x-7.0, firstRect.origin.y, 14, 14);
    
    [self drawCircleInRect:firstCircleRect color:[colorArray objectAtIndex:0] context:c];
    
    // last point
    CGRect lastRect = CGRectMake(x,lineStart+viewHeight,6,6);
    CGRect lastCircleRect = CGRectMake(lastRect.origin.x-7.0 , lastRect.origin.y, 14, 14);
    
    [self drawCircleInRect:lastCircleRect color:[colorArray lastObject] context:c];
    
    for (int j=0;j<segmentsCount;j++) {
        
        if (j==0 ) {
            currentY=lineStart+transferHeight;
        } else {
            currentY=[[points objectAtIndex:j-1] floatValue]+transferHeight;
        }
        
        NSArray *tempStations = [stations objectAtIndex:j];
        
        int segStationsCount = [tempStations count];

        for (int k=1; k<segStationsCount;k++) {
            
                CGRect firstRect1 = CGRectMake(x,currentY,8,8);
                CGRect firstCircleRect1 = CGRectMake(firstRect1.origin.x-7.0, firstRect1.origin.y, 14, 14);
            
                [self drawCircleInRect:firstCircleRect1 color:[colorArray objectAtIndex:j] context:c];

                currentY+=stationHeight;
        }
    }
    
    for (int i=0;i<transferNumb;i++)
    {
        UIImage *img= [UIImage imageNamed:@"scepka_vertic.png"];
        
        [img drawInRect:CGRectMake(x-img.size.width/2, [[points objectAtIndex:i] floatValue]-img.size.height/2, img.size.width, img.size.height)];
        
        CGRect allRect = CGRectMake(x-img.size.width/2, [[points objectAtIndex:i] floatValue]-img.size.height/2, img.size.width, img.size.height);
        CGRect circleRect = CGRectMake(allRect.origin.x + 6, allRect.origin.y + 6, 12, 12);
        
        [self drawCircleInRect:circleRect color:[colorArray objectAtIndex:i] context:c];
        
        
        CGRect allRect2 = CGRectMake(x-img.size.width/2, [[points objectAtIndex:i] floatValue], img.size.width, img.size.height);
        CGRect circleRect2 = CGRectMake(allRect2.origin.x + 6, allRect2.origin.y + 4, 12, 12);
        [self drawCircleInRect:circleRect2 color:[colorArray objectAtIndex:i+1] context:c];
    } 
}


-(void) drawCircleInRect:(CGRect)circleRect color:(UIColor*)color context:(CGContextRef)c
{
    const CGFloat* components = CGColorGetComponents([color CGColor]);
    CGContextSetRGBStrokeColor(c, components[0],components[1], components[2],  CGColorGetAlpha([color CGColor])); 
    CGContextSetRGBFillColor(c, components[0],components[1], components[2],  CGColorGetAlpha([color CGColor]));  
    CGContextSetLineWidth(c, 2.0);
    CGContextFillEllipseInRect(c, circleRect);
    CGContextStrokeEllipseInRect(c, circleRect);
}

@end
