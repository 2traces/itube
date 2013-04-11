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
#import "ManagedObjects.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

@implementation NativeGallery

- (id)initWithFrame:(CGRect)frame withGalleryPictures:(NSSet *)galleryPictures withAppDelegate:(tubeAppDelegate *)appDelegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.pictures = galleryPictures;
        self.imagesArray = [NSMutableArray array];
        self.titlesArray = [NSMutableArray array];
        self.backgroundColor = [UIColor blackColor];
        
        //add bgImageView
        self.bgImageView = [[UIImageView alloc] initWithFrame:frame];
        self.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:self.bgImageView];
        
        //add title
        self.titleLabel = [[UILabel alloc] initWithFrame:frame];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        if (IS_IPAD) {
            self.titleLabel.font = [UIFont systemFontOfSize:20];
        }
        [self addSubview:self.titleLabel];
        
        [self loadThumbs:appDelegate];
        self.bgImageView.image = [self.imagesArray objectAtIndex:0];
        self.bgImageView.userInteractionEnabled = YES;
        [self.bgImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] init]];
        self.titleLabel.text = [self.titlesArray objectAtIndex:0];
    }
    return self;
}

- (void)loadThumbs:(tubeAppDelegate*)appDelegate{
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
    int i = 0;
    for (MGalleryPicture *picture in self.pictures) {
        int y = offsetY + i * (thumbSize+padding);
        IndexedImageView *thumb = [[IndexedImageView alloc] initWithFrame:CGRectMake(offsetX, y, thumbSize, thumbSize)];
        NSString *path = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, picture.path];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        thumb.image = image;
        [self.imagesArray addObject:image];
        if (picture.title == nil) {
            [self.titlesArray addObject:@""];
        }else{
            [self.titlesArray addObject:picture.title];
        }
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
        i++;
    }
}

- (void)thumbTapped:(UITapGestureRecognizer*)recognizer{
    IndexedImageView *thumb = (IndexedImageView*)recognizer.view;
    self.bgImageView.image = [self.imagesArray objectAtIndex:thumb.index];
    self.titleLabel.text = [self.titlesArray objectAtIndex:thumb.index];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [self.bgImageView.layer addAnimation:transition forKey:nil];
}

- (void)dealloc{
    [self.pictures release];
    [self.imagesArray release];
    [self.bgImageView release];
    [self.titleLabel release];
    [self.titlesArray release];
    [super dealloc];
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
