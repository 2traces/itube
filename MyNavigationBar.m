//
//  MyNavigationBar.m
//  
//
//  Created by sergey on 28.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MyNavigationBar.h"

@implementation MyNavigationBar

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed: @"grey_top_bar.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];   
}

@end