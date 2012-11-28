//
//  PhotoViewerViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 28/11/12.
//
//

#import "PhotoViewerViewController.h"
#import "tubeAppDelegate.h"

@interface PhotoViewerViewController ()

@end

@implementation PhotoViewerViewController

@synthesize scrollView;
@synthesize photos;


- (UIImage*)imageForPhotoObject:(MPhoto*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}


- (id) initWithPlace:(MPlace*)place {
    self = [super initWithNibName:@"PhotoViewerViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
        for (MPhoto* photo in place.photos) {
            UIImage *image = [self imageForPhotoObject:photo];
            if (image) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                [tempArray addObject:[imageView autorelease]];
            }
        }
        self.photos = [NSArray arrayWithArray:tempArray];
    }
    return self;
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
    CGFloat offset = 0;
    NSInteger index = 0;
    // Do any additional setup after loading the view from its nib.
    for (UIImageView *image in self.photos) {
        UIScrollView *zoomView = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
        zoomView.contentSize = image.frame.size;
        [zoomView addSubview:image];
        zoomView.delegate = self;
        zoomView.tag = index;
        zoomView.maximumZoomScale = 2.0f;
        zoomView.minimumZoomScale = zoomView.frame.size.width / image.frame.size.width;
        CGRect frame = zoomView.frame;
        frame.origin = CGPointMake(offset, 0);
        zoomView.frame = frame;
        [zoomView setZoomScale:zoomView.minimumZoomScale];
        zoomView.contentMode = (UIViewContentModeScaleAspectFit);
        offset += self.scrollView.frame.size.width;
        index++;
        [self.scrollView addSubview:[zoomView autorelease]];
    }
    self.scrollView.contentSize = CGSizeMake(offset, self.scrollView.frame.size.height);
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
        NSInteger page = (self.scrollView.contentOffset.x + self.scrollView.frame.size.width/2 - 1) / self.scrollView.frame.size.width;
        if (page != currentPage) {
            currentPage = page;
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
        if (_scrollView && _scrollView.tag != currentPage) {
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


@end
