//
//  IAPManager.h
//  HomeWorks
//
//  Created by Alexey Starovoitov on 21/11/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKStoreManager.h"

@class StartScreenViewController;

@interface IAPManager : NSObject <SKProductsRequestDelegate>

@property (assign) NSInteger purchased;
@property (strong) NSMutableArray *purchasedIds;

// These are the methods you will be using in your app
+ (IAPManager*)sharedManager;

- (NSInteger) remainingDownloads;

- (void) buyFeature:(NSString*) featureId
         onComplete:(void (^)(NSString*, NSData*, NSArray*)) completionBlock
        onCancelled:(void (^)(void)) cancelBlock;

- (void) restorePreviousTransactionsOnComplete:(void (^)(void)) completionBlock
                                       onError:(void (^)(NSError*)) errorBlock;


- (void)requestPurchasesWithDelegate:(StartScreenViewController*)delegate;
- (BOOL) isFeaturePurchased:(NSString*) featureId;

@end
