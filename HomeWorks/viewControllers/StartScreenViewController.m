//
// Created by bsideup on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "StartScreenViewController.h"
#import "AFHTTPRequestOperation.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "MKStoreManager.h"
#import "MKStoreManager+customPurchases.h"

@interface StartScreenViewController () <SKProductsRequestDelegate>
@end

@implementation StartScreenViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		if (screenSize.height > 480.0f)
		{
			self.backgroundView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
			self.backgroundView.contentScaleFactor = 2.0;
		}
	}
	else
	{
		if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		{
			NSLog(@"landscape");
			self.backgroundView.image = [UIImage imageNamed:@"Default-Landscape"];
		}
		else
		{
			self.backgroundView.image = [UIImage imageNamed:@"Default-Portrait"];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	NSURLRequest *request = [NSURLRequest requestWithURL:self.catalogDownloadUrl];
	AFHTTPRequestOperation *catalogDownloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

	[catalogDownloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSLog(@"Catalog succesfully downloaded");

		RXMLElement *rxml = [RXMLElement elementFromXMLData:operation.responseData];

		// Check that file is parsed fine
		if ([rxml attribute:@"baseurl"])
		{
			[self.catalogRxml initFromXMLData:operation.responseData];
			[operation.responseString writeToFile:self.catalogFilePath atomically:YES encoding:operation.responseStringEncoding error:nil];
            [self addSkipBackupAttributeToItemAtPath:self.catalogFilePath];
		}

		[self prepareProducts];

	}                                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		NSLog(@"error downloading catalog!");
		[self prepareProducts];
	}];

	[catalogDownloadOperation start];
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [url path]]);
    
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    else {
        //NSLog(@"Successfully excluded file from backup: %@", [url lastPathComponent]);
    }
    
    return success;
}

- (void)prepareProducts
{
    NSArray* purchaseIds = [MKStoreManager appStorePurchaseIDs];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:purchaseIds]];
	productsRequest.delegate = self;
	[productsRequest start];
}

- (void)continueApplicationLoading
{
	[self performSegueWithIdentifier:@"showList" sender:self];
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