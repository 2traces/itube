//
//  NativeGallery.h
//  tube
//
//  Created by alex on 09.04.13.
//
//

#import <UIKit/UIKit.h>

@interface NativeGallery : UIView

@property int currentSlideNumber;
@property int slidesCount;
@property (retain) NSString *photosPrefix;
@property (retain) NSString *photosExt;
@property (retain) NSMutableArray *imagesArray;
@property (retain) UIImageView *bgImageView;

- (id)initWithFrame:(CGRect)frame withPrefix:(NSString*)prefix withExt:(NSString*)ext withSlidesCount:(int)count;


@end
