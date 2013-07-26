//
//  UIViewPosition.m
//  tube
//
//  Created by alex on 26.07.13.
//
//

#import "RectObject.h"

@implementation RectObject

@synthesize rect;

+(id)rectWithCGRect:(CGRect)pRect{
    RectObject *obj = [[[RectObject alloc] init] autorelease];
    obj.rect = pRect;
    return obj;
}

@end
