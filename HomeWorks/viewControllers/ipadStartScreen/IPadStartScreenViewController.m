//
// Created by Sergey Egorov on 6/26/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "IPadStartScreenViewController.h"


@implementation IPadStartScreenViewController
{

}

- (void)viewDidAppear:(BOOL)animated
{
	[self performSegueWithIdentifier:@"show" sender:self];
}

@end