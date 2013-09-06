//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "InfoViewController.h"
#import "MKStoreManager.h"
#import "DejalActivityView.h"

NSString *kAppStoreURL = @"https://itunes.apple.com/ru/app/angry-birds/id343200656?l=en&mt=8";

@implementation InfoViewController
{

}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:121.0 / 255.0 green:166.0 / 255.0 blue:191.0 / 255.0 alpha:1.0]];
	[self.navigationController.navigationBar setTitleTextAttributes:
			@{
					UITextAttributeTextShadowColor : [UIColor blackColor],
					UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)]
			}];

	UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0)];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsLandscapePhone];
}

- (IBAction)tlDismissMe:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
#ifndef HW_PRO
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:kAppStoreURL]];
#endif
        return;
    }
	if (indexPath.section != 1)
	{
		return;
	}

	[DejalBezelActivityView activityViewForView:self.view.window withLabel:@""].showNetworkActivityIndicator = YES;

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