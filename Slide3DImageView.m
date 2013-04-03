//
//  Slide3DImageView.m
//  tube
//
//  Created by alex on 22.03.13.
//
//

#import "Slide3DImageView.h"

#define PAN_THRESHOLD 20


@implementation Slide3DImageView

@synthesize panGR;
@synthesize currentSlideNumber;
@synthesize slidesCount;
@synthesize lastTranslation;
@synthesize photosExt;
@synthesize photosPrefix;

- (id)initWithImage:(UIImage *)image withPrefix:(NSString*)prefix withExt:(NSString*)ext withSlidesCount:(int)count{
    self = [super initWithImage:image];
    if (self) {
        self.currentSlideNumber = 0;
        self.slidesCount = count;
        self.lastTranslation = 0;
        self.photosExt = ext;
        self.photosPrefix = prefix;
        self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:self.panGR];
    }
    return self;
}

- (void) handleRotation:(UIPanGestureRecognizer*)recognizer{
    CGPoint translation = [recognizer translationInView:self];
    int delta = round((translation.x - self.lastTranslation) / PAN_THRESHOLD);
    if (delta < 0){
        self.currentSlideNumber -= 1;
        if (self.currentSlideNumber < 0) {
            self.currentSlideNumber = self.slidesCount - 1;
        }
        self.lastTranslation = round(translation.x);
        [self loadSlideWithNumber:self.currentSlideNumber];
    }else{
        if(delta > 0){
            self.currentSlideNumber += 1;
            if (self.currentSlideNumber >= self.slidesCount) {
                self.currentSlideNumber = 0;
            }
            self.lastTranslation = round(translation.x);
            [self loadSlideWithNumber:self.currentSlideNumber];
        }
    }
}

- (void)loadSlideWithNumber:(int)slideNumber{
    NSString *imagePath = [NSString stringWithFormat:@"%@%i%@", self.photosPrefix, self.currentSlideNumber, self.photosExt];
    UIImage *loadedImage = [UIImage imageWithContentsOfFile:imagePath];
    self.image = loadedImage;
}

- (void) dealloc{
    [self.panGR release];
    self.photosExt = nil;
    self.photosPrefix = nil;
    [super dealloc];
}

@end
