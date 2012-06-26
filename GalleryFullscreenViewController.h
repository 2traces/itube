//
//  GalleryFullscreenViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryItemView.h"

@interface GalleryFullscreenViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView *scrollView;
    UIImageView *imageView;
    id<GalleryItemDelegate> delegate;
    NSInteger itemID;
    NSString *itemName;
    UILabel *label;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title image:(UIImage*)image itemID:(NSInteger)itemId;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, assign) id<GalleryItemDelegate> delegate;
@property (nonatomic, assign) NSInteger itemID;

- (IBAction)goBack:(id)sender;
- (IBAction)showOnMap:(id)sender;

@end
