//
//  PathDrawView.m
//  tube
//
//  Created by sergey on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathDrawView.h"
#import "ManagedObjects.h"

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
    CGFloat overallLineWidth = 265.0f;
    CGFloat lineStart = 40.0f;
    //   CGFloat lineEnd = lineStart + overallLineWidth;
    CGFloat y = 29.0f+rect.origin.y;
    
    CGFloat x, segmentLenght;
    
    x=lineStart;
    
    NSArray *colorArray = [delegate dsGetLinesColorArray];
    NSArray *timeArray = [delegate dsGetLinesTimeArray];
    
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
        CGContextSetLineWidth(c, 8.0);
        CGContextMoveToPoint(c, x, y);
        CGContextAddLineToPoint(c, x+segmentLenght, y);
        CGContextStrokePath(c);
        
        x+=segmentLenght;
        
        [points addObject:[NSNumber numberWithFloat:x]];
        
    }
    
    //first point
    CGRect firstRect = CGRectMake(lineStart,y,8,8);
    CGRect firstCircleRect = CGRectMake(firstRect.origin.x, firstRect.origin.y-4.0, 8, 8);
    
    [self drawCircleInRect:firstCircleRect color:[colorArray objectAtIndex:0] context:c];
    
    // last point
    CGRect lastRect = CGRectMake(overallLineWidth+lineStart,y,6,6);
    CGRect lastCircleRect = CGRectMake(lastRect.origin.x , lastRect.origin.y -4.0, 8, 8);
    
    [self drawCircleInRect:lastCircleRect color:[colorArray lastObject] context:c];
  
    int transfers = [timeArray count]-1;
    
    for (int i=0;i<transfers;i++)
    {
        
        UIImage *img= [UIImage imageNamed:@"scepka_horiz.png"];
 
        [img drawInRect:CGRectMake([[points objectAtIndex:i] floatValue]-img.size.width/2, y-img.size.height/2, img.size.width, img.size.height)];
        
        CGRect allRect = CGRectMake([[points objectAtIndex:i] floatValue]-img.size.width/2, y-img.size.height/2, img.size.width, img.size.height);
        CGRect circleRect = CGRectMake(allRect.origin.x + 4, allRect.origin.y + 4, 6,
                                       6);

        [self drawCircleInRect:circleRect color:[colorArray objectAtIndex:i] context:c];
        

        CGRect allRect2 = CGRectMake([[points objectAtIndex:i] floatValue], y-img.size.height/2, img.size.width, img.size.height);
        CGRect circleRect2 = CGRectMake(allRect2.origin.x + 4, allRect2.origin.y + 4, 6,
                                       6);
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
