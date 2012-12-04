//
//  CustomPopoverBackgroundView.m
//  tube
//
//  Created by Sergey Mingalev on 27.08.12.
//
//

#import "CustomPopoverBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

#define CONTENT_INSET 0.0
#define CAP_INSET 7.0
#define ARROW_BASE 30.0
#define ARROW_HEIGHT 14.0

@implementation CustomPopoverBackgroundView

-(id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _borderImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popover-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(CAP_INSET,CAP_INSET,CAP_INSET,CAP_INSET)]];
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
        [self addSubview:_borderImageView];
        [self addSubview:_arrowView];

        _borderImageView.layer.cornerRadius = 10.0f;
//        _borderImageView.layer.masksToBounds = NO;
//        _borderImageView.layer.borderWidth = 1.0f;
//        _borderImageView.layer.borderColor = [UIColor blackColor].CGColor;
        _borderImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _borderImageView.layer.shadowOpacity = 0.8;
        _borderImageView.layer.shadowRadius = 10;
        _borderImageView.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
        
    }
    
    return self;
}

- (CGFloat) arrowOffset { return _arrowOffset; }
- (void) setArrowOffset:(CGFloat)arrowOffset { _arrowOffset = arrowOffset; }
- (UIPopoverArrowDirection)arrowDirection { return _arrowDirection; }
- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection { _arrowDirection = arrowDirection; }
+(UIEdgeInsets)contentViewInsets{ return UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET); }
+(CGFloat)arrowHeight{ return ARROW_HEIGHT; }
+(CGFloat)arrowBase{ return ARROW_BASE; }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat _height = self.frame.size.height;
    CGFloat _width = self.frame.size.width;
    CGFloat _left = 0.0;
    CGFloat _top = 0.0;
    CGFloat _coordinate = 0.0;
    CGAffineTransform _rotation = CGAffineTransformIdentity;
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            _top += ARROW_HEIGHT;
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            _arrowView.frame = CGRectMake(_coordinate, 0, ARROW_BASE, ARROW_HEIGHT);
            break;
        case UIPopoverArrowDirectionDown:
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            _arrowView.frame = CGRectMake(_coordinate, _height, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( M_PI );
            break;
        case UIPopoverArrowDirectionLeft:
            _left += ARROW_BASE; _width -= ARROW_BASE;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset) - (ARROW_HEIGHT/2);
            _arrowView.frame = CGRectMake(0, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( -M_PI_2 );
            break;
        case UIPopoverArrowDirectionRight:
            _width -= ARROW_BASE;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset)- (ARROW_HEIGHT/2);
            _arrowView.frame = CGRectMake(_width, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( M_PI_2 );
            break;
    }
    
    _borderImageView.frame = CGRectMake(_left, _top, _width, _height);
    [_arrowView setTransform:_rotation];
}

@end

