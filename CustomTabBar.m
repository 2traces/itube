//
//  CustomTabBar.m
//  tube
//
//  Created by sergey on 11.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomTabBar.h"

@implementation CustomTabBar

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideExistingTabBar];
}


- (void)hideExistingTabBar
{
	for(UIView *view in self.view.subviews)
	{
		if([view isKindOfClass:[UITabBar class]])
		{
			view.hidden = YES;
			break;
		}
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}

@end    