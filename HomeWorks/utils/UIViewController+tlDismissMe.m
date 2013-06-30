//
// Created by Sergey Egorov on 6/30/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIViewController+tlDismissMe.h"


@implementation UIViewController (tlDismissMe)


- (IBAction)tlDismissMe:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end