//
//  StatusViewController.h
//  tube
//
//  Created by sergey on 04.09.12.
//
//

#import <UIKit/UIKit.h>
#import "StatusDownloader.h"

@interface StatusViewController : UIViewController <UIGestureRecognizerDelegate,StatusDownloaderDelegate>

@property (nonatomic,retain) UISwipeGestureRecognizer *swipeRecognizerU;
@property (nonatomic,retain) UISwipeGestureRecognizer *swipeRecognizerD;
@property (nonatomic,retain) UITextView *textView;

-(void)recieveStatusInfo;

@end
