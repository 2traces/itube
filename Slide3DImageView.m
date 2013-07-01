//
//  Slide3DImageView.m
//  tube
//
//  Created by alex on 22.03.13.
//
//

#import "Slide3DImageView.h"
#import "LCUtil.h"

#define PAN_THRESHOLD 20


@implementation Slide3DImageView

@synthesize panGR = _panGR;
@synthesize tapGR = _tapGR;
@synthesize mainImageView = _mainImageView;
@synthesize currentSlideNumber;
@synthesize slidesCount;
@synthesize lastTranslation;
@synthesize photosExt;
@synthesize photosPrefix;

- (id)initWithImage:(UIImage *)image withFrame:(CGRect)frame withPrefix:(NSString*)prefix withExt:(NSString*)ext withSlidesCount:(int)count{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentSlideNumber = 0;
        self.slidesCount = count;
        self.lastTranslation = 0;
        self.photosExt = ext;
        self.photosPrefix = prefix;
        
        self.mainImageView = [[UIImageView alloc] initWithFrame:frame];
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.mainImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        self.mainImageView.image = image;
        [self addSubview:self.mainImageView];
        
        self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
        self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.mainImageView.userInteractionEnabled = YES;
        [self.mainImageView addGestureRecognizer:self.panGR];
        [self.mainImageView addGestureRecognizer:self.tapGR];
    }
    return self;
}

- (void) handleRotation:(UIPanGestureRecognizer*)recognizer{
    CGPoint translation = [recognizer translationInView:self.mainImageView];
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
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.lastTranslation = 0;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer{
    //nothing to do
}

- (void)loadSlideWithNumber:(int)slideNumber{
    NSString *imagePath = [LCUtil getLocalizedPath:[NSString stringWithFormat:@"%@%i%@", self.photosPrefix, self.currentSlideNumber, self.photosExt]];
    UIImage *loadedImage = [UIImage imageWithContentsOfFile:imagePath];
    self.mainImageView.image = loadedImage;
}

- (void) dealloc{
    [self.mainImageView removeGestureRecognizer:self.panGR];
    [_panGR release];
    
    [self.mainImageView removeGestureRecognizer:self.tapGR];
    [_tapGR release];
    
    [self.mainImageView removeFromSuperview];
    [_mainImageView release];
    
    self.photosExt = nil;
    self.photosPrefix = nil;
    [super dealloc];
}

@end
