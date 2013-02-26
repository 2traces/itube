//
//  PhotoViewerViewController.m
//  tube
//
//  Created by Alexey on 28/11/12.
//
//

#import "PhotoViewerViewController.h"
#import "tubeAppDelegate.h"
#import "UIImage+animatedGIF.h"

@interface PhotoViewerViewController ()

@end

@implementation PhotoViewerViewController

@synthesize scrollView;
@synthesize photos;


- (UIImage*)imageForPhotoObject:(MPhoto*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *image = nil;
    NSArray *images = nil;
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    
    if (IS_IPAD)
    {
        NSString *iPadPath = [NSString stringWithFormat:@"%@/photos_ipad/%@", appDelegate.mapDirectoryPath, photo.filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:iPadPath])
            imagePath = iPadPath;
    }
    
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



- (id) initWithPlace:(MPlace*)place index:(NSInteger)index {
    self = [super initWithNibName:@"PhotoViewerViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
        for (MPhoto* photo in place.photos) {
            [tempArray addObject:photo];

        }
        self.photos = [NSArray arrayWithArray:tempArray];
        currentPage = index;
    }
    return self;
}

- (UIScrollView*)zoomingViewWithIndex:(NSInteger)index {
    MPhoto *photo = self.photos[index];
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

    UIScrollView *zoomView = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
    zoomView.contentSize = imageView.frame.size;
    [zoomView addSubview:[imageView autorelease]];
    zoomView.delegate = self;
    zoomView.tag = index + 1;
    zoomView.maximumZoomScale = 2.0f;
    zoomView.minimumZoomScale = zoomView.frame.size.width / imageView.frame.size.width;
    CGRect frame = zoomView.frame;
    frame.origin = CGPointMake(self.scrollView.frame.size.width * index, 0);
    zoomView.frame = frame;
    [zoomView setZoomScale:zoomView.minimumZoomScale];
    zoomView.contentMode = (UIViewContentModeScaleAspectFit);
    return [zoomView autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPAD) {
        CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
               self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, windowBounds.size.width, windowBounds.size.height);
            }
    

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self.photos count], self.scrollView.frame.size.height);

    self.scrollView.contentOffset = CGPointMake(currentPage*self.scrollView.frame.size.width, 0);
    
    //Preload current item, -1 and +1
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
        if (i < 0 || i > [self.photos count] - 1) {
            continue;
        }
        if ( [self.scrollView viewWithTag:(i + 1)] ) {
            continue;
        }
        else {
            // view is missing, create it and set its tag to currentPage+1
            UIScrollView *zoomView = [self zoomingViewWithIndex:i];
            [self.scrollView addSubview:zoomView];
        }
    }

    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    tapGR.delegate = self;
    [self.scrollView addGestureRecognizer:tapGR];
    [tapGR autorelease];
}

- (void)photoTapped:(UITapGestureRecognizer *)recognizer {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)_scrollView {
    if (_scrollView != self.scrollView) {
        for (UIView *subview in _scrollView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                return subview;
            }
        }
    }
    return nil;
}


- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
    if (_scrollView == self.scrollView) {
        NSInteger page = (self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
        if (page != currentPage) {
            currentPage = page;
            
            for (int i = currentPage - 1; i <= currentPage + 1; i++) {
                if (i < 0 || i > [self.photos count] - 1) {
                    continue;
                }
                if ( [self.scrollView viewWithTag:(i + 1)] ) {
                    continue;
                }
                else {
                    // view is missing, create it and set its tag to currentPage+1
                    UIScrollView *zoomView = [self zoomingViewWithIndex:i];
                    [self.scrollView addSubview:zoomView];
                }
            }
            
            for ( int i = 0; i < [self.photos count]; i++ ) {
                if ( (i < (currentPage - 1) || i > (currentPage + 1)) && [self.scrollView viewWithTag:(i + 1)] ) {
                    [[self.scrollView viewWithTag:(i + 1)] removeFromSuperview];
                }
            }
            
        }
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetZoomForAllImages];
}

- (void)resetZoomForAllImages {
    for (UIView *subview in self.scrollView.subviews) {
        UIScrollView *_scrollView = nil;
        if ([subview isKindOfClass:[UIScrollView class]]) {
            _scrollView = (UIScrollView*)subview;
        }
        if (_scrollView && _scrollView.tag != currentPage + 1) {
            _scrollView.zoomScale = _scrollView.minimumZoomScale;
        }
    }
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

-(void)scrollViewDidZoom:(UIScrollView *)_scrollView
{
    if (_scrollView != self.scrollView) {
        UIImageView *imageView = nil;
        for (UIView *subview in _scrollView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                imageView = (UIImageView*)subview;
                break;
            }
        }
        if (imageView) {
            imageView.frame = [self centeredFrameForScrollView:_scrollView andUIView:imageView];
        }
    }
}

- (void)dealloc {
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
