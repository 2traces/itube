//
//  GalleryView.h
//  tube
//
//  Created by Alexey Starovoitov on 8/1/12.
//
//

#import <UIKit/UIKit.h>
#import "GalleryViewController.h"

@interface GalleryView : UIView {
    GalleryViewController *galleryViewController;
}

@property (nonatomic, retain) IBOutlet GalleryViewController *galleryViewController;

@end
