//
//  RasterLayer.m
//  tube
//
//  Created by Vasiliy Makarov on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RasterLayer.h"

@class RPiece;

/***** RManager *****/

@interface RManager : NSObject {
    NSMutableArray *queue;
    NSTimer *timer;
    id target;
    SEL selector;
    NSString *path;
}

-(id)initWithPath:(NSString*)path;
-(id)initWithTarget:(id)target selector:(SEL)selector andPath:(NSString*)path;
-(void)load:(RPiece*)piece;

@end

@implementation RManager

-(void)loading
{
    BOOL res = NO;
    while([queue count]) {
        [[queue objectAtIndex:0] load];
        res = YES;
    }
    if(res) {
        [target performSelector:selector];
    }
}

-(id)initWithPath:(NSString*)p
{
    return [self initWithTarget:nil selector:nil andPath:p];
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

/***** RPiece *****/

@interface RPiece : NSObject {
    CGRect rect;
    NSString *path;
    CGImageRef image;
    int actuality;
}
@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) int actuality;
@property (nonatomic, readonly) BOOL loaded;

-(id)initWithPath:(NSString*)path andRect:(CGRect)r;
-(BOOL)draw:(CGContextRef)context;
-(void)skip;
-(void)load;
-(void)unload;

@end

@implementation RPiece

@synthesize rect;
@synthesize actuality;

-(id) initWithPath:(NSString *)p andRect:(CGRect)r
{
    if((self = [super init])) {
        const char* pf = [p UTF8String];
        FILE *fi = fopen(pf, "r");
        if(fi == 0) {
            [self release];
            return nil;
        }
        path = [p retain];
        rect = r;
        image = nil;
        actuality = 0;
    }
    return self;
}

-(BOOL) loaded
{
    return image != nil;
}

-(BOOL) draw:(CGContextRef)context
{
    if(image == nil) {
        [Manager load:self];
        return NO;
    } else {
        CGContextDrawImage(context, rect, image);
        actuality = 0;
        return YES;
    }
}

-(void) skip
{
    actuality ++;
}

-(void)load
{
	const char* fileName = [path UTF8String];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
	image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
}

-(void)unload
{
    if(image != nil) {
        CGImageRelease(image);
        image = nil;
    }
}

-(void)dealloc
{
    [path release];
    if(image) CGImageRelease(image);
    [super dealloc];
}

@end

/***** RLayer *****/

@interface RLayer : NSObject {
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


/***** RasterLayer *****/

@implementation RasterLayer

-(id) initWithRect:(CGRect)rect
{
    if((self = [super init])) {
        rasterPath = [[NSBundle mainBundle] pathForResource:@"raster" ofType:nil];
        layers = [[NSMutableArray alloc] init];
        for (int i=0; i<=13; i++) {
            [layers addObject:[[RLayer alloc] initWithPath:[NSString stringWithFormat:@"%@/%d",rasterPath,i] num:i andRect:rect]];
        }
        [[layers objectAtIndex:0] upload];
    }
    return self;
}

-(BOOL)draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale
{
    int l = (int)(scale - 0.5f);
    if(l < 0) l = 0;
    if(l >= [layers count]) l = [layers count]-1;
    for(int i=0; i<[layers count]; i++) {
        if(i != l) [[layers objectAtIndex:i] skip];
    }
    if([[layers objectAtIndex:l] covers:rect]) {
        [[layers objectAtIndex:l] draw:context rect:rect];
        return YES;
    } else {
        [[layers objectAtIndex:0] draw:context rect:rect];
        [[layers objectAtIndex:l] draw:context rect:rect];
        return NO;
    }
}


-(void) freeSomeMemory
{
    for (RLayer *l in layers) {
        [l freeSomeMemory];
    }
}

@end
