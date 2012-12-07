//
//  CategoriesViewController.h
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface HCTeaserObject : NSObject

+ (id) teaserObjectWithName:(NSString*)name image:(UIImage*)image url:(NSString*)url;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *urlString;

@end

@interface CategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableView;
    UIScrollView *scrollView;
    UIButton *buttonSettings;
    NSArray *categories;
    NSArray *itemsNames;
    NSArray *itemsImages;
    NSArray *itemsImagesHighlighted;
}

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSArray *teasers;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *buttonSettings;
@property (nonatomic, assign) id<NavigationDelegate> navigationDelegate;

- (IBAction)showSettings:(id)sender;


@end
