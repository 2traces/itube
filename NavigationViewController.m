//
//  NavigationViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import "NavigationViewController.h"
#import "CategoriesViewController.h"
#import "PhotosViewController.h"
#import "MainViewController.h"
#import "MainView.h"
#import "TopTwoStationsView.h"
#import "HCBookmarksViewController.h"
#import "ReaderViewController.h"
#import "ManagedObjects.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

@synthesize categoriesController;
@synthesize photosController;
@synthesize mainController;
@synthesize glController;
@synthesize bookmarksController;
@synthesize readerController;
@synthesize currentPlaces;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mainViewController:(MainViewController*)mainViewController glViewController:(GlViewController*)glViewController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.mainController = mainViewController;
        self.mainController.navigationViewController = self;

        self.glController = glViewController;
        self.glController.navigationViewController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.categoriesController = [[[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.categoriesController.navigationDelegate = self;
    self.photosController = [[[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:[NSBundle mainBundle]]  autorelease];
    self.photosController.navigationDelegate = self;
    self.mainController.view.layer.cornerRadius = self.photosController.view.layer.cornerRadius = 5;
    self.mainController.view.layer.masksToBounds = self.photosController.view.layer.masksToBounds = YES;
    [self.view addSubview:[self.categoriesController view]];
    [self.view addSubview:[self.mainController view]];
    [self.view addSubview:[self.photosController view]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showCategories:(id)sender {

    [UIView animateWithDuration:0.5f animations:^{
        CGRect mainViewFrame = self.mainController.view.frame;
        CGRect photosViewFrame = self.photosController.view.frame;
        if (mainViewFrame.origin.x == 0) {
            mainViewFrame.origin.x = photosViewFrame.origin.x = 227;
            categoriesOpen = YES;
        }
        else {
            mainViewFrame.origin.x = photosViewFrame.origin.x = 0;
            categoriesOpen = NO;

        }
        self.mainController.view.frame = self.glController.view.frame = mainViewFrame;
        self.photosController.view.frame = photosViewFrame;
    }];
}

- (void) showBookmarks:(id)sender {
    if (!self.bookmarksController) {
        self.bookmarksController = [[[HCBookmarksViewController alloc] initWithNibName:@"HCBookmarksViewController" bundle:[NSBundle mainBundle]] autorelease];
    }
    [self presentModalViewController:self.bookmarksController animated:YES];

}


- (void) showHidePhotos:(id)sender {
    if (categoriesOpen) {
        return;
    }
    CGRect photosViewFrame = self.photosController.view.frame;
    CGRect panelFrame = self.photosController.panelView.frame;
    if (photosViewFrame.origin.y != 0) {
        photosViewFrame.origin.x = 0;
        panelFrame.origin = CGPointMake(0, 216);
        [self.photosController.view addSubview:self.photosController.panelView];
    }
    self.photosController.panelView.frame = panelFrame;
    self.photosController.view.frame = photosViewFrame;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect photosViewFrame = self.photosController.view.frame;

        if (photosViewFrame.origin.y == 0) {
            photosViewFrame.origin.y = -176;
            self.photosController.disappearingView.alpha = 0;

        }
        else {
            photosViewFrame.origin.y = 0;
            self.photosController.disappearingView.alpha = 1.0f;

        }
        self.photosController.view.frame = photosViewFrame;
    } completion:^(BOOL finished) {
        CGRect photosViewFrame = self.photosController.view.frame;
        CGRect panelFrame = self.photosController.panelView.frame;
        if (photosViewFrame.origin.y == 0) {

        }
        else {
            photosViewFrame.origin.x = 320;

            panelFrame.origin = CGPointMake(0, 216 - 176);
            [self.mainController.view insertSubview:self.photosController.panelView aboveSubview:self.mainController.stationsView];
        }
        self.photosController.panelView.frame = panelFrame;
        self.photosController.view.frame = photosViewFrame;
    }];
}

- (void) showRasterMap {
    [self.view insertSubview:self.glController.view belowSubview:self.mainController.view];
    [self.mainController.view removeFromSuperview];
}

- (void) showMetroMap {
    [self.view insertSubview:self.mainController.view belowSubview:self.glController.view];

    [self.glController.view removeFromSuperview];
}

- (void) showReaderWithItems:(NSArray*)items activePage:(NSInteger)activePage {
    if (categoriesOpen) {
        return;
    }
    self.readerController = [[[ReaderViewController alloc] initWithReaderItems:items] autorelease];
    [self.navigationController pushViewController:self.readerController animated:YES];
}

- (void) selectCategoryWithIndex:(NSInteger)index {
    self.currentPlaces = [[MHelper sharedHelper] getPlacesForCategoryIndex:index];
    [photosController loadPlaces:self.currentPlaces];
}


@end
