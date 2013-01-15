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
#import "UIImage+animatedGIF.h"
#import <MediaPlayer/MediaPlayer.h>

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
@synthesize moviePlayers;

- (IBAction)showCategories:(id)sender {
    [self.navigationDelegate showCategories:self];
}

- (IBAction)showBookmarks:(id)sender {

    
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

- (IBAction)addToFavorites:(id)sender {
    [self.navigationDelegate showBookmarks:self];
}

- (IBAction)centerMapOnUser:(id)sender {
    [self.navigationDelegate centerMapOnUser];
}


- (UIImage*)imageForPhotoObject:(MPhoto*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *image = nil;
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    if ([[[photo.filename pathExtension] lowercaseString] isEqualToString:@"gif"]) {
        image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfFile:imagePath] duration:2.5f];
    }
    else if ([[[photo.filename pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
        return nil;
    } else {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
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
                [UIImage imageNamed:@"bt_photo_like"] :
                [UIImage imageNamed:@"bt_photo_like_empty"];
    [self.btShowHideBookmarks setImage:btImage forState:UIControlStateNormal];
    //[self.btAddToFavorites setImage:btImage forState:UIControlStateNormal];
    CGFloat distance = [self.navigationDelegate selectPlaceWithIndex:[place.index integerValue]];
    NSLog(@"%f km", distance);
    if (distance == 0) {
        self.distanceLabel.text = @"";
    }
    else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", distance];
        CGFloat direction = [self.navigationDelegate radialDirectionOffsetToPlaceWithIndex:[place.index integerValue]];
        NSLog(@"%f radians", direction);
        //[self.directionImage
        self.directionImage.transform = CGAffineTransformMakeRotation(0);
        self.directionImage.transform = CGAffineTransformMakeRotation(direction);
    }


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateInfoForCurrentPage];
}

- (UIView*)imageViewWithIndex:(NSInteger)index {
    MPhoto *photo = self.currentPhotos[index];
    UIImage *image = [self imageForPhotoObject:photo];
    UIView *mediaView = nil;
    if (!image) {
        //OMG, it's not an image, it's a... Video!
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *videoPath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
        MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        moviePlayerController.fullscreen = NO;
        moviePlayerController.controlStyle = MPMovieControlStyleNone;
        moviePlayerController.repeatMode = MPMovieRepeatModeNone;
        moviePlayerController.shouldAutoplay = YES;
        [moviePlayerController prepareToPlay];
        [moviePlayerController stop];
        mediaView = [moviePlayerController.view retain];
        //[moviePlayerController autorelease];
        [self.moviePlayers addObject:moviePlayerController];
        [moviePlayerController autorelease];
        
    }
    else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        mediaView = imageView;
    }
    mediaView.contentMode = UIViewContentModeScaleAspectFill;
    mediaView.clipsToBounds = YES;
    if (mediaView.frame.size.width < self.scrollPhotos.frame.size.width ||
        mediaView.frame.size.height < self.scrollPhotos.frame.size.height ) {
        mediaView.contentMode = UIViewContentModeCenter;
        
    }
    mediaView.frame = self.scrollPhotos.frame;
    CGRect imageFrame = mediaView.frame;
    imageFrame.size.width -= 20;
    imageFrame.origin.x = self.scrollPhotos.frame.size.width * index;
    imageFrame.origin.y = 0;
    mediaView.frame = imageFrame;
    mediaView.tag = index + 1;
    return [mediaView autorelease];
}

- (void)reloadScrollView {
    for (UIView *subview in self.scrollPhotos.subviews) {
        [subview removeFromSuperview];
    }
    self.scrollPhotos.contentOffset = CGPointZero;
    self.currentPhotos = nil;
    NSMutableArray *mutablePhotos = [NSMutableArray arrayWithCapacity:10];
    NSInteger index = 0;
    NSSortDescriptor* desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    for (MPlace *place in self.currentPlaces) {
        NSArray *sortedPhotos = [place.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
        for (MPhoto *photo in sortedPhotos) {
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
    self.placeDescriptionBg.layer.cornerRadius = 5;
    self.placeDescription.font = [UIFont fontWithName:@"MyriadPr-Italic" size:16.0f];
    self.distanceLabel.font = [UIFont fontWithName:@"MyriadPr-Italic" size:10.0f];
    self.distanceLabel.textColor = [UIColor darkGrayColor];
    self.distanceLabel.text = @"";
    [self.scrollPhotos addGestureRecognizer:tapGR];
    self.moviePlayers = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
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
    
    [self.navigationDelegate showFullMap];
    
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
    if (self.view.frame.origin.y + delta_y < -261) {
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
    NSInteger rest = ((int)self.scrollPhotos.contentOffset.x % (int)self.scrollPhotos.frame.size.width);
    //NSLog(@"%f, %f", self.scrollPhotos.contentOffset.x, self.scrollPhotos.frame.size.width);
    //NSInteger visiblePage = (self.scrollPhotos.contentOffset.y / self.scrollPhotos.frame.size.width);
    // display the image and maybe +/-1 for a smoother scrolling
	// but be sure to check if the image already exists, you can do this very easily using tags
    if (rest == 0) {
        UIView *mediaView = [self.scrollPhotos viewWithTag:page + 1];
        if (![mediaView isKindOfClass:[UIImageView class]]) {
            for (MPMoviePlayerController *mp in self.moviePlayers) {
                if (mp.view == mediaView) {
                    [mp stop];
                    [mp play];
                    break;
                }
            }
        }
    }
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
                UIView *mediaView = [self.scrollPhotos viewWithTag:(i + 1)];
                MPMoviePlayerController *mpc = nil;
                
                for (MPMoviePlayerController *mp in self.moviePlayers) {
                    if (mp.view == mediaView) {
                        mpc = mp;
                        break;
                    }
                }
                
                [self.moviePlayers removeObject:mpc];
                [[self.scrollPhotos viewWithTag:(i + 1)] removeFromSuperview];
            }
        }
        
        [self updateInfoForCurrentPage];
    }
}


@end
