//
//  PhotosViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import "PhotosViewController.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface PhotosViewController ()

@end

@implementation PhotosViewController

@synthesize scrollPhotos;
@synthesize buttonCategories;
@synthesize navigationDelegate;
@synthesize disappearingView;
@synthesize panelView;
@synthesize currentPlaces;
@synthesize currentPhotos;
@synthesize placeDescription;
@synthesize placeNameHeader;
@synthesize placeNamePanel;
@synthesize btAddToFavorites;
@synthesize btShowHideBookmarks;

- (IBAction)showCategories:(id)sender {
    [self.navigationDelegate showCategories:self];
}

- (IBAction)showBookmarks:(id)sender {
    [self.navigationDelegate showBookmarks:self];

}

- (IBAction)addToFavorites:(id)sender {
    MPlace *place = [(MPhoto*)(self.currentPhotos[currentPage]) place];
    place.isFavorite = [place.isFavorite boolValue] ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [self updateInfoForCurrentPage];
}


- (UIImage*)imageForPhotoObject:(MPhoto*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

- (void)updateInfoForCurrentPage {
    MPlace *place = [(MPhoto*)(self.currentPhotos[currentPage]) place];
    self.placeNameHeader.text = place.name;
    self.placeNamePanel.text = place.name;
    self.placeDescription.text = [NSString stringWithFormat:@"\"%@\"", place.text];
    UIImage *btImage = [place.isFavorite boolValue] ?
                [UIImage imageNamed:@"bt_star_solid"] :
                [UIImage imageNamed:@"bt_star"];
    [self.btAddToFavorites setImage:btImage forState:UIControlStateNormal];
    [self.navigationDelegate selectPlaceWithIndex:[place.index integerValue]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateInfoForCurrentPage];
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
    imageFrame.origin.y = 0;
    imageView.frame = imageFrame;
    imageView.tag = index + 1;
    return [imageView autorelease];
}

- (void)reloadScrollView {
    for (UIView *subview in self.scrollPhotos.subviews) {
        [subview removeFromSuperview];
    }
    self.scrollPhotos.contentOffset = CGPointZero;
    self.currentPhotos = nil;
    NSMutableArray *mutablePhotos = [NSMutableArray arrayWithCapacity:10];
    NSInteger index = 0;
    for (MPlace *place in self.currentPlaces) {
        for (MPhoto *photo in place.photos) {
            [mutablePhotos addObject:photo];
            //[self.scrollPhotos addSubview:[self imageViewWithIndex:index]];
            index++;
        }
    }
   // NSLog(@"Loaded %i photos!", index);
    self.currentPhotos = [NSArray arrayWithArray:mutablePhotos];
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

    
    if ([self.currentPhotos count]) {
        [self updateInfoForCurrentPage];
    }
}

- (void) loadPlaces:(NSArray*)places {
    self.currentPlaces = places;
    [self reloadScrollView];
}



- (IBAction)showHidePhotos:(id)sender {
    [self.navigationDelegate showHidePhotos:self];
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
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    tapGR.delegate = self;
    self.placeNameHeader.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18.0f];
    self.placeNamePanel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0f];
    self.placeDescription.layer.cornerRadius = 11;
    self.placeDescription.font = [UIFont fontWithName:@"MyriadPr-Italic" size:16.0f];
    [self.scrollPhotos addGestureRecognizer:tapGR];
    [tapGR autorelease];
}

- (void)photoTapped:(UITapGestureRecognizer *)recognizer {
    MPlace* place = [((MPhoto*)self.currentPhotos[currentPage]) place];
    
    [self.navigationDelegate showReaderWithItems:self.currentPlaces activePage:[self.currentPlaces indexOfObject:place]];
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
        
        [self updateInfoForCurrentPage];
    }
}


@end
