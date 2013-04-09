//
//  NativeGallery.m
//  tube
//
//  Created by alex on 09.04.13.
//
//

#import "NativeGallery.h"
#import "ColorFactory.h"
#import <QuartzCore/QuartzCore.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

@implementation NativeGallery

@synthesize currentSlideNumber;
@synthesize slidesCount;
@synthesize photosExt;
@synthesize photosPrefix;

- (id)initWithFrame:(CGRect)frame withPrefix:(NSString*)prefix withExt:(NSString*)ext withSlidesCount:(int)count{
    self = [super initWithFrame:frame];
    if (self) {
        self.imagesArray = [NSMutableArray array];
        self.currentSlideNumber = 0;
        self.slidesCount = count;
        self.photosExt = ext;
        self.photosPrefix = prefix;
        self.backgroundColor = [ColorFactory lightGrayColor];
        for (int i = 0; i < self.slidesCount; i++) {
            [self.imagesArray addObject:[self loadSlideWithNumber:i]];
        }
        self.bgImageView = [[UIImageView alloc] initWithFrame:frame];
        self.bgImageView.image = [self.imagesArray objectAtIndex:0];
        self.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:self.bgImageView];
        [self loadThumbs];
    }
    return self;
}

- (void)loadThumbs{
    int offsetX, offsetY, thumbSize, padding;
    if (IS_IPAD) {
        offsetX = 50;
        offsetY = 50;
        thumbSize = 100;
        padding = 10;
    }else{
        offsetX = 50;
        offsetY = 50;
        thumbSize = 100;
        padding = 10;
    }
    for (int i = 0; i < self.slidesCount; i++) {
        int y = offsetY + i * (thumbSize+padding);
        UIImageView *thumb = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, y, thumbSize, thumbSize)];
        thumb.image = [self.imagesArray objectAtIndex:i];
        [thumb.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [thumb.layer setBorderWidth: 2.0];
        [self addSubview:thumb];
    }
}

- (void)dealloc{
    [self.photosExt release];
    [self.photosPrefix release];
    [self.imagesArray release];
    [self.bgImageView release];
    [super dealloc];
}

- (UIImage*)loadSlideWithNumber:(int)slideNumber{
    NSString *imagePath = [NSString stringWithFormat:@"%@%i%@", self.photosPrefix, slideNumber, self.photosExt];
    return [UIImage imageWithContentsOfFile:imagePath];
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
