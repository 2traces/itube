//
// Created by bsideup on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSObject+homeWorksServiceLocator.h"
#import "PurchasesService.h"


@implementation NSObject (homeWorksServiceLocator)

-(NSString *)monthlySubscriptionIAP
{
	return @"monthly";
}

-(NSString *)yearlySubscriptionIAP
{
	return @"yearly";
}

- (NSString *)pageURLStringFormat
{
	return [[self.catalogRxml attribute:@"baseurl"] stringByAppendingString:@"/%@/%@/%@/%@.%@"];
}

- (NSString *)pageCoverStringFormat
{
	return [[self.catalogRxml attribute:@"baseurl"] stringByAppendingString:@"/%@/%@/%@/cover.jpg"];
}

- (NSString *)pageFilePathStringFormat
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"terms%@subjects%@books%@answer%@.%@"];
}

- (NSURL *)catalogDownloadUrl
{
	static NSURL *catalogDownloadUrl;

	if (catalogDownloadUrl == nil)
	{
		catalogDownloadUrl = [NSURL URLWithString:@"http://parismetromaps.info/homeworks/catalog.xml"];
	}

	return catalogDownloadUrl;
}

- (NSString *)catalogFilePath
{
	static NSString *catalogFilePath;

	if (catalogFilePath == nil)
	{
		NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		catalogFilePath = [documentsDirectory stringByAppendingPathComponent:@"catalog.xml"];
	}

	return catalogFilePath;
}

- (RXMLElement *)catalogRxml
{
	static RXMLElement *catalogRxml;

	if (catalogRxml == nil)
	{
		NSString *libraryOrBundledCatalogFilePath;

		if ([[NSFileManager defaultManager] fileExistsAtPath:self.catalogFilePath])
		{
			libraryOrBundledCatalogFilePath = self.catalogFilePath;
		} else
		{
			libraryOrBundledCatalogFilePath = [[NSBundle mainBundle] pathForResource:@"Homeworks.bundle/catalog" ofType:@"xml"];
		}
		catalogRxml = [RXMLElement elementFromXMLString:[NSString stringWithContentsOfFile:libraryOrBundledCatalogFilePath encoding:NSUTF8StringEncoding error:nil] encoding:NSUTF8StringEncoding];
	}

	return catalogRxml;
}

- (PurchasesService *)purchaseService
{
	static PurchasesService *purchasesService;

	if(purchasesService == nil)
	{
		purchasesService = [[PurchasesService alloc] init];
	}

	return purchasesService;
}


@end