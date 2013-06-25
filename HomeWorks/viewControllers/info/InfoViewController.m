//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "InfoViewController.h"
#import "MKStoreManager.h"
#import "DejalActivityView.h"
#import "AFHTTPRequestOperation.h"
#import "NSObject+homeWorksServiceLocator.h"


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
	switch(indexPath.section)
	{
		case 1:
			[self restorePurchases];
			break;
		case 2:
			[self updateCatalog];
			break;
		default:
			break;
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateCatalog
{
	[DejalBezelActivityView activityViewForView:self.view.window withLabel:@""].showNetworkActivityIndicator = YES;

	NSURLRequest *request = [NSURLRequest requestWithURL:self.catalogDownloadUrl];
	AFHTTPRequestOperation *catalogDownloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

	[catalogDownloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSLog(@"Catalog succesfully downloaded");

		RXMLElement *rxml = [RXMLElement elementFromXMLData:operation.responseData];

		// Check that file is parsed fine
		if ([rxml attribute:@"baseurl"])
		{
			[self.catalogRxml initFromXMLData:operation.responseData];
			[operation.responseString writeToFile:self.catalogFilePath atomically:YES encoding:operation.responseStringEncoding error:nil];
		}

		[DejalBezelActivityView removeView];

	}                                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		NSLog(@"error downloading catalog!");
		[DejalBezelActivityView removeView];
	}];

	[catalogDownloadOperation start];
}

- (void)restorePurchases
{
	[DejalBezelActivityView activityViewForView:self.view.window withLabel:@""].showNetworkActivityIndicator = YES;    
    
	[[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^()
     {
          [DejalBezelActivityView removeView];
     } onError:^(NSError *restoreError)
     {
         [DejalBezelActivityView removeView];
     }];
}

@end