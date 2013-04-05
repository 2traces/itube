//
// Created by bsideup on 06.11.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIViewController+TLDismissable.h"


@implementation UIViewController (TLDismissable)

- ( IBAction ) tlDismissMe:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

@end