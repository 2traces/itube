//
//  Server.m
//  iPif
//
//  Created by SergeyM on 30/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Server.h"
#import "XMLParser.h"
#import "tubeAppDelegate.h"

@implementation Server

@synthesize connection;
@synthesize responseData;
@synthesize listener;

NSString *url = @"http://paris.metro.dim0xff.com/cgi-bin/search.pl";

- (id)init
{
    if (self = [super init]) { 
        
        NSMutableData *aData = [[NSMutableData alloc] init];
        self.responseData=aData;
        [aData release];
    }
    
    return self;
}

-(NSMutableString *) listToString:(NSArray*)stationList
{
    NSMutableString *request = [[NSMutableString alloc] initWithString:@""];
    
    for (NSString *stationName in stationList) {
        
        NSString *tempString;
        
        if ([request isEqual:@""]) {
            tempString =  [[NSString alloc] initWithFormat:@"search=%@",stationName];
        } else {
            tempString = [[NSString alloc] initWithFormat:@"&search=%@",stationName];
        }
        
        [request appendString:tempString];
        [tempString release];
        
    }
    
    return [request autorelease];
}

-(void) sendRequestStationList:(NSArray *)stationList
{
    NSMutableString *requestString = [self listToString:stationList];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														 cachePolicy:NSURLRequestUseProtocolCachePolicy
													 timeoutInterval:20.0];
	[request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
	NSString *postBody = [NSString stringWithFormat:@"%@",requestString,nil];
    
	[request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
	
	self.connection=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
	if (connection) {
		NSLog(@"Server::sendRequest");
		[connection start];
	} else {
		NSLog(@"Server::sendRequest START ERROR");
		if (listener) [listener serverDone:nil];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
//    NSLog(@"%@",data);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Server::sendRequest FAIL - %@", error);
    
    //	if (listener) [listener serverDone:nil];
    self.connection = nil; 
}

-(void)connectionDidFinishLoading:(NSURLConnection *)aconnection {

	NSLog(@"Server::sendRequest DONE");
    NSLog(@"Response:\n%@\n\n", [self responseXml]);
	
    XMLParser *parseOperation = [[XMLParser alloc] initWithData:[self responseData]];  
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate]; 
    
    [appDelegate.parseQueue addOperation:parseOperation];
    [parseOperation release];   
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseComplete:)
                                                 name:kParseComplete
                                               object:nil];
    
    self.responseData=nil;
    self.connection=nil;
}

-(NSString*)responseXml {
    
	if (responseData) {
		NSString* xml = [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease];
		return xml;
	} else {
		return nil;
	}
}

-(void)parseComplete:(NSNotification*)note
{
    NSLog(@"%@",[note object]);
    [listener serverDone:(NSMutableDictionary*)[note object]];    
}


-(void)dealloc {
    
    NSLog(@"server dealloc");
    self.listener=nil;
	[connection release];
	[responseData release];
	[super dealloc];
}

@end
