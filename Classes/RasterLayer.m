//
//  RasterLayer.m
//  tube
//
//  Created by Vasiliy Makarov on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RasterLayer.h"

/***** RDescription *****/

@implementation RDescription

@synthesize name;
@synthesize description;

-(id)initWithName:(NSString *)n andDescription:(NSString *)descr
{
    if((self = [super init])) {
        self->name = [n retain];
        self->description = [descr retain];
    }
    return self;
}

@end

/***** RObject *****/

@implementation RObject

-(id)initWithString:(NSString *)str rect:(CGRect)rect
{
    if((self = [super init])) {
        NSArray *a1 = [str componentsSeparatedByString:@"\t"];
        number = [[a1 objectAtIndex:0] intValue];
        path = CGPathCreateMutable();
        NSArray *a2 = [[a1 objectAtIndex:1] componentsSeparatedByString:@","];
        for(int i=0; i<[a2 count]; i+=2) {
            CGFloat x = (CGFloat)[[a2 objectAtIndex:i] intValue] / 256.f * rect.size.width;// + rect.origin.x;
            CGFloat y = (CGFloat)[[a2 objectAtIndex:i+1] intValue] / 256.f * rect.size.height;// + rect.origin.y;
            if(!i) CGPathMoveToPoint(path, nil, x, y);
            else CGPathAddLineToPoint(path, nil, x, y);
        }
        CGPathCloseSubpath(path);
        lineWidth = rect.size.width / 256.f;
        color = CGColorRetain([[UIColor redColor] CGColor]);
        boundingBox = CGPathGetBoundingBox(path);
    }
    return self;
}

-(void)draw:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

-(void)dealloc
{
    if(color) CGColorRelease(color);
    if(path) CGPathRelease(path);
    [super dealloc];
}

@end

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
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
        for (RObject *ob in objects) {
            [ob draw:context];
        }
        CGContextRestoreGState(context);
    }
}

-(void) skip
{
    actuality ++;
}

-(int)checkPoint:(CGPoint)point
{
    for (RObject *ob in objects) {
        if(CGRectContainsPoint(ob->boundingBox, point)) {
            return ob->number;
        }
    }
    return -1;
}

-(void)dealloc
{
    if(image) CGImageRelease(image);
    [objects release];
    [super dealloc];
}

@end

/***** RManager *****/

@implementation RManager

@synthesize lock;

-(BOOL)loadPiece:(RPiece*)p
{
    if(p->image == nil) {
        NSString *pt = [NSString stringWithFormat:@"%@/%d/%d/%d.jpg", path, p->level, p->x, p->y];
        const char* fileName = [pt UTF8String];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
        if(dataProvider == nil) {
            //NSLog(@"file not found %@", pt);
            p->level = -1;
        } else {
            p->image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
            p->layer->piecesCount ++;
            pt = [NSString stringWithFormat:@"%@/%d/%d/%d.txt", path, p->level, p->x, p->y];
            NSString *contents = [NSString stringWithContentsOfFile:pt encoding:NSUTF8StringEncoding error:nil];
            if(contents != nil) p->objects = [[NSMutableArray alloc] init];
            [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [p->objects addObject:[[RObject alloc] initWithString:line rect:p->rect]];
            }];
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

/***** DownloadPiece *****/

@implementation DownloadPiece

-(id)initWithPiece:(RPiece *)p andConnection:(NSURLConnection *)con
{
    if((self = [super init])) {
        piece = p;
        connection = con;
        data = [[NSMutableData data] retain];
    }
    return self;
}

-(void)dealloc
{
    [connection release];
    [data release];
    [super dealloc];
}

@end

/***** RasterDownloader *****/

@implementation RasterDownloader

-(id)initWithUrl:(NSString *)url
{
    if((self = [super init])) {
        baseUrl = [url retain];
        queue = [[NSMutableDictionary alloc] init];
        secondQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setTarget:(id)t andSelector:(SEL)sel
{
    target = t;
    selector = sel;
}

-(void)check
{
    if([queue count] == 0) {
        if(signal) [target performSelector:selector];
        for (RPiece* piece in secondQueue) {
            signal = NO;
            NSString *url = [NSString stringWithFormat:@"%@/%d/%d/%d.jpg_", baseUrl, piece->level, piece->x, piece->y];
            NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
            if (theConnection)
                [queue setObject:[[DownloadPiece alloc] initWithPiece:piece andConnection:theConnection] forKey:theConnection];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DownloadPiece *dp = [queue objectForKey:connection];
    [queue removeObjectForKey:connection];
    dp->piece->level = -1;
    [dp release];
    [self check];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    DownloadPiece *dp = [queue objectForKey:connection];
    [queue removeObjectForKey:connection];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(dp->data);
    if(dataProvider == nil) {
        dp->piece->level = -1;
    } else {
        dp->piece->image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
    }
    [dp release];
    [self check];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DownloadPiece *dp = [queue objectForKey:connection];
    [dp->data appendData:data];
}

-(BOOL)loadPiece:(RPiece *)piece
{
    if(piece->image == nil) {
        signal = YES;
        NSString *url = [NSString stringWithFormat:@"%@/%d/%d/%d.jpg_", baseUrl, piece->level, piece->x, piece->y];
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        // create the connection with the request
        // and start loading the data
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            [queue setObject:[[DownloadPiece alloc] initWithPiece:piece andConnection:theConnection] forKey:theConnection];
            return YES;
        } else {
            // Inform the user that the connection failed.
            return NO;
        }
    }
    return NO;
}

-(void)secondLoadPiece:(RPiece *)piece
{
    [secondQueue addObject:piece];
}

-(void)dealloc
{
    [baseUrl release];
    [queue release];
    [super dealloc];
}

@end

/***** VectorDownloader *****/

@implementation VectorDownloader



@end

/***** RDownloadManger *****/

@implementation RDownloadManager
@synthesize lock;
//@synthesize rasterDownloader;
//@synthesize vectorDownloader;

-(void)rasterComplete
{
    complete ++;
    if(complete >= 2)
        [target performSelector:selector];
}

-(void)vectorComplete
{
    complete ++;
    if(complete >= 2)
        [target performSelector:selector];
}

-(void)setRasterDownloader:(id)_rasterDownloader
{
    rasterDownloader = _rasterDownloader;
    [rasterDownloader setTarget:self andSelector:@selector(rasterComplete)];
}

-(id)rasterDownloader
{
    return rasterDownloader;
}

-(void)setVectorDownloader:(id)_vectorDownloader
{
    vectorDownloader = _vectorDownloader;
    [vectorDownloader setTarget:self andSelector:@selector(vectorComplete)];
}

-(id)vectorDownloader
{
    return vectorDownloader;
}

-(id)initWithTarget:(id)t selector:(SEL)s 
{
    if((self = [super init])) {
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
    [rasterDownloader load:piece];
    [vectorDownloader load:piece];
    complete = 0;
}

-(void)secondLoad:(RPiece *)piece
{
    [rasterDownloader secondLoad:piece];
    [vectorDownloader secondLoad:piece];
    complete = 0;
}

-(void)dealloc
{
    [queue release];
    [secondQueue release];
    [timer release];
    [super dealloc];
}

@end

/***** RasterLayer *****/

@implementation RasterLayer
@synthesize currentObject;
@synthesize currentObjectNumber;
@synthesize cacheZoom;
@synthesize cacheDirection;

-(id) initWithRect:(CGRect)rect
{
    if((self = [super init])) {
        allRect = rect;
        NSString *rasterPath = [[NSBundle mainBundle] pathForResource:@"raster" ofType:nil];
        levels = [[NSMutableDictionary alloc] init];
        lock = [[NSLock alloc] init];
        level = 0;
        MAX_PIECES = 60;
        loader = [[RManager alloc] initWithTarget:self selector:@selector(complete) andPath:rasterPath];
        description = [[NSMutableDictionary alloc] init];
        // TODO other languages
        NSString *fn = [NSString stringWithFormat:@"%@/en-names.txt", rasterPath];
        NSString *contents = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:nil];
        [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            NSArray *words = [line componentsSeparatedByString:@"\t"];
            int _id = [[words objectAtIndex:0] intValue];
            NSString *name = [words objectAtIndex:1];
            RDescription *desc = [description objectForKey:[NSNumber numberWithInt:_id]];
            if(desc == nil) {
                desc = [[RDescription alloc] initWithName:name andDescription:nil];
                [description setObject:desc forKey:[NSNumber numberWithInt:_id]];
            } else {
                desc.name = name;
            }
        }];
        // TODO other languages
        fn = [NSString stringWithFormat:@"%@/en-descriptions.txt", rasterPath];
        NSString *contents2 = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:nil];
        [contents2 enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            NSArray *words = [line componentsSeparatedByString:@"\t"];
            int _id = [[words objectAtIndex:0] intValue];
            NSString *name = [words objectAtIndex:1];
            RDescription *desc = [description objectForKey:[NSNumber numberWithInt:_id]];
            if(desc == nil) {
                desc = [[RDescription alloc] initWithName:nil andDescription:name];
                [description setObject:desc forKey:[NSNumber numberWithInt:_id]];
            } else {
                desc.description = name;
            }
        }];
        
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

-(BOOL)checkLevel:(CGFloat)scale
{
    int _sc = 1, _lvl = 0;
    while (scale > _sc) {
        _sc *= 2;
        _lvl ++;
    }
    return  level != _lvl;
}

-(BOOL)draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale
{
    [lock lock];
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
    double dx = (double)allRect.size.width / size, dy = (double)allRect.size.height / size;
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
                CGRect r = CGRectMake(dx*X, dy*Y, dx, dy);
                RPiece *p = [[RPiece alloc] initWithRect:r level:level x:X y:Y];
                p->layer = self;
                [lev addObject:p];
                [loader load:p];
                allLoaded = NO;
            }
        }
    }
    // check next layer
    int nextLevel = level;
    if(cacheZoom > 0) {
        NSLog(@"cache zoom in");
        dx *= 0.5f;
        dy *= 0.5f;
        x1 *= 2;
        y1 *= 2;
        x2 *= 2;
        y2 *= 2;
        nextLevel = level+1;
        n = [NSNumber numberWithInt:nextLevel];
        lev = [levels objectForKey:n];
    } else if(cacheZoom < 0 && level > 0) {
        NSLog(@"cache zoom out");
        dx *= 2.f;
        dy *= 2.f;
        x1 *= 0.5f;
        y1 *= 0.5f;
        x2 *= 0.5f;
        y2 *= 0.5f;
        nextLevel = level-1;
        n = [NSNumber numberWithInt:nextLevel];
        lev = [levels objectForKey:n];
    }
    switch (cacheDirection) {
        case 0:
        default:
            // nothing to do
            break;
        case 1: {
            NSLog(@"cache to right");
            int st = (x2-x1)/2;
            x1 += st;
            x2 += st;
            break;
        }
        case 2: {
            NSLog(@"cache to bottom");
            int st = (y2-y1)/2;
            y1 += st;
            y2 += st;
            break;
        }
        case 3: {
            NSLog(@"cache to left");
            int st = (x2-x1)/2;
            x1 -= st;
            x2 -= st;
            break;
        }
        case 4: {
            NSLog(@"cache to up");
            int st = (y2-y1)/2;
            y1 -= st;
            y2 -= st;
            break;
        }
    }
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
                CGRect r = CGRectMake(dx*X, dy*Y, dx, dy);
                RPiece *p = [[RPiece alloc] initWithRect:r level:nextLevel x:X y:Y];
                p->layer = self;
                [lev addObject:p];
                [loader secondLoad:p];
                cached ++;
            }
        }
    }
    [loader.lock unlock];
    [lock unlock];
    if(allLoaded) NSLog(@"raster drawing complete at level %d, %d pieces", level, piecesCount);
    else NSLog(@"raster drawing not complete at level %d, %d pieces", level, piecesCount);

    if(allLoaded) while(piecesCount > MAX_PIECES) {
        [self freeSomeMemory];
    }
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
    [lock lock];
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
    [lock unlock];
}

-(BOOL)checkPoint:(CGPoint *)point
{
    NSNumber *n = [NSNumber numberWithInt:level];
    NSMutableArray *lev = [levels objectForKey:n];
    if(lev == nil) {
        return NO;
    }
    int size = 1 << level;
    double dx = (double)allRect.size.width / size, dy = (double)allRect.size.height / size;
    int X = point->x / dx, Y = point->y / dy;
    for (RPiece *p in lev) {
        if(p->x == X && p->y == Y) {
            currentObjectNumber = [p checkPoint:CGPointMake(point->x - X*dx, point->y - Y*dy)];
            if(currentObjectNumber >= 0) {
                currentObject = [description objectForKey:[NSNumber numberWithInt:currentObjectNumber]];
                if(currentObject == nil) {
                    currentObject = [[RDescription alloc] initWithName:[NSString stringWithFormat:@"Name of object #%d",currentObjectNumber] andDescription:[NSString stringWithFormat:@"Description of object #%d",currentObjectNumber]];
                    [description setObject:currentObject forKey:[NSNumber numberWithInt:currentObjectNumber]];
                }
                return YES;
            } else {
                currentObject = nil;
                return NO;
            }
        }
    }
    return NO;
}

-(void)dealloc
{
    [loader release];
    [levels release];
    [super dealloc];
}

@end
