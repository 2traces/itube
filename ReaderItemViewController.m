//
//  ReaderItemViewController.m
//  tube
//
//  Created by Alexey on 16/11/12.
//
//

#import "ReaderItemViewController.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"
#import "UIImage+animatedGIF.h"

@interface ReaderItemViewController ()

@end

@implementation ReaderItemViewController

@synthesize scrollPhotos;
@synthesize textView;
@synthesize place;
@synthesize currentPhotos;

- (NSInteger)currentPage {
    return currentPage;
}


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
    UIImage *image = nil;
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    if ([[[photo.filename pathExtension] lowercaseString] isEqualToString:@"gif"]) {
        image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfFile:imagePath] duration:2.5f];
    } else {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if (!image) {
        image = [UIImage imageNamed:@"no_image.jpeg"];
    }
    return image;
}


- (UIImageView*)imageViewWithIndex:(NSInteger)index {
    MPhoto *photo = self.currentPhotos[index];
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
    imageFrame.size.width -= 20;
    imageFrame.origin.y = 0;
    imageView.frame = imageFrame;
    imageView.tag = index + 1;
    return [imageView autorelease];
}



- (void)reloadScrollView {
    for (UIView *subview in self.scrollPhotos.subviews) {
        [subview removeFromSuperview];
    }
    self.scrollPhotos.delegate = self;
    self.scrollPhotos.contentOffset = CGPointZero;
    NSInteger index = 0;
    NSMutableArray *tempPhotos = [NSMutableArray arrayWithCapacity:[self.place.photos count]];
    for (MPhoto *photo in self.place.photos) {
        [tempPhotos addObject:photo];
        index++;
    }
    self.currentPhotos = tempPhotos;
    self.scrollPhotos.contentSize = CGSizeMake(self.scrollPhotos.frame.size.width * index, self.scrollPhotos.frame.size.height);
    self.scrollPhotos.pagingEnabled = YES;
    
    currentPage = 0;
    
    //Preload first two images
    UIImageView *imageView = nil;
    if (index) {
        imageView = [self imageViewWithIndex:currentPage];
        [self.scrollPhotos addSubview:imageView];
    }
    if (index > 1) {
        imageView = [self imageViewWithIndex:currentPage + 1];
        [self.scrollPhotos addSubview:imageView];
    }

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = (self.scrollPhotos.contentOffset.x / self.scrollPhotos.frame.size.width);
    //NSLog(@"%f, %f", self.scrollPhotos.contentOffset.y, self.scrollPhotos.frame.size.width);
    //NSInteger visiblePage = (self.scrollPhotos.contentOffset.y / self.scrollPhotos.frame.size.width);
    // display the image and maybe +/-1 for a smoother scrolling
	// but be sure to check if the image already exists, you can do this very easily using tags
    
    if (page != currentPage) {
        currentPage = page;
        
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
            if (i < 0 || i > [self.currentPhotos count] - 1) {
                continue;
            }
            if ( [self.scrollPhotos viewWithTag:(i + 1)] ) {
                continue;
            }
            else {
                // view is missing, create it and set its tag to currentPage+1
                UIImageView *imageView = [self imageViewWithIndex:i];
                [self.scrollPhotos addSubview:imageView];
            }
        }
        
        for ( int i = 0; i < [self.currentPhotos count]; i++ ) {
            if ( (i < (currentPage - 1) || i > (currentPage + 1)) && [self.scrollPhotos viewWithTag:(i + 1)] ) {
                [[self.scrollPhotos viewWithTag:(i + 1)] removeFromSuperview];
            }
        }
    }
}



@end
