//
//  GlPanel.h
//  tube
//
//  Created by Vasiliy Makarov on 23.11.12.
//
//

#import <Foundation/Foundation.h>
#import "GlSprite.h"
#import "GlText.h"

@interface GlPanel : NSObject {
    GlSprite * sprite;
    CGPoint origin;
    CGRect frame;
    float alpha;
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGFloat alpha;

-(id)initWithBackground:(NSString*)fileName position:(CGPoint)position andRect:(CGRect)rect;
-(void)drawWithScale:(CGFloat)scale;

@end

@interface AbstractPanel : NSObject {
    BOOL closed;
    enum {HIDDEN=0, RISING, SHOWN, HIDING} state;
    float alpha;
    GlPanel *panel;
    GlText *text;
    CGPoint origin;
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, readonly) BOOL closed;

-(void)show;
-(void)hide;
-(void)update:(CGFloat)time;
-(void)drawWithScale:(CGFloat)scale;

@end

@interface SmallPanel : AbstractPanel {
    
}
-(id)initWithText:(NSString*)str;

@end

@interface BigPanel : AbstractPanel {
    
}
-(id)initWithText:(NSString*)str;

@end