//
//  CategoryCell.h
//  tube
//
//  Created by Alexey Starovoitov on 12/11/12.
//
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell

@property (nonatomic, retain) UIImage *imageNormal;
@property (nonatomic, retain) UIImage *imagePressed;
@property (nonatomic, retain) UIImageView *imageCategory;
@property (nonatomic, retain) UILabel *labelCategory;

- (id)initwithTitle:(NSString*)title image:(UIImage*)image highlightedImage:(UIImage*)highlighted;

@end
