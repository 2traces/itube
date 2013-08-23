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
#import "HomeworksIAPHelper.h"
#import "IAPHelper.h"

@implementation BuyViewController
{
	DejalActivityView *activityView;
}

-(IBAction)cancel
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseFailed:) name:@"IAPHelperProductFailedNotification" object:nil];

}

- (void)productPurchased:(NSNotification *)notification {
//    NSString * productIdentifier = notification.object;
    [activityView removeFromSuperview];
    [self finish:YES];
}


- (void)productPurchaseFailed:(NSNotification *)notification {
//    NSString * productIdentifier = notification.object;
    [activityView removeFromSuperview];

    [[[UIAlertView alloc]
      initWithTitle:@"Ошибка"
      message:@"Внимание! Покупка не удалась и деньги не снялись. Попробуйте позднее."
      delegate:nil cancelButtonTitle:@"OK"
      otherButtonTitles:nil] show];
    [self finish:NO];
}

-(void)finish:(BOOL)result
{
	[self.delegate buyControllerDidFinish:result];
	[self cancel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (IBAction)buyMonth:(id)sender {
	NSLog(@"buying");
	activityView = [DejalBezelActivityView activityViewForView:self.view.window withLabel:@""];
	[self.purchaseService purchaseSubscription:self.monthlySubscriptionIAP];
}

- (IBAction)buyYear:(id)sender {
	NSLog(@"buying");
	activityView = [DejalBezelActivityView activityViewForView:self.view.window withLabel:@""];
	[self.purchaseService purchaseSubscription:self.yearlySubscriptionIAP];
}

@end