//
//  AnswersViewController.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import <RaptureXML/RXMLElement.h>
#import "AnswersViewController.h"
#import "AnswerViewController.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "AnswersViewHeader.h"
#import "MKStoreManager.h"
#import "DejalActivityView.h"
#import "AFHTTPRequestOperation.h"
#import "AnswerFileURL.h"

NSString *kCellID = @"answerCell";
NSString *kLockedCellID = @"lockedAnswerCell";
NSString *kHeaderID = @"collectionHeader";

@interface AnswersViewController () <QLPreviewControllerDataSource>
@end

@implementation AnswersViewController
{
	BOOL purchased;
	NSString *featureId;

	NSDictionary *fileAlreadyDownloading;
	NSOperationQueue *operationQueue;
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

	if (!purchased && indexPath.item > 1)
	{
		[self buy];
		return;
	}

	AnswerViewController *previewController = [[AnswerViewController alloc] init];
	previewController.dataSource = self;
	previewController.currentPreviewItemIndex = indexPath.item;
	[self.navigationController pushViewController:previewController animated:YES];
}

- (IBAction)buy
{
	NSLog(@"buying %@", featureId);
	[DejalBezelActivityView activityViewForView:self.view.window withLabel:@"Purchasing..."];

	[[MKStoreManager sharedManager] buyFeature:featureId onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
	{
		purchased = YES;
		self.navigationItem.rightBarButtonItem = nil;
		[self.collectionView reloadData];
		[DejalBezelActivityView removeView];
	}                              onCancelled:^
	{
		NSLog(@"canceled");
		[DejalBezelActivityView removeView];
	}];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return purchased ? [_book attributeAsInt:@"numPages"] : 2;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	__weak __typeof (&*controller) weakController = controller;

	NSString *pageFilePath = [NSString stringWithFormat:self.pageFilePathStringFormat,
														[_term attribute:@"id"],
														[_subject attribute:@"id"],
														[_book attribute:@"id"],
														(index + 1),
														[_book attribute:@"type"]];

	if (![[NSFileManager defaultManager] fileExistsAtPath:pageFilePath] && [fileAlreadyDownloading valueForKey:pageFilePath] == nil)
	{
		NSLog(@"starting downloading for file %@", pageFilePath);
		[fileAlreadyDownloading setValue:@(YES) forKey:pageFilePath];
		NSString *urlAsString = [NSString stringWithFormat:self.pageURLStringFormat,
														   [_term attribute:@"id"],
														   [_subject attribute:@"id"],
														   [_book attribute:@"id"],
														   (index + 1),
														   [_book attribute:@"type"]];

		NSLog(urlAsString);

		NSURL *url = [NSURL URLWithString:urlAsString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];

		AFHTTPRequestOperation *catalogDownloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

		if(index == controller.currentPreviewItemIndex) {
			[operationQueue cancelAllOperations];
			catalogDownloadOperation.queuePriority = NSOperationQueuePriorityHigh;
		}

		[catalogDownloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
		{
			[operation.responseData writeToFile:pageFilePath atomically:YES];

			if (weakController.currentPreviewItemIndex == index)
			{
				[weakController refreshCurrentPreviewItem];
			}

		}                                               failure:nil];

		[operationQueue addOperation:catalogDownloadOperation];
	}
	return [AnswerFileURL fileURLWithPath:pageFilePath previewTitle:[NSString stringWithFormat:@"%d", index + 1]];
}


- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	return [_book attributeAsInt:@"numPages"];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	featureId = [NSString stringWithFormat:self.bookIAPStringFormat,
										   [_term attribute:@"id"],
										   [_subject attribute:@"id"],
										   [_book attribute:@"id"]];
	purchased = [MKStoreManager isFeaturePurchased:featureId];
	if (purchased)
	{
		[self.navigationItem setRightBarButtonItem:nil];
	}

	self.collectionView.allowsMultipleSelection = NO;

	fileAlreadyDownloading = [NSMutableDictionary dictionary];
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];

}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	PSUICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:((!purchased && indexPath.item > 1) ? kLockedCellID : kCellID) forIndexPath:indexPath];

	if (cell.reuseIdentifier == kCellID)
	{
		[[cell.contentView.subviews objectAtIndex:0] setText:[NSString stringWithFormat:@"%d", (indexPath.item + 1)]];
	}

	return cell;
}

- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{

	if ([kind isEqualToString:PSTCollectionElementKindSectionHeader])
	{
		AnswersViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderID forIndexPath:indexPath];

		headerView.nameLabel.text = [_book attribute:@"name"];
		headerView.authorsLabel.text = [_book attribute:@"authors"];
		return headerView;
	}

	return nil;
}

- (void)dealloc
{
	fileAlreadyDownloading = nil;
	[operationQueue cancelAllOperations];
	operationQueue = nil;
}

@end