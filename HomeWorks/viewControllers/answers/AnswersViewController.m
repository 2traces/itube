//
//  AnswersViewController.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperation.h>
#import "AnswersViewController.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "AnswersViewHeader.h"
#import "MKStoreManager.h"
#import "DejalActivityView.h"
#import "AnswerFileURL.h"
#import "AnswerViewCell.h"
#import "ConcreateAnswerViewController.h"
#import "PurchasesService.h"

NSString *kCellID = @"answerCell";
NSString *kLockedCellID = @"lockedAnswerCell";
NSString *kEmptyCellID = @"emptyAnswerCell";
NSString *kHeaderID = @"collectionHeader";
NSString *kFooterID = @"collectionFooter";

@interface AnswersViewController ()
@property(nonatomic) BOOL purchased;
@end

@implementation AnswersViewController
{
	NSArray *answers;

	NSOperationQueue *operationQueue;
	DejalActivityView *activityView;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	answers = [_book children:@"a"];

	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [_book attribute:@"id"];

	self.purchased = [self.purchaseService isPurchasedTermId:termId  withSubjectId:subjectId withBookId:bookId];

	self.collectionView.allowsMultipleSelection = NO;

	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:121.0 / 255.0 green:166.0 / 255.0 blue:191.0 / 255.0 alpha:1.0]];
	[self.navigationController.navigationBar setTitleTextAttributes:
			@{
					UITextAttributeTextShadowColor : [UIColor blackColor],
					UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)]
			}];

	UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0)];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsLandscapePhone];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		self.collectionView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackgroundIpad"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 768.0, 0.0, 0.0)]];
	}
	else
	{
		self.collectionView.backgroundView  = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)]];

	}
	self.collectionView.backgroundColor = [UIColor clearColor];

	operationQueue = [[NSOperationQueue alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[operationQueue cancelAllOperations];
}

- (void)setPurchased:(BOOL)value
{
	_purchased = value;
	if (value)
	{
		[self updateAllFilesDownloadedStatus];
	}
	else
	{
		self.navigationItem.rightBarButtonItem.title = @"Купить все за 0.99$";
	}
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

	if (!self.purchased && indexPath.item > 1)
	{
		[self purchase];
		return;
	}

	ConcreateAnswerViewController *previewController = [[ConcreateAnswerViewController alloc] initWithTerm:_term subject:_subject book:_book purchased:_purchased];
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

- (IBAction)rightBarButtonItemPresses
{
	if (!self.purchased)
	{
		[self purchase];
	}
	else
	{
		[self downloadAll];
	}
}

- (BOOL)updateAllFilesDownloadedStatus
{
	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [_book attribute:@"id"];
	NSString *answerExt = [_book attribute:@"ext"];

	for (RXMLElement *answer in answers)
	{
		NSString *answerFile = answer.text;
		NSString *pageFilePath = [NSString stringWithFormat:self.pageFilePathStringFormat,
															termId,
															subjectId,
															bookId,
															answerFile,
															answerExt];

		if (![[NSFileManager defaultManager] fileExistsAtPath:pageFilePath])
		{
			self.navigationItem.rightBarButtonItem.title = @"Загрузить все ответы";
			return NO;
		}
	}

	if (self.purchased)
	{
		self.navigationItem.rightBarButtonItem = nil;
	}

	return YES;
}

- (void)purchase
{
	NSLog(@"buying");
	activityView = [DejalBezelActivityView activityViewForView:self.view.window withLabel:@""];

	[self.purchaseService purchaseMonthlySubscriptionWithComplete:^()
	{
		[activityView removeFromSuperview];
		self.purchased = YES;
		[self.collectionView reloadData];
	} andError:^()
	{
		[self removeActivityView:activityView];
	}];

	[self performSelector:@selector(removeActivityView:) withObject:activityView afterDelay:5];
}

- (void)downloadAll
{
	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [_book attribute:@"id"];

	__weak __typeof (&*self) weakSelf = self;

	__block int succesfullyDownloaded = 0;

	void (^successOrFailure)() = ^
	{
		activityView.activityLabel.text = [NSString stringWithFormat:@"Загружено %d из %d",
																	 succesfullyDownloaded,
																	 answers.count];

		if (operationQueue.operationCount == 0)
		{
			[DejalBezelActivityView removeView];
			[weakSelf updateAllFilesDownloadedStatus];
			[weakSelf.collectionView reloadData];
		}
	};

	[operationQueue cancelAllOperations];
	[operationQueue setSuspended:YES];
	NSString *answerExt = [_book attribute:@"ext"];
	for (RXMLElement *answer in answers)
	{
		NSString *answerFile = answer.text;
		NSString *pageFilePath = [NSString stringWithFormat:self.pageFilePathStringFormat,
															termId,
															subjectId,
															bookId,
															answerFile,
															answerExt];

		if (![[NSFileManager defaultManager] fileExistsAtPath:pageFilePath])
		{
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:self.pageURLStringFormat,
																												 termId,
																												 subjectId,
																												 bookId,
																												 answerFile,
																												 answerExt]]];

			AFHTTPRequestOperation *catalogDownloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
			[catalogDownloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
			{
				[operation.responseData writeToFile:pageFilePath atomically:YES];
				succesfullyDownloaded++;
				successOrFailure();

			}                                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
			{
				successOrFailure();
			}];

			[operationQueue addOperation:catalogDownloadOperation];
		}
		else
		{
			succesfullyDownloaded++;
		}
	}
	if (operationQueue.operationCount > 0)
	{
		activityView = [DejalBezelActivityView activityViewForView:self.view withLabel:@"" width:200];
		successOrFailure();
	}
	[operationQueue setSuspended:NO];
}

- (void)removeActivityView:(DejalActivityView *)activityViewToRemove
{
	if (activityViewToRemove.superview != nil)
	{
		[activityViewToRemove removeFromSuperview];
		[[[UIAlertView alloc]
				initWithTitle:@"Ошибка"
					  message:@"Внимание! Покупка не удалась и деньги не снялись. Попробуйте позднее."
					 delegate:nil cancelButtonTitle:@"OK"
			otherButtonTitles:nil] show];
	}
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

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	AnswerViewCell *cell;
	if (indexPath.item >= answers.count)
	{
		return [cv dequeueReusableCellWithReuseIdentifier:kEmptyCellID forIndexPath:indexPath];
	}
	else if (indexPath.item < 2 || self.purchased)
	{
		cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
		cell.label.text = [NSString stringWithFormat:@"%@", [[answers objectAtIndex:indexPath.item] text]];
		return cell;
	}
	else
	{
		return [cv dequeueReusableCellWithReuseIdentifier:kLockedCellID forIndexPath:indexPath];
	}
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
	}
	else if ([kind isEqualToString:PSTCollectionElementKindSectionFooter])
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
	[operationQueue cancelAllOperations];
	operationQueue = nil;
}

@end