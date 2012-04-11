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
    CGFloat ylineStart = 20.0f;
    CGFloat x=20.0f;
    
    CGFloat transferHeight = 95.0f;
    CGFloat emptyTransferHeight = 40.0f; //without train picture, without exit information
    CGFloat stationHeight = 20.0f;
    CGFloat finalHeight = 60.0f;
    
    NSMutableArray *stations = [[[NSMutableArray alloc] initWithArray:[delegate dsGetStationsArray]] autorelease];
    
    int trainType = 0;
    int stationType = 0;
    int finalType = 0;
    
    points = [[NSMutableArray alloc] initWithCapacity:1];
    
    CGFloat viewHeight=0;
    CGFloat segmentHeight;
    
    if ([delegate dsIsStartingTransfer]) {
        [stations removeObjectAtIndex:0];
        ylineStart+=20.0;
    }
    
    if ([delegate dsIsEndingTransfer]) {
        [stations removeLastObject];
    }
    
    NSMutableArray *exits = [delegate dsGetExitForStations]; 
    
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
        
        segmentHeight =  (float)trainType * tempTH +(float)finalType*finalHeight + (float)stationType * stationHeight;    
        [points addObject:[NSNumber numberWithFloat:segmentHeight]];
        
        viewHeight += segmentHeight;
    }
    
    
    NSArray *colorArray = [delegate dsGetLinesColorArray];
    NSArray *timeArray = [delegate dsGetLinesTimeArray];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat currentY = ylineStart;
    
    int segmentsCount = [timeArray count]; //[points count];
    
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
        
    }
    
    if ([delegate dsIsStartingTransfer]) {
        UIImage *img= [UIImage imageNamed:@"scepka_vertic.png"];
        
        [img drawInRect:CGRectMake(x-img.size.width/2, ylineStart-img.size.height/2, img.size.width, img.size.height)];
        
        CGRect allRect = CGRectMake(x-img.size.width/2, ylineStart-img.size.height/2, img.size.width, img.size.height);
        CGRect circleRect = CGRectMake(allRect.origin.x + 6, allRect.origin.y + 6, 12, 12);
        
        [self drawCircleInRect:circleRect color:[delegate dsFirstStationSaturatedColor] context:c];
        
        CGRect allRect2 = CGRectMake(x-img.size.width/2, ylineStart, img.size.width, img.size.height);
        CGRect circleRect2 = CGRectMake(allRect2.origin.x + 6, allRect2.origin.y + 4, 12, 12);
      
        [self drawCircleInRect:circleRect2 color:[colorArray objectAtIndex:0] context:c];

    } else {

        CGRect firstRect = CGRectMake(x,ylineStart,8,8);
        CGRect firstCircleRect = CGRectMake(firstRect.origin.x-7.0, firstRect.origin.y-7.0, 14, 14);
        
        [self drawCircleInRect:firstCircleRect color:[colorArray objectAtIndex:0] context:c];

    }
    
     if ([delegate dsIsEndingTransfer]) {
         UIImage *img= [UIImage imageNamed:@"scepka_vertic.png"];
         
         [img drawInRect:CGRectMake(x-img.size.width/2, currentY-img.size.height/2, img.size.width, img.size.height)];
         
         CGRect allRect = CGRectMake(x-img.size.width/2, currentY-img.size.height/2, img.size.width, img.size.height);
         CGRect circleRect = CGRectMake(allRect.origin.x + 6, allRect.origin.y + 6, 12, 12);
         
         [self drawCircleInRect:circleRect color:[colorArray lastObject] context:c];
         
         CGRect allRect2 = CGRectMake(x-img.size.width/2, currentY, img.size.width, img.size.height);
         CGRect circleRect2 = CGRectMake(allRect2.origin.x + 6, allRect2.origin.y + 4, 12, 12);
        
         [self drawCircleInRect:circleRect2 color:[delegate dsLastStationSaturatedColor] context:c];
 
     } else {

         CGRect lastRect = CGRectMake(x,ylineStart+viewHeight,6,6);
         CGRect lastCircleRect = CGRectMake(lastRect.origin.x-7.0 , lastRect.origin.y-7.0, 14, 14);
         
         [self drawCircleInRect:lastCircleRect color:[colorArray lastObject] context:c];
     }

    

    // точки станций
    for (int j=0;j<segmentsCount;j++) {
        
        if (j==0 ) {
            if ([[exits objectAtIndex:j] intValue]!=0) {
                currentY=ylineStart+transferHeight;
            } else {
                currentY=ylineStart+emptyTransferHeight;
            }
            
        } else {
            currentY=0;
            
            NSArray *array = [points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, j)]];
            
            
            for (NSNumber *segmentH in array) {
                currentY+=[segmentH floatValue];
            }
            
            if ([[exits objectAtIndex:j] intValue]!=0) {
                currentY+=transferHeight+ylineStart;
            } else {
                currentY+=emptyTransferHeight+ylineStart;
            }
            
        }

        int qqq = [[stations objectAtIndex:j] count]-2;
        for (int jj=0;jj<qqq;jj++) {
 
                CGRect firstRect1 = CGRectMake(x,currentY,8,8);
                CGRect firstCircleRect1 = CGRectMake(firstRect1.origin.x-5.0, firstRect1.origin.y, 10, 10);
                
                [self drawCircleInRect:firstCircleRect1 color:[colorArray objectAtIndex:j] context:c];
                
                currentY+=stationHeight;
            
        }
    }
    
    
    for (int i=0;i<[timeArray count]-1;i++)
    {
        UIImage *img= [UIImage imageNamed:@"scepka_vertic.png"];
        
        currentY=0;
            
        NSArray *array = [points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, i+1)]];
            
        for (NSNumber *segmentH in array) {
            currentY+=[segmentH floatValue];
        }
            
        currentY+=ylineStart;
    
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
