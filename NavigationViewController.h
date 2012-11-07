//
//  NavigationViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 5/11/12.
//
//

#import <UIKit/UIKit.h>

@class CategoriesViewController;
@class PhotosViewController;
@class MainViewController;

@protocol NavigationDelegate <NSObject>

- (void) showCategories:(id)sender;

@end

@interface NavigationViewController : UIViewController <NavigationDelegate> {
    CategoriesViewController *categoriesController;
    PhotosViewController *photosController;
    MainViewController *mainController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mainViewController:(MainViewController*)mainViewController;


@property (nonatomic, retain) CategoriesViewController *categoriesController;
@property (nonatomic, retain) PhotosViewController *photosController;
@property (nonatomic, retain) MainViewController *mainController;

@end
