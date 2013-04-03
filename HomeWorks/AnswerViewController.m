//
// Created by bsideup on 4/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AnswerViewController.h"
#import "AFNetworking.h"


@interface AnswerViewController () <QLPreviewControllerDataSource, NSURLConnectionDelegate>
@end

@implementation AnswerViewController {
    UIBarStyle oldBarStyle;
    UIStatusBarStyle oldStatusBarStyle;
    NSMutableData *receivedData;

    NSString *currentURL;

    NSURL *fileURL;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index1 {
    return fileURL;
}

- (id)initWithURL:(NSString *)url {
    if(self = [super init]) {
        self.dataSource = self;
        currentURL = url;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:currentURL]
                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                             timeoutInterval:60*60*24*365*10];

        [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

        self.navigationItem.rightBarButtonItem = nil;
    }
    return self;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    receivedData = [NSMutableData data];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString: currentURL.lastPathComponent]];
    [receivedData writeToURL:fileURL atomically:YES];

    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    oldBarStyle = self.navigationController.navigationBar.barStyle;
    oldStatusBarStyle =[UIApplication sharedApplication].statusBarStyle;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationController.navigationBar.barStyle = oldBarStyle;
    [UIApplication sharedApplication].statusBarStyle = oldStatusBarStyle;
}

-(void)onTap
{
    if([self.navigationController isNavigationBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES  withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}


@end