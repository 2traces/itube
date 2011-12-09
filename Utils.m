//
//  utils.m
//  tube
//
//  Created by Alex 1 on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"


@implementation Utils

-(NSArray*) readMap: (NSString*)filename
{
	
	//	NSString *appFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"%@%@",filename,@".map"];
	NSString *appFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filename]];
	DLog(@" %@ ",appFile);
	NSFileHandle *nf=[NSFileHandle fileHandleForReadingAtPath:appFile];

	//NSAssert(nf=nil,@"Level file not found");
	if (nf==nil) DLog(@"WARNING FILE NOT FOUND"); 
	
	NSData *resp = [nf readDataOfLength: 50240];
	NSString *response = [[NSString alloc] initWithData: resp encoding: NSUTF8StringEncoding]; 
	
	//DLog(@" readed from file %@",response);
	//формируем символы 13 и 10 
	NSString *s = [NSString stringWithFormat:@"%C%C", [response characterAtIndex:1],[response characterAtIndex:2]];
//	NSString *s = [NSString stringWithFormat:@"%C", [response characterAtIndex:1]];
	
	NSArray *list1 = [response componentsSeparatedByString:s];
	DLog(@"Количество строк %d ",[list1 count]);
	
	
	//NSArray *ns = [NSArray arrayWithContentsOfFile:appFile];
	//DLog(@"array ellemcets count %d ",[ns count]);
	return list1;
}


@end
