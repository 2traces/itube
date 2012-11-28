//
//  PhotoViewerViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 28/11/12.
//
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@interface PhotoViewerViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView *scrollView;
    NSArray *photos;
    NSInteger currentPage;
}

- (id) initWithPlace:(MPlace*)place;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSArray *photos;

@end
