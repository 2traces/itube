//
//  Resource.m
//  tube
//
//  Created by user on 07.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Resource.h"


@implementation Resource

@synthesize selectedStation;


-(void) initData {
	selectedStation = [UIImage imageWithContentsOfFile: 
					[[NSBundle mainBundle] pathForResource:@"select_mear_station" ofType:@"png"]];
}
@end
