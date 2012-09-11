//
//  StatusDownloader.m
//  tube
//
//  Created by sergey on 05.09.12.
//
//

#import "StatusDownloader.h"

@implementation StatusDownloader

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
}

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
    NSString *text = [[[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding] autorelease];
    
    [delegate statusInfoDidLoad:text];
    
    self.activeDownload = nil;
    self.imageConnection = nil;
}

@end
