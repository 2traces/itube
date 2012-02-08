//
//  MyScrollView.m
//  tube
//
//  Created by Alex 1 on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyScrollView.h"


@implementation MyScrollView

@synthesize scrolledView;

- (id)initWithFrame:(CGRect)frame 
{
    if((self = [super initWithFrame:frame])) {
        tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tgr.numberOfTouchesRequired = 1;
        tgr.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tgr];
        tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        tgr2.numberOfTouchesRequired = 1;
        tgr2.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tgr2];
        tgr22 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDebugTap:)];
        tgr22.numberOfTouchesRequired = 2;
        tgr22.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tgr22];
    }
	return self;
}

-(void)dealloc
{
    [tgr release];
    [tgr2 release];
}

-(void)handleTap:(UITapGestureRecognizer*) sender
{
    if(sender.state == UIGestureRecognizerStateEnded) {
        CGPoint p1;// = [sender locationInView:self.superview];
        CGPoint p2 = [sender locationInView:scrolledView];

        [scrolledView selectStationAt:&p2];
        p1 = [self convertPoint:p2 fromView:scrolledView];
        p1 = [self convertPoint:p1 toView:self.superview];
        [self.superview selectStationAt:p1];
    }
}

-(void)handleDoubleTap:(UITapGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateEnded) {
        CGPoint p = [sender locationInView:[self.subviews objectAtIndex:0]];
        CGFloat zoom = self.zoomScale;
        p.x /= zoom;
        p.y /= zoom;
        zoom *= 1.5f;
        CGRect rect = CGRectMake(0, 0, self.frame.size.width / zoom, self.frame.size.height / zoom);
        rect.origin.x = p.x - rect.size.width / 2;
        rect.origin.y = p.y - rect.size.height / 2;
        [self zoomToRect:rect animated:YES];
    }
}

-(void)handleDebugTap:(UITapGestureRecognizer*)sender
{
    //[scrolledView setShowVectorLayer:![scrolledView showVectorLayer]];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize bounds = self.bounds.size;
    CGRect frame = scrolledView.frame;
    if(frame.size.width < bounds.width)
        frame.origin.x = (bounds.width - frame.size.width) / 2;
    else 
        frame.origin.x = 0;
    if(frame.size.height < bounds.height)
        frame.origin.y = (bounds.height - frame.size.height) / 2;
    else 
        frame.origin.y = 0;
    //scrolledView.frame = frame;
    for (UIView *v in self.subviews) {
        v.frame = frame;
    }
}

@end
