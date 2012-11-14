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

@protocol NavigationDelegate <NSObject>

- (void) showCategories:(id)sender;
- (void) showBookmarks:(id)sender;
- (void) showHidePhotos:(id)sender;
- (void) showRasterMap;
- (void) showMetroMap;

@end

@interface NavigationViewController : UIViewController <NavigationDelegate> {
    CategoriesViewController *categoriesController;
    PhotosViewController *photosController;
    HCBookmarksViewController *bookmarksController;
    MainViewController *mainController;
    GlViewController *glController;
    BOOL categoriesOpen;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mainViewController:(MainViewController*)mainViewController glViewController:(GlViewController*)glViewController;

@property (nonatomic, retain) CategoriesViewController *categoriesController;
@property (nonatomic, retain) PhotosViewController *photosController;
@property (nonatomic, retain) HCBookmarksViewController *bookmarksController;
@property (nonatomic, retain) MainViewController *mainController;
@property (nonatomic, retain) GlViewController *glController;

@end
