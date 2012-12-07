//
//  GlText.m
//  tube
//
//  Created by Vasiliy Makarov on 23.11.12.
//
//

#import <UIKit/UIKit.h>
#import "GlText.h"

@implementation GlText

@synthesize width;
@synthesize height;
@synthesize position = origin;
@synthesize alpha;

-(id)initWithText:(NSString *)text font:(NSString *)font fontSize:(CGFloat)fontSize andRect:(CGRect)rect
{
    if((self = [super init])) {
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
		label.font = [UIFont fontWithName:font size:fontSize];
        label.textAlignment = UITextAlignmentCenter;
		label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 10;
        label.text = text;
        UIGraphicsBeginImageContext(label.frame.size);
        [label.layer drawInContext:UIGraphicsGetCurrentContext()];
        UIImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        sprite = [[GlSprite alloc] initWithImage:[layerImage CGImage] andRect:rect];
        [label release];
        frame = rect;
    }
    return self;
}

-(void)drawInto:(CGRect)rect
{
    sprite.rect = rect;
    sprite.alpha = alpha;
    [sprite draw];
}

-(void)drawWithScale:(CGFloat)scale
{
    CGRect rect = CGRectMake(origin.x + frame.origin.x / scale, origin.y + frame.origin.y / scale, frame.size.width / scale, frame.size.height / scale);
    [self drawInto:rect];
}

-(void)dealloc
{
    [sprite release];
    [super dealloc];
}

@end
