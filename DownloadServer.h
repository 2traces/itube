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
    NSString *mapName;
}

@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, assign) id <DownloadServerListener> listener;
@property(nonatomic, retain) NSString *mapName;

-(void)loadFileAtURL:(NSString*)url;

@end

@protocol DownloadServerListener

-(void)downloadDone:(NSMutableData*)data mapName:(NSString*)mapName;

@end
