//
// Created by bsideup on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "RXMLElement.h"

@class PurchasesService;

@interface NSObject (homeWorksServiceLocator)

-(NSString *)monthlySubscriptionIAP;

-(NSString *)yearlySubscriptionIAP;

- (NSString *)pageURLStringFormat;

- (NSString *)pageCoverStringFormat;

- (NSString *)pageFilePathStringFormat;

- (NSURL *)catalogDownloadUrl;

- (NSString *)catalogFilePath;

- (RXMLElement *)catalogRxml;

-(PurchasesService *)purchaseService;

@end