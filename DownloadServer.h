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
}

@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, assign) id <DownloadServerListener> listener;

-(void)loadFileAtURL:(NSString*)url;

@end

@protocol DownloadServerListener

-(void)downloadDone:(NSMutableData*)data;

@end
