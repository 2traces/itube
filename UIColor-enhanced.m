//
//  UIColor-enhanced.m
//  tube
//
//  Created by sergey on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor-enhanced.h"

static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if (delta == 0) {
        *h = 0;
    } else {
        if( r == max )
            *h = ( g - b ) / delta;     // between yellow & magenta
        else if( g == max )
            *h = 2 + ( b - r ) / delta; // between cyan & yellow
        else
            *h = 4 + ( r - g ) / delta; // between magenta & cyan
    }
    *h *= 60.0;               // degrees
    if( *h < 0 )
        *h += 360.0;
    *h /= 360.0;
    *v /= 256.0;
}


@implementation UIColor (enhanced)

-(UIColor*)saturatedColor {
    
    CGFloat r, g, b, a, h, s, v;
    
    const CGFloat *comp = CGColorGetComponents([self CGColor]);
    
    r = comp[0]*255.0;
    g = comp[1]*255.0;
    b = comp[2]*255.0;
    a = comp[3];
    
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    return [UIColor colorWithHue:h saturation:s*2.0 brightness:v alpha:a];
}

- (UInt32)rgbHex {
    
    CGFloat r,g,b;

    const CGFloat *comp = CGColorGetComponents([self CGColor]);
    
    r = MIN(MAX(comp[0], 0.0f), 1.0f);
    g = MIN(MAX(comp[1], 0.0f), 1.0f);
    b = MIN(MAX(comp[2], 0.0f), 1.0f);
    
    return (((int)roundf(r * 255)) << 16)
    | (((int)roundf(g * 255)) << 8)
    | (((int)roundf(b * 255)));
}

- (NSString *)hexStringFromColor {
    return [NSString stringWithFormat:@"%0.6X", self.rgbHex];
}

-(UIColor*)darkenedColor {
    
    CGFloat r, g, b, a, h, s, v;
    
    const CGFloat *comp = CGColorGetComponents([self CGColor]);
    
    r = comp[0]*256.0;
    g = comp[1]*256.0;
    b = comp[2]*256.0;
    a = comp[3];
    
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    return [UIColor colorWithHue:h saturation:s brightness:v*0.5 alpha:a];
}

@end
