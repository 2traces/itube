//
//  NavigationViewController.m
//  tube
//
//  Created by Alexey on 5/11/12.
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
#import "tubeAppDelegate.h"

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
@synthesize currentCategory;
@synthesize separatingView;
@synthesize shadow;

- (void) showSettings
{
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) showPurchases:(int)index
{
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (BOOL) photosOpen {
    if (photosMode == HCPhotosVisibleFully) {
        return YES;
    }
    return NO;
}

- (BOOL) categoriesOpen {
    return categoriesOpen;
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
//
//    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
//    self.view.frame = windowBounds;
    
    self.categoriesController = [[[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.categoriesController.navigationDelegate = self;
    self.photosController = [[[PhotosViewController alloc] initWithNibName:(IS_IPAD?@"PhotosViewController-iPad":@"PhotosViewController") bundle:[NSBundle mainBundle]]  autorelease];
    self.photosController.navigationDelegate = self;
    self.mainController.view.layer.cornerRadius = self.photosController.view.layer.cornerRadius = self.glController.view.layer.cornerRadius = self.separatingView.layer.cornerRadius = 5;
    self.mainController.view.layer.masksToBounds = self.photosController.view.layer.masksToBounds = YES;
    [self.view insertSubview:[self.categoriesController view] belowSubview:self.separatingView];
    [self.view insertSubview:[self.mainController view] aboveSubview:self.separatingView];
    [self.view insertSubview:[self.photosController view] aboveSubview:self.mainController.view];
    
    self.categoriesController.view.layer.cornerRadius = 5;
    self.categoriesController.view.clipsToBounds = YES;
    
    CGRect mainViewFrame = self.mainController.view.frame;
    self.mainController.view.frame = self.glController.view.frame = mainViewFrame;
    
    rectMapFull = mainViewFrame;
    rectMapCut = rectMapFull;
    
    CGFloat delta;
    
    if (IS_IPAD)
        delta = self.photosController.view.frame.size.height - 96;
    else
        delta = self.photosController.view.frame.size.height - 70;
    
    rectMapCut.size.height -= delta;
    rectMapCut.origin.y += delta;
    
    fMetroMode = YES;
    layerMode = HCMetroLayer;
    if (IS_IPAD)
    {
        photosMode = HCPhotosHiddenFully;

        [self transitPhotosToMode:HCPhotosVisibleFully animated:false];
    } else
        photosMode = HCPhotosVisibleFully;
    
    currentPlacePin = -1;
   

}

- (void)viewDidAppear:(BOOL)animated {
    
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    //self.view.frame = windowBounds;
    
    if (windowBounds.size.height > 480) {
        if (IS_IPAD)
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher_ipad.png"];
        else
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher.png"];
        CGRect frame = self.shadow.frame;
        if (IS_IPAD)
        {
            frame.size.height = 1004;
        }
        else
            frame.size.height = 548;
        self.shadow.frame = frame;
    }

    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.shouldShowRateScreen) {
        [appDelegate askForRate];
        appDelegate.shouldShowRateScreen = NO;
    }
    
    if (IS_IPAD) {
        [appDelegate.mainViewController hideiPadLeftPathView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect windowBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    //self.view.frame = windowBounds;
    
    if (windowBounds.size.height > 480) {
        if (IS_IPAD)
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher_ipad.png"];
        else
            self.shadow.image = [UIImage imageNamed:@"navigation_shadow_higher.png"];
        CGRect frame = self.shadow.frame;
        if (IS_IPAD)
        {
            frame.size.height = 1004;
        }
        else
            frame.size.height = 548;
        self.shadow.frame = frame;
    }
    
    if (photosMode == HCPhotosVisibleFully) {
        [self showCutMap];

    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showCategories:(id)sender {

    [UIView animateWithDuration:0.5f animations:^{
        CGRect mainViewFrame = self.mainController.view.frame;
        CGRect glViewFrame = self.glController.view.frame;
        CGRect photosViewFrame = self.photosController.view.frame;
        CGRect separatingFrame = self.separatingView.frame;

        if (mainViewFrame.origin.x == 0) {
            mainViewFrame.origin.x = photosViewFrame.origin.x = separatingFrame.origin.x = glViewFrame.origin.x = 227;
            categoriesOpen = YES;
        }
        else {
            mainViewFrame.origin.x = photosViewFrame.origin.x = separatingFrame.origin.x = glViewFrame.origin.x =  0;
            categoriesOpen = NO;

        }
        self.mainController.view.frame = self.bookmarksController.view.frame = mainViewFrame;
        self.glController.view.frame = glViewFrame;
        self.photosController.view.frame = photosViewFrame;
        self.separatingView.frame = separatingFrame;
    }];
}

- (void) hideCategoriesAnimated:(BOOL)animated {
    CGFloat duration = animated ? 0.5f : 0;
    //[UIView animateWithDuration:duration animations:^{
        CGRect mainViewFrame = self.mainController.view.frame;
        CGRect separatingFrame = self.separatingView.frame;
        CGRect photosViewFrame = self.photosController.view.frame;
        mainViewFrame.origin.x = photosViewFrame.origin.x = separatingFrame.origin.x = 0;
        categoriesOpen = NO;
        self.mainController.view.frame = self.glController.view.frame = mainViewFrame;
        self.photosController.view.frame = photosViewFrame;
        self.separatingView.frame = separatingFrame;
    //}];
}

- (void) showFullMap {
    CGRect newRect = self.mainController.view.frame;
    newRect.origin.y = rectMapFull.origin.y;
    newRect.size.height = rectMapFull.size.height;
    
    self.mainController.view.frame = self.glController.view.frame = newRect;
    [self.glController moveModeButtonToFullScreen];
    [self.mainController moveModeButtonToFullScreen];
}

- (void) showCutMap {
    CGRect newRect = self.mainController.view.frame;
    newRect.origin.y = rectMapCut.origin.y;
    newRect.size.height = rectMapCut.size.height;
    
    self.mainController.view.frame = newRect;
    
    CGRect specialMapRect = newRect;
    specialMapRect.origin.y += 40;
    specialMapRect.size.height -= 40;
    self.glController.view.frame = specialMapRect;
    [self.glController moveModeButtonToCutScreen];
    [self.mainController moveModeButtonToCutScreen];
}

- (void) centerMapOnUser {
    [self.glController centerMapOnUser];
    [self.mainController centerMapOnUser];
}

- (void) reloadCategories {
    [self.categoriesController reloadCategories];
}



- (void) showBookmarks:(id)sender {
    if (layerMode != HCBookmarksLayer) {
        [self showBookmarksLayer];
    }
    else {
        [self hideBookmarksLayer];
        [self transitPhotosToMode:HCPhotosVisibleFully animated:YES];
    }
}

- (void) stickThePanelBackToPhotos {
    CGRect panelFrame = self.photosController.panelView.frame;
    
    if (IS_IPAD)
        panelFrame.origin = CGPointMake(0, 745);
    else
        panelFrame.origin = CGPointMake(0, 304);
    [self.photosController.view addSubview:self.photosController.panelView];
    self.photosController.panelView.frame = panelFrame;
}

- (void)transitPhotosToMode:(HCPhotosPresentationMode)mode animated:(BOOL)animated {
    if (photosMode == mode) {
        return;
    }
    
    NSInteger oldMode = photosMode;
    
    photosMode = mode;

    CGRect photosViewFrame = self.photosController.view.frame;
    CGRect panelFrame = self.photosController.panelView.frame;
    CGFloat animationDuration = animated ? 0.5 : 0;
    
    photosViewFrame.origin.x = 0;
    if (IS_IPAD)
    {
        panelFrame.origin = CGPointMake(0, 745);
        //panelFrame.size = CGSizeMake(panelFrame.size.width, 90);
    }
    else
        panelFrame.origin = CGPointMake(0, 304);
    [self.photosController.view addSubview:self.photosController.panelView];
    self.photosController.panelView.frame = panelFrame;
    self.photosController.view.frame = photosViewFrame;
    
    switch (mode) {
        case HCPhotosVisibleFully:
            self.photosController.disappearingView.alpha = 0;
            //[self.mainController toggleTap];
            [self.mainController clearPath];
            if (IS_IPAD)
                [self.mainController hideiPadLeftPathView];

            [UIView animateWithDuration:animationDuration animations:^{
                CGRect photosViewFrame = self.photosController.view.frame;
                photosViewFrame.origin.y = 0;
                self.photosController.disappearingView.alpha = 1.0f;
                self.photosController.view.frame = photosViewFrame;
                self.photosController.placeNamePanel.hidden = NO;
                self.photosController.distanceContainer.hidden = NO;
            } completion:^(BOOL finished) {
                [self showCutMap];
                MainView *mainView = (MainView*)[self.mainController view];
                [mainView changedToLandscape:NO];

            }];
            break;
        case HCPhotosHiddenFully:
            self.photosController.disappearingView.alpha = 1;
            self.photosController.placeNamePanel.hidden = NO;
            self.photosController.distanceContainer.hidden = NO;
            [self showFullMap];

            [UIView animateWithDuration:animationDuration animations:^{
                CGRect photosViewFrame = self.photosController.view.frame;
                if (IS_IPAD)
                    photosViewFrame.origin.y = -745;
                else
                    photosViewFrame.origin.y = -304;
                self.photosController.disappearingView.alpha = 0;
                self.photosController.view.frame = photosViewFrame;
                self.photosController.placeNamePanel.hidden = NO;
                self.photosController.distanceContainer.hidden = NO;
            } completion:^(BOOL finished) {
                MainView *mainView = (MainView*)[self.mainController view];
                [mainView changedToLandscape:YES];
            }];
            break;
        case HCPhotosHiddenMetroDefault:
            self.photosController.disappearingView.alpha = 1;
            self.photosController.placeNamePanel.hidden = NO;
            self.photosController.distanceContainer.hidden = NO;
            [self showFullMap];
            returningFromLandscape = NO;
            
            if (oldMode != HCPhotosHiddenMetroPath) {
                //Here we should set the destination station
                Station *station = [self.photosController stationForCurrentPhoto];
                MStation *stationObject = [[MHelper sharedHelper] getStationWithName:station.name forLine:station.line.name];
                [self.mainController resetBothStationsInASpecialWay];

                //[self.mainController resetFromStation];
                
                Station *userStation = [self.mainController nearestStation];
                if (userStation) {
                    MStation *stationUserObject = [[MHelper sharedHelper] getStationWithName:userStation.name forLine:userStation.line.name];
                    [self.mainController returnFromSelection:[NSArray arrayWithObjects:stationUserObject, stationObject, nil]];
                    
                }
                else {
                    [self.mainController returnFromSelection:[NSArray arrayWithObject:stationObject]];
                }
            }

            
            [UIView animateWithDuration:animationDuration animations:^{
                CGRect photosViewFrame = self.photosController.view.frame;
                if (IS_IPAD)
                    photosViewFrame.origin.y = -702;
                else
                    photosViewFrame.origin.y = -261;
                self.photosController.disappearingView.alpha = 0;
                self.photosController.view.frame = photosViewFrame;
            } completion:^(BOOL finished) {                
                CGRect photosViewFrame = self.photosController.view.frame;
                CGRect panelFrame = self.photosController.panelView.frame;
                if (IS_IPAD) {
                    photosViewFrame.origin.x = self.view.frame.size.width;
                    panelFrame.origin = CGPointMake(0, 745 - 702);
                } else {
                    photosViewFrame.origin.x = 320;
                    panelFrame.origin = CGPointMake(0, 304 - 261);
                }
                [self.mainController.view insertSubview:self.photosController.panelView aboveSubview:self.mainController.stationsView];
                self.photosController.panelView.frame = panelFrame;
                self.photosController.view.frame = photosViewFrame;
                
                MainView *mainView = (MainView*)[self.mainController view];
                [mainView changedToLandscape:YES];
        
            }];
            break;
        case HCPhotosHiddenMetroPath:
            [self.mainController toggleTap];
            self.photosController.disappearingView.alpha = 1;
            self.photosController.placeNamePanel.hidden = NO;
            self.photosController.distanceContainer.hidden = NO;
            [self showFullMap];

            [UIView animateWithDuration:animationDuration animations:^{
                CGRect photosViewFrame = self.photosController.view.frame;
                if (IS_IPAD)
                    photosViewFrame.origin.y = -702;
                else
                    photosViewFrame.origin.y = -261;
                self.photosController.disappearingView.alpha = 0;
                self.photosController.view.frame = photosViewFrame;
            } completion:^(BOOL finished) {
                if (returningFromLandscape) {
                    returningFromLandscape = NO;
                    return;
                }
                if (!IS_IPAD)
                    self.photosController.placeNamePanel.hidden = YES;
                self.photosController.distanceContainer.hidden = YES;
                CGRect photosViewFrame = self.photosController.view.frame;
                CGRect panelFrame = self.photosController.panelView.frame;
                if (IS_IPAD) {
                    photosViewFrame.origin.x = self.view.frame.size.width;
                    panelFrame.origin = CGPointMake(0, 745 - 702);
                } else {
                    photosViewFrame.origin.x = 320;
                    panelFrame.origin = CGPointMake(0, 304 - 261 - (44 - 28));
                }
                
                [self.mainController.view insertSubview:self.photosController.panelView aboveSubview:self.mainController.stationsView];
                
                self.photosController.panelView.frame = panelFrame;
                self.photosController.view.frame = photosViewFrame;
                
                MainView *mainView = (MainView*)[self.mainController view];
                [mainView changedToLandscape:YES];
            }];
            break;
            
        default:
            break;
    }
}

- (void)transitToPathMode{
    [self transitPhotosToMode:HCPhotosHiddenMetroPath animated:NO];
}

- (void)transitToNormalMode {
    [self transitPhotosToMode:HCPhotosHiddenMetroDefault animated:NO];
}


- (void)placeAddedToFavorites:(MPlace*)place {
    MainView* map = (MainView*)[self.mainController view];
    CGPoint placePoint = CGPointMake([place.posX floatValue], [place.posY floatValue]);

    Station *nearestStation = [map stationNearestToGeoPosition:placePoint];

    [self.glController setStarAtPlace:place color:nearestStation.line.pinColor];
    [self.mainController setStarAtStation:nearestStation];
}

- (void)placeRemovedFromFavorites:(MPlace*)place {
    MainView* map = (MainView*)[self.mainController view];
    CGPoint placePoint = CGPointMake([place.posX floatValue], [place.posY floatValue]);

    Station *nearestStation = [map stationNearestToGeoPosition:placePoint];
    [self.glController removePinAtPlace:place];
    [self.mainController removeStarFromStation:nearestStation.name];
}

- (void) showHidePhotos:(id)sender {
    if (categoriesOpen) {
        return;
    }
    if (layerMode == HCBookmarksLayer) {
        [self hideBookmarksLayer];
        [self transitPhotosToMode:HCPhotosVisibleFully animated:YES];
        return;
    }
    if (photosMode != HCPhotosVisibleFully) {
        [self transitPhotosToMode:HCPhotosVisibleFully animated:YES];
    }
    else {
        if (layerMode == HCMetroLayer) {
            [self transitPhotosToMode:HCPhotosHiddenMetroDefault animated:YES];
        }
        else {
            [self transitPhotosToMode:HCPhotosHiddenFully animated:YES];
        }
    }
 }

- (void) switchToLayerMode:(HCLayerMode)mode {
    if (mode == layerMode) {
        //If we're trying to set same layer, do nothing
        return;
    }
    HCLayerMode oldMode = layerMode;

    if (layerMode == HCBookmarksLayer) {
        //As bookmarks layer is just placed ABOVE map/metro layer, we need to first dismiss it
        [self.bookmarksController.view removeFromSuperview];
        [self.photosController.btShowHideBookmarks setImage:[UIImage imageNamed:@"bt_photo_like"] forState:UIControlStateNormal];
        self.photosController.placeNamePanel.hidden = NO;
        self.photosController.btShowHideBookmarks.enabled = YES;

        [self.photosController updateInfoForCurrentPage];
        if (fMetroMode) {
            layerMode = HCMetroLayer;
        }
        else {
            layerMode = HCOSMLayer;
        }
    }
    //As layerMode could have changed after removing bookmarks layer, check once more
    if (mode != layerMode) {
        switch (mode) {
            case HCBookmarksLayer:
                //Also, as bookmarks layer is simply placed ABOVE any other layer, if we need to show it, we just do
                if (!self.bookmarksController) {
                    self.bookmarksController = [[[HCBookmarksViewController alloc] initWithNibName:@"HCBookmarksViewController" bundle:[NSBundle mainBundle]] autorelease];
                }
                CGRect frame = self.bookmarksController.view.frame;
                frame.origin = CGPointMake(0, 0);
                self.bookmarksController.view.frame = frame;
//                [self.photosController.btShowHideBookmarks setImage:[UIImage imageNamed:@"bt_bookmarks_map"] forState:UIControlStateNormal];
                self.photosController.btShowHideBookmarks.enabled = NO;
                if (fMetroMode) {
                    [self.view insertSubview:self.bookmarksController.view aboveSubview:self.mainController.view];
                }
                else {
                    [self.view insertSubview:self.bookmarksController.view aboveSubview:self.glController.view];
                }
                [self transitPhotosToMode:HCPhotosHiddenFully animated:YES];
                layerMode = HCBookmarksLayer;
                self.photosController.placeNamePanel.text = @"Bookmarks";

                break;
            case HCMetroLayer:
                [self.view insertSubview:self.mainController.view belowSubview:self.glController.view];
                [self.glController.view removeFromSuperview];
                fMetroMode = YES;
                layerMode = HCMetroLayer;
                break;
            case HCOSMLayer:
                [self.view insertSubview:self.glController.view belowSubview:self.mainController.view];
                [self.mainController.view removeFromSuperview];
                fMetroMode = NO;
                layerMode = HCOSMLayer;
                break; 
                
            default:
                break;
        }
    }
    //Adjust photos position
    switch (layerMode) {
        case HCBookmarksLayer:
            [self transitPhotosToMode:HCPhotosHiddenFully animated:YES];
            break;
        case HCMetroLayer:
            if (oldMode == HCBookmarksLayer) {
                [self transitPhotosToMode:HCPhotosVisibleFully animated:YES];
            }
            else if (photosMode == HCPhotosHiddenFully) {
                [self transitPhotosToMode:HCPhotosHiddenMetroDefault animated:YES];
            }
            break;
        case HCOSMLayer:
            if (photosMode == HCPhotosHiddenMetroDefault || photosMode == HCPhotosHiddenMetroPath) {
                [self transitPhotosToMode:HCPhotosHiddenFully animated:YES];
            }
            break;
            
        default:
            break;
    }
}

- (void) showRasterMap {
    [self switchToLayerMode:HCOSMLayer];

}

- (void) showMetroMap {
    [self switchToLayerMode:HCMetroLayer];
}

- (void) showBookmarksLayer {
    [self switchToLayerMode:HCBookmarksLayer];
}

- (BOOL) isMetroMode {
    return fMetroMode;
}

- (void) hideBookmarksLayer {
    [self switchToLayerMode:fMetroMode ? HCMetroLayer : HCOSMLayer];
}

- (void) showReaderWithItems:(NSArray*)items activePage:(NSInteger)activePage {
    if (categoriesOpen) {
        [self showCategories:nil];
        return;
    }
    self.readerController = [[[ReaderViewController alloc] initWithReaderItems:items currentItemIndex:activePage] autorelease];
    [self.navigationController pushViewController:self.readerController animated:YES];
}

- (void) selectCategoryWithIndex:(NSInteger)index {
    self.currentPlaces = [[MHelper sharedHelper] getPlacesForCategoryIndex:index];
    MCategory * category = self.categoriesController.categories[index - 1];
    self.currentCategory = category.name;
    [photosController loadPlaces:self.currentPlaces];

}

- (void) centerMapOnPlace:(MPlace*)place {
    CGPoint placePosition = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    [(MainView*)(self.mainController.view) setGeoPosition:placePosition withZoom:-1];
    [self.glController setGeoPosition:placePosition withZoom:-1];
}

- (CGFloat) selectPlaceWithIndex:(NSInteger)index {
    MPlace *place = [[MHelper sharedHelper] getPlaceWithIndex:index];
    CGPoint placePosition = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    
    [(MainView*)(self.mainController.view) setGeoPosition:placePosition withZoom:100500];
    [self.glController scrollToGeoPosition:placePosition withZoom:60000];
    //if (currentPlacePin != -1) {
    //    [self.glController removePin:currentPlacePin];
    //}
    currentPlacePin = [self.glController setLocation:placePosition];
    Pin *pin = [self.glController getPin:currentPlacePin];
    return pin.distanceToUser;
}


- (CGFloat) radialDirectionOffsetToPlaceWithIndex:(NSInteger)index {
    MPlace *place = [[MHelper sharedHelper] getPlaceWithIndex:index];
    CGPoint placePosition = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    return [glController radialOffsetToPoint:placePosition];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if (IS_IPAD)
        return interfaceOrientation == UIInterfaceOrientationPortrait;// || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
    
    if (layerMode == HCBookmarksLayer || self.presentedViewController) {
            return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    if (IS_IPAD)
        return UIInterfaceOrientationMaskPortrait ;//| UIInterfaceOrientationMaskPortraitUpsideDown;
    if (layerMode == HCBookmarksLayer || self.presentedViewController) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    MainView *mainView = (MainView*)[self.mainController view];
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        returningFromLandscape = YES;
        [mainView changedToLandscape:NO];
        if (!IS_IPAD)
        {
            photosMode = HCPhotosHiddenFully;
            [self transitPhotosToMode:HCPhotosVisibleFully animated:NO];
        } else
        {
            if (photosMode != HCPhotosVisibleFully)
            {
                photosMode = HCPhotosVisibleFully;
                [self transitPhotosToMode:HCPhotosHiddenMetroPath animated:NO];
            }
        }
        self.photosController.view.hidden = self.categoriesController.view.hidden = self.photosController.panelView.hidden = NO;

    } else {
        [mainView changedToLandscape:YES];
        if (layerMode == HCBookmarksLayer) {
            //As bookmarks layer is just placed ABOVE map/metro layer, we need to first dismiss it
            [self.bookmarksController.view removeFromSuperview];
            [self.photosController.btShowHideBookmarks setImage:[UIImage imageNamed:@"bt_photo_like"] forState:UIControlStateNormal];
            self.photosController.placeNamePanel.hidden = NO;
            if (fMetroMode) {
                layerMode = HCMetroLayer;
            }
            else {
                layerMode = HCOSMLayer;
            }
        }
        if (self.presentedViewController) {
            [self.presentedViewController dismissModalViewControllerAnimated:YES];
        }

        [self hideCategoriesAnimated:NO];
        //[self transitPhotosToMode:HCPhotosVisibleFully animated:NO];
        if (IS_IPAD)
        {
            self.categoriesController.view.hidden = YES;
            
            /*if (photosMode != HCPhotosVisibleFully)
            {
                photosMode = HCPhotosVisibleFully;
                [self transitPhotosToMode:HCPhotosHiddenMetroPath animated:NO];
            } else*/
                [self transitPhotosToMode:photosMode animated:NO];
        }
        else
        {
            self.photosController.view.hidden = self.categoriesController.view.hidden = self.photosController.panelView.hidden = YES;
        
            [self showFullMap];
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (IS_IPAD)
        [self.photosController reloadScrollView]; // TODO: save current position
}


@end
