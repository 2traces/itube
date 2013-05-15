//
//  DownloadServer.m
//  tube
//
//  Created by Sergey Mingalev on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadServer.h"

@implementation DownloadServer

@synthesize connection;
@synthesize responseData;
@synthesize listener;
@synthesize prodID;

NSString *regularMainUrl = @"http://findmystation.info";

- (id)init
{
    if (self = [super init]) { 
        
        NSMutableData *aData = [[NSMutableData alloc] init];
        self.responseData=aData;
        [aData release];
    }
    
    return self;
}

-(NSURL*)makeFullURL:(NSString*)suburl withMainUrl:(NSString*)mainUrl
{
    NSString *preurl = [NSString stringWithFormat:@"%@/%@",mainUrl,suburl];
    NSURL *url = [[[NSURL alloc] initWithString:preurl] autorelease];
    return url;
}

- (void)loadFileAtURL:(NSString *)url withMainURL:(NSString*)mainUrl {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self makeFullURL:url withMainUrl:mainUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] autorelease];
    [request release];
    request=nil;
}

-(void)loadFileAtURL:(NSString *)suburl {
    [self loadFileAtURL:suburl withMainURL:regularMainUrl];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedBytes = [response expectedContentLength];
    [listener startDownloading:prodID];
}

-(void)connection:(NSURLConnection *)fconnection didReceiveData:(NSData *)data {
    if (fconnection==self.connection) {
        [responseData appendData:data];
        [listener downloadedBytes:(long)[responseData length] outOfBytes:expectedBytes prodID:prodID];
    }
}

-(void)connection:(NSURLConnection *)fconnection didFailWithError:(NSError *)error {
    if (fconnection==self.connection) {
        [listener downloadFailed:self];
        self.responseData=nil;
        self.connection=nil;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)fconnection {
    if (fconnection==self.connection) {
        [listener downloadDone:self.responseData prodID:(NSString*)self.prodID server:self]; 
        self.responseData=nil;
        self.connection=nil;
    }    
}

-(void)cancel
{
    [self.connection cancel];
    self.connection=nil;
}

-(void)dealloc {
    
    NSLog(@"server dealloc");
    self.listener=nil;
    [prodID release];
	[connection release];
	[responseData release];
	[super dealloc];
}

@end
