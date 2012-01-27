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
	return [super initWithFrame:frame];
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
    scrolledView.frame = frame;
}

@end
