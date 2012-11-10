//
//  GalleryView.m
//  tube
//
//  Created by Alexey Starovoitov on 8/1/12.
//
//

#import "GalleryView.h"

@implementation GalleryView

@synthesize galleryViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint tempPoint = [self convertPoint:point toView:galleryViewController.scrollView];
    BOOL pointInsideScrollView = [galleryViewController.scrollView pointInside:tempPoint withEvent:event];
    if ([self pointInside:point withEvent:event] && !pointInsideScrollView) {
        return galleryViewController.scrollView;
    }
    return [super hitTest:point withEvent:event];
}

@end
