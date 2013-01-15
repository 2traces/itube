//
//  DownloadServer.h
//  tube
//
//  Created by sergey on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadServerListener;

@interface DownloadServer : NSObject {
    NSURLConnection *connection;
    NSMutableData *responseData;
    id <DownloadServerListener> listener;
    NSString *prodID;
    
    long expectedBytes;
}

@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, assign) id <DownloadServerListener> listener;
@property(nonatomic, retain) NSString *prodID;

-(void)loadFileAtURL:(NSString*)url;
-(void)cancel;

@end

@protocol DownloadServerListener

-(void)downloadDone:(NSMutableData*)data prodID:(NSString*)prodID server:(DownloadServer*)myid;
-(void)startDownloading:(NSString*)prodID;
-(void)downloadedBytes:(float)part prodID:(NSString*)prodID;
-(void)downloadedBytes:(long)part outOfBytes:(long)whole prodID:(NSString*)prodID;
-(void)downloadFailed:(DownloadServer*)myid;

@end
