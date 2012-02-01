//
//  VectorLayer.m
//  tube
//
//  Created by Vasiliy Makarov on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VectorLayer.h"

@implementation VectorLine

@synthesize boundingBox;

-(id) initWithPoints:(NSArray *)points andColor:(CGColorRef)color
{
    if((self = [super init])) {
        col = CGColorRetain(color);
        width = [[points lastObject] intValue];
        path = CGPathCreateMutable();
        NSRange range;
        range.location = 0;
        range.length = [points count] - 1;
        BOOL first = YES;
        for (NSString* s in [points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]) {
            NSArray *c = [s componentsSeparatedByString:@","];
            if([c count] < 2) continue;
            if(first) {
                CGPathMoveToPoint(path, nil, [[c objectAtIndex:0] intValue], [[c objectAtIndex:1] intValue]);
                first = NO;
            } else
                CGPathAddLineToPoint(path, nil, [[c objectAtIndex:0] intValue], [[c objectAtIndex:1] intValue]);
        }
        boundingBox = CGPathGetPathBoundingBox(path);
    }
    return self;
}

-(void) dealloc
{
    CGColorRelease(col);
    CGPathRelease(path);
}

-(void) draw:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, col);
    CGContextSetLineWidth(context, width);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

@end

@implementation VectorPolygon

@synthesize boundingBox;

-(id) initWithPoints:(NSArray *)points andColor:(CGColorRef)color
{
    if((self = [super init])) {
        col = CGColorRetain(color);
        path = CGPathCreateMutable();
        BOOL first = YES;
        for (NSString *s in points) {
            NSArray *c = [s componentsSeparatedByString:@","];
            if([c count] < 2) continue;
            if(first) {
                CGPathMoveToPoint(path, nil, [[c objectAtIndex:0] intValue], [[c objectAtIndex:1] intValue]);
                first = NO;
            } else 
                CGPathAddLineToPoint(path, nil, [[c objectAtIndex:0] intValue], [[c objectAtIndex:1] intValue]);

        }
        CGPathCloseSubpath(path);
        boundingBox = CGPathGetPathBoundingBox(path);
    }
    return self;
}

-(void)dealloc
{
    CGColorRelease(col);
    CGPathRelease(path);
}

-(void)draw:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, col);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
}

@end

@implementation VectorLayer

-(id)initWithFile:(NSString *)fileName
{
    if((self = [super init])) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        elements = [[NSMutableArray alloc] init];
        [self loadFrom:fileName];
    }
    return self;
}

-(void)dealloc
{
    [elements release];
    CGColorRelease(brushColor);
    CGColorRelease(penColor);
    CGColorSpaceRelease(colorSpace);
}

- (CGColorRef) colorForHex:(NSString *)hexColor {
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
				 [NSCharacterSet whitespaceAndNewlineCharacterSet]
				 ] uppercaseString];  
	
    // String should be 6 or 7 characters if it includes '#'  
    if ([hexColor length] < 6) 
		return nil;
	
    // strip # if it appears  
    if ([hexColor hasPrefix:@"#"]) 
		hexColor = [hexColor substringFromIndex:1];  
	
    // if the value isn't 6 characters at this point return 
    // the color black	
    if ([hexColor length] != 6) 
		return nil;
	
    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2; 
	
    NSString *rString = [hexColor substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
	
    range.location = 4;  
    NSString *bString = [hexColor substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
    
    float components[4];
    components[0] = (float) r / 255.0f;
    components[1] = (float) g / 255.0f;
    components[2] = (float) b / 255.0f;
    components[3] = 1.f;
	
    return CGColorCreate(colorSpace, components);
}


-(void)loadFrom:(NSString *)fileName
{
    NSString *fn = [[NSBundle mainBundle] pathForResource:fileName ofType:@"vec"];
    NSString *contents = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:nil];
    [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSArray *words = [line componentsSeparatedByString:@" "];
        NSString *w = [[words objectAtIndex:0] lowercaseString];
        if([w isEqualToString:@"size"]) {
            NSArray *a = [[words objectAtIndex:1] componentsSeparatedByString:@"x"];
            size.width = [[a objectAtIndex:0] intValue];
            size.height = [[a objectAtIndex:1] intValue];
            
        } else if([w isEqualToString:@"brushcolor"]) {
            if(brushColor != nil) CGColorRelease(brushColor);
            brushColor = [self colorForHex:[words objectAtIndex:1]];
            
        } else if([w isEqualToString:@"pencolor"]) {
            if(penColor != nil) CGColorRelease(penColor);
            penColor = [self colorForHex:[words objectAtIndex:1]];
            
        } else if([w isEqualToString:@"line"]) {
            NSRange range;
            range.location = 1;
            range.length = [words count] - 1;
            [elements addObject:[[VectorLine alloc] initWithPoints:[words objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]] andColor:penColor]];
            
        } else if([w isEqualToString:@"polygon"]) {
            NSRange range;
            range.location = 1;
            range.length = [words count] - 1;
            [elements addObject:[[VectorPolygon alloc] initWithPoints:[words objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]] andColor:brushColor]];
            
        }
    }];
}

-(void)draw:(CGContextRef)context inRect:(CGRect)rect
{
    for (id element in elements) {
        if(CGRectIntersectsRect(rect, [element boundingBox])) {
            [element draw:context];
        }
    }
}

@end
