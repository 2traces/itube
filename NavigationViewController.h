//
//  NavigationViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
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
- (void) showReaderWithItems:(NSArray*)items activePage:(NSInteger)activePage;
- (void) selectCategoryWithIndex:(NSInteger)index;
- (void) selectPlaceWithIndex:(NSInteger)index;

@end

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
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mainViewController:(MainViewController*)mainViewController glViewController:(GlViewController*)glViewController;

@property (nonatomic, retain) IBOutlet UIView *separatingView;
@property (nonatomic, retain) NSArray *currentPlaces;
@property (nonatomic, retain) CategoriesViewController *categoriesController;
@property (nonatomic, retain) PhotosViewController *photosController;
@property (nonatomic, retain) ReaderViewController *readerController;
@property (nonatomic, retain) HCBookmarksViewController *bookmarksController;
@property (nonatomic, retain) MainViewController *mainController;
@property (nonatomic, retain) GlViewController *glController;

@end
