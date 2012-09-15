//
//  StatusViewController.h
//  tube
//
//  Created by sergey on 04.09.12.
//
//

#import <UIKit/UIKit.h>
#import "StatusDownloader.h"
#import "DownloadServer.h"

@interface StatusViewController : UIViewController <UIGestureRecognizerDelegate,StatusDownloaderDelegate,DownloadServerListener>

@property (nonatomic,retain) UISwipeGestureRecognizer *swipeRecognizerU;
@property (nonatomic,retain) UISwipeGestureRecognizer *swipeRecognizerD;
@property (nonatomic,retain) UITextView *textView;
@property (nonatomic,readonly) BOOL isShown;
@property (nonatomic,retain) NSString *infoURL;
@property (nonatomic,retain) UIImageView *shadowView;
@property (nonatomic,assign) BOOL isNewMapAvailable;
@property (nonatomic,retain) NSMutableArray *servers;

-(void)recieveStatusInfo;
-(void)refreshStatusInfo;
-(void)showInitialSizeView;
-(void)hideInitialSizeView;
-(void)showFullSizeView;
-(void)hideFullSizeView;

@end
