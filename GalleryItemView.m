//
//  GalleryItemView.m
//  tube
//
//  Created by Alexey Starovoitov on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryItemView.h"

@implementation GalleryItemView

@synthesize imageView;
@synthesize itemID;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)centerImage {
    self.imageView.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
}

- (void)setOriginalImageSize:(CGSize)_imageSize {
    imageSize = _imageSize;
}

- (CGSize)originalImageSize {
    return imageSize;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate showFullscreenItemWithID:itemID];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
