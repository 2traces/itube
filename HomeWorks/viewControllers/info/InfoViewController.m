//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "InfoViewController.h"
#import "DejalActivityView.h"
#import "AFHTTPRequestOperation.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "HomeworksIAPHelper.h"
#import <Parse/Parse.h>

@implementation InfoViewController
{

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lbLogin.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:self.lbLogin.font.pointSize];
    self.lbSubscription.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:self.lbSubscription.font.pointSize];

    if ([PFUser currentUser].isAuthenticated) {
        self.lbLogin.text = [NSString stringWithFormat:@"Выйти (%@)", [PFUser currentUser].username];
    }
    else {
        self.lbLogin.text = @"Авторизация";
    }
    
    if ([[HomeworksIAPHelper sharedInstance] daysRemainingOnSubscription] > 0) {
        self.lbSubscription.hidden = NO;
        self.lbSubscription.text = [NSString stringWithFormat:@"Ваша подписка закончится %@", [[HomeworksIAPHelper sharedInstance] getExpiryDateString]];
    }
    else {
        self.lbSubscription.hidden = YES;
    }
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:121.0 / 255.0 green:166.0 / 255.0 blue:191.0 / 255.0 alpha:1.0]];
//	[self.navigationController.navigationBar setTitleTextAttributes:
//			@{
//					UITextAttributeTextShadowColor : [UIColor blackColor],
//					UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)]
//			}];

	UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0)];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsLandscapePhone];


}

- (IBAction)tlDismissMe:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
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
        case 3:
            [self loginRegister];
		default:
			break;
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loginRegister {
    
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
			id obj = [self.catalogRxml initFromXMLData:operation.responseData];
            NSLog(@"Silenting compilation warning due to bad architecture. Object created: %@", obj);
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
    
//	[[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^()
//     {
//          [DejalBezelActivityView removeView];
//     } onError:^(NSError *restoreError)
//     {
//         [DejalBezelActivityView removeView];
//     }];

    //1
    if ([PFUser currentUser].isAuthenticated) {
//        [[HomeworksIAPHelper sharedInstance] restoreCompletedTransactions];

        if (![[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]) {
            [[PFUser currentUser] refresh];
            if (![[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]) {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Внимание! Чтобы восстановить покупки, вам необходимо подтвердить адрес электронной почты." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [errorAlertView show];
                [DejalBezelActivityView removeView];
                return;
            }
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        
        [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *object, NSError *error) {
            
            //2
            NSDate *serverDate = [[object objectForKey:@"ExpirationDate"] lastObject];
            
            [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:@"ExpirationDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.tableView reloadData];
            [DejalBezelActivityView removeView];

            NSLog(@"Restore Complete!");
        }];
    } else {
        [DejalBezelActivityView removeView];
        [[[UIAlertView alloc]
          initWithTitle:@"Ошибка"
          message:@"Внимание! Чтобы восстановить покупки, вам необходимо авторизоваться."
          delegate:nil cancelButtonTitle:@"OK"
          otherButtonTitles:nil] show];
    }
}

@end