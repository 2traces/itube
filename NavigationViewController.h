//
//  NavigationViewController.h
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import <UIKit/UIKit.h>
#import "GlViewController.h"

@class CategoriesViewController;
@class PhotosViewController;
@class MainViewController;
@class GlViewController;
@class HCBookmarksViewController;
@class ReaderViewController;

@protocol NavigationDelegate <NSObject>

- (void) showCategories:(id)sender;
- (void) showBookmarks:(id)sender;
- (void) showHidePhotos:(id)sender;
- (void) showRasterMap;
- (void) showMetroMap;
- (BOOL) isMetroMode;
- (void) showBookmarksLayer;
- (void) hideBookmarksLayer;
- (void) showReaderWithItems:(NSArray*)items activePage:(NSInteger)activePage;
- (void) selectCategoryWithIndex:(NSInteger)index;
- (CGFloat) selectPlaceWithIndex:(NSInteger)index;
- (CGFloat) radialDirectionOffsetToPlaceWithIndex:(NSInteger)index;
- (void) showSettings;
- (BOOL) photosOpen;
- (BOOL) categoriesOpen;
- (void) stickThePanelBackToPhotos;
- (void) showFullMap;
- (void) showCutMap;
- (void) centerMapOnUser;
- (void) reloadCategories;
- (void) showPurchases:(int)index;

@end

typedef enum {
    HCPhotosVisibleFully,
    HCPhotosHiddenFully,
    HCPhotosHiddenMetroDefault,
    HCPhotosHiddenMetroPath
} HCPhotosPresentationMode;

typedef enum {
    HCMetroLayer,
    HCOSMLayer,
    HCBookmarksLayer,
} HCLayerMode;

@interface NavigationViewController : UIViewController <NavigationDelegate> {
    CategoriesViewController *categoriesController;
    PhotosViewController *photosController;
    HCBookmarksViewController *bookmarksController;
    ReaderViewController *readerController;
    MainViewController *mainController;
    GlViewController *glController;
    UIView *separatingView;
    BOOL categoriesOpen;
    BOOL fMetroMode;
    HCPhotosPresentationMode photosMode;
    HCLayerMode layerMode;
    NSInteger currentPlacePin;
    UIImageView *shadow;

    CGRect rectMapFull, rectMapCut;
    
    BOOL returningFromLandscape; //another freaking dummy flag to keep old and new UI consistent and synchronized...
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mainViewController:(MainViewController*)mainViewController glViewController:(GlViewController*)glViewController;

- (void)transitToPathMode;
- (void)transitToNormalMode;

- (void)placeAddedToFavorites:(MPlace*)place;
- (void)placeRemovedFromFavorites:(MPlace*)place;

- (void) centerMapOnPlace:(MPlace*)place;


@property (nonatomic, retain) IBOutlet UIView *separatingView;
@property (nonatomic, retain) IBOutlet UIImageView *shadow;
@property (nonatomic, retain) NSArray *currentPlaces;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) CategoriesViewController *categoriesController;
@property (nonatomic, retain) PhotosViewController *photosController;
@property (nonatomic, retain) ReaderViewController *readerController;
@property (nonatomic, retain) HCBookmarksViewController *bookmarksController;
@property (nonatomic, retain) MainViewController *mainController;
@property (nonatomic, retain) GlViewController *glController;

@end
