//
//  Schedule.h
//  tube
//
//  Created by vasiliym on 07.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject {
    NSString *lineName;
}
@property (nonatomic, readonly) NSString* lineName;

+(NSDictionary*) loadSchedules:(NSString*)fileName;
-(id)initWithName:(NSString*)name andFile:(NSString*)fileName;

@end
