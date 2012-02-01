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
        [self addGestureRecognizer:tgr];
    }
	return self;
}

-(void)dealloc
{
    [tgr release];
    [tgr2 release];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.scrollEnabled=NO;
//	[self performSelector:@selector(longTap:) withObject:nil afterDelay:1.5];
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
//	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longTap:) object:nil];
	self.scrollEnabled=YES;
	// If not dragging, send event to next responder
	if (!self.dragging) 
	{
		DLog(@" nod dragging ");
		[self.nextResponder touchesEnded: touches withEvent:event]; 
	}
	else
	{
		DLog(@" dragging ");
		[super touchesEnded: touches withEvent: event];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	DLog(@"scroll !! ");
}

-(void)handleTap:(UITapGestureRecognizer*) sender
{
    if(sender.state == UIGestureRecognizerStateEnded) {
        CGPoint p1 = [sender locationInView:self];
        CGPoint p2 = [sender locationInView:scrolledView];
        // TODO station selection
    }
}

-(void)handleDoubeTap:(UITapGestureRecognizer*)sender
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
