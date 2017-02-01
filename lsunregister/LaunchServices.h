#import <Foundation/Foundation.h>


extern OSStatus _LSUnregisterURL(CFURLRef url) __attribute__((weak_import));


@interface LSApplicationWorkspace : NSObject

@property (readonly) NSArray *allApplications;

+ (id)defaultWorkspace;

@end

