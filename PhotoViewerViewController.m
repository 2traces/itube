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
    // Do any additional setup after loading the view from its nib.
    for (UIImageView *image in self.photos) {
        UIScrollView *zoomView = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
        zoomView.contentSize = image.frame.size;
        [zoomView addSubview:image];
        zoomView.delegate = self;
        zoomView.maximumZoomScale = 2.0f;
        CGRect frame = zoomView.frame;
        frame.origin = CGPointMake(offset, 0);
        zoomView.frame = frame;
        offset += self.scrollView.frame.size.width;
        [self.scrollView addSubview:[zoomView autorelease]];
    }
    self.scrollView.contentSize = CGSizeMake(offset, self.scrollView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)_scrollView {
    if (_scrollView != self.scrollView) {
        return self.photos[currentPage];
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



@end
