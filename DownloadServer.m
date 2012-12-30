//
//  DownloadServer.m
//  tube
//
//  Created by sergey on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadServer.h"

@implementation DownloadServer

@synthesize connection;
@synthesize responseData;
@synthesize listener;
@synthesize prodID;

NSString *mainurl = @"http://x-provocation.com/maps";

- (id)init
{
    if (self = [super init]) { 
        
        NSMutableData *aData = [[NSMutableData alloc] init];
        self.responseData=aData;
        [aData release];
    }
    
    return self;
}

-(NSURL*)makeFullURL:(NSString*)suburl
{
    NSString *preurl = [NSString stringWithFormat:@"%@/%@",mainurl,suburl];
    if ([preurl isEqualToString:@"http://x-provocation.com/maps/com.zuev.hiddencities.paris.plist"]) {
        preurl = @"http://findmystation.info/com.zuev.highlights.paris.plist";
    }
    
    
    
    NSURL *url = [[[NSURL alloc] initWithString:preurl] autorelease];
    return url;
}

-(void)loadFileAtURL:(NSString *)suburl
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self makeFullURL:suburl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] autorelease];
    [request release];
    request=nil;    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedBytes = [response expectedContentLength];
    [listener startDownloading:prodID];
}

-(void)connection:(NSURLConnection *)fconnection didReceiveData:(NSData *)data {
    if (fconnection==self.connection) {
        [responseData appendData:data];
        float part = (float)[responseData length]/(float)expectedBytes;
        [listener downloadedBytes:part prodID:prodID];
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
