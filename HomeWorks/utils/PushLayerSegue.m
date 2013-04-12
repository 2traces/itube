//
// Created by bsideup on 4/12/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <FRLayeredNavigationController/FRLayeredNavigationController.h>
#import "PushLayerSegue.h"
#import "UIViewController+FRLayeredNavigationController.h"
#import "FRLayeredNavigationItem.h"
#import "AnswersViewController.h"

@implementation PushLayerSegue
{

}

- (void)perform
{
	UIViewController *sourceViewController = self.sourceViewController;

	[sourceViewController.layeredNavigationController pushViewController:self.destinationViewController
															   inFrontOf:sourceViewController.navigationController
															maximumWidth:YES
																animated:YES
														   configuration:^(FRLayeredNavigationItem *item)
	{
		item.hasChrome = NO;
	}];
}
@end