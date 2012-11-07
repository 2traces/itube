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
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollPhotos;
@property (nonatomic, retain) IBOutlet UIButton *buttonCategories;
@property (nonatomic, assign) id<NavigationDelegate> navigationDelegate;

- (IBAction)showCategories:(id)sender;

@end
