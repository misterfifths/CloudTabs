// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <AppKit/AppKit.h>
#import "AppDelegate.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        AppDelegate *appDelegate = [AppDelegate new];

        NSApplication.sharedApplication.delegate = appDelegate;
        [NSApplication.sharedApplication run];
    }

    return 0;
}
