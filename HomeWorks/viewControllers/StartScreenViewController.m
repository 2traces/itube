//
// Created by bsideup on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "StartScreenViewController.h"
#import "AFHTTPRequestOperation.h"
#import "RXMLElement.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "MKStoreManager.h"


@interface StartScreenViewController () <SKProductsRequestDelegate>
@end

@implementation StartScreenViewController

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
			//[self.catalogRxml initFromXMLData:operation.responseData];
			//[operation.responseString writeToFile:self.catalogFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}

		[self prepareProducts];

	}                                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		NSLog(@"error downloading catalog!");
		[self prepareProducts];
	}];

	[catalogDownloadOperation start];
}

- (void)prepareProducts
{
	NSMutableSet *productsSet = [NSMutableSet set];

	[self.catalogRxml iterate:@"term" usingBlock:^(RXMLElement *term)
	{
		[term iterate:@"subject" usingBlock:^(RXMLElement *subject)
		{
			[subject iterate:@"book" usingBlock:^(RXMLElement *book)
			{
				[productsSet addObject:[NSString stringWithFormat:self.bookIAPStringFormat,
																  [term attribute:@"id"],
																  [subject attribute:@"id"],
																  [book attribute:@"id"]]];
			}];
		}];
	}];


	SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productsSet];
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