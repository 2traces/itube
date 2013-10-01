//
//  GlPanel.m
//  tube
//
//  Created by Vasiliy Makarov on 23.11.12.
//
//

#import "GlPanel.h"

@implementation GlPanel

@synthesize position = origin;
@synthesize alpha;

-(id)initWithBackground:(NSString *)fileName position:(CGPoint)position andRect:(CGRect)rect
{
    if((self = [super init])) {
        sprite = [[GlSprite alloc] initWithPicture:fileName];
        origin = position;
        frame = rect;
    }
    return self;
}

-(void)drawWithScale:(CGFloat)scale
{
    sprite.alpha = alpha;
    CGRect rect = CGRectMake(origin.x + frame.origin.x / scale, origin.y + frame.origin.y / scale, frame.size.width / scale, frame.size.height / scale);
    sprite.rect = rect;
    [sprite draw];
}

-(void)dealloc
{
    [sprite release];
    [super dealloc];
}

@end

@implementation AbstractPanel

@synthesize closed;

-(id)init
{
    if((self = [super init])) {
        closed = YES;
    }
    return self;
}

-(void)setPosition:(CGPoint)position
{
    origin = position;
    panel.position = position;
    text.position = position;
}

-(CGPoint)position
{
    return origin;
}

-(void)show
{
    if(state == HIDDEN) {
        state = RISING;
        alpha = 0;
        closed = NO;
    }
}

-(void)hide
{
    if(state == SHOWN) {
        state = HIDING;
        alpha = 1.f;
    } else if(state == RISING) {
        state = HIDING;
    }
}

-(void)drawWithScale:(CGFloat)scale
{
    if(state == HIDDEN) return;
    panel.alpha = alpha;
    text.alpha = alpha;
    [panel drawWithScale:scale];
    [text drawWithScale:scale];
}

-(void)update:(CGFloat)time
{
    switch (state) {
        case HIDDEN:
        default:
            break;
        case RISING:
            alpha += time * 4.f;
            if(alpha >= 1.f) {
                state = SHOWN;
                alpha = 1.f;
            }
            break;
        case SHOWN:
            break;
        case HIDING:
            alpha -= time * 4.f;
            if(alpha <= 0.f) {
                state = HIDDEN;
                alpha = 0.f;
                closed = YES;
            }
            break;
    }
}

-(void) dealloc
{
    [panel release];
    [text release];
    [super dealloc];
}

@end

@implementation SmallPanel

-(id)initWithText:(NSString *)str
{
    if((self = [super init])) {
        panel = [[GlPanel alloc] initWithBackground:@"small-frame-with-shadow" position:CGPointZero andRect:CGRectMake(-54, -83, 109, 83)];
        text = [[GlText alloc] initWithText:str font:@"Arial" fontSize:12.f andRect:CGRectMake(-41, -77, 82, 50)];
        //[self show];
    }
    return self;
}

@end

@implementation BigPanel

-(id)initWithText:(NSString *)str
{
    if((self = [super init])) {
        panel = [[GlPanel alloc] initWithBackground:@"big-blue-frame-with-shadow" position:CGPointZero andRect:CGRectMake(-120, -110, 240, 120)];
        text = [[GlText alloc] initWithText:str font:@"Arial" fontSize:12.f andRect:CGRectMake(-70, -90, 140, 60)];
        //[self show];
    }
    return self;
}

@end