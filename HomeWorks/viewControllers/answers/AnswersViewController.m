//
//  AnswersViewController.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import "AFNetworking/AFHTTPRequestOperation.h"
#import "AnswersViewController.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "AnswersViewHeader.h"
#import "DejalActivityView.h"
#import "AnswerFileURL.h"
#import "AnswerViewCell.h"
#import "ConcreateAnswerViewController.h"
#import "PurchasesService.h"
#import "UIViewController+tlDismissMe.h"
#import "BooksService.h"
#import "BuyViewController.h"

NSString *kCellID = @"answerCell";
NSString *kLockedCellID = @"lockedAnswerCell";
NSString *kEmptyCellID = @"emptyAnswerCell";
NSString *kHeaderID = @"collectionHeader";
NSString *kFooterID = @"collectionFooter";

@interface AnswersViewController () <BuyViewControllerDelegate>
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

	[self buyControllerDidFinish:NO];

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

- (void)buyControllerDidFinish:(BOOL)success
{
	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [_book attribute:@"id"];

	self.purchased = [self.purchaseService isPurchasedTermId:termId  withSubjectId:subjectId withBookId:bookId];
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
		self.navigationItem.rightBarButtonItem.title = @"посмотреть все ответы";
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item >= answers.count)
	{
		return;
	}

	if (!self.purchased && indexPath.item > 1)
	{
		return;
	}

	ConcreateAnswerViewController *previewController = [[ConcreateAnswerViewController alloc] initWithTerm:_term subject:_subject book:_book purchased:_purchased];
	previewController.currentPreviewItemIndex = indexPath.item;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		previewController.modalPresentationStyle = UIModalPresentationFullScreen;
		[self presentViewController:previewController animated:YES completion:nil];
	}
	else
	{
		UINavigationController *navigationControllerForPreview = [[UINavigationController alloc] initWithRootViewController:previewController];

		previewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																										   target:navigationControllerForPreview
																										   action:@selector(tlDismissMe:)];
		navigationControllerForPreview.navigationBar.barStyle = UIBarStyleBlack;
		navigationControllerForPreview.toolbar.barStyle = UIBarStyleBlack;
		navigationControllerForPreview.modalPresentationStyle = UIModalPresentationFullScreen;

		[self presentViewController:navigationControllerForPreview animated:YES completion:nil];
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
		UINavigationController *buyNagivationController = [self.storyboard instantiateViewControllerWithIdentifier:@"buy"];
		BuyViewController *buyViewController = [buyNagivationController topViewController];

		buyViewController.delegate = self;
		[self presentViewController:buyNagivationController animated:YES completion:nil];
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

	if(![self.booksService isAvailableOfflineWithTermId:termId withSubjectId:subjectId withBookId:bookId])
	{
		self.navigationItem.rightBarButtonItem.title = @"Загрузить все ответы";
		return NO;
	}

	if (self.purchased)
	{
		self.navigationItem.rightBarButtonItem = nil;
	}

	return YES;
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
			NSString *offlineFilePath = [NSString stringWithFormat:self.offlineFilePathStringFormat,
																termId,
																subjectId,
																bookId];
			[[NSData data] writeToFile:offlineFilePath atomically:NO];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	int numRows = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 6 : 4;
	NSUInteger answersCountByNumRows = answers.count % numRows;
	return (answersCountByNumRows == 0) ? answers.count : ((answers.count - answersCountByNumRows) + numRows);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if ([kind isEqualToString:UICollectionElementKindSectionHeader])
	{
		AnswersViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderID forIndexPath:indexPath];

		[headerView.backgroundImage setImage:[[UIImage imageNamed:@"table_button_top"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
		headerView.nameLabel.text = [_book attribute:@"name"];
		headerView.authorsLabel.text = [_book attribute:@"authors"];
		return headerView;
	}
	else if ([kind isEqualToString:UICollectionElementKindSectionFooter])
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