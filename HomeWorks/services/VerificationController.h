#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


#define IS_IOS6_AWARE (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1)

#define ITMS_PROD_VERIFY_RECEIPT_URL        @"https://buy.itunes.apple.com/verifyReceipt"
#define ITMS_SANDBOX_VERIFY_RECEIPT_URL     @"https://sandbox.itunes.apple.com/verifyReceipt";

#define KNOWN_TRANSACTIONS_KEY              @"knownIAPTransactions"

#define ITC_CONTENT_PROVIDER_SHARED_SECRET  @"ff524d602ff44f3ea798bcc621c40a91"

char* base64_encode(const void* buf, size_t size);
void * base64_decode(const char* s, size_t * data_len);

typedef void (^VerifyCompletionHandler)(BOOL success);

@interface VerificationController : NSObject {
    NSMutableDictionary *transactionsReceiptStorageDictionary;
}

+ (VerificationController *) sharedInstance;


// Checking the results of this is not enough.
// The final verification happens in the connection:didReceiveData: callback within
// this class.  So ensure IAP feaures are unlocked from there.
- (void)verifyPurchase:(SKPaymentTransaction *)transaction completionHandler:(VerifyCompletionHandler)completionHandler;

@end
