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
@synthesize enabled;

-(id) initWithPoints:(NSArray *)points color:(CGColorRef)color andDisabledColor:(CGColorRef)dcol
{
    if((self = [super init])) {
        col = CGColorRetain(color);
        disabledCol = CGColorRetain(dcol);
        width = [[points lastObject] intValue];
        path = CGPathCreateMutable();
        enabled = YES;
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
    CGColorRelease(disabledCol);
    CGPathRelease(path);
}

-(void) draw:(CGContextRef)context
{
    if(enabled) CGContextSetStrokeColorWithColor(context, col);
    else CGContextSetStrokeColorWithColor(context, disabledCol);
    CGContextSetLineWidth(context, width);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

@end

@implementation VectorPolygon

@synthesize boundingBox;
@synthesize enabled;

-(id) initWithPoints:(NSArray *)points color:(CGColorRef)color andDisabledColor:(CGColorRef)dcol
{
    if((self = [super init])) {
        col = CGColorRetain(color);
        disabledCol = CGColorRetain(dcol);
        path = CGPathCreateMutable();
        enabled = YES;
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
    CGColorRelease(disabledCol);
    CGPathRelease(path);
}

-(void)draw:(CGContextRef)context
{
    if(enabled) CGContextSetFillColorWithColor(context, col);
    else CGContextSetStrokeColorWithColor(context, disabledCol);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
}

@end

@implementation VectorLayer

-(id)initWithFile:(NSString *)fileName
{
    if((self = [super init])) {
        enabled = YES;
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

-(BOOL) enabled {
    return enabled;
}

-(void) setEnabled:(BOOL)_enabled {
    enabled = _enabled;
    for (id element in elements) {
        [element setEnabled:enabled];
    }
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

-(CGColorRef) disabledColor:(CGColorRef)normalColor {
    const CGFloat *rgba = CGColorGetComponents(normalColor);
    CGFloat r, g, b, M, m, sd;
    r = rgba[0];
    g = rgba[1];
    b = rgba[2];
    
    // set brightness to 90%
    M = MAX(r, MAX(g, b));
    sd = 0.9f / M;
    r *= sd;
    g *= sd;
    b *= sd;
    M = 0.9f;
    
    // set saturation to 10%
    m = MIN(r, MIN(g, b));
    sd = (0.1f * M) / (M-m);
    r = M - (M-r)*sd;
    g = M - (M-g)*sd;
    b = M - (M-b)*sd;
    
    float components[4];
    components[0] = r;
    components[1] = g;
    components[2] = b;
    components[3] = 1.f;
    return CGColorCreate(colorSpace, components);
}


-(void)loadFrom:(NSString *)fileName
{
    [elements removeAllObjects];
    NSString *fn = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
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
            [elements addObject:[[[VectorLine alloc] initWithPoints:[words objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]] color:penColor andDisabledColor:[self disabledColor:penColor]] autorelease]];
            
        } else if([w isEqualToString:@"polygon"]) {
            NSRange range;
            range.location = 1;
            range.length = [words count] - 1;
            [elements addObject:[[[VectorPolygon alloc] initWithPoints:[words objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]] color:brushColor andDisabledColor:[self disabledColor:brushColor]] autorelease]];
            
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
