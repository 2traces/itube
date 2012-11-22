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
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageForPhotoObject:photo]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.frame = self.scrollPhotos.frame;
            CGRect imageFrame = imageView.frame;
            imageFrame.origin.x = self.scrollPhotos.frame.size.width * index;
            imageFrame.origin.y = 0;
            imageView.frame = imageFrame;
            [self.scrollPhotos addSubview:[imageView autorelease]];
            index++;
        }
    }
    self.currentPhotos = [NSArray arrayWithArray:mutablePhotos];
    self.scrollPhotos.contentSize = CGSizeMake(self.scrollPhotos.frame.size.width * index, self.scrollPhotos.frame.size.height);
    self.scrollPhotos.pagingEnabled = YES;
    currentPage = 0;
    [self updateInfoForCurrentPage];
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
    self.placeDescription.font = [UIFont fontWithName:@"MyriadPr-Italic" size:16.0f];
    [self.scrollPhotos addGestureRecognizer:tapGR];
    [tapGR autorelease];
}

- (void)photoTapped:(UITapGestureRecognizer *)recognizer {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    for (int i = 0; i < 10; i++) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Place %i", i+1], @"title", @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", @"text", nil];
        [array addObject:dict];
    }
    
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
    NSInteger page = (self.scrollPhotos.contentOffset.x + self.scrollPhotos.frame.size.width/2 - 1) / self.scrollPhotos.frame.size.width;
    if (page != currentPage) {
        currentPage = page;
        [self updateInfoForCurrentPage];
    }
}


@end
