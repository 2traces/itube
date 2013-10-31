//
//  MKStoreManager+customPurchases.m
//  HomeWorks
//
//  Created by Max on 31.10.13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "MKStoreManager+customPurchases.h"

@implementation MKStoreManager (customPurchases)

+(NSArray *)appStorePurchaseIDs
{
    NSUInteger n = 15;
    NSMutableArray* purchaseIDs = [NSMutableArray arrayWithCapacity:n];
    for (size_t i = 0; i < n; ++i)
    {
        [purchaseIDs addObject:[NSString stringWithFormat:@"ru.trylogic.homeworks.purchase.%d", n]];
    }
    return purchaseIDs;
}

+ (NSString *)inAppPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [[basePath stringByAppendingPathComponent:@"inApp"] stringByAppendingPathExtension:@"dic"];
}

+(BOOL)isBookAlreadyPurchased:( NSString* )pageId
{
    NSDictionary* savedPurchases = [NSDictionary dictionaryWithContentsOfFile:[self inAppPath]];
    if (!savedPurchases)
    {
        return NO;
    }
    if (savedPurchases.count >= [self appStorePurchaseIDs].count)
    {
        return YES;
    }
    
    NSString* appstoreId = savedPurchases[pageId];
    return [MKStoreManager isFeaturePurchased:appstoreId];
}

+(NSString*)firstUnusedAppstoreID
{
    NSDictionary* savedPurchases = [NSDictionary dictionaryWithContentsOfFile:[self inAppPath]];
    if (!savedPurchases)
    {
        savedPurchases = [NSDictionary dictionary];
    }
    
    for (NSString* appStoreId in  [self appStorePurchaseIDs] )
    {
        if (![savedPurchases.allValues containsObject:appStoreId])
        {
            return appStoreId;
        }
    }
    return nil;
}

+(void)saveBuyedBookId:( NSString* )bookID withAppStoreId:( NSString* )appstoreId;
{
    NSMutableDictionary* savedPurchases = [[NSDictionary dictionaryWithContentsOfFile:[self inAppPath]] mutableCopy];
    if (!savedPurchases)
    {
        savedPurchases = [NSMutableDictionary dictionary];
    }
    
    if ([savedPurchases.allKeys containsObject:bookID])
    {
        return;
    }
    
    savedPurchases[bookID] = appstoreId;
    
    [savedPurchases writeToFile:[self inAppPath] atomically:YES];
}

@end
