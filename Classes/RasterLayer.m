//
//  RasterLayer.m
//  tube
//
//  Created by Vasiliy Makarov on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RasterLayer.h"

/***** RPiece *****/

@implementation RPiece

-(id) initWithRect:(CGRect)r level:(int)_level x:(int)_x y:(int)_y
{
    if((self = [super init])) {
        rect = r;
        level = _level;
        x = _x;
        y = _y;
        image = nil;
        actuality = 0;
    }
    return self;
}

-(BOOL) loaded
{
    return image != nil;
}

-(void) draw:(CGContextRef)context
{
    if(image != nil) {
        CGContextDrawImage(context, rect, image);
        actuality = 0;
    }
}

-(void) skip
{
    actuality ++;
}

-(void)dealloc
{
    if(image) CGImageRelease(image);
    [super dealloc];
}

@end

/***** RManager *****/

@implementation RManager

-(void)loading
{
    BOOL res = NO;
    while([queue count]) {
        RPiece *p = [queue objectAtIndex:0];
        if(p->image == nil) {
            NSString *pt = [NSString stringWithFormat:@"%@/%d/%d/%d.jpg", path, p->level, p->x, p->y];
            const char* fileName = [pt UTF8String];
            CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
            p->image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
        }
        [queue removeObjectAtIndex:0];
        res = YES;
    }
    if(res) {
        [target performSelector:selector];
    }
}

-(id)initWithTarget:(id)t selector:(SEL)s andPath:(NSString*)p
{
    if((self = [super init])) {
        path = [p retain];
        target = target;
        selector = selector;
        queue = [[NSMutableArray alloc] init];
        timer = [NSTimer timerWithTimeInterval:0.1f target:self selector:@selector(loading) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)load:(RPiece *)piece
{
    [queue addObject:piece];
}

-(void)dealloc
{
    [path release];
    [queue release];
    [timer release];
    [super dealloc];
}

@end

/***** RLayer *****/

/*@interface RLayer : NSObject {
    NSString *layerPath;
    NSMutableArray *pieces;
}
-(id) initWithPath:(NSString*)path num:(int)num andRect:(CGRect)rect;
-(void)draw:(CGContextRef)context rect:(CGRect)rect;
-(void)upload;
-(BOOL)covers:(CGRect)rect;
-(void)skip;
-(void)freeSomeMemory;

@end

@implementation RLayer

-(id)initWithPath:(NSString *)path num:(int)num andRect:(CGRect)r
{
    if((self = [super init])) {
        layerPath = [path retain];
        pieces = [[NSMutableArray alloc] init];
        int size = 1;
        for(int i=0; i<num; i++) size *= 2;
        CGFloat dx = r.size.width / size;
        CGFloat dy = r.size.height / size;
        CGRect r1 = CGRectMake(r.origin.x, r.origin.y, dx, dy);
        for(int x=0; x<size; x++) {
            r1.origin.x = r.origin.x + x*dx;
            for(int y=0; y<size; y++) {
                r1.origin.y = r.origin.y + y*dy;
                NSString *p1 = [NSString stringWithFormat:@"%@/%d/%d.jpg", path, x, y];
                RPiece *p = [[RPiece alloc] initWithPath:p1 andRect:r1];
                if(p != nil) {
                    [pieces addObject:p];
                }
            }
        }
        
    }
    return self;
}

-(void)draw:(CGContextRef)context rect:(CGRect)rect
{
    for (RPiece *p in pieces) {
        if(CGRectIntersectsRect(rect, p.rect)) {
            [p draw:context];
        } else {
            [p skip];
        }
    }
}

-(void) upload
{
    for (RPiece* p in pieces) {
        [p load];
    }
}

-(BOOL) covers:(CGRect)rect
{
    for (RPiece *p in pieces) {
        if(CGRectIntersectsRect(rect, p.rect) && !p.loaded)
            return NO;
    }
    return YES;
}

-(void) skip
{
    for (RPiece *p in pieces) {
        [p skip];
    }
}

-(void)freeSomeMemory
{
    for (RPiece *p in pieces) {
        if(p.actuality > 5) [p unload];
    }
}

-(void)dealloc
{
    [layerPath release];
    [super dealloc];
}

@end
*/

/***** RasterLayer *****/

@implementation RasterLayer

-(id) initWithRect:(CGRect)rect
{
    if((self = [super init])) {
        allRect = rect;
        NSString *rasterPath = [[NSBundle mainBundle] pathForResource:@"raster" ofType:nil];
        pieces = [[NSMutableArray alloc] init];
        level = 0;
        loader = [[RManager alloc] initWithTarget:self selector:@selector(complete) andPath:rasterPath];
        RPiece *p = [[RPiece alloc] initWithRect:rect level:0 x:0 y:0];
        [loader load:p];
    }
    return self;
}

-(void)complete
{
    // TODO
}

-(BOOL)draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale
{
    level = (int)(scale - 0.5f);
    if(level < 0) level = 0;
    NSNumber *n = [NSNumber numberWithInt:level];
    NSMutableArray *lev = [levels objectForKey:n];
    if(lev == nil) {
        lev = [NSMutableArray array];
        [levels setObject:lev forKey:n];
    }
    int size = 1 << level;
    CGFloat dx = allRect.size.width / size, dy = allRect.size.height / size;
    int x1 = rect.origin.x / dx, y1 = rect.origin.y / dy;
    int x2 = (rect.origin.x + rect.size.width) / dx, y2 = (rect.origin.y + rect.size.height) / dy;
    for(int X=x1; X<=x2; X++) {
        for(int Y=y1; Y<=y2; Y++) {
            BOOL found = NO;
            for (RPiece *p in lev) {
                if(p->x == X && p->y == Y) {
                    [p draw:context];
                    found = YES;
                }
            }
            if(!found) {
                // loading
            }
        }
    }
}


-(void) freeSomeMemory
{
    for (id key in levels) {
        NSMutableArray *l = [levels objectForKey:key];
        for (RPiece *p in l) {
            if(p->actuality > 5) [l removeObject:p];
        }
        if([l count] <= 0) {
            [levels removeObjectForKey:key];
        }
    }
}

@end
