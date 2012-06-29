//
//  RasterLayer.h
//  tube
//
//  Created by Vasiliy Makarov on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RasterLayer;

/***** RDescription *****/

@interface RDescription : NSObject {
    NSString *name;
    NSString *description;
}
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;

-(id)initWithName:(NSString*)n andDescription:(NSString*)descr;

@end

/***** RObject *****/

@interface RObject : NSObject {
@public
    CGColorRef color;
    CGMutablePathRef path;
    int number;
    CGFloat lineWidth;
    CGRect boundingBox;
    CGPoint center;
}
-(id)initWithString:(NSString*)str rect:(CGRect)rect;
-(void)draw:(CGContextRef)context;
-(int)checkPoint:(CGPoint)point;

@end

/***** RPiece *****/

@interface RPiece : NSObject {
    BOOL vloaded, rloaded;
@public
    CGRect rect;
    CGImageRef image;
    int actuality, level, x, y;
    RasterLayer *layer;
    NSMutableArray *objects;
}

-(id)initWithRect:(CGRect)r level:(int)level x:(int)x y:(int)y;
-(void)draw:(CGContextRef)context;
-(RObject*)checkPoint:(CGPoint)point;
-(BOOL)empty;
-(BOOL)trash;
-(void)rasterLoaded;
-(void)vectorLoaded;
@end

/***** RManager *****/

/*@interface RManager : NSObject {
    NSMutableArray *queue;
    NSMutableArray *secondQueue;
    NSTimer *timer;
    id target;
    SEL selector;
    NSString *path;
    NSRecursiveLock *lock;
}
//@property (nonatomic, readonly) NSRecursiveLock *lock;

-(id)initWithTarget:(id)target selector:(SEL)selector andPath:(NSString*)path;
-(void)load:(RPiece*)piece;
-(void)secondLoad:(RPiece*)piece;
-(void)debugStatus;

@end
*/
/***** DownloadPiece *****/

@interface DownloadPiece : NSObject {
@public
    RPiece *piece;
    NSMutableData *data;
    NSURLConnection *connection;
}

-(id)initWithPiece:(RPiece*)p andConnection:(NSURLConnection*)con;

@end

/***** ConnectionQueue *****/

@interface ConnectionQueue : NSObject {
    NSMutableArray *array;
}
-(id)init;
-(void)put:(DownloadPiece*)piece;
-(DownloadPiece*)get:(NSURLConnection*)connection;
-(void)removeByConnection:(NSURLConnection*)connection;
-(void)removePiece:(DownloadPiece*)piece;
-(int)count;
-(NSArray*)allConnections;

@end

/***** DownloadCache *****/

@interface DownloadCache : NSObject {
@public
    NSData* data;
    int level, x, y;
}
-(id)initWithLevel:(int)l x:(int)x y:(int)y data:(NSData*)d;
- (BOOL)isEqualToDownloadCache:(DownloadCache*)other;

@end

/***** RasterDownloader *****/

@interface RasterDownloader : NSObject {
    NSString *baseUrl;
    ConnectionQueue *queue;
    NSMutableArray *secondQueue;
    NSMutableSet *minusCache, *plusCache;
    id target;
    SEL selector;
    NSString *altSource;
}
@property (nonatomic, retain) NSString* altSource;

-(id)initWithUrl:(NSString*)url;
-(void)setTarget:(id)t andSelector:(SEL)sel;
-(void)loadPiece:(RPiece*)piece;
-(void)secondLoadPiece:(RPiece*)piece;
-(void)debugStatus;
-(void)stopBut:(int)level;
-(void)advance:(RPiece*)piece;

@end

/***** VectorDownloader *****/

@interface VectorDownloader : NSObject {
    NSString *baseUrl;
    ConnectionQueue *queue;
    NSMutableArray *secondQueue;
    NSMutableSet *minusCache, *plusCache;
    id target;
    SEL selector;
    NSString *altSource;
}
@property (nonatomic, retain) NSString* altSource;

-(id)initWithUrl:(NSString*)url;
-(void)setTarget:(id)t andSelector:(SEL)sel;
-(void)loadPiece:(RPiece*)piece;
-(void)secondLoadPiece:(RPiece*)piece;
-(void)debugStatus;
-(void)stopBut:(int)level;
-(void)advance:(RPiece*)piece;

@end

/***** RDownloadManager *****/

@interface RDownloadManager : NSObject {
    id target;
    SEL selector;
    //NSRecursiveLock *lock;
    id rasterDownloader;
    id vectorDownloader;
}
//@property (nonatomic, readonly) NSRecursiveLock *lock;
@property (nonatomic, retain) id rasterDownloader;
@property (nonatomic, retain) id vectorDownloader;

-(id)initWithTarget:(id)target selector:(SEL)selector;
-(void)load:(RPiece*)piece;
-(void)secondLoad:(RPiece*)piece;
-(void)debugStatus;
-(void)advance:(RPiece*)piece;

@end


/***** RasterLayer *****/

@interface RasterLayer : NSObject {
    RDownloadManager *loader;
    NSMutableDictionary *levels;
    NSMutableDictionary *description;
    int level, MAX_PIECES;
    CGRect allRect;
    id target;
    SEL selector;
    NSRecursiveLock *lock;
    RDescription *currentObject;
    int currentObjectNumber;
    int cacheZoom;
    int cacheDirection;
    NSTimer *timer;
    BOOL altSource;
    VectorDownloader *vloader;
    RasterDownloader *rloader1, *rloader2;
@public
    int piecesCount;
}

@property (nonatomic, readonly) RDescription* currentObject;
@property (nonatomic, readonly) int currentObjectNumber;
@property (nonatomic, assign) int cacheZoom;
@property (nonatomic, assign) int cacheDirection;

-(id) initWithRect:(CGRect)rect;
-(BOOL) draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale;
-(BOOL) checkLevel:(CGFloat)scale;
-(void) freeSomeMemory;
-(void) setSignal:(id)target selector:(SEL)selector;
-(BOOL) checkPoint:(CGPoint*)point;
-(BOOL) changeSource;
-(void) stopLoadingBut:(CGFloat)scale;

//Получить координаты точки в системе координат UIView карты, в которую нужно будет положить пин
- (CGPoint) pointOnMapViewForItemWithID:(NSInteger)itemID; 

@end
