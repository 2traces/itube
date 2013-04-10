//
//  NativeGallery.h
//  tube
//
//  Created by alex on 09.04.13.
//
//

#import <UIKit/UIKit.h>
#import "tubeAppDelegate.h"

@interface NativeGallery : UIView

@property (retain) NSMutableArray *imagesArray;
@property (retain) UIImageView *bgImageView;
@property (retain) NSSet *pictures;

- (id)initWithFrame:(CGRect)frame withGalleryPictures:(NSSet*)pictures withAppDelegate:(tubeAppDelegate*)appDelegate;


@end
