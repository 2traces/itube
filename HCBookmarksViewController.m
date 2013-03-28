//
//  HCBookmarksViewController.m
//  tube
//
//  Created by Alexey on 14/11/12.
//
//

#import "HCBookmarksViewController.h"
#import "HCBookmarkItemView.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"
#import "MainView.h"
#import "UIImage+animatedGIF.h"
#import "MediaTypeFactory.h"

@interface HCBookmarksViewController ()

@end

@implementation HCBookmarksViewController

@synthesize items;
@synthesize scrollView;
@synthesize places;
@synthesize emptyPlaceholder;

- (IBAction)close:(id)sender {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideBookmarks];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (UIImage*)imageForPhotoObject:(MMedia*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *image = nil;
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    
    if (IS_IPAD)
    {
        NSString *iPadPath = [NSString stringWithFormat:@"%@/photos_ipad/%@", appDelegate.mapDirectoryPath, photo.filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:iPadPath])
            imagePath = iPadPath;
    }
    
    if ([[[photo.filename pathExtension] lowercaseString] isEqualToString:@"gif"]) {
        image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfFile:imagePath] duration:2.5f];
    }
    else {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if (!image) {
        image = [UIImage imageNamed:@"no_image.jpeg"];
    }
    return image;
}



- (void) reloadScrollView {
    self.places = [[MHelper sharedHelper] getFavoritePlacesList];
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    [self.items removeAllObjects];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    MainView* map = (MainView*)[appDelegate.mainViewController view];
    
    CGFloat offset = 50;
    
    if (!self.places || ![self.places count]) {
        self.emptyPlaceholder.hidden = NO;
    }
    else {
        self.emptyPlaceholder.hidden = YES;
    }
    
    for (MPlace *place in self.places) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:(IS_IPAD ? @"HCBookmarkItemView-iPad" : @"HCBookmarkItemView") owner:self options:nil];
        HCBookmarkItemView *itemView = (HCBookmarkItemView*)[nibObjects objectAtIndex:0];
        MMedia *firstPhoto = nil;
        itemView.bookmarkDelegate = self;
        if ([place.photos count]) {
            firstPhoto = [place.photos anyObject];
        }
        CGPoint placePoint = CGPointMake([place.posX floatValue], [place.posY floatValue]);
        Station *nearestStation = [map stationNearestToGeoPosition:placePoint];
        itemView.tag = [place.index integerValue];
        [self.items addObject:itemView];
        [self.scrollView addSubview:itemView];
        CGRect frame = itemView.frame;
        frame.origin.y = offset;
        offset += itemView.frame.size.height;
        itemView.frame = frame;
        UIView *mediaView = [MediaTypeFactory viewForMedia:firstPhoto withParent:itemView.mainView withOrientation:self.interfaceOrientation withIndex:[place.index integerValue]];
        mediaView.frame = CGRectMake(0, 0, itemView.mainView.frame.size.width, itemView.mainView.frame.size.height);
        NSLog(@"mediaView %@", mediaView.description);
        [itemView setView:mediaView text:place.text placeName:place.name placeDistance:nearestStation.name];
    }
    self.scrollView.contentSize = CGSizeMake(320.0f, offset);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
//    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, windowBounds.size.height);
    
    // Do any additional setup after loading the view from its nib.
    self.items = [NSMutableArray arrayWithCapacity:5];
    //[self reloadScrollView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    if (IS_IPAD)
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, windowBounds.size.width, windowBounds.size.height);
    else
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, windowBounds.size.height);
    [self reloadScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (HCBookmarkItemView*)viewForPlaceIndex:(NSInteger)index {
    for (UIView *view in self.items) {
        if (view.tag == index && [view isKindOfClass:[HCBookmarkItemView class]]) {
            return (HCBookmarkItemView*)view;
        }
    }
    return nil;
}


- (void) removeFromFavoritesItemWithIndex:(NSInteger)index {
    HCBookmarkItemView *view = [self viewForPlaceIndex:index];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    [UIView animateWithDuration:1.0f animations:^{
        view.alpha = 0.0f;
        NSInteger indexOfRemovedItem = [self.items indexOfObject:view];
        for (int i = indexOfRemovedItem + 1; i < [self.items count]; i++) {
            HCBookmarkItemView *movedView = self.items[i];
            CGRect frame = movedView.frame;
            frame.origin.y -= view.frame.size.height;
            movedView.frame = frame;
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height - view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.items removeObject:view];
        [view removeFromSuperview];
        MPlace *place = [[MHelper sharedHelper] getPlaceWithIndex:view.tag];
        place.isFavorite = [NSNumber numberWithBool:NO];
        [appDelegate placeRemovedFromFavorites:place];
        [self reloadScrollView];
    }];
}

- (void) showMapForItemWithIndex:(NSInteger)index {
    HCBookmarkItemView *view = [self viewForPlaceIndex:index];
    MPlace *place = [[MHelper sharedHelper] getPlaceWithIndex:view.tag];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate centerMapOnPlace:place];
    [self close:nil];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end
