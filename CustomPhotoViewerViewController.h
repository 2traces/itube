//
//  CustomPhotoViewerViewController.h
//  tube
//
//  Created by Nomad on 28/11/12.
//
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@interface CustomPhotoViewerViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate> {
    UIScrollView *scrollView;
    NSArray *photos;
    NSInteger currentPage;
}

- (id) initWithNames:(NSArray*)names;
- (id) initWithVideo:(NSString *)link;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSString *link;

@end
