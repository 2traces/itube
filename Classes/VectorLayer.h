//
//  VectorLayer.h
//  tube
//
//  Created by Vasiliy Makarov on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/***** Vector Line *****/

@interface VectorLine : NSObject {
@private
    CGRect boundingBox;
    CGColorRef col;
    CGColorRef disabledCol;
    CGMutablePathRef path;
    int width;
    BOOL enabled;
}
@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, assign) BOOL enabled;

-(id) initWithPoints:(NSArray*)points color:(CGColorRef) color andDisabledColor:(CGColorRef) dcol;
-(void) draw:(CGContextRef) context;

@end

/***** Vector Polygon *****/

@interface VectorPolygon : NSObject {
@private
    CGRect boundingBox;
    CGColorRef col;
    CGColorRef disabledCol;
    CGMutablePathRef path;
    BOOL enabled;
}
@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, assign) BOOL enabled;

-(id) initWithPoints:(NSArray*) points color:(CGColorRef)color andDisabledColor:(CGColorRef)dcol;
-(void) draw:(CGContextRef) context;

@end

/***** Vector Layer *****/

@interface VectorLayer : NSObject {
@private
    CGSize size;
    CGColorSpaceRef colorSpace;
    CGColorRef brushColor, penColor;
    NSMutableArray *elements;
    BOOL enabled;
}
@property (nonatomic, assign) BOOL enabled;

-(id) initWithFile:(NSString*)fileName;
-(void) loadFrom:(NSString*)fileName;
-(void) draw:(CGContextRef) context inRect:(CGRect)rect;

@end
