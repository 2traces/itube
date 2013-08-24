//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "VerificationController.h"
#import <Parse/Parse.h>

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

NSString *const IAPHelperProductFailedNotification = @"IAPHelperProductFailedNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        //Initialize errors
        self.backendErrors = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Произошла непредвиденная ошибка. Попробуйте повторить запрос позже.", @-1,
                              @"Произошла непредвиденная ошибка. Попробуйте повторить запрос позже.", @1,
                              @"Ошибка подключения. Попробуйте повторить запрос позже.", @100,
                              @"Пользователя с указанной комбинацией логина и пароля не найдено. Проверьте правильность введенных данных.", @101,
                              @"Произошла непредвиденная ошибка.", @102,
                              @"Произошла непредвиденная ошибка.", @103,
                              @"Произошла непредвиденная ошибка.", @104,
                              @"Произошла непредвиденная ошибка.", @105,
                              @"Произошла непредвиденная ошибка.", @106,
                              @"Произошла непредвиденная ошибка.", @107,
                              @"Произошла непредвиденная ошибка.", @108,
                              @"Произошла непредвиденная ошибка.", @109,
                              @"Произошла непредвиденная ошибка.", @111,
                              @"Произошла непредвиденная ошибка.", @112,
                              @"Произошла непредвиденная ошибка.", @115,
                              @"Произошла непредвиденная ошибка.", @116,
                              @"Произошла непредвиденная ошибка.", @119,
                              @"Произошла непредвиденная ошибка.", @120,
                              @"Произошла непредвиденная ошибка.", @121,
                              @"Произошла непредвиденная ошибка.", @122,
                              @"Произошла непредвиденная ошибка.", @123,
                              @"Произошла непредвиденная ошибка.", @124,
                              @"Некорректный адрес электронной почты.", @125,
                              @"Произошла непредвиденная ошибка.", @137,
                              @"Произошла непредвиденная ошибка.", @139,
                              @"Превышен лимит запросов. Попробуйте повторить запрос позже.", @140,
                              @"Произошла непредвиденная ошибка.", @141,
                              @"Отсутствует имя пользователя", @200,
                              @"Отсутствует пароль", @201,
                              @"Пользователь с таким адресом электронной почты уже существует.", @202,
                              @"Пользователь с таким адресом электронной почты уже существует.", @203,
                              @"Отсутствует адрес электронной почты.", @204,
                              @"Указанный электронный адрес не найден.", @205,
                              @"Произошла непредвиденная ошибка.", @206,
                              @"Произошла непредвиденная ошибка.", @207,
                              @"Произошла непредвиденная ошибка.", @208,
                              @"Произошла непредвиденная ошибка.", @250,
                              @"Произошла непредвиденная ошибка.", @251,
                              @"Произошла непредвиденная ошибка.", @252,
                              nil];
        
    }
    return self;
    
}

- (NSString*)errorWithCode:(NSNumber*)code {
    return [self.backendErrors objectForKey:code];
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    VerificationController * verifier = [VerificationController sharedInstance];
    [verifier verifyPurchase:transaction completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Successfully verified receipt!");
            [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
        } else {
            NSLog(@"Failed to validate receipt.");
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductFailedNotification object:transaction.payment.productIdentifier userInfo:nil];
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        }
    }];
}

-(int)daysRemainingOnSubscription {
    
    NSDate * expiryDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"dd MM yyyy"];
    NSTimeInterval timeInt = [[dateformatter dateFromString:[dateformatter stringFromDate:expiryDate]] timeIntervalSinceDate: [dateformatter dateFromString:[dateformatter stringFromDate:[NSDate date]]]]; //Is this too complex and messy?
    int days = timeInt / 60 / 60 / 24;
    
    if (days >= 0) {
        return days;
    } else {
        return 0;
    }
}

-(NSString *)getExpiryDateString {
    if ([self daysRemainingOnSubscription] > 0) {
        NSDate *today = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        return [NSString stringWithFormat:@"%@ (дней: %i)",[dateFormat stringFromDate:today],[self daysRemainingOnSubscription]];
    } else {
        return @"Not Subscribed";
    }
}

-(NSDate *)getExpiryDateForMonths:(int)months {
    
    NSDate *originDate;
    
    if ([self daysRemainingOnSubscription] > 0) {
        originDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    } else {
        originDate = [NSDate date];
    }
	NSDateComponents *dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:months];
	[dateComp setDay:1]; //an extra days grace because I am nice...
	return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp toDate:originDate options:0];
}

- (void)updateSubscriptionInfo {
    NSDate * localDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    NSString *objectId = @"";
    
    if ([PFUser currentUser].isAuthenticated) {
        objectId = [PFUser currentUser].objectId;
    }
    
    NSError *error;
    
    PFObject *object = [query getObjectWithId:objectId error:&error];
    NSDate * serverDate = [[object objectForKey:@"ExpirationDate"] lastObject];
    
    if (!localDate || [serverDate compare:localDate] == NSOrderedDescending) { //if server date is more recent, update local date
        [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:@"ExpirationDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [object addObject:localDate forKey:@"ExpirationDate"];
    }
    [object addUniqueObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceId"];
    [object saveInBackground];

    NSLog(@"Date updated!");
}

-(void)purchaseSubscriptionWithMonths:(int)months {
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    NSString *objectId = @"";
    
    if ([PFUser currentUser].isAuthenticated) {
        objectId = [PFUser currentUser].objectId;
    }
    
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        
        NSDate * serverDate = [[object objectForKey:@"ExpirationDate"] lastObject];
        NSDate * localDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
        
        if ([serverDate compare:localDate] == NSOrderedDescending) { //if server date is more recent, update local date
            [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:@"ExpirationDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSDate * expiryDate = [self getExpiryDateForMonths:months];
        
        [object addObject:expiryDate forKey:@"ExpirationDate"];
        [object saveInBackground];
        
        [[NSUserDefaults standardUserDefaults] setObject:expiryDate forKey:@"ExpirationDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:nil userInfo:nil];

        NSLog(@"Subscription Complete!");
    }];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    //if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductFailedNotification object:transaction.payment.productIdentifier userInfo:nil];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    

    if ([productIdentifier isEqualToString:@"ru.homeworks.month"]) {
            [self purchaseSubscriptionWithMonths:1];
    } else if ([productIdentifier isEqualToString:@"ru.homeworks.year"]) {
            [self purchaseSubscriptionWithMonths:12];
    } else {
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end