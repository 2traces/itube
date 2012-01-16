//
//  Server.h
//  iPif
//
//  Created by SergeyM on 30/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerListener;

@interface Server : NSObject {
	NSURLConnection *connection;
	NSMutableData *responseData;
	id <ServerListener> listener;
}

@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, assign) id <ServerListener> listener;

-(void) sendRequestStationList:(NSArray *)stationList;
-(NSString*)responseXml;

@end


@protocol ServerListener

-(void)serverDone:(NSMutableDictionary*)schedule;

@end