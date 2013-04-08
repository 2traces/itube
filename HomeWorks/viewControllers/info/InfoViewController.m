//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "InfoViewController.h"
#import "MKStoreManager.h"
#import "DejalActivityView.h"


@implementation InfoViewController
{

}

- (IBAction)tlDismissMe:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section != 1)
	{
		return;
	}

	[DejalBezelActivityView activityViewForView:self.view.window].showNetworkActivityIndicator = YES;

	[[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^
	{
		[DejalBezelActivityView removeView];
	}                                                             onError:^(NSError *error)
	{
		[DejalBezelActivityView removeView];
	}];

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end