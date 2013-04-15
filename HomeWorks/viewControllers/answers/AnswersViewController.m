//
//  AnswersViewController.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "AnswersViewController.h"
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

	NSArray *answers;

	UIAlertView *errorAlertView;
}

- (IBAction)tlDismissMe:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item >= answers.count)
	{
		return;
	}

	if (!purchased && indexPath.item > 1)
	{
		[self buy];
		return;
	}

	QLPreviewController *previewController = [[QLPreviewController alloc] init];
	previewController.dataSource = self;
	previewController.currentPreviewItemIndex = indexPath.item;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[self presentModalViewController:previewController animated:YES];
	}
	else
	{
		UINavigationController *navigationControllerForPreview = [[UINavigationController alloc] initWithRootViewController:previewController];

		previewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																										   target:navigationControllerForPreview
																										   action:@selector(dismissModalViewControllerAnimated:)];
		navigationControllerForPreview.navigationBar.barStyle = UIBarStyleBlack;
		navigationControllerForPreview.toolbar.barStyle = UIBarStyleBlack;

		[self presentModalViewController:navigationControllerForPreview animated:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (IBAction)buy
{
	NSLog(@"buying %@", featureId);
	DejalActivityView *activityView = [DejalBezelActivityView activityViewForView:self.view.window withLabel:@""];

	[[MKStoreManager sharedManager] buyFeature:featureId onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
	{
		[DejalBezelActivityView removeView];
		if(errorAlertView) {
			[errorAlertView dismissWithClickedButtonIndex:0 animated:NO];
			errorAlertView = nil;
		}
		purchased = YES;
		self.navigationItem.rightBarButtonItem = nil;
		[self.collectionView reloadData];
	}                              onCancelled:^
	{
		NSLog(@"canceled");
		[DejalBezelActivityView removeView];
	}];

	[self performSelector:@selector(removeActivityView:) withObject:activityView afterDelay:10];
}

- (void)removeActivityView:(DejalActivityView *)activityView
{
	if (activityView.superview != nil)
	{
		[activityView removeFromSuperview];
		errorAlertView = [[UIAlertView alloc]
				initWithTitle:@"Ошибка"
					  message:@"Внимание! Покупка не удалась и деньги не снялись. Попробуйте позднее."
					 delegate:nil cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
		[errorAlertView show];
	}
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return purchased ? answers.count : 2;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	__weak __typeof (&*controller) weakController = controller;

	RXMLElement *answer = [answers objectAtIndex:index];

	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [_book attribute:@"id"];
	NSString *answerFile = [answer attribute:@"file"];
	NSString *answerExt = [answer attribute:@"ext"];
	NSString *pageFilePath = [NSString stringWithFormat:self.pageFilePathStringFormat,
														termId,
														subjectId,
														bookId,
														answerFile,
														answerExt];

	if (![[NSFileManager defaultManager] fileExistsAtPath:pageFilePath] && [fileAlreadyDownloading valueForKey:pageFilePath] == nil)
	{
		[fileAlreadyDownloading setValue:@(YES) forKey:pageFilePath];
		NSString *urlAsString = [NSString stringWithFormat:self.pageURLStringFormat,
														   termId,
														   subjectId,
														   bookId,
														   answerFile,
														   answerExt];

		NSLog(@"starting downloading for %@", urlAsString);

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
	return [AnswerFileURL fileURLWithPath:pageFilePath previewTitle:[NSString stringWithFormat:@"%@", answerFile]];
}


- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	int numRows = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 6 : 4;
	NSUInteger answersCountByNumRows = answers.count % numRows;
	return (answersCountByNumRows == 0) ? answers.count : ((answers.count - answersCountByNumRows) + numRows);
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	answers = [_book children:@"answer"];

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

	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:121.0 / 255.0 green:166.0 / 255.0 blue:191.0 / 255.0 alpha:1.0]];
	[self.navigationController.navigationBar setTitleTextAttributes:
			@{
					UITextAttributeTextShadowColor : [UIColor blackColor],
					UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)]
			}];

	UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0)];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage
												  forBarMetrics:UIBarMetricsLandscapePhone];

	//self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)]];
	//self.collectionView.backgroundColor = [UIColor clearColor];

	self.collectionView.backgroundColor = [UIColor colorWithRed:222.0 / 255.0 green:225.0 / 255.0 blue:230.0 / 255.0 alpha:1.0];

	fileAlreadyDownloading = [NSMutableDictionary dictionary];
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];

}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	AnswerViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];

	if (indexPath.item >= answers.count)
	{
		cell.label.hidden = YES;
		cell.backgroundImage.hidden = YES;
	}
	else
	{
		if (purchased || (indexPath.item < 2))
		{
			cell.label.hidden = NO;
			cell.label.text = [NSString stringWithFormat:@"%@", [[answers objectAtIndex:indexPath.item] attribute:@"file"]];
			cell.backgroundImage.image = [UIImage imageNamed:@"element"];
		} else
		{
			cell.label.hidden = YES;
			cell.backgroundImage.image = [UIImage imageNamed:@"element-locked"];
		}
		cell.backgroundImage.hidden = NO;
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