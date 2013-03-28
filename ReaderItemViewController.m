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
#import "MediaTypeFactory.h"

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
        self.scrollPhotos.frame = CGRectMake(0/*scrollPhotos.frame.origin.x*/, 0, 320/*scrollPhotos.frame.size.width*/, center);
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

- (UIView*)mediaViewWithIndex:(NSInteger)index {
    MMedia *media = self.currentPhotos[index];
    return [MediaTypeFactory viewForMedia:media withParent:self.scrollPhotos withOrientation:self.interfaceOrientation withIndex:index];
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
    for (MMedia *photo in sortedPhotos) {
        [tempPhotos addObject:photo];
        index++;
    }
    self.currentPhotos = tempPhotos;
    self.scrollPhotos.contentSize = CGSizeMake(self.scrollPhotos.frame.size.width * index, self.scrollPhotos.frame.size.height);
    self.scrollPhotos.pagingEnabled = YES;
    
    currentPage = 0;
    
    //Preload first two images
    UIView *mediaView = nil;
    if (index) {
        mediaView = [self mediaViewWithIndex:currentPage];
        [self.scrollPhotos addSubview:mediaView];
    }
    if (index > 1) {
        mediaView = [self mediaViewWithIndex:currentPage + 1];
        [self.scrollPhotos addSubview:mediaView];
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
                UIImageView *mediaView = [self mediaViewWithIndex:i];
                [self.scrollPhotos addSubview:mediaView];
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
