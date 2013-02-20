//
//  PhotoViewerViewController.h
//  tube
//
//  Created by Alexey on 28/11/12.
//
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@interface PhotoViewerViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView *scrollView;
    NSArray *photos;
    NSInteger currentPage;
}

- (id) initWithPlace:(MPlace*)place index:(NSInteger)index;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSArray *photos;


@end
