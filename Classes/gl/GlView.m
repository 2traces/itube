//
//  GlView.m
//  tube
//
//  Created by Vasiliy Makarov on 05.11.12.
//
//

#import "GlView.h"
#import "tubeAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ZonesButtonConf.h"

@implementation GlView

@synthesize zonesButton = zones;

-(void)layoutSubviews {
    if (IS_IPAD && zones) {
        //CGRect zonesRect=CGRectMake(self.bounds.size.width-70, self.bounds.size.height-50, 43, 25);
//        CGRect zonesRect=CGRectMake(self.bounds.size.width-70, self.bounds.size.height-50, 71, 43);
//        [zones setFrame:IPAD_CITYMAP_ZONES_RECT];
    }
    self.layer.cornerRadius = 5;
}

@end
