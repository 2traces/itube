//
//  RasterLayer.h
//  tube
//
//  Created by Vasiliy Makarov on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RasterLayer : NSObject {
    NSString *rasterPath;
    NSMutableArray *layers;
}

-(id) initWithRect:(CGRect)rect;
-(BOOL) draw:(CGContextRef)context inRect:(CGRect)rect withScale:(CGFloat)scale;
-(void) freeSomeMemory;

@end
