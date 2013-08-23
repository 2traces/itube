//
// Created by Sergey Egorov on 4/17/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RaptureXML/RXMLElement.h"
#import "ConcreateAnswerViewController.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "AnswerFileURL.h"
#import "AFHTTPRequestOperation.h"


@interface ConcreateAnswerViewController () <QLPreviewControllerDataSource>
@end

@implementation ConcreateAnswerViewController
{
	NSArray *answers;

	NSMutableDictionary *fileAlreadyDownloading;
	NSOperationQueue *operationQueue;
}

- (id)initWithTerm:(RXMLElement *)term subject:(RXMLElement *)subject book:(RXMLElement *)book purchased:(BOOL)purchased
{
	self = [super init];
	if (self)
	{
		self.term = term;
		self.subject = subject;
		self.book = book;
		self.purchased = purchased;
	}

	return self;
}

-(void)viewDidLoad
{
	[super viewDidLoad];

	answers = [_book children:@"a"];

	self.dataSource = self;

	fileAlreadyDownloading = [NSMutableDictionary dictionary];
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return _purchased ? answers.count : 2;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{

	RXMLElement *answer = [answers objectAtIndex:index];

	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [_book attribute:@"id"];
	NSString *answerExt = [_book attribute:@"ext"];
	NSString *answerFile = answer.text;
	NSString *pageFilePath = [NSString stringWithFormat:self.pageFilePathStringFormat,
														termId,
														subjectId,
														bookId,
														answerFile,
														answerExt];

	if (![[NSFileManager defaultManager] fileExistsAtPath:pageFilePath] && [fileAlreadyDownloading valueForKey:pageFilePath] == nil)
	{
		__weak __typeof (&*controller) weakController = controller;
		[fileAlreadyDownloading setObject:@(YES) forKey:pageFilePath];
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
			[operation.responseData writeToFile:pageFilePath atomically:NO];

			if (weakController.currentPreviewItemIndex == index)
			{
				[weakController refreshCurrentPreviewItem];
			}

		}                                               failure:nil];

		[operationQueue addOperation:catalogDownloadOperation];
	}
	return [AnswerFileURL fileURLWithPath:pageFilePath previewTitle:[NSString stringWithFormat:@"%@", answerFile]];
}

- (void)dealloc
{
	fileAlreadyDownloading = nil;
	[operationQueue cancelAllOperations];
	operationQueue = nil;
}

@end