//
//  HCBookmarksViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 14/11/12.
//
//

#import "HCBookmarksViewController.h"
#import "HCBookmarkItemView.h"
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"

@interface HCBookmarksViewController ()

@end

@implementation HCBookmarksViewController

@synthesize items;
@synthesize scrollView;
@synthesize places;

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


- (UIImage*)imageForPhotoObject:(MPhoto*)photo {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, photo.filename];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}


- (void) reloadScrollView {
    self.places = [[MHelper sharedHelper] getFavoritePlacesList];
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    [self.items removeAllObjects];
    
    CGFloat offset = 50;
    for (MPlace *place in self.places) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"HCBookmarkItemView" owner:self options:nil];
        HCBookmarkItemView *itemView = (HCBookmarkItemView*)[nibObjects objectAtIndex:0];
        MPhoto *firstPhoto = nil;
        itemView.bookmarkDelegate = self;
        if ([place.photos count]) {
            firstPhoto = [place.photos anyObject];
        }
        [itemView setImage:[self imageForPhotoObject:firstPhoto] text:place.text placeName:place.name placeDistance:@"Some really long address, or distance."];
        itemView.tag = [place.index integerValue];
        [self.items addObject:itemView];
        [self.scrollView addSubview:itemView];
        CGRect frame = itemView.frame;
        frame.origin.y = offset;
        offset += itemView.frame.size.height;
        itemView.frame = frame;
    }
    self.scrollView.contentSize = CGSizeMake(320.0f, offset);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.items = [NSMutableArray arrayWithCapacity:5];
    [self reloadScrollView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    }];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
