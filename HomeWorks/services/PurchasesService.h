//
// Created by Sergey Egorov on 6/20/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface PurchasesService : NSObject

-(BOOL)isPurchasedTermId:(NSString *)termId withSubjectId:(NSString *)subjectId withBookId:(NSString *)bookId;

- (void)purchaseMonthlySubscriptionWithComplete:(void (^)())complete andError:(void (^)())error;
@end