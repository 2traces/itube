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

NSString *mainurl = @"http://astro-friends.net/itube";

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
    NSURL *url = [[[NSURL alloc] initWithString:preurl] autorelease];
    return url;
}

-(void)loadFileAtURL:(NSString *)suburl
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[self makeFullURL:suburl]];
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] autorelease];
    [request release];
    request=nil;    
}

-(void)connection:(NSURLConnection *)fconnection didReceiveData:(NSData *)data {
    if (fconnection==self.connection) {
        [responseData appendData:data];
    }
}

-(void)connection:(NSURLConnection *)fconnection didFailWithError:(NSError *)error {
    if (fconnection==self.connection) {
        self.responseData=nil;
        self.connection=nil;
    }
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)fconnection {
    if (fconnection==self.connection) {
        [listener downloadDone:self.responseData]; 
        self.responseData=nil;
        self.connection=nil;
    }    
}

-(void)dealloc {
    
    NSLog(@"server dealloc");
    self.listener=nil;
	[connection release];
	[responseData release];
	[super dealloc];
}

@end
