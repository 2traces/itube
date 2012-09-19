//
//  utils.m
//  tube
//
//  Created by Alex 1 on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation Utils

-(NSArray*) readMap: (NSString*)filename
{
	
	//	NSString *appFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"%@%@",filename,@".map"];
	NSString *appFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filename]];
	DLog(@" %@ ",appFile);
	NSFileHandle *nf=[NSFileHandle fileHandleForReadingAtPath:appFile];

	//NSAssert(nf=nil,@"Level file not found");
	if (nf==nil) {DLog(@"WARNING FILE NOT FOUND")}; 
	
	NSData *resp = [nf readDataOfLength: 50240];
	NSString *response = [[NSString alloc] initWithData: resp encoding: NSUTF8StringEncoding]; 
	
	//DLog(@" readed from file %@",response);
	//формируем символы 13 и 10 
	NSString *s = [NSString stringWithFormat:@"%C%C", [response characterAtIndex:1],[response characterAtIndex:2]];
//	NSString *s = [NSString stringWithFormat:@"%C", [response characterAtIndex:1]];
	
	NSArray *list1 = [response componentsSeparatedByString:s];
	DLog(@"Количество строк %d ",[list1 count]);
	
    [response release];
	
	//NSArray *ns = [NSArray arrayWithContentsOfFile:appFile];
	//DLog(@"array ellemcets count %d ",[ns count]);
	return list1;
}


+ (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    if ([sDeviceModel isEqualToString:@"iPhone1,1"]) return @"iPhone1G";   //iPhone 1G
    if ([sDeviceModel isEqualToString:@"iPhone1,2"]) return @"iPhone3G";   //iPhone 3G
    if ([sDeviceModel isEqualToString:@"iPhone2,1"]) return @"iPhone3GS";  //iPhone 3GS
    if ([sDeviceModel isEqualToString:@"iPhone3,1"]) return @"iPhone3GS";  //iPhone 4 - AT&T
    if ([sDeviceModel isEqualToString:@"iPhone3,2"]) return @"iPhone3GS";  //iPhone 4 - Other carrier
    if ([sDeviceModel isEqualToString:@"iPhone3,3"]) return @"iPhone4";    //iPhone 4 - Other carrier
    if ([sDeviceModel isEqualToString:@"iPhone4,1"]) return @"iPhone4S";   //iPhone 4S
    if ([sDeviceModel isEqualToString:@"iPod1,1"])   return @"iPod1stGen"; //iPod Touch 1G
    if ([sDeviceModel isEqualToString:@"iPod2,1"])   return @"iPod2ndGen"; //iPod Touch 2G
    if ([sDeviceModel isEqualToString:@"iPod3,1"])   return @"iPod3rdGen"; //iPod Touch 3G
    if ([sDeviceModel isEqualToString:@"iPod4,1"])   return @"iPod4thGen"; //iPod Touch 4G
    if ([sDeviceModel isEqualToString:@"iPad1,1"])   return @"iPadWiFi";   //iPad Wifi
    if ([sDeviceModel isEqualToString:@"iPad1,2"])   return @"iPad3G";     //iPad 3G
    if ([sDeviceModel isEqualToString:@"iPad2,1"])   return @"iPad2";      //iPad 2 (WiFi)
    if ([sDeviceModel isEqualToString:@"iPad2,2"])   return @"iPad2";      //iPad 2 (GSM)
    if ([sDeviceModel isEqualToString:@"iPad2,3"])   return @"iPad2";      //iPad 2 (CDMA)
    if ([sDeviceModel isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([sDeviceModel isEqualToString:@"iPad3,1"])   return @"iPad-3G (WiFi)";
    if ([sDeviceModel isEqualToString:@"iPad3,2"])   return @"iPad-3G (4G)";
    if ([sDeviceModel isEqualToString:@"iPad3,3"])   return @"iPad-3G (4G)";
    if ([sDeviceModel isEqualToString:@"i386"])      return @"Simulator";
    if ([sDeviceModel isEqualToString:@"x86_64"])    return @"Simulator";
    
    //If none was found, send the original string
    return sDeviceModel;
}

@end

