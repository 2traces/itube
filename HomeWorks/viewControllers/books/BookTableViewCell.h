//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface BookTableViewCell : UITableViewCell


@property(nonatomic) IBOutlet UIImageView *bookImage;
@property(nonatomic) IBOutlet UILabel *nameLabel;
@property(nonatomic) IBOutlet UILabel *authorsLabel;

@end