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
}
-(id)initWithString:(NSString*)str rect:(CGRect)rect;
-(void)draw:(CGContextRef)context;

@end

/***** RPiece *****/

@interface RPiece : NSObject {
@public
    CGRect rect;
    CGImageRef image;
    int actuality, level, x, y;
    RasterLayer *layer;
    NSMutableArray *objects;
}
@property (nonatomic, readonly) BOOL loaded;

-(id)initWithRect:(CGRect)r level:(int)level x:(int)x y:(int)y;
-(void)draw:(CGContextRef)context;
-(int)checkPoint:(CGPoint)point;

@end

/***** RManager *****/

@interface RManager : NSObject {
    NSMutableArray *queue;
    NSMutableArray *secondQueue;
    NSTimer *timer;
    id target;
    SEL selector;
    NSString *path;
    NSRecursiveLock *lock;
}
@property (nonatomic, readonly) NSRecursiveLock *lock;

-(id)initWithTarget:(id)target selector:(SEL)selector andPath:(NSString*)path;
-(void)load:(RPiece*)piece;
-(void)secondLoad:(RPiece*)piece;

@end


/***** RasterLayer *****/

@interface RasterLayer : NSObject {
    RManager *loader;
    NSMutableDictionary *levels;
    NSMutableDictionary *description;
    int level, MAX_PIECES;
    CGRect allRect;
    id target;
    SEL selector;
    NSLock *lock;
    RDescription *currentObject;
    int currentObjectNumber;
@public
    int piecesCount;
}

@property (nonatomic, readonly) RDescription* currentObject;
@property (nonatomic, readonly) int currentObjectNumber;

-(id) initWithRect:(CGRect)rect;
-(BOOL) draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale;
-(BOOL) checkLevel:(CGFloat)scale;
-(void) freeSomeMemory;
-(void) setSignal:(id)target selector:(SEL)selector;
-(BOOL) checkPoint:(CGPoint*)point;

@end
