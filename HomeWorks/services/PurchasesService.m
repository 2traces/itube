//
// Created by Sergey Egorov on 6/20/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PurchasesService.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "MKStoreManager.h"


@implementation PurchasesService
{

}
- (BOOL)isPurchasedTermId:(NSString *)termId withSubjectId:(NSString *)subjectId withBookId:(NSString *)bookId
{
	NSString *xpath = [NSString stringWithFormat:@"/catalog/term[@id=%@]/subject[@id=%@]/book[@id=%@]", termId, subjectId, bookId];
	__block BOOL bookIsFree = NO;

	[self.catalogRxml iterateWithRootXPath:xpath usingBlock:^(RXMLElement *element)
	{
		if([element attributeAsInt:@"free"])
		{
			bookIsFree = YES;
		}
	}];

	if(bookIsFree)
	{
		return YES;
	}

	if([[MKStoreManager sharedManager] isSubscriptionActive:self.yearlySubscriptionIAP])
	{
		return YES;
	}

	if([[MKStoreManager sharedManager] isSubscriptionActive:self.monthlySubscriptionIAP])
	{
		return YES;
	}

	return NO;
}

- (void)purchaseMonthlySubscriptionWithComplete:(void (^)())complete andError:(void (^)())error
{
	[[MKStoreManager sharedManager] buyFeature:self.monthlySubscriptionIAP onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
	{
		complete();
	} onCancelled:error];
}

- (void)restorePurchasesOnComplete:(void (^)())complete onError:(void (^)())error
{
	[[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:complete onError:^(NSError *restoreError)
	{
		error();
	}];

}

@end