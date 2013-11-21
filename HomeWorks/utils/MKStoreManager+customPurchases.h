//
//  MKStoreManager+customPurchases.h
//  HomeWorks
//
//  Created by Max on 31.10.13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "MKStoreManager.h"

@interface MKStoreManager (customPurchases)

+(NSArray*)appStorePurchaseIDs;

+(BOOL)isBookAlreadyPurchased:( NSString* )purchaseId;

+(NSString*)firstUnusedAppstoreID;

+(void)saveBuyedBookId:( NSString* )purchaseId withAppStoreId:( NSString* )appstoreId;

@end
