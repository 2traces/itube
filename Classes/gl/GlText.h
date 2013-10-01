//
//  GlText.h
//  tube
//
//  Created by Vasiliy Makarov on 23.11.12.
//
//

#import <Foundation/Foundation.h>
#import "GlSprite.h"

@interface GlText : NSObject {
    GlSprite * sprite;
    unsigned int width, height;
    CGPoint origin;
    CGRect frame;
    float alpha;
}

@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGFloat alpha;

-(id)initWithText:(NSString*)text font:(NSString*)font fontSize:(CGFloat)fontSize andRect:(CGRect)rect;
-(id)initWithText:(NSString *)text font:(NSString *)font fontSize:(CGFloat)fontSize fontColor:(UIColor*)color andRect:(CGRect)rect;
-(void)drawInto:(CGRect)rect;
-(void)drawWithScale:(CGFloat)scale;

@end
