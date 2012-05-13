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
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.f, rect.origin.y*2.f + rect.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        CGContextDrawImage(context, rect, image);
        CGContextRestoreGState(context);
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

@synthesize lock;

-(BOOL)loadPiece:(RPiece*)p
{
    if(p->image == nil) {
        NSString *pt = [NSString stringWithFormat:@"%@/%d/%d/%d.png", path, p->level, p->x, p->y];
        const char* fileName = [pt UTF8String];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
        if(dataProvider == nil) {
            //NSLog(@"file not found %@", pt);
            p->level = -1;
        } else {
            p->image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
            p->layer->piecesCount ++;
            return YES;
        }
    }
    return NO;
}

-(void)loading
{
    int res = 0;
    while([queue count]) {
        [lock lock];
        if([self loadPiece:[queue objectAtIndex:0]]) res ++;
        [queue removeObjectAtIndex:0];
        [lock unlock];
    }
    if(res) {
        [target performSelector:selector];
    }
    res = 0;
    while([secondQueue count]) {
        [lock lock];
        if([self loadPiece:[secondQueue objectAtIndex:0]]) res ++;
        [secondQueue removeObjectAtIndex:0];
        [lock unlock];
    }
}

-(id)initWithTarget:(id)t selector:(SEL)s andPath:(NSString*)p
{
    if((self = [super init])) {
        path = [p retain];
        target = t;
        selector = s;
        lock = [[NSRecursiveLock alloc] init];
        queue = [[NSMutableArray alloc] init];
        secondQueue = [[NSMutableArray alloc] init];
        timer = [NSTimer timerWithTimeInterval:0.1f target:self selector:@selector(loading) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)load:(RPiece *)piece
{
    [queue addObject:piece];
}

-(void)secondLoad:(RPiece *)piece
{
    [secondQueue addObject:piece];
}

-(void)dealloc
{
    [path release];
    [queue release];
    [secondQueue release];
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
        levels = [[NSMutableDictionary alloc] init];
        level = 0;
        MAX_PIECES = 30;
        loader = [[RManager alloc] initWithTarget:self selector:@selector(complete) andPath:rasterPath];
        piecesCount = 0;
    }
    return self;
}

-(void)complete
{
    NSLog(@"raster map is loaded");
    [loader.lock lock];
    NSMutableArray *l = [levels objectForKey:[NSNumber numberWithInt:level]];
    NSMutableArray *removePieces = [NSMutableArray array];
    for (RPiece *p in l) {
        if(p->level < 0) {
            [removePieces addObject:p];
        }
    }
    [l removeObjectsInArray:removePieces];
    if([l count] <= 0) [levels removeObjectForKey:[NSNumber numberWithInt:level]];
    [loader.lock unlock];
    if(target != nil) {
        [target performSelector:selector];
    }
    while(piecesCount > MAX_PIECES) {
        [self freeSomeMemory];
    }
}

-(BOOL)draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale
{
    for (id key in levels) {
        NSMutableArray *l = [levels objectForKey:key];
        if([l count] > 0) for (RPiece *p in l) {
            [p skip];
        }
    }
    int _sc = 1, _lvl = 0;
    while (scale > _sc) {
        _sc *= 2;
        _lvl ++;
    }
    level = _lvl;
    if(level < 0) level = 0;
    NSNumber *n = [NSNumber numberWithInt:level];
    NSMutableArray *lev = [levels objectForKey:n];
    if(lev == nil) {
        lev = [NSMutableArray array];
        [levels setObject:lev forKey:n];
    }
    [loader.lock lock];
    BOOL allLoaded = YES;
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
                    break;
                }
            }
            if(!found) {
                // loading
                CGRect r = CGRectMake(x1 + dx*X, y1 + dy*Y, dx, dy);
                RPiece *p = [[RPiece alloc] initWithRect:r level:level x:X y:Y];
                p->layer = self;
                [lev addObject:p];
                [loader load:p];
                allLoaded = NO;
            }
        }
    }
    // check next layer
    dx *= 0.5f;
    dy *= 0.5f;
    x1 *= 2;
    y1 *= 2;
    x2 *= 2;
    y2 *= 2;
    n = [NSNumber numberWithInt:level+1];
    lev = [levels objectForKey:n];
    if(lev == nil) {
        lev = [NSMutableArray array];
        [levels setObject:lev forKey:n];
    }
    int cached = 0;
    for(int X=x1; X<=x2; X++) {
        for(int Y=y1; Y<=y2; Y++) {
            BOOL found = NO;
            for (RPiece *p in lev) {
                if(p->x == X && p->y == Y) {
                    found = YES;
                    break;
                }
            }
            if(!found) {
                // loading
                CGRect r = CGRectMake(x1 + dx*X, y1 + dy*Y, dx, dy);
                RPiece *p = [[RPiece alloc] initWithRect:r level:level+1 x:X y:Y];
                p->layer = self;
                [lev addObject:p];
                [loader secondLoad:p];
                cached ++;
            }
        }
    }
    
    [loader.lock unlock];
    if(allLoaded) NSLog(@"raster drawing complete at level %d, %d pieces", level, piecesCount);
    else NSLog(@"raster drawing not complete at level %d, %d pieces", level, piecesCount);
    return allLoaded;
}

-(void)setSignal:(id)_target selector:(SEL)_selector
{
    target = _target;
    selector = _selector;
}


-(void) freeSomeMemory
{
    // remove one piece
    id farthest = nil;
    int length = -1;
    for (id key in levels) {
        int l = abs([key intValue] - level);
        if(length < l) {
            length = l;
            farthest = key;
        }
    }
    if (farthest != nil) {
        NSMutableArray *l = [levels objectForKey:farthest];
        int act = -1;
        RPiece *fp = nil;
        for (RPiece *p in l) {
            if(p->actuality > act)  {
                act = p->actuality;
                fp = p;
            }
        }
        if(fp != nil) {
            [l removeObject:fp];
            piecesCount --;
        }
        if([l count] <= 0) {
            [levels removeObjectForKey:farthest];
        }
    }
}

-(void)dealloc
{
    [loader release];
    [levels release];
    [super dealloc];
}

@end
