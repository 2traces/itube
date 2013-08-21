//
// Created by Sergey Egorov on 6/20/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PurchasesService.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "MKStoreManager.h"
#import "HomeworksIAPHelper.h"
#import "AppDelegate.h"

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

    if ([[HomeworksIAPHelper sharedInstance] daysRemainingOnSubscription] > 0) {
        return YES;
    }

	return NO;
}

- (void)purchaseSubscription:(NSString *)subscriptionId WithComplete:(void (^)())complete andError:(void (^)())error
{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    for (SKProduct *product in appDelegate.products) {
        if ([product.productIdentifier isEqualToString:subscriptionId]) {
            NSLog(@"Buying %@...", subscriptionId);
            [[HomeworksIAPHelper sharedInstance] buyProduct:product];
            break;
        }
    }
    
//	[[MKStoreManager sharedManager] buyFeature:subscriptionId onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
//	{
//		complete();
//	} onCancelled:error];
    
}

@end