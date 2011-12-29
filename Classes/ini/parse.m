#include <stdio.h>
#include <string.h>

#import "ini.h"

@implementation INIParser (Parsing)

- (int)parse: (char *)filename
{
	int err;
	char buf [1024];
	char * lb;
	FILE * file;
	
	file = fopen (filename, "r");
	if (file == NULL)
		return INIP_ERROR_FOPEN_FAILED;

	while (1) {
		if (fgets (buf, 1023, file) == NULL)
			break;

		lb = [self trim: buf];
		//if (*lb == 0)
		//	break;

		if ((*lb != 0)){
			err = [self parseLine: lb];
			if (err != INIP_ERROR_NONE) {
				fclose (file);
				return err;
			}
			
		}
	}
	
	fclose (file);
	return INIP_ERROR_NONE;
}

- (int)parseLine: (char *) line
{
	int err;

	if (*line == '[') err = [self parseSection: line];
	else		  err = [self parseAssignment: line];
	
	return err;
}

- (int)parseSection: (char *)line
{
	INISection * section;
	NSString * name;
	char * l;
	
	l = strchr (line, ']');
	if (l == NULL)
		return INIP_ERROR_INVALID_SECTION;
	
	*l = 0;
	name = [NSString stringWithUTF8String: line +1];
	section = [[INISection alloc] initWithName: name];
	[sections setObject: section forKey: name];
	csection = section;
	return INIP_ERROR_NONE;
}

- (int)parseAssignment: (char *)line
{
	char * name, * value;
	NSString * n, * v;
	
	if (csection == nil)
		return INIP_ERROR_NO_SECTION;

	name = line;
	value = strchr (name, '=');
	if (value == NULL)
		return INIP_ERROR_INVALID_ASSIGNMENT;
	
	*value++ = 0;
	n = [NSString stringWithUTF8String: name];
	v = [NSString stringWithUTF8String: value];
	[csection insert: n value: v];
	return INIP_ERROR_NONE;
}

@end
