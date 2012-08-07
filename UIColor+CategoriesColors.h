//
//  UIColor+CategoriesColors.h
//  tube
//
//  Created by Alexey Starovoitov on 8/7/12.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (CategoriesColors)

+ (UIColor*)colorWithCategoryID:(NSString*)categoryID;
- (NSString*)categoryID;

@end
