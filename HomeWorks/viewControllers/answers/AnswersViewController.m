//
//  AnswersViewController.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "AnswersViewController.h"
#import "AnswerViewController.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "AnswersViewHeader.h"
#import "MKStoreManager.h"
#import "DejalActivityView.h"
#import "AFHTTPRequestOperation.h"
#import "AnswerFileURL.h"
#import "AnswerViewCell.h"

NSString *kCellID = @"answerCell";
NSString *kHeaderID = @"collectionHeader";
NSString *kFooterID = @"collectionFooter";

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

	if (indexPath.item >= [_book attributeAsInt:@"numPages"])
	{
		return;
	}

	AnswerViewController *previewController = [[AnswerViewController alloc] init];
	previewController.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	previewController.dataSource = self;
	previewController.currentPreviewItemIndex = indexPath.item;

	UINavigationController *navigationControllerForPreview = [[UINavigationController alloc] initWithRootViewController:previewController];

	previewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																									   target:navigationControllerForPreview
																									   action:@selector(dismissModalViewControllerAnimated:)];

	[self presentModalViewController:navigationControllerForPreview animated:YES];
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
	for (id object in controller.childViewControllers)
	{
		if ([object isKindOfClass:[UINavigationController class]])
		{
			UINavigationController *navController = object;
			navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		}
	}
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

		if (index == controller.currentPreviewItemIndex)
		{
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
	return ([_book attributeAsInt:@"numPages"] / 4 + 1) * 4;
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

	self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)]];
	self.collectionView.backgroundColor = [UIColor clearColor];

	fileAlreadyDownloading = [NSMutableDictionary dictionary];
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];

}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	AnswerViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];

	if (indexPath.item >= [_book attributeAsInt:@"numPages"])
	{
		cell.label.text = @"";
	}
	else
	{
		if (purchased || (indexPath.item < 2))
		{
			cell.label.text = [NSString stringWithFormat:@"%d", (indexPath.item + 1)];
			cell.backgroundImage.image = [UIImage imageNamed:@"element"];
		} else
		{
			cell.label.text = @"";
			cell.backgroundImage.image = [UIImage imageNamed:@"element-locked"];
		}
	}

	cell.backgroundColor = [UIColor colorWithRed:233.0 / 255.0 green:233.0 / 255.0 blue:233.0 / 255.0 alpha:1.0];

	return cell;
}

- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if ([kind isEqualToString:PSTCollectionElementKindSectionHeader])
	{
		AnswersViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderID forIndexPath:indexPath];

		[headerView.backgroundImage setImage:[[UIImage imageNamed:@"table_button_top"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		headerView.nameLabel.text = [_book attribute:@"name"];
		headerView.authorsLabel.text = [_book attribute:@"authors"];
		return headerView;
	} else if ([kind isEqualToString:PSTCollectionElementKindSectionFooter])
	{
		AnswersViewHeader *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kFooterID forIndexPath:indexPath];
		[footerView.backgroundImage setImage:[UIImage imageNamed:@"table_button_top"]];
		footerView.backgroundImage.transform = CGAffineTransformMakeRotation(M_PI);
		return footerView;
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