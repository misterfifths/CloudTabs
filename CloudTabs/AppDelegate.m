// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "AppDelegate.h"
#import "SafariShared.h"
#import "WebLocWriter.h"


@interface AppDelegate () <WBSCloudTabStoreDelegate>

@property (nonatomic, strong) WBSCloudTabStore *tabStore;
@property (nonatomic, strong) NSURL *dumpDirectoryURL;

@end


@implementation AppDelegate

-(instancetype)initWithDumpDirectoryURL:(NSURL *)dumpDirectoryURL
{
    self = [super init];
    if(self) {
        _dumpDirectoryURL = dumpDirectoryURL;
    }

    return self;
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.tabStore = [WBSCloudTabStore new];
    self.tabStore.wbsDelegate = self;
    [self.tabStore fetchSyncedCloudTabDevicesAndCloseRequestsFromCloudKit];

    NSLog(@"Fetching...");
}

-(void)didUpdateDevicesAndCloseRequestsFromCloudKitForCloudTabStore:(WBSCloudTabStore *)cloudTabStore
{
    NSArray<WBSCloudTabDevice *> *devices = cloudTabStore.syncedCloudTabDevices;

    NSString *deviceNames = [[devices valueForKey:@"name"] componentsJoinedByString:@", "];
    NSLog(@"Found %lu devices: %@", devices.count, deviceNames);

    [[self class] dumpTabsFromDevices:devices toDirectory:self.dumpDirectoryURL];

    [NSApp terminate:nil];
}

+(void)dumpTabsFromDevices:(NSArray<WBSCloudTabDevice *> *)devices toDirectory:(NSURL *)directoryURL
{
    for(WBSCloudTabDevice *device in devices) {
        if(device.tabs.count == 0) continue;

        NSString *directoryName = [NSString stringWithFormat:@"%@-tabs", device.name];
        NSURL *deviceDirectory = [directoryURL URLByAppendingPathComponent:directoryName isDirectory:YES];

        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:deviceDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if(!success) {
            NSLog(@"Error creating directory: %@", error);
            continue;
        }

        [self dumpTabsFromDevice:device toDirectory:deviceDirectory];
    }
}

+(void)dumpTabsFromDevice:(WBSCloudTabDevice *)device toDirectory:(NSURL *)directoryURL
{
    NSLog(@"Dumping %lu tabs from %@ to %@", device.tabs.count, device.name, directoryURL);
    for(WBSCloudTab *tab in device.tabs) {
        [self dumpTab:tab fromDevice:device toDirectory:directoryURL];
    }
}

+(void)dumpTab:(WBSCloudTab *)tab fromDevice:(WBSCloudTabDevice *)device toDirectory:(NSURL *)directoryURL
{
    NSError *error = nil;
    if(![WebLocWriter writeWebLocForURL:tab.url title:tab.title toDirectory:directoryURL error:&error]) {
        NSLog(@"Error writing webloc for %@: %@", tab.title, error);
    }
}

@end
