// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <AppKit/AppKit.h>
#import "AppDelegate.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSURL *dumpDirectoryURL = [NSURL fileURLWithPath:@"~/Desktop/cloudtabs-dump".stringByExpandingTildeInPath isDirectory:YES];
        AppDelegate *appDelegate = [[AppDelegate alloc] initWithDumpDirectoryURL:dumpDirectoryURL];

        NSApplication.sharedApplication.delegate = appDelegate;
        [NSApplication.sharedApplication run];
    }

    return 0;
}
