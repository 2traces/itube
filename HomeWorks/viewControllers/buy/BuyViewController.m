//
// Created by Sergey Egorov on 6/30/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BuyViewController.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "PurchasesService.h"
#import "DejalActivityView.h"


@implementation BuyViewController
{
	DejalActivityView *activityView;
}

-(IBAction)cancel
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)finish:(BOOL)result
{
	[self.delegate buyControllerDidFinish:result];
	[self cancel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"buying");
	activityView = [DejalBezelActivityView activityViewForView:self.view.window withLabel:@""];
	[self.purchaseService purchaseSubscription:indexPath.section == 0 ? self.monthlySubscriptionIAP : self.yearlySubscriptionIAP
			WithComplete:^()
			{
				[activityView removeFromSuperview];
				[self finish:YES];
			} andError:^()
	{
		[self removeActivityView:activityView];
		[self finish:NO];
	}];
	[self performSelector:@selector(removeActivityView:) withObject:activityView afterDelay:30];
}

- (void)removeActivityView:(DejalActivityView *)activityViewToRemove
{
	if (activityViewToRemove.superview != nil)
	{
		[activityViewToRemove removeFromSuperview];
		[[[UIAlertView alloc]
				initWithTitle:@"Ошибка"
					  message:@"Внимание! Покупка не удалась и деньги не снялись. Попробуйте позднее."
					 delegate:nil cancelButtonTitle:@"OK"
			otherButtonTitles:nil] show];
		[self finish:NO];
	}
}

@end