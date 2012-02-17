//
//  ActiveView.m
//  tube
//
//  Created by vasiliym on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActiveView.h"
#import "MyTiledLayer.h"
#import "tubeAppDelegate.h"

@implementation ActiveView

+ (Class)layerClass
{
    return [MyTiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        cityMap = appDelegate.cityMap;
        [self.layer setLevelsOfDetail:5];
        [self.layer setLevelsOfDetailBias:2];
        self.frame = CGRectMake(0, 0, cityMap.w, cityMap.h);
        self.opaque = NO;
    }
    return self;
}

-(void) setHidden:(BOOL)hidden
{
    if(hidden == NO) {
        // это недокументированный метод, так что если он в будущем изменится, то ой
        [self.layer invalidateContents];
        [self setNeedsDisplay];
    }
    super.hidden = hidden;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    CGContextSaveGState(context);
    CGRect r = CGContextGetClipBoundingBox(context);
    printf("active layer x=%d y=%d w=%d h=%d\n", (int)r.origin.x, (int)r.origin.y, (int)r.size.width, (int)r.size.height);
	CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.5f] CGColor]);
	CGContextFillRect(context, r);
    
    CGContextRef ctx = context;
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetShouldSmoothFonts(ctx, false);
    CGContextSetAllowsFontSmoothing(ctx, false);
    
    [cityMap drawActive:ctx inRect:r];
    
    CGContextRestoreGState(context);
}

@end
