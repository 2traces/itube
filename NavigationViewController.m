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
#import "SettingsNavController.h"

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
@synthesize separatingView;

- (void) showSettings {
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}


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
    [self.view insertSubview:[self.categoriesController view] belowSubview:self.separatingView];
    [self.view insertSubview:[self.mainController view] aboveSubview:self.separatingView];
    [self.view insertSubview:[self.photosController view] aboveSubview:self.mainController.view];
    
    CGRect mainViewFrame = self.mainController.view.frame;
    self.mainController.view.frame = self.glController.view.frame = self.separatingView.frame = mainViewFrame;
    
    fMetroMode = YES;
    fPhotosOpen = YES;
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
        self.mainController.view.frame = self.glController.view.frame = self.separatingView.frame = self.bookmarksController.view.frame = mainViewFrame;
        self.photosController.view.frame = photosViewFrame;
    }];
}

- (void) hideCategoriesAnimated:(BOOL)animated {
    CGFloat duration = animated ? 0.5f : 0;
    //[UIView animateWithDuration:duration animations:^{
        CGRect mainViewFrame = self.mainController.view.frame;
        CGRect photosViewFrame = self.photosController.view.frame;
        mainViewFrame.origin.x = photosViewFrame.origin.x = 0;
        categoriesOpen = NO;
        self.mainController.view.frame = self.glController.view.frame = self.separatingView.frame = mainViewFrame;
        self.photosController.view.frame = photosViewFrame;
    //}];
}

- (void) showBookmarks:(id)sender {
    if (fBookmarksOpen) {
        [self hideBookmarksLayer];
        if (!fPhotosOpen) {
            [self showPhotos];
        }
    }
    else {
        if (!fPhotosOpen) {
            //Oops!
            [self.mainController toggleTap];
        }
        [self showBookmarksLayer];
        [self hidePhotos];
    }
}

- (void)transitToPathMode{
    if (!fPhotosOpen) {
        self.photosController.placeNamePanel.hidden = YES;
        CGRect panelFrame = self.photosController.panelView.frame;
        panelFrame.origin = CGPointMake(0, 216 - 176 - (44 - 28));
        self.photosController.panelView.frame = panelFrame;
    }

}

- (void)transitToNormalMode {
    if (!fPhotosOpen) {
        self.photosController.placeNamePanel.hidden = NO;
        CGRect panelFrame = self.photosController.panelView.frame;
        panelFrame.origin = CGPointMake(0, 216 - 176);
        self.photosController.panelView.frame = panelFrame;
    }

}

- (void)showPhotos {
    
    CGRect photosViewFrame = self.photosController.view.frame;
    CGRect panelFrame = self.photosController.panelView.frame;
    
    if (!fBookmarksOpen) {
        photosViewFrame.origin.x = 0;
        panelFrame.origin = CGPointMake(0, 216);
        [self.photosController.view addSubview:self.photosController.panelView];
        [self.mainController toggleTap];
    }
    else {
        //For now we don't allow to show photos while browsing bookmarks
        return;
    }
    
    self.photosController.panelView.frame = panelFrame;
    self.photosController.view.frame = photosViewFrame;
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect photosViewFrame = self.photosController.view.frame;
        photosViewFrame.origin.y = 0;
        self.photosController.disappearingView.alpha = 1.0f;
        self.photosController.view.frame = photosViewFrame;
    } completion:^(BOOL finished) {
        [self.mainController.stationsView resetBothStations];
    }];
 
    fPhotosOpen = YES;
}

- (void)hidePhotos {
    __block BOOL fBookmarksWereOpen = fBookmarksOpen;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect photosViewFrame = self.photosController.view.frame;
        if (fBookmarksWereOpen) {
            photosViewFrame.origin.y = -216;
        }
        else {
            photosViewFrame.origin.y = -176;
            self.photosController.disappearingView.alpha = 0;
        }
        self.photosController.view.frame = photosViewFrame;
    } completion:^(BOOL finished) {
        if (!fBookmarksWereOpen) {
            CGRect photosViewFrame = self.photosController.view.frame;
            CGRect panelFrame = self.photosController.panelView.frame;
            photosViewFrame.origin.x = 320;
            panelFrame.origin = CGPointMake(0, 216 - 176);

            if (fMetroMode) {
                [self.mainController.view insertSubview:self.photosController.panelView aboveSubview:self.mainController.stationsView];
            }
            else {
                [self.glController.view insertSubview:self.photosController.panelView aboveSubview:self.glController.stationsView];
            }
            
            self.photosController.panelView.frame = panelFrame;
            self.photosController.view.frame = photosViewFrame;
        }
    }];

    
    fPhotosOpen = NO;
}

- (void) showHidePhotos:(id)sender {
    if (categoriesOpen) {
        return;
    }
    
    if (fPhotosOpen) {
        [self hidePhotos];
    }
    else {
        [self showPhotos];
    }
 }

- (void) showRasterMap {
    [self hideBookmarksLayer];
    if (fMetroMode) {
        [self.view insertSubview:self.glController.view belowSubview:self.mainController.view];
        [self.mainController.view removeFromSuperview];
        fMetroMode =  NO;
    }
}

- (void) showMetroMap {
    [self hideBookmarksLayer];
    if (!fMetroMode) {
        [self.view insertSubview:self.mainController.view belowSubview:self.glController.view];
        [self.glController.view removeFromSuperview];
        fMetroMode = YES;
    }
}

- (void) showBookmarksLayer {
    if (fBookmarksOpen) {
        return;
    }
    if (!self.bookmarksController) {
        self.bookmarksController = [[[HCBookmarksViewController alloc] initWithNibName:@"HCBookmarksViewController" bundle:[NSBundle mainBundle]] autorelease];
    }
    [self.photosController.btShowHideBookmarks setImage:[UIImage imageNamed:@"bt_bookmarks_map"] forState:UIControlStateNormal];
    if (fMetroMode) {
        [self.view insertSubview:self.bookmarksController.view aboveSubview:self.mainController.view];
    }
    else {
        [self.view insertSubview:self.bookmarksController.view aboveSubview:self.glController.view];
    }
    
    if (!fPhotosOpen) {
        CGRect photosViewFrame = self.photosController.view.frame;
        CGRect panelFrame = self.photosController.panelView.frame;
        
        photosViewFrame.origin.x = 0;
        panelFrame.origin = CGPointMake(0, 216);
        [self.photosController.view addSubview:self.photosController.panelView];
        self.photosController.panelView.frame = panelFrame;
        self.photosController.view.frame = photosViewFrame;
        photosViewFrame.origin.y = -216;
        [UIView animateWithDuration:0.2f animations:^{
            self.photosController.disappearingView.alpha = 1;

            self.photosController.view.frame = photosViewFrame;
        }];
    }
    
    self.photosController.placeNamePanel.hidden = YES;
    
    fBookmarksOpen = YES;
}

- (void) hideBookmarksLayer {
    if (fBookmarksOpen) {
        [self.bookmarksController.view removeFromSuperview];
        [self.photosController.btShowHideBookmarks setImage:[UIImage imageNamed:@"bt_photo_like"] forState:UIControlStateNormal];
        self.photosController.placeNamePanel.hidden = NO;

        fBookmarksOpen = NO;
    }
}

- (void) showReaderWithItems:(NSArray*)items activePage:(NSInteger)activePage {
    if (categoriesOpen) {
        return;
    }
    self.readerController = [[[ReaderViewController alloc] initWithReaderItems:items currentItemIndex:activePage] autorelease];
    [self.navigationController pushViewController:self.readerController animated:YES];
}

- (void) selectCategoryWithIndex:(NSInteger)index {
    self.currentPlaces = [[MHelper sharedHelper] getPlacesForCategoryIndex:index];
    [photosController loadPlaces:self.currentPlaces];
}

- (void) selectPlaceWithIndex:(NSInteger)index {
    MPlace *place = [[MHelper sharedHelper] getPlaceWithIndex:index];
    CGPoint placePosition = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    placePosition = [self.glController translateFromGeoToMap:placePosition];
    
    
    //[(MainView*)(self.mainController.view) selectStationAt:placePosition];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

//- (BOOL)shouldAutorotate {
//        return YES;
//}
//
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
//}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.photosController.view.hidden = self.categoriesController.view.hidden = self.photosController.panelView.hidden = NO;
    } else {

        [self hideCategoriesAnimated:NO];
        self.photosController.view.hidden = self.categoriesController.view.hidden = self.photosController.panelView.hidden = YES;

        
    }
}



@end
