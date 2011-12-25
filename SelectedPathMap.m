//
//  SelectedPathMap.m
//  tube
//
//  Created by Alex 1 on 10/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectedPathMap.h"


@implementation SelectedPathMap
@synthesize drawedPath;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		DLog(@" SelectedMap InitWithFrame ");
		self.userInteractionEnabled = YES;
		[self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	
	DLog(@" begin clear SelectedMap ");
	CGContextRef cgContext = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(cgContext, [[UIColor clearColor] CGColor]);
	CGContextFillRect(cgContext, CGRectMake(0, 0, 2000, 2000));

	if (drawedPath!=nil)
	{
		DLog(@"drawMap");
		[drawedPath drawInRect:CGRectMake(0,0,2000,2000)];
	}
	
	if((cgContext != nil) && (1!=1))
	{
		DLog(@" inside drawRect SelectedMap");

	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DLog(@" touch -1");
	//self.scrollEnabled=NO;
	//	[self performSelector:@selector(longTap:) withObject:nil afterDelay:1.5];
    [self.nextResponder touchesBegan:touches withEvent:event];
}

@end
