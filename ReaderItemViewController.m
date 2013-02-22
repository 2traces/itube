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

    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    if (IS_IPAD) {
        float center = windowBounds.size.height / 2 - 20;
        self.scrollPhotos.frame = CGRectMake(scrollPhotos.frame.origin.x, 0, scrollPhotos.frame.size.width, center);
        self.separator.frame = CGRectMake(0, center, self.separator.frame.size.width, self.separator.frame.size.height);
        self.textView.frame = CGRectMake(textView.frame.origin.x, center + self.separator.frame.size.height, textView.frame.size.width, windowBounds.size.height - center - self.separator.frame.size.height);
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, windowBounds.size.width, windowBounds.size.height);
    }
    
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
    NSArray *images = nil;
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    if ([[[photo.filename pathExtension] lowercaseString] isEqualToString:@"gif"]) {
        images = [UIImage imagesArrayWithAnimatedGIFData:[NSData dataWithContentsOfFile:imagePath] duration:2.5f];
        if (images) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:images[0]];
            imageView.animationImages = images;
            imageView.animationDuration = 2.5f;
            imageView.animationRepeatCount = [photo.repeatCount integerValue];
            [imageView startAnimating];
            //...Returning UIImageView instead of declared UIImage...
            //I know that it's a crappy solution, however, the quickest possible,
            //as using animatedImage method of UIImage can't control repeat count —
            //we have to switch to animated UIImageView to be able to control amount
            //of times to repeat the animation.
            return [imageView autorelease];
        }
    }
    else {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if (!image) {
        image = [UIImage imageNamed:@"no_image.jpeg"];
    }
    return image;
}


- (UIImageView*)imageViewWithIndex:(NSInteger)index {
    MPhoto *photo = self.currentPhotos[index];
    UIImageView *imageView = nil;
    UIImage *image = [self imageForPhotoObject:photo];
    if ([image isKindOfClass:[UIImageView class]]) {
        //...Checking if we got UIImageView instead of expected UIImage...
        //I know that it's a crappy solution, however, the quickest possible,
        //as using animatedImage method of UIImage can't control repeat count —
        //we have to switch to animated UIImageView to be able to control amount
        //of times to repeat the animation.
        imageView = [(UIImageView*)image retain];
    }
    else {
        imageView = [[UIImageView alloc] initWithImage:image];
    }
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
    NSSortDescriptor* desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortedPhotos = [self.place.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    for (MPhoto *photo in sortedPhotos) {
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



- (void)dealloc {
    [_separator release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSeparator:nil];
    [super viewDidUnload];
}
@end
