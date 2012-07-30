//
//  GalleryViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryItemView.h"

@interface GalleryViewController : UIViewController <UIScrollViewDelegate, GalleryItemDelegate> {
    UIScrollView *scrollView;
    UILabel *label;
    NSArray *images;
    CGFloat currentPage;
    UIView *loadingView;
    NSInteger activePin;
    NSArray *galleryItems;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

@end
