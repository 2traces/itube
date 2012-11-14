//
//  PhotosViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface PhotosViewController : UIViewController {
    UIScrollView *scrollPhotos;
    UIButton *buttonCategories;
    UIView *disappearingView;
    UIView *panelView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollPhotos;
@property (nonatomic, retain) IBOutlet UIButton *buttonCategories;
@property (nonatomic, retain) IBOutlet UIView *disappearingView;
@property (nonatomic, retain) IBOutlet UIView *panelView;
@property (nonatomic, assign) id<NavigationDelegate> navigationDelegate;

- (IBAction)showCategories:(id)sender;
- (IBAction)showHidePhotos:(id)sender;
- (IBAction)showBookmarks:(id)sender;

@end
