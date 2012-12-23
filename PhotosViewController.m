//
//  PhotosViewController.m
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import "PhotosViewController.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "MainView.h"

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
@synthesize placeDescriptionBg;
@synthesize btAddToFavorites;
@synthesize btShowHideBookmarks;
@synthesize distanceContainer;
@synthesize distanceLabel;
@synthesize btPanel;
@synthesize directionImage;

- (IBAction)showCategories:(id)sender {
    [self.navigationDelegate showCategories:self];
}

- (IBAction)showBookmarks:(id)sender {
    [self.navigationDelegate showBookmarks:self];

}

- (IBAction)addToFavorites:(id)sender {
    MPlace *place = [(MPhoto*)(self.currentPhotos[currentPage]) place];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([place.isFavorite boolValue]) {
        [appDelegate placeRemovedFromFavorites:place];
    }
    else {
        [appDelegate placeAddedToFavorites:place];
    }
    place.isFavorite = [place.isFavorite boolValue] ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [self updateInfoForCurrentPage];
}


- (UIImage*)imageForPhotoObject:(MPhoto*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        image = [UIImage imageNamed:@"no_image.jpeg"];
    }
    return image;
}

- (Station*)stationForCurrentPhoto {
    MPlace *place = [(MPhoto*)(self.currentPhotos[currentPage]) place];
    CGPoint placePoint = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    MainView* map = (MainView*)[appDelegate.mainViewController view];
    Station *nearestStation = [map stationNearestToGeoPosition:placePoint];
    return nearestStation;
}

- (void)updateInfoForCurrentPage {
    MPlace *place = [(MPhoto*)(self.currentPhotos[currentPage]) place];
    self.placeNameHeader.text = place.name;
    self.placeNamePanel.text = place.name;
    self.placeDescription.text = [NSString stringWithFormat:@"\"%@\"", place.text];
    self.placeDescriptionBg.frame = self.placeDescription.frame;
    self.placeDescriptionBg.center = CGPointMake(self.placeDescription.center.x, self.placeDescription.center.y - 3);
    UIImage *btImage = [place.isFavorite boolValue] ?
                [UIImage imageNamed:@"bt_star_solid"] :
                [UIImage imageNamed:@"bt_star"];
    [self.btAddToFavorites setImage:btImage forState:UIControlStateNormal];
    CGFloat distance = [self.navigationDelegate selectPlaceWithIndex:[place.index integerValue]];
    NSLog(@"%f meters", distance);
    if (distance == 0) {
        self.distanceLabel.text = @"";
    }
    else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", distance/1000.0f];
    }
    CGFloat direction = [self.navigationDelegate radialDirectionOffsetToPlaceWithIndex:[place.index integerValue]];
    NSLog(@"%f radians", direction);
    //[self.directionImage

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
    self.placeDescriptionBg.layer.cornerRadius = 11;
    self.placeDescription.font = [UIFont fontWithName:@"MyriadPr-Italic" size:16.0f];
    self.distanceLabel.font = [UIFont fontWithName:@"MyriadPr-Italic" size:10.0f];
    self.distanceLabel.textColor = [UIColor darkGrayColor];
    self.distanceLabel.text = @"";
    [self.scrollPhotos addGestureRecognizer:tapGR];
    [tapGR autorelease];
    currentPage = 0;
    [self updateInfoForCurrentPage];
    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.view addGestureRecognizer:[swipeUpGestureRecognizer autorelease]];

    [self.btPanel addTarget:self action:@selector(wasDragged:withEvent:)
     forControlEvents:UIControlEventTouchDragInside];
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    if ([self.navigationDelegate categoriesOpen]) {
        return;
    }
    
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_x = 0;//location.x - previousLocation.x;
	CGFloat delta_y = location.y - previousLocation.y;
    
    if (self.view.frame.origin.y + delta_y > 0) {
        return;
    }
    if (self.view.frame.origin.y + delta_y < -176) {
        return;
    }
    
	// move button
    //[self.navigationDelegate stickThePanelBackToPhotos];
	self.view.center = CGPointMake(self.view.center.x + delta_x,
                                self.view.center.y + delta_y);
}

- (void)handleSwipeUpFrom:(UIGestureRecognizer*)recognizer {
    if ([self.navigationDelegate photosOpen]) {
        [self showHidePhotos:nil];
    }
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
    //NSLog(@"%f, %f", self.scrollPhotos.contentOffset.x, self.scrollPhotos.frame.size.width);
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
