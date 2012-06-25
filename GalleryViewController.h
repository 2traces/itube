//
//  GalleryViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UIViewController {
    UIScrollView *scrollView;
    UILabel *label;
    NSArray *images;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *label;

@end
