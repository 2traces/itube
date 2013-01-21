//
//  ImageDownloader.m
//  tube
//
//  Created by Sergey Mingalev on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize imageName;
@synthesize imageURLString;

#pragma mark

- (void)dealloc
{
    [activeDownload release];
    [imageName release];
    [imageConnection cancel];
    [imageConnection release];
    [imageURLString release];
    
    [super dealloc];
}


- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSString *fullPath = [imageURLString stringByAppendingPathComponent:imageName];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:fullPath]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
    self.delegate=nil;
}

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
//{
//    if (redirectResponse) {
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)redirectResponse;
//        int statusCode = [httpResponse statusCode];
//        
//        if (redirectResponse && statusCode > 400)
//            NSLog(@"disable redirect!");
//            self.activeDownload = nil;
//            self.imageConnection = nil;
//            return nil;
//    } else {
//        return request;
//    }
//}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.activeDownload = nil;
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [cacheDir stringByAppendingPathComponent:imageName];

    if (self.activeDownload) {
        UIImage *image = [UIImage imageWithData:self.activeDownload];
        if (image) {
            [self.activeDownload writeToFile:path atomically:YES];
        }
    }
    
    self.activeDownload = nil;
    self.imageConnection = nil;
    
    [delegate appImageDidLoad];
}

@end
