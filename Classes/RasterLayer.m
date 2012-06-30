//
//  RasterLayer.m
//  tube
//
//  Created by Vasiliy Makarov on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RasterLayer.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"

#define MAX_QUEUE 10

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
        center = CGPointMake(boundingBox.origin.x + boundingBox.size.width*0.5f, boundingBox.origin.y + boundingBox.size.height*0.5f);
        float dx = boundingBox.size.width * 0.5f;
        float dy = boundingBox.size.height * 0.5f;
        boundingBox.origin.x -= dx;
        boundingBox.origin.y -= dy;
        boundingBox.size.width *= 2.f;
        boundingBox.size.height *= 2.f;
        
//        MItem *it = [[MHelper sharedHelper] getItemWithIndex:number];
//        if(it) {
//            NSNumber *zero = [NSNumber numberWithDouble:0];
//            if([it.posX isEqualToNumber:zero] || [it.posY isEqualToNumber:zero]) {
//                it.posX = [NSNumber numberWithDouble:rect.origin.x + center.x];
//                it.posY = [NSNumber numberWithDouble:rect.origin.y + center.y];
//            }
//        }
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

-(int)checkPoint:(CGPoint)point
{
//    if(CGPathContainsPoint(path, nil, point, true)) {
//        return number;
//    }
    if(CGRectContainsPoint(boundingBox, point)) {
        return number;
    }
    return -1;
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

-(void) draw:(CGContextRef)context
{
    if(image != nil) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.f, rect.origin.y*2.f + rect.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        CGContextDrawImage(context, rect, image);
        CGContextRestoreGState(context);
    } else {
        CGFloat color[3];
        color[0] = color[1] = color[2] = 0.5f;
        CGContextSetFillColor(context, color);
        CGContextFillRect(context, rect);
    }
    actuality = 0;
    if([objects count] > 0) {
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

-(RObject*)checkPoint:(CGPoint)point
{
    for (RObject *ob in objects) {
        int n = [ob checkPoint:point];
        if(n >= 0) return ob;
    }
    return nil;
}

-(void)dealloc
{
    if(image) CGImageRelease(image);
    [objects release];
    [super dealloc];
}

-(BOOL)empty
{
    return image == nil;// && [objects count] == 0;
}

-(BOOL)trash
{
    return [self empty] && rloaded && vloaded;
}

-(void)rasterLoaded
{
    rloaded = YES;
}

-(void)vectorLoaded
{
    vloaded = YES;
}

@end

/***** RManager *****/

/*@implementation RManager

//@synthesize lock;

-(BOOL)loadPiece:(RPiece*)p
{
    if(p->image == nil) {
        [p rasterLoaded];
        [p vectorLoaded];
        NSString *pt = [NSString stringWithFormat:@"%@/%d/%d/%d.jpg", path, p->level, p->x, p->y];
        const char* fileName = [pt UTF8String];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
        if(dataProvider == nil) {
            //NSLog(@"file not found %@", pt);
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

-(void)debugStatus
{
    NSLog(@"queue %d pieces, second queue %d pieces", [queue count], [secondQueue count]);
}

@end
*/
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

/***** ConnectionQueue *****/

@implementation ConnectionQueue

-(id)init
{
    if((self = [super init])) {
        array = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)put:(DownloadPiece*)piece
{
    [array addObject:piece];
}

-(DownloadPiece*)get:(NSURLConnection*)connection
{
    for (DownloadPiece* p in array) {
        if(p->connection == connection) return p;
    }
    return nil;
}

-(void)removeByConnection:(NSURLConnection*)connection
{
    [array removeObject:[self get:connection]];
}

-(void)removePiece:(DownloadPiece*)piece
{
    [array removeObject:piece];
}

-(void)dealloc
{
    [array release];
    [super dealloc];
}

-(int)count 
{
    return [array count];
}

-(NSArray*) allConnections
{
    NSMutableArray *cons = [NSMutableArray array];
    for (DownloadPiece* p in array) {
        [cons addObject:p->connection];
    }
    return [NSArray arrayWithArray:cons];
}

@end

/***** DownloadCache *****/

@implementation DownloadCache

-(id)initWithLevel:(int)l x:(int)_x y:(int)_y data:(NSData*)d
{
    if((self = [super init])) {
        level = l;
        x = _x;
        y = _y;
        data = [d retain];
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToDownloadCache:other];
}

- (BOOL)isEqualToDownloadCache:(DownloadCache*)other {
    if (self == other)
        return YES;
    return level == other->level && x == other->x && y == other->y;
}

- (NSUInteger)hash
{
    return level * 10000 + x * 100 + y;
}

-(void)dealloc
{
    [data release];
    [super dealloc];
}

@end

/***** RasterDownloader *****/

@implementation RasterDownloader
@synthesize altSource;

-(id)initWithUrl:(NSString *)url
{
    if((self = [super init])) {
        baseUrl = [url retain];
        queue = [[ConnectionQueue alloc] init];
        secondQueue = [[NSMutableArray alloc] init];
        minusCache = [[NSMutableSet alloc] init];
        plusCache = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)setTarget:(id)t andSelector:(SEL)sel
{
    target = t;
    selector = sel;
}

-(BOOL)checkCache:(RPiece*)piece
{
    DownloadCache *dc = [[[DownloadCache alloc] initWithLevel:piece->level x:piece->x y:piece->y data:nil] autorelease];
    if([minusCache containsObject:dc]) {
        [piece rasterLoaded];
        return YES;
    }
    dc = [plusCache member:dc];
    if(dc != nil) {
        [piece rasterLoaded];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)dc->data);
        if(dataProvider != nil) 
            piece->image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
        [target performSelector:selector withObject:piece];
        return YES;
    }
    return NO;
}

-(BOOL)startLoadingPiece:(RPiece *)piece
{
    if(piece->image == nil) {
        NSString *url = [NSString stringWithFormat:@"%@/%d/%d/%d.jpg", baseUrl, piece->level, piece->x, piece->y];
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        // create the connection with the request
        // and start loading the data
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            [queue put:[[DownloadPiece alloc] initWithPiece:piece andConnection:theConnection]];
            return YES;
        } else {
            // Inform the user that the connection failed.
            return NO;
        }
    }
    return NO;
}

-(void)checkQueue
{
    while([queue count] < MAX_QUEUE && [secondQueue count] > 0) {
        RPiece* piece = [secondQueue objectAtIndex:0];
        [self startLoadingPiece:piece];
        [secondQueue removeObjectAtIndex:0];
    }
}

-(BOOL)altLoadPiece:(RPiece*)p
{
    NSString *pt = [NSString stringWithFormat:@"%@/%d/%d/%d.jpg", altSource, p->level, p->x, p->y];
    const char* fileName = [pt UTF8String];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
    if(dataProvider != nil) {
        p->image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
        p->layer->piecesCount ++;
        [p rasterLoaded];
        return YES;
    }
    return NO;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"response");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DownloadPiece *dp = [queue get:connection];
    if(dp != nil) {
        [dp->piece rasterLoaded];
        [queue removeByConnection:connection];
        [minusCache addObject:[[DownloadCache alloc] initWithLevel:dp->piece->level x:dp->piece->x y:dp->piece->y data:nil]];
        [dp release];
    }
    [self checkQueue];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    DownloadPiece *dp = [queue get:connection];
    if(dp == nil) {
        NSLog(@"Lost piece '%@'", connection.originalRequest.URL.absoluteString);
    } else {
        [dp->piece rasterLoaded];
        [queue removeByConnection:connection];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)dp->data);
        if(dataProvider != nil) {
            dp->piece->image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
            dp->piece->layer->piecesCount ++;
        }
        [plusCache addObject:[[DownloadCache alloc] initWithLevel:dp->piece->level x:dp->piece->x y:dp->piece->y data:dp->data]];
        [target performSelector:selector withObject:dp->piece];
        [dp release];
    }
    [self checkQueue];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DownloadPiece *dp = [queue get:connection];
    if(dp == nil) {
        NSLog(@"Lost piece '%@'", connection.originalRequest.URL.absoluteString);
        return;
    }
    [dp->data appendData:data];
}

-(void)loadPiece:(RPiece*)piece
{
    if([self checkCache:piece]) return;
    if(altSource != nil && [self altLoadPiece:piece]) return;
    if([queue count] > MAX_QUEUE) {
        [secondQueue insertObject:piece atIndex:0];
    } else {
        [self performSelectorOnMainThread:@selector(startLoadingPiece:) withObject:piece waitUntilDone:NO];
    }
}

-(void)secondLoadPiece:(RPiece *)piece
{
    if([self checkCache:piece]) return;
    [secondQueue addObject:piece];
}

-(void)dealloc
{
    [altSource release];
    [baseUrl release];
    [queue release];
    [secondQueue release];
    [minusCache release];
    [plusCache release];
    [super dealloc];
}

-(void)debugStatus
{
    NSLog(@"raster queue %d pieces, second queue %d pieces", [queue count], [secondQueue count]);
}

-(void)stopBut:(int)level
{
    NSArray *cons = [queue allConnections];
    for (NSURLConnection *con in cons) {
        DownloadPiece *dp = [queue get:con];
        if(abs(dp->piece->level - level) > 1) {
            [con cancel];
            [queue removeByConnection:con];
        }
    }
}

-(void)advance:(RPiece *)piece
{
    if([secondQueue containsObject:piece]) {
        [secondQueue removeObject:piece];
        [secondQueue insertObject:piece atIndex:0];
    }
}

@end

/***** VectorDownloader *****/

@implementation VectorDownloader
@synthesize altSource;

-(id)initWithUrl:(NSString *)url
{
    if((self = [super init])) {
        baseUrl = [url retain];
        queue = [[ConnectionQueue alloc] init];
        secondQueue = [[NSMutableArray alloc] init];
        minusCache = [[NSMutableSet alloc] init];
        plusCache = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)setTarget:(id)t andSelector:(SEL)sel
{
    target = t;
    selector = sel;
}

-(BOOL)checkCache:(RPiece*)piece
{
    DownloadCache *dc = [[[DownloadCache alloc] initWithLevel:piece->level x:piece->x y:piece->y data:nil] autorelease];
    if([minusCache containsObject:dc]) {
        [piece vectorLoaded];
        return YES;
    }
    dc = [plusCache member:dc];
    if(dc != nil) {
        [piece vectorLoaded];
        NSString *contents = [NSString stringWithCString:(const char*)([dc->data bytes]) encoding:NSUTF8StringEncoding];
        if(contents != nil) {
            NSMutableArray *a = [[NSMutableArray alloc] init];
            [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [a addObject:[[RObject alloc] initWithString:line rect:piece->rect]];
            }];
            [piece->objects release];
            piece->objects = a;
        }
        [target performSelector:selector withObject:piece];
        return YES;
    }
    return NO;
}

-(BOOL)startLoadingPiece:(RPiece *)piece
{
    if(piece->image == nil) {
        if([self checkCache:piece]) return YES;
        NSString *url = [NSString stringWithFormat:@"%@/%d/%d/%d.txt", baseUrl, piece->level, piece->x, piece->y];
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        // create the connection with the request
        // and start loading the data
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            [queue put:[[DownloadPiece alloc] initWithPiece:piece andConnection:theConnection]];
            return YES;
        } else {
            // Inform the user that the connection failed.
            return NO;
        }
    }
    return NO;
}

-(void)checkQueue
{
    while([queue count] < MAX_QUEUE && [secondQueue count] > 0) {
        RPiece* piece = [secondQueue objectAtIndex:0];
        [self startLoadingPiece:piece];
        [secondQueue removeObjectAtIndex:0];
    }
}

-(BOOL)altLoadPiece:(RPiece*)piece
{
    NSString* pt = [NSString stringWithFormat:@"%@/%d/%d/%d.txt", altSource, piece->level, piece->x, piece->y];
    NSString *contents = [NSString stringWithContentsOfFile:pt encoding:NSUTF8StringEncoding error:nil];
    if(contents != nil) {
        [piece vectorLoaded];
        piece->objects = [[NSMutableArray alloc] init];
        [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [piece->objects addObject:[[RObject alloc] initWithString:line rect:piece->rect]];
        }];
        return YES;
    }
    return NO;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"response");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DownloadPiece *dp = [queue get:connection];
    if(dp != nil) {
        [dp->piece vectorLoaded];
        [queue removeByConnection:connection];
        [minusCache addObject:[[DownloadCache alloc] initWithLevel:dp->piece->level x:dp->piece->x y:dp->piece->y data:nil]];
        [dp release];
    }
    [self checkQueue];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    DownloadPiece *dp = [queue get:connection];
    if(dp != nil) {
        char term = 0;
        [dp->data appendBytes:&term length:1];
        [queue removeByConnection:connection];
        [dp->piece vectorLoaded];
        NSString *contents = [NSString stringWithCString:(const char*)([dp->data bytes]) encoding:NSUTF8StringEncoding];
        if(contents != nil) {
            NSMutableArray *a = [[NSMutableArray alloc] init];
            [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [a addObject:[[RObject alloc] initWithString:line rect:dp->piece->rect]];
            }];
            [dp->piece->objects release];
            dp->piece->objects = a;
        }

        [plusCache addObject:[[DownloadCache alloc] initWithLevel:dp->piece->level x:dp->piece->x y:dp->piece->y data:dp->data]];
        [target performSelector:selector withObject:dp->piece];
        [dp release];
    } 
    [self checkQueue];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DownloadPiece *dp = [queue get:connection];
    if(dp != nil)
        [dp->data appendData:data];
}

-(void)loadPiece:(RPiece *)piece
{
    if([self checkCache:piece]) return;
    if(altSource != nil && [self altLoadPiece:piece]) return;
    if([queue count] > MAX_QUEUE) {
        [secondQueue insertObject:piece atIndex:0];
    } else {
        [self performSelectorOnMainThread:@selector(startLoadingPiece:) withObject:piece waitUntilDone:NO];
    }
}

-(void)secondLoadPiece:(RPiece *)piece
{
    [secondQueue addObject:piece];
}

-(void)dealloc
{
    [altSource release];
    [baseUrl release];
    [queue release];
    [secondQueue release];
    [minusCache release];
    [plusCache release];
    [super dealloc];
}

-(void)debugStatus
{
    NSLog(@"vector queue %d pieces, second queue %d pieces", [queue count], [secondQueue count]);
}

-(void)stopBut:(int)level
{
    NSArray *cons = [queue allConnections];
    for (NSURLConnection *con in cons) {
        DownloadPiece *dp = [queue get:con];
        if(abs(dp->piece->level - level) > 1) {
            [con cancel];
            [queue removeByConnection:con];
        }
    }
}

-(void)advance:(RPiece *)piece
{
    if([secondQueue containsObject:piece]) {
        [secondQueue removeObject:piece];
        [secondQueue insertObject:piece atIndex:0];
    }
}

@end

/***** RDownloadManger *****/

@implementation RDownloadManager
//@synthesize lock;
//@synthesize rasterDownloader;
//@synthesize vectorDownloader;

-(void)rasterComplete:(RPiece*)piece
{
    [target performSelector:selector withObject:[NSValue valueWithCGRect:piece->rect]];
}

-(void)vectorComplete:(RPiece*)piece
{
    [target performSelector:selector withObject:[NSValue valueWithCGRect:piece->rect]];
}

-(void)setRasterDownloader:(id)_rasterDownloader
{
    if(rasterDownloader != nil) [rasterDownloader setTarget:nil andSelector:nil];
    rasterDownloader = _rasterDownloader;
    [rasterDownloader setTarget:self andSelector:@selector(rasterComplete:)];
}

-(id)rasterDownloader
{
    return rasterDownloader;
}

-(void)setVectorDownloader:(id)_vectorDownloader
{
    if(vectorDownloader != nil) [vectorDownloader setTarget:nil andSelector:nil];
    vectorDownloader = _vectorDownloader;
    [vectorDownloader setTarget:self andSelector:@selector(vectorComplete:)];
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
        //lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

-(void)load:(RPiece *)piece
{
    if(rasterDownloader != nil) {
        //[rasterDownloader performSelectorOnMainThread:@selector(loadPiece:) withObject:piece waitUntilDone:NO];
        [rasterDownloader loadPiece:piece];
    } else
        [piece rasterLoaded];
    if(vectorDownloader != nil) {
        //[vectorDownloader performSelectorOnMainThread:@selector(loadPiece:) withObject:piece waitUntilDone:NO];
        [vectorDownloader loadPiece:piece];
    } else 
        [piece vectorLoaded];
}

-(void)secondLoad:(RPiece *)piece
{
    if(rasterDownloader != nil) [rasterDownloader secondLoadPiece:piece];
    else [piece rasterLoaded];
    if(vectorDownloader != nil) [vectorDownloader secondLoadPiece:piece];
    else [piece vectorLoaded];
}

-(void)dealloc
{
    [super dealloc];
}

-(void)debugStatus
{
    [rasterDownloader debugStatus];
    [vectorDownloader debugStatus];
}

-(void)advance:(RPiece*)piece
{
    [rasterDownloader advance:piece];
    [vectorDownloader advance:piece];
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
        NSString *rasterPath = [[NSBundle mainBundle] pathForResource:@"vector" ofType:nil];
        levels = [[NSMutableDictionary alloc] init];
        lock = [[NSRecursiveLock alloc] init];
        timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(freeSomeMemory) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        level = 0;
        MAX_PIECES = 60;
        //loader = [[RManager alloc] initWithTarget:self selector:@selector(complete) andPath:rasterPath];
        
        RDownloadManager* dm = [[RDownloadManager alloc] initWithTarget:self selector:@selector(complete:)];
        //dm.rasterDownloader = [[RasterDownloader alloc] initWithUrl:@"http://www.x-provocation.com/maps/cuba/RASTER"];
        //dm.rasterDownloader = [[RasterDownloader alloc] initWithUrl:@"http://www.x-provocation.com/maps/cuba/OSM"];
        NSURL *vurl = [[[NSURL alloc] initFileURLWithPath:rasterPath] autorelease];
        NSString* vurlstr = [vurl absoluteString];
        vloader = [[VectorDownloader alloc] initWithUrl:vurlstr];
        rloader1 = [[RasterDownloader alloc] initWithUrl:@"http://www.x-provocation.com/maps/cuba/OSM"];
        rloader1.altSource = [[NSBundle mainBundle] pathForResource:@"OSM" ofType:nil];
        rloader2 = [[RasterDownloader alloc] initWithUrl:@"http://www.x-provocation.com/maps/cuba/RASTER"];
        rloader2.altSource = [[NSBundle mainBundle] pathForResource:@"RASTER" ofType:nil];
        dm.vectorDownloader = vloader;
        dm.rasterDownloader = rloader1;
        loader = dm;
        
//        description = [[NSMutableDictionary alloc] init];
//        // TODO other languages
//        NSString *fn = [NSString stringWithFormat:@"%@/en-names.txt", rasterPath];
//        NSString *contents = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:nil];
//        [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
//            NSArray *words = [line componentsSeparatedByString:@"\t"];
//            int _id = [[words objectAtIndex:0] intValue];
//            NSString *name = [words objectAtIndex:1];
//            RDescription *desc = [description objectForKey:[NSNumber numberWithInt:_id]];
//            if(desc == nil) {
//                desc = [[RDescription alloc] initWithName:name andDescription:nil];
//                [description setObject:desc forKey:[NSNumber numberWithInt:_id]];
//            } else {
//                desc.name = name;
//            }
//        }];
//        // TODO other languages
//        fn = [NSString stringWithFormat:@"%@/en-descriptions.txt", rasterPath];
//        NSString *contents2 = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:nil];
//        [contents2 enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
//            NSArray *words = [line componentsSeparatedByString:@"\t"];
//            int _id = [[words objectAtIndex:0] intValue];
//            NSString *name = [words objectAtIndex:1];
//            RDescription *desc = [description objectForKey:[NSNumber numberWithInt:_id]];
//            if(desc == nil) {
//                desc = [[RDescription alloc] initWithName:nil andDescription:name];
//                [description setObject:desc forKey:[NSNumber numberWithInt:_id]];
//            } else {
//                desc.description = name;
//            }
//        }];
        
        [self readMapItemNames];
        
        tubeAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [[MHelper sharedHelper] readHistoryFile:[delegate nameCurrentMap]];
        [[MHelper sharedHelper] readBookmarkFile:[delegate nameCurrentMap]];
        
        piecesCount = 0;
    }
    return self;
}

- (void)readMapItemNames {
//    [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
    NSString *rasterPath = [[NSBundle mainBundle] pathForResource:@"vector" ofType:nil];
    NSString *fn = [NSString stringWithFormat:@"%@/en-names.txt", rasterPath];
    NSString *contents = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:nil];
    __block BOOL areWeReadingCategories = YES;
    [contents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        
        if ([line isEqualToString:@"[categories]"]) {
            areWeReadingCategories = YES;
        } 
        else if ([line isEqualToString:@"[list]"]) {
            areWeReadingCategories = NO;
        } 
        else {
            NSMutableArray *words = [NSMutableArray arrayWithArray:[line componentsSeparatedByString:@"\t"]];
            int _id = [[words objectAtIndex:0] intValue];
            NSString *name = [words objectAtIndex:1];
            if (areWeReadingCategories) {
                MCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
                category.name = name;
                category.index = [NSNumber numberWithInt:_id];
                NSString *colors = nil;
                if ([words count] > 2) {
                    colors = [words objectAtIndex:2];
                }
                if (colors) {
                    NSArray *colorValues = [colors componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
                    CGFloat red = [[colorValues objectAtIndex:0] floatValue];
                    CGFloat green = [[colorValues objectAtIndex:1] floatValue];
                    CGFloat blue = [[colorValues objectAtIndex:2] floatValue];
                    UIColor *color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
                    category.color = color;
                }
            } 
            else {
                MItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
                item.name = name;
                item.index = [NSNumber numberWithInt:_id];
                NSString *categories = nil;
                NSString *images = nil;
                
                //Try reading categories
                if ([words count] > 2) {
                    categories = [words objectAtIndex:2];   
                }
                if (categories) {
                    NSArray *catIds = [categories componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
                    NSMutableSet *set = [item mutableSetValueForKey:@"categories"];
                    for (NSString *catId in catIds) {
                        MCategory *cat = [[MHelper sharedHelper] categoryByIndex:[catId intValue]];
                        if (cat) {
                            [set addObject:cat];
                        }
                        else {
                            //OMG, it's not a category, it's an... image!
                            [words addObject:categories]; //let images be on index 3, as expected
                            break;
                        }
                    }
                }
                
                //Try reading images
                if ([words count] > 3) {
                    images = [words objectAtIndex:3];
                }
                if (images) {
                    NSArray *imageNames = [images componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
                    NSMutableSet *set = [item mutableSetValueForKey:@"photos"];
                    for (NSString *imageName in imageNames) {
                        if (![imageName isEqualToString:@""]) {
                            MPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
                            photo.fileName = imageName;
                            if (photo) {
                                [set addObject:photo];
                            }
                            [[MHelper sharedHelper] saveContext];
                        }
                    }
                }
            }
        }
        [[MHelper sharedHelper] saveContext];
    }];
}

-(void)complete:(NSValue*)value
{
    NSLog(@"raster map is loaded");
    [lock lock];
    NSMutableArray *l = [levels objectForKey:[NSNumber numberWithInt:level]];
    NSMutableArray *removePieces = [NSMutableArray array];
    for (RPiece *p in l) {
        if(p->level < 0) {
            [removePieces addObject:p];
        }
    }
    [l removeObjectsInArray:removePieces];
    if([l count] <= 0) [levels removeObjectForKey:[NSNumber numberWithInt:level]];
    [lock unlock];
    if(target != nil) {
        [target performSelector:selector withObject:value];
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

-(BOOL)upperDraw:(CGContextRef)context rect:(CGRect)rect level:(int)l
{
    for(int curlev = l; curlev >= 0; curlev --) {
        NSNumber *n = [NSNumber numberWithInt:curlev];
        NSMutableArray *lev = [levels objectForKey:n];
        if(lev == nil) continue;
        int size = 1 << curlev;
        double dx = (double)allRect.size.width / size, dy = (double)allRect.size.height / size;
        int x1 = rect.origin.x / dx, y1 = rect.origin.y / dy;
        for (RPiece *p in lev) {
            if(p->x == x1 && p->y == y1) {
                if(![p empty]) {
                    CGContextSaveGState(context);
                    CGContextClipToRect(context, rect);
                    [p draw:context];
                    CGContextRestoreGState(context);
                    return YES;
                }
                break;
            }
        }
    }
    return NO;
}

-(BOOL)lowerDraw:(CGContextRef)context rect:(CGRect)rect level:(int)l
{
    NSNumber *n = [NSNumber numberWithInt:l];
    NSMutableArray *lev = [levels objectForKey:n];
    if(lev == nil) return NO;
    int size = 1 << l;
    double dx = (double)allRect.size.width / size, dy = (double)allRect.size.height / size;
    int x1 = rect.origin.x / dx, y1 = rect.origin.y / dy;
    int x2 = (rect.origin.x + rect.size.width) / dx, y2 = (rect.origin.y + rect.size.height) / dy;
    int pcount = 0;
    for(int X=x1; X<=x2; X++) {
        for(int Y=y1; Y<=y2; Y++) {
            for (RPiece *p in lev) {
                if(p->x == X && p->y == Y) {
                    if(![p empty]) {
                        pcount ++;
                        [p draw:context];
                    }
                }
            }
        }
    }
    return pcount > 0;
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
    //[loader.lock lock];
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
                    if([p empty]) {
                        [loader advance:p];
                        CGRect r = CGRectMake(dx*X, dy*Y, dx, dy);
                        if([self upperDraw:context rect:r level:level-1] || [self lowerDraw:context rect:r level:level+1]) {}
                    } else {
                        [p draw:context];
                    }
                    found = YES;
                    break;
                }
            }
            if(!found) {
                // loading
                CGRect r = CGRectMake(dx*X, dy*Y, dx, dy);
                if([self upperDraw:context rect:r level:level-1] || [self lowerDraw:context rect:r level:level+1]) {}
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
        //NSLog(@"cache zoom in");
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
        //NSLog(@"cache zoom out");
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
            //NSLog(@"cache to right");
            int st = (x2-x1)/2;
            x1 += st;
            x2 += st;
            break;
        }
        case 2: {
            //NSLog(@"cache to bottom");
            int st = (y2-y1)/2;
            y1 += st;
            y2 += st;
            break;
        }
        case 3: {
            //NSLog(@"cache to left");
            int st = (x2-x1)/2;
            x1 -= st;
            x2 -= st;
            break;
        }
        case 4: {
            //NSLog(@"cache to up");
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
    //[loader.lock unlock];
    [lock unlock];
    //if(allLoaded) NSLog(@"raster drawing complete at level %d, %d pieces", level, piecesCount);
    //else NSLog(@"raster drawing not complete at level %d, %d pieces", level, piecesCount);
    [loader debugStatus];

    /*if(allLoaded) while(piecesCount > MAX_PIECES) {
        [self freeSomeMemory];
    }*/
    return allLoaded;
}

-(void)setSignal:(id)_target selector:(SEL)_selector
{
    target = _target;
    selector = _selector;
}

-(void) freeSomeMemory
{
    while(piecesCount > MAX_PIECES) {
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
            RObject *ob = [p checkPoint:CGPointMake(point->x - X*dx, point->y - Y*dy)];
            if(ob != nil) {
                *point = CGPointMake(X*dx + ob->center.x, Y*dy + ob->center.y);
                currentObjectNumber = ob->number;
                currentObject = [description objectForKey:[NSNumber numberWithInt:currentObjectNumber]];
                if(currentObject == nil) {
                    currentObject = [[RDescription alloc] initWithName:[NSString stringWithFormat:@"Name of object #%d",currentObjectNumber] andDescription:[NSString stringWithFormat:@"Description of object #%d",currentObjectNumber]];
                    [description setObject:currentObject forKey:[NSNumber numberWithInt:currentObjectNumber]];
                }
                return YES;
            } else {
                currentObjectNumber = -1;
                currentObject = nil;
                return NO;
            }
        }
    }
    return NO;
}

-(void)dealloc
{
    [vloader release];
    [rloader1 release];
    [rloader2 release];
    [timer release];
    [loader release];
    [levels release];
    [super dealloc];
}

-(BOOL) changeSource
{
    [lock lock];
    altSource = !altSource;
    if(altSource) {
        loader.rasterDownloader = rloader2;
        //loader.vectorDownloader = nil;
    } else {
        loader.rasterDownloader = rloader1;
       // loader.vectorDownloader = vloader;
    }
    [levels removeAllObjects];
    [lock unlock];
    return altSource;
}

-(void) stopLoadingBut:(CGFloat)scale
{
    int _sc = 1, _lvl = 0;
    while (scale > _sc) {
        _sc *= 2;
        _lvl ++;
    }
    [loader.rasterDownloader stopBut:_lvl];
    [loader.vectorDownloader stopBut:_lvl];
}

- (CGPoint) pointOnMapViewForItemWithID:(NSInteger)itemID
{
    MItem *it = [[MHelper sharedHelper] getItemWithIndex:itemID];
    if(it != nil) 
        return CGPointMake([it.posX floatValue], [it.posY floatValue]);
    return CGPointZero;
}

@end
