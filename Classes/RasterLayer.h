//
//  RasterLayer.h
//  tube
//
//  Created by Vasiliy Makarov on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/***** RPiece *****/

@interface RPiece : NSObject {
@public
    CGRect rect;
    CGImageRef image;
    int actuality, level, x, y;
}
@property (nonatomic, readonly) BOOL loaded;

-(id)initWithRect:(CGRect)r level:(int)level x:(int)x y:(int)y;
-(void)draw:(CGContextRef)context;

@end

/***** RManager *****/

@interface RManager : NSObject {
    NSMutableArray *queue;
    NSTimer *timer;
    id target;
    SEL selector;
    NSString *path;
    NSRecursiveLock *lock;
}
@property (nonatomic, readonly) NSRecursiveLock *lock;

-(id)initWithTarget:(id)target selector:(SEL)selector andPath:(NSString*)path;
-(void)load:(RPiece*)piece;

@end


/***** RasterLayer *****/

@interface RasterLayer : NSObject {
    RManager *loader;
    NSMutableDictionary *levels;
    int level, piecesCount;
    CGRect allRect;
    id target;
    SEL selector;
}

-(id) initWithRect:(CGRect)rect;
-(BOOL) draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale;
-(void) freeSomeMemory;
-(void) setSignal:(id)target selector:(SEL)selector;

@end
