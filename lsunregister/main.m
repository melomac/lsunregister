#include <getopt.h>

#import <Foundation/Foundation.h>

#import "LaunchServices.h"


static int main_ap(int argc, const char *argv[]);
static int print_all(void);
static int unregister(NSPredicate *predicate);
static void usage(void);


#pragma mark -


int main(int argc, const char *argv[])
{
	@autoreleasepool
	{
		return main_ap(argc, argv);
	}
}


static int main_ap(int argc, const char *argv[])
{
	int ch;
	
	static struct option longopts[] = {
		{ "debug",	no_argument,		NULL,	'd' },
		{ "help",	no_argument,		NULL,	'h' },
		{ "like",	required_argument,	NULL,	'l' },
		{ "prefix",	required_argument,	NULL,	'p' },
		{ "regex",	required_argument,	NULL,	'r' },
		{ NULL,		0,					NULL,	 0  }
	};
	
	while ((ch = getopt_long(argc, (char * const *)argv, "dhl:p:r:", longopts, NULL)) != -1)
	{
		switch (ch)
		{
			case 'd':
				return print_all();
			
			case 'h':
			{
				usage();
				
				return EXIT_SUCCESS;
			}
			
			case 'l':
			{
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleURL.path LIKE %@", @(optarg)];
				
				return unregister(predicate);
			}
			
			case 'p':
			{
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleURL.path BEGINSWITH %@", @(optarg).stringByExpandingTildeInPath];
				
				return unregister(predicate);
			}
			
			case 'r':
			{
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleURL.path MATCHES %@", @(optarg)];
				
				return unregister(predicate);
			}
		}
	}
	
	usage();
	
	return EXIT_FAILURE;
}


#pragma mark -


static int print_all(void)
{
	LSApplicationWorkspace *workspace = [LSApplicationWorkspace defaultWorkspace];
	
	if (workspace == nil)
		return EXIT_FAILURE;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleURL.path != nil"];
	
	for (NSBundle *proxy in [workspace.allApplications filteredArrayUsingPredicate:predicate])
		fprintf(stdout, "%s\n", proxy.bundleURL.path.UTF8String);
	
	return EXIT_SUCCESS;
}


static int unregister(NSPredicate *predicate)
{
	LSApplicationWorkspace *workspace = [LSApplicationWorkspace defaultWorkspace];
	
	if (workspace == nil || _LSUnregisterURL == NULL)
		return EXIT_FAILURE;
	
	for (NSBundle *proxy in [workspace.allApplications filteredArrayUsingPredicate:predicate])
	{
		CFURLRef urlRef = (__bridge CFURLRef)proxy.bundleURL;
		
		if (urlRef == nil)
		{
			fprintf(stderr, "Unregister failure: %s (CFURLRef is nil)\n", proxy.bundleURL.path.UTF8String);
			
			continue;
		}
		
		OSStatus status = _LSUnregisterURL(urlRef);
		
		if (status != noErr)
		{
			fprintf(stderr, "Unregister failure: %s (%s: %s)\n", proxy.bundleURL.path.UTF8String, GetMacOSStatusErrorString(status), GetMacOSStatusCommentString(status));
			
//			NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
//			
//			fprintf(stderr, "Unregister failure: %s (%s)\n", proxy.bundleURL.path.UTF8String, error.description.UTF8String);
			
			continue;
		}
		
		fprintf(stdout, "Unregister success: %s\n", proxy.bundleURL.path.UTF8String);
	}
	
	return EXIT_SUCCESS;
}


static void usage(void)
{
	fprintf(stderr, "\n");
	fprintf(stderr, "Usage:\n");
	fprintf(stderr, "   lsunregister --prefix / -p <prefix>\n");
	fprintf(stderr, "   lsunregister --like   / -l <pattern>\n");
	fprintf(stderr, "   lsunregister --regex  / -r <regular expression>\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "Helper:\n");
	fprintf(stderr, "   lsunregister --debug  / -d : print all registered applications and exit.\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "Examples:\n");
	fprintf(stderr, "   lsunregister --prefix ~/.Trash/\n");
	fprintf(stderr, "   lsunregister --like   \"/Volumes/*/.Trashes/*\"\n");
	fprintf(stderr, "   lsunregister --regex  \"/Users/.*?/(\\.Trash|Desktop|Downloads|Library/Mail)/.*\"\n");
	fprintf(stderr, "   lsunregister --debug  | sort\n");
	fprintf(stderr, "\n");
}

