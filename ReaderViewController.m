//
//  ReaderViewController.m
//  tube
//
//  Created by Alexey on 16/11/12.
//
//

#import "ReaderViewController.h"
#import "ReaderItemViewController.h"
#import "ManagedObjects.h"
#import "PhotoViewerViewController.h"
#import "tubeAppDelegate.h"

@interface ReaderViewController ()

@end

@implementation ReaderViewController

@synthesize btBack;
@synthesize btStar;
@synthesize lbHeader;
@synthesize scrollView;
@synthesize pageControl;
@synthesize items;
@synthesize itemViews;
@synthesize visibleItems;

- (IBAction)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)addToFavorites:(id)sender {
    MPlace *place = self.items[currentPage];
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


- (id) initWithReaderItems:(NSArray*)_items currentItemIndex:(NSInteger)currentItemIndex {
    self = [super initWithNibName:@"ReaderViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        self.items = _items;
        currentPage = currentItemIndex;
    }
    return self;
}


- (void)updateInfoForCurrentPage {
    MPlace *place = self.items[currentPage];
    self.lbHeader.text = place.name;
    UIImage *btImage = [place.isFavorite boolValue] ?
    [UIImage imageNamed:@"bt_star_solid"] :
    [UIImage imageNamed:@"bt_star"];
    [self.btStar setImage:btImage forState:UIControlStateNormal];
}

//Get item, if there is one
- (ReaderItemViewController*)itemViewControllerForIndex:(NSInteger)index {
    ReaderItemViewController *item = [self.visibleItems objectForKey:[NSNumber numberWithInteger:index]];
    return item;
}

//Create a NEW item
- (ReaderItemViewController*)itemViewControllerWithIndex:(NSInteger)index {
    ReaderItemViewController *itemVC = [[ReaderItemViewController alloc] initWithPlaceObject:self.items[index]];
    CGRect frame = itemVC.view.frame;
    frame.origin = CGPointMake(self.scrollView.frame.size.width * index + 10, 0);
    //frame.size.width -= 20;
    itemVC.view.frame = frame;
    return [itemVC autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    if (IS_IPAD)
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, windowBounds.size.width, windowBounds.size.height);
    else
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, windowBounds.size.height);
    // Do any additional setup after loading the view from its nib.
    self.visibleItems = [NSMutableDictionary dictionaryWithCapacity:5];
    self.scrollView.contentSize = CGSizeMake([self.items count] * self.scrollView.frame.size.width, 440);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * currentPage, 0);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.pageControl setNumberOfPages:[self.itemViews count]];
    [self.pageControl setCurrentPage:currentPage];
    self.lbHeader.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18.0f];
    self.btBack.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0f];
    
    //Preload current item, -1 and +1
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
        if (i < 0 || i > [self.items count] - 1) {
            continue;
        }
        if ( [self itemViewControllerForIndex:i] ) {
            continue;
        }
        else {
            // view is missing, create it and set its tag to currentPage+1
            ReaderItemViewController *vc = [self itemViewControllerWithIndex:i];
            CGRect frame = vc.view.frame;
            frame.size.height = self.scrollView.frame.size.height;
            vc.view.frame = frame;
            [self.scrollView addSubview:vc.view];
            [self.visibleItems setObject:vc forKey:[NSNumber numberWithInteger:i]];
        }
    }

    
    [self updateInfoForCurrentPage];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    tapGR.delegate = self;
    [self.scrollView addGestureRecognizer:tapGR];
    [tapGR autorelease];
}

- (void)photoTapped:(UITapGestureRecognizer *)recognizer {
    MPlace* place = self.items[currentPage];
    ReaderItemViewController *itemVC = [self itemViewControllerForIndex:currentPage];
    NSInteger currentPhoto = [itemVC currentPage];
    PhotoViewerViewController *viewer = [[PhotoViewerViewController alloc] initWithPlace:place index:currentPhoto];
    viewer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentModalViewController:[viewer autorelease] animated:YES];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = (self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    //NSLog(@"%f, %f", self.scrollPhotos.contentOffset.y, self.scrollPhotos.frame.size.width);
    //NSInteger visiblePage = (self.scrollPhotos.contentOffset.y / self.scrollPhotos.frame.size.width);
    // display the image and maybe +/-1 for a smoother scrolling
	// but be sure to check if the image already exists, you can do this very easily using tags
    
    if (page != currentPage) {
        currentPage = page;
        
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
            if (i < 0 || i > [self.items count] - 1) {
                continue;
            }
            if ( [self itemViewControllerForIndex:i] ) {
                continue;
            }
            else {
                // view is missing, create it and set its tag to currentPage+1
                ReaderItemViewController *vc = [self itemViewControllerWithIndex:i];
                CGRect frame = vc.view.frame;
                frame.size.height = self.scrollView.frame.size.height;
                vc.view.frame = frame;
                
                [self.scrollView addSubview:vc.view];
                [self.visibleItems setObject:vc forKey:[NSNumber numberWithInteger:i]];
            }
        }
        
        for ( int i = 0; i < [self.items count]; i++ ) {
            if ( (i < (currentPage - 1) || i > (currentPage + 1)) && [self itemViewControllerForIndex:i] ) {
                ReaderItemViewController *vc = [self itemViewControllerForIndex:i];
                [vc.view removeFromSuperview];
                [self.visibleItems removeObjectForKey:[NSNumber numberWithInteger:i]];
            }
        }
        
        [self updateInfoForCurrentPage];
        [self.pageControl setCurrentPage:currentPage];

    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}

@end
