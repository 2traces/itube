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
#import "IndexedImageView.h"

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
        self.backgroundColor = [UIColor blackColor];
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
    int offsetX, offsetY, thumbSize, padding, borderWidth, cornerRadius;
    if (IS_IPAD) {
        offsetX = 50;
        offsetY = 50;
        thumbSize = 100;
        padding = 10;
        borderWidth = 5;
        cornerRadius = 10;
    }else{
        offsetX = 25;
        offsetY = 40;
        thumbSize = 50;
        padding = 5;
        borderWidth = 2;
        cornerRadius = 5;
    }
    for (int i = 0; i < self.slidesCount; i++) {
        int y = offsetY + i * (thumbSize+padding);
        IndexedImageView *thumb = [[IndexedImageView alloc] initWithFrame:CGRectMake(offsetX, y, thumbSize, thumbSize)];
        thumb.image = [self.imagesArray objectAtIndex:i];
        thumb.index = i;
        thumb.userInteractionEnabled = YES;
        [thumb addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbTapped:)]];
        thumb.layer.backgroundColor = [[UIColor clearColor] CGColor];
        [thumb.layer setBorderColor: [[ColorFactory lightGrayColor] CGColor]];
        [thumb.layer setBorderWidth: borderWidth];
        thumb.layer.cornerRadius = cornerRadius;
        [thumb.layer setMasksToBounds:YES];
        thumb.clipsToBounds = YES;
        thumb.backgroundColor = [UIColor clearColor];
        [self addSubview:thumb];
    }
}

- (void)thumbTapped:(UITapGestureRecognizer*)recognizer{
    IndexedImageView *thumb = (IndexedImageView*)recognizer.view;
    self.bgImageView.image = [self.imagesArray objectAtIndex:thumb.index];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [self.bgImageView.layer addAnimation:transition forKey:nil];
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
