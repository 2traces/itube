//
//  UIColor+CategoriesColors.m
//  tube
//
//  Created by Alexey Starovoitov on 8/7/12.
//
//

#import "UIColor+CategoriesColors.h"

@implementation UIColor (CategoriesColors)

static NSMutableDictionary *categoriesColors = NULL;

__attribute__((constructor))
static void initialize_categoriesColors() {
    categoriesColors = [[NSMutableDictionary alloc] init];
    [categoriesColors setObject:[UIColor colorWithRed:154.0f/255.0f green:63.0f/255.0f blue:3.0f/255.0f alpha:1.0f]
                         forKey:@"11"];
    [categoriesColors setObject:[UIColor colorWithRed:56.0f/255.0f green:105.0f/255.0f blue:148.0f/255.0f alpha:1.0f]
                         forKey:@"12"];
    [categoriesColors setObject:[UIColor colorWithRed:220.0f/255.0f green:150.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
                         forKey:@"13"];
    [categoriesColors setObject:[UIColor colorWithRed:192.0f/255.0f green:45.0f/255.0f blue:11.0f/255.0f alpha:1.0f]
                         forKey:@"14"];
    [categoriesColors setObject:[UIColor colorWithRed:155.0f/255.0f green:62.0f/255.0f blue:155.0f/255.0f alpha:1.0f]
                         forKey:@"15"];
    [categoriesColors setObject:[UIColor colorWithRed:85.0f/255.0f green:182.0f/255.0f blue:153.0f/255.0f alpha:1.0f]
                         forKey:@"16"];
    [categoriesColors setObject:[UIColor colorWithRed:79.0f/255.0f green:169.0f/255.0f blue:24.0f/255.0f alpha:1.0f]
                         forKey:@"17"];
    
}

__attribute__((destructor))
static void destroy_categoriesColors() {
    [categoriesColors release];
}

+ (UIColor*)colorWithCategoryID:(NSString*)categoryID {
    UIColor *returnValue = nil;
    
    returnValue = [categoriesColors objectForKey:categoryID];
    
    if (!returnValue) {
        return [UIColor whiteColor];
    }
    
    return returnValue;
}

- (NSString*)categoryID {
    NSArray *allKeys = [categoriesColors allKeys];
    for (NSString *key in allKeys) {
        if ([[categoriesColors objectForKey:key] isEqual:self]) {
            return key;
        }
    }
    return nil;
}

@end
