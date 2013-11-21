//
//  IAPManager.m
//  HomeWorks
//
//  Created by Alexey Starovoitov on 21/11/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "IAPManager.h"
#import "StartScreenViewController.h"

#define INAPP_NAME_FORMAT @"inAppBook_%i"
#define INAPP_COUNT 10

@interface IAPManager () {
    StartScreenViewController *delegate;
}

@end

@implementation IAPManager

static IAPManager* _sharedManager;

#pragma mark Singleton Methods

+ (IAPManager*)sharedManager
{
	if(!_sharedManager) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedManager = [[self alloc] init];
            [MKStoreManager sharedManager];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            _sharedManager.purchased = [[defaults objectForKey:@"kPurchasedAmount"] integerValue];
            if ([defaults objectForKey:@"kPurchasedIds"]) {
                _sharedManager.purchasedIds = [NSMutableArray arrayWithArray:[defaults objectForKey:@"kPurchasedIds"]];
            }
            else {
                _sharedManager.purchasedIds = [NSMutableArray arrayWithCapacity:1];
            }
        });
    }
    return _sharedManager;
}

- (BOOL) isFeaturePurchased:(NSString*) featureId {
    [self checkForPurchases];
    return [self.purchasedIds containsObject:featureId];
}

- (NSInteger) remainingDownloads {
    return self.purchased - [self.purchasedIds count];
}

- (void)checkForPurchases {
    for (int i = self.purchased + 1; i <= INAPP_COUNT; i++) {
        if ([MKStoreManager isFeaturePurchased:[NSString stringWithFormat:INAPP_NAME_FORMAT, i]]) {
            self.purchased++;
        }
        else {
            break;
        }
    }
    [self updateDefaults];
}

- (void)updateDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSNumber numberWithInteger:self.purchased] forKey:@"kPurchasedAmount"];
    [defaults setObject:[NSArray arrayWithArray:self.purchasedIds] forKey:@"kPurchasedIds"];
    
    [defaults synchronize];
}

- (void) buyFeature:(NSString*) featureId
         onComplete:(void (^)(NSString*, NSData*, NSArray*)) completionBlock
        onCancelled:(void (^)(void)) cancelBlock {
    if ([self remainingDownloads] > 0) {
        [self.purchasedIds addObject:featureId];
        [self updateDefaults];

        completionBlock(featureId, nil, nil);
    }
    else {
        
        NSMutableArray *purchasableObjects = [MKStoreManager sharedManager].purchasableObjects;
        NSString *numFeatureId = [NSString stringWithFormat:INAPP_NAME_FORMAT, self.purchased + 1];

        for (SKProduct *product in purchasableObjects)
        {
            if ([[product productIdentifier] isEqualToString:numFeatureId])
            {
                [[MKStoreManager sharedManager] buyFeature:numFeatureId onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
                 {
                     self.purchased++;
                     [self.purchasedIds addObject:featureId];
                     [self updateDefaults];
                     
                     completionBlock(featureId, purchasedReceipt, availableDownloads);
                 } onCancelled:cancelBlock];
                return;
            }
        }
        cancelBlock();
    }
}

- (void) restorePreviousTransactionsOnComplete:(void (^)(void)) completionBlock
                                       onError:(void (^)(NSError*)) errorBlock {
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
        [self checkForPurchases];
        completionBlock();
    } onError:errorBlock];
}


- (void)requestPurchasesWithDelegate:(StartScreenViewController*)_delegate {
	NSMutableSet *productsSet = [NSMutableSet set];
    delegate = _delegate;
    
    for (int i = 1; i <= INAPP_COUNT; i++) {
        [productsSet addObject:[NSString stringWithFormat:INAPP_NAME_FORMAT, i]];
    }
    
	SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productsSet];
	productsRequest.delegate = self;
	[productsRequest start];
}


- (void)continueApplicationLoading
{
    [delegate continueApplicationLoading];
    delegate = nil;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[[MKStoreManager sharedManager] productsRequest:request didReceiveResponse:response];
}

- (void)requestDidFinish:(SKRequest *)request
{
	[self continueApplicationLoading];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	[[MKStoreManager sharedManager] request:request didFailWithError:error];
	[self continueApplicationLoading];
}


@end
