//
//  NativeGallery.m
//  tube
//
//  Created by alex on 09.04.13.
//
//

#import "NativeGallery.h"

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
        for (int i = 0; i < self.slidesCount; i++) {
            [self.imagesArray addObject:[self loadSlideWithNumber:i]];
        }
        self.bgImageView = [[UIImageView alloc] initWithFrame:frame];
        self.bgImageView.image = [self.imagesArray objectAtIndex:0];
        self.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:self.bgImageView];
    }
    return self;
}

- (void)dealloc{
    [self.photosExt release];
    [self.photosPrefix release];
    [self.imagesArray release];
    [self.bgImageView release];
    [super dealloc];
}

- (UIImage*)loadSlideWithNumber:(int)slideNumber{
    NSString *imagePath = [NSString stringWithFormat:@"%@%i%@", self.photosPrefix, self.currentSlideNumber, self.photosExt];
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
