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

@interface NavigationViewController : UIViewController {
    CategoriesViewController *categoriesController;
    PhotosViewController *photosController;
    MainViewController *mainController;
}

@property (nonatomic, retain) CategoriesViewController *categoriesController;
@property (nonatomic, retain) PhotosViewController *photosController;
@property (nonatomic, retain) MainViewController *mainController;

@end
