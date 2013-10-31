//
// Created by Sergey Egorov on 4/17/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RaptureXML/RXMLElement.h"
#import "MKStoreKit/MKStoreManager.h"
#import "MKStoreManager+customPurchases.h"
#import "ConcreateAnswerViewController.h"
#import "NSObject+homeWorksServiceLocator.h"
#import "AnswerFileURL.h"
#import "AFHTTPRequestOperation.h"


@interface ConcreateAnswerViewController () <QLPreviewControllerDataSource>
@end

@implementation ConcreateAnswerViewController
{
	BOOL purchased;
	NSArray *answers;

	NSMutableDictionary *fileAlreadyDownloading;
	NSOperationQueue *operationQueue;
}


- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    
	RXMLElement *answer = [answers objectAtIndex:index];
    
	NSString *termId = [_term attribute:@"id"];
	NSString *subjectId = [_subject attribute:@"id"];
	NSString *bookId = [_book attribute:@"id"];
	NSString *answerExt = [answer attribute:@"ext"];
    if (!answerExt || ![answerExt length]) {
        answerExt = [_book attribute:@"ext"];
    }
    //    else {
    //        NSLog(@"New extenstion implemented!");
    //    }
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
             
             [self addSkipBackupAttributeToItemAtPath:pageFilePath];
             
             //             if (ABS(weakController.currentPreviewItemIndex - index) < 1)
             if (weakController.currentPreviewItemIndex == index || weakController.currentPreviewItemIndex + 1 == index)
             {
                 [weakController refreshCurrentPreviewItem];
                 //[weakController reloadData];
                 //                 NSLog(@"Current preview index is %i and we've just downloaded %i, so... Refreshing!", weakController.currentPreviewItemIndex, index);
                 
             }
             else {
                 //                 NSLog(@"Current preview index is %i and we've just downloaded %i, so... Not refreshing.", weakController.currentPreviewItemIndex, index);
             }
             
         }                                               failure:nil];
        
		[operationQueue addOperation:catalogDownloadOperation];
	}
	return [AnswerFileURL fileURLWithPath:pageFilePath previewTitle:[NSString stringWithFormat:@"%@", answerFile]];
}


-(void)viewDidLoad
{
	[super viewDidLoad];

	answers = [_book children:@"a"];


#ifdef HW_PRO
	purchased = YES;
#else
    NSString *featureId = [NSString stringWithFormat:self.bookIAPStringFormat,
                           [_term attribute:@"id"],
                           [_subject attribute:@"id"],
                           [_book attribute:@"id"]];

    purchased = [MKStoreManager isBookAlreadyPurchased:featureId];
#endif
	self.dataSource = self;

	fileAlreadyDownloading = [NSMutableDictionary dictionary];
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return purchased ? answers.count : 2;
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

- (void)dealloc
{
	fileAlreadyDownloading = nil;
	[operationQueue cancelAllOperations];
	operationQueue = nil;
}

@end