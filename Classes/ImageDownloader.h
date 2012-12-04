//
//  ImageDownloader.h
//  tube
//
//  Created by Sergey Mingalev on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject
{
    id <ImageDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSString *imageName;
    NSString *imageURLString;
}

@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *imageURLString;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol ImageDownloaderDelegate 

- (void)appImageDidLoad;

@end