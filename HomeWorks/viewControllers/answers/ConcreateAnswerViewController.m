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
	__block NSString *pageFilePath = [NSString stringWithFormat:self.pageFilePathStringFormat,
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
             
         }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Failed to download item...");
         }];
        
		[operationQueue addOperation:catalogDownloadOperation];
	}
    NSURL *ans = [AnswerFileURL fileURLWithPath:pageFilePath previewTitle:[NSString stringWithFormat:@"%@", answerFile]];
    if ([[NSFileManager defaultManager] fileExistsAtPath: [ans path]]) {
        NSLog(@"Giving away existing file url.");
    }
    else {
        NSLog(@"Giving away missing file url.");
    }
	return ans;
}

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
    NSLog(@"Opening URL: %@", [url absoluteString]);
    return YES;
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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[self.navigationController navigationBar] setBarTintColor:[UIColor whiteColor]];
        
        
        UIImage *navigationBarBackgroundImage = [[UIImage imageNamed:@"bar_bg_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)];
        
        [self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"bar_shadow"];
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor grayColor], UITextAttributeTextColor,
          [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:16.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
        
        [[self.navigationController navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                           [UIColor grayColor], UITextAttributeTextColor, [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:16.0], UITextAttributeFont, nil]];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        }

        
    }
    else {
    
    }




    
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIToolbar *toolbar = self.navigationController.toolbar;
    toolbar.hidden = YES;
    [toolbar removeFromSuperview];
    [self.navigationController setToolbarHidden:YES animated:NO];
    NSArray *gr = self.view.gestureRecognizers;
    for (UIGestureRecognizer *g in gr) {
        if ([g isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:g];
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:16.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return _purchased ? answers.count : 2;
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