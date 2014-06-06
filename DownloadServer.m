//
//  DownloadServer.m
//  tube
//
//  Created by sergey on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadServer.h"

@interface DownloadServer ()

@property (nonatomic, retain) NSFileHandle *file;

@end

@implementation DownloadServer {
    long counter;
}

@synthesize connection;
@synthesize responseData;
@synthesize listener;
@synthesize prodID, filename, file;

NSString *mainurl = @"http://parismetromaps.info/maps";

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
//    if ([preurl isEqualToString:@"http://parismetromaps.info/maps/com.zuev.hiddencities.paris.plist"]) {
//        preurl = @"http://findmystation.info/com.zuev.highlights.paris.plist";
//        //preurl = @"http://dl.dropbox.com/u/16378090/maps.plist";
//    }
//    if ([preurl isEqualToString:@"http://parismetromaps.info/maps/paris/paris.zip"]) {
//        preurl = @"http://dl.dropbox.com/u/16378090/paris.zip";
//        //preurl = @"http://dl.dropbox.com/u/16378090/maps.plist";
//    }
    
    
    NSURL *url = [[[NSURL alloc] initWithString:preurl] autorelease];
    return url;
}

-(void)loadFileAtURL:(NSString *)suburl
{
    [self loadFileAtFullURL:[self makeFullURL:suburl]];
}

-(void)loadFileAtFullURL:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] autorelease];
    [request release];
    request=nil;
}

-(void)loadFileAtFullURL:(NSURL *)url toFile:(NSString *)fileName
{
    filename = [fileName retain];
    NSError *err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filename error:&err];
    if(err) {
        NSLog(@"Can't remove file %@\nError: %@", filename, err);
    }
    [self loadFileAtFullURL:url];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedBytes = [response expectedContentLength];
    [listener startDownloading:prodID];
}

-(void)connection:(NSURLConnection *)fconnection didReceiveData:(NSData *)data {
    @autoreleasepool {
        if (fconnection==self.connection) {
            counter += [data length];
            if(filename) {
                if(!file) {
                    [[NSFileManager defaultManager] createFileAtPath:filename contents:data attributes:nil];
                    file = [[NSFileHandle fileHandleForWritingAtPath:filename] retain];
                    [file seekToEndOfFile];
                } else {
                    [file writeData:data];
                }
            } else {
                [responseData appendData:data];
            }
            [listener downloadedBytes:counter outOfBytes:(long)expectedBytes prodID:prodID];
        }
    }
}

-(void)connection:(NSURLConnection *)fconnection didFailWithError:(NSError *)error {
    if (fconnection==self.connection) {
        [listener downloadFailed:self];
        self.responseData=nil;
        self.connection=nil;
        if(file) {
            [file closeFile];
            [file release];
            file = nil;
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)fconnection {
    if (fconnection==self.connection) {
        [listener downloadDone:self.responseData prodID:(NSString*)self.prodID server:self]; 
        self.responseData=nil;
        self.connection=nil;
        if(file) {
            [file closeFile];
            [file release];
            file = nil;
        }
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
    file = nil;
    [prodID release];
	[connection release];
	[responseData release];
    [filename release];
    [file release];
	[super dealloc];
}

@end
