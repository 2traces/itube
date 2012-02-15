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

@implementation PathDrawView

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


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat overallLineWidth = 261.0f;
    CGFloat lineStart = 44.0f;
    CGFloat y = 29.0f+rect.origin.y;
    CGFloat lineH=6.0;
    CGFloat firstAndLastR=9.0;
    CGFloat middleR=9.0;
    
    CGFloat x, segmentLenght;
    
    x=lineStart;
    
    NSArray *colorArray = [delegate dsGetLinesColorArray];
    NSArray *timeArray = [delegate dsGetLinesTimeArray];
    
    for (UIColor *color1 in colorArray) {
        color1 = [color1 saturatedColor]; 
    }
    
    points = [[NSMutableArray alloc] initWithCapacity:1];
    
    travelTime=0;
    
    for (NSNumber *segTime in timeArray) {
        travelTime+=[segTime integerValue];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
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
    
    //first point
    CGRect firstCircleRect = CGRectMake(lineStart-firstAndLastR/2.0, y-firstAndLastR/2.0, firstAndLastR, firstAndLastR);
    
    [self drawCircleInRect:firstCircleRect color:[colorArray objectAtIndex:0] context:c];
    
    // last point
    CGRect lastCircleRect = CGRectMake(overallLineWidth+lineStart - firstAndLastR/2.0 , y-firstAndLastR/2.0, firstAndLastR, firstAndLastR);
    
    [self drawCircleInRect:lastCircleRect color:[colorArray lastObject] context:c];
  
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
