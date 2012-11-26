//
//  ReaderItemViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 16/11/12.
//
//

#import "ReaderItemViewController.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"

@interface ReaderItemViewController ()

@end

@implementation ReaderItemViewController

@synthesize scrollPhotos;
@synthesize textView;
@synthesize place;

- (id)initWithPlaceObject:(MPlace*)_place
{
    self = [super initWithNibName:@"ReaderItemViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        self.place = _place;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0f];
    [self reloadScrollView];
    self.textView.text = self.place.text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImage*)imageForPhotoObject:(MPhoto*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}



- (void)reloadScrollView {
    for (UIView *subview in self.scrollPhotos.subviews) {
        [subview removeFromSuperview];
    }
    self.scrollPhotos.contentOffset = CGPointZero;
    NSInteger index = 0;
    for (MPhoto *photo in self.place.photos) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageForPhotoObject:photo]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;

        if (imageView.frame.size.width < self.scrollPhotos.frame.size.width ||
            imageView.frame.size.height < self.scrollPhotos.frame.size.height ) {
            imageView.contentMode = UIViewContentModeCenter;
            
        }
        imageView.frame = self.scrollPhotos.frame;
        CGRect imageFrame = imageView.frame;
        imageFrame.origin.x = self.scrollPhotos.frame.size.width * index;
        imageFrame.origin.y = 0;
        imageView.frame = imageFrame;
        [self.scrollPhotos addSubview:[imageView autorelease]];
        index++;
    }
    self.scrollPhotos.contentSize = CGSizeMake(self.scrollPhotos.frame.size.width * index, self.scrollPhotos.frame.size.height);
    self.scrollPhotos.pagingEnabled = YES;
}


@end
