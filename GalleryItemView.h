//
//  GalleryItemView.h
//  tube
//
//  Created by Alexey Starovoitov on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GalleryItemDelegate <NSObject>

- (void)showFullscreenItemWithID:(NSInteger)itemID;
- (void)showItemOnMapWithID:(NSInteger)itemID;
- (void)closeFullscreenItem;

@end

@interface GalleryItemView : UIView {
    NSInteger itemID;
    UIImageView *imageView;
    UIImageView *shadowView;
    CGSize imageSize;
    id<GalleryItemDelegate> delegate;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *shadowView;
@property (nonatomic, assign) NSInteger itemID;
@property (nonatomic, assign) id<GalleryItemDelegate> delegate;

- (void)centerImage;
- (void)setOriginalImageSize:(CGSize)_imageSize;
- (CGSize)originalImageSize;

@end
