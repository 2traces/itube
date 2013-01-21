//
//  StatusDownloader.h
//  tube
//
//  Created by Sergey Mingalev on 05.09.12.
//
//

#import <Foundation/Foundation.h>

@protocol StatusDownloaderDelegate;

@interface StatusDownloader : NSObject
{
    id <StatusDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSString *imageName;
    NSString *imageURLString;
}

@property (nonatomic, assign) id <StatusDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *imageURLString;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol StatusDownloaderDelegate

- (void)statusInfoDidLoad:(NSString*)info server:(StatusDownloader*)server;
-(void)connectionFailed:(StatusDownloader*)server;

@end