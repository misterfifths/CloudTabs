// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "SafariSharedHelpers.h"


@implementation WBSCloudTabStore (Helpers)

-(NSDictionary *)jsonRepresentation
{
    NSMutableArray *deviceDicts = [NSMutableArray arrayWithCapacity:self.syncedCloudTabDevices.count];
    for(WBSCloudTabDevice *device in self.syncedCloudTabDevices) {
        [deviceDicts addObject:[device jsonRepresentation]];
    }

    return @{ @"devices": deviceDicts };
}

-(WBSCloudTabDevice *)deviceNamed:(NSString *)deviceName
{
    for(WBSCloudTabDevice *device in self.syncedCloudTabDevices) {
        if([device.name isEqualToString:deviceName]) {
            return device;
        }
    }

    return nil;
}

-(BOOL)closeTabWithUUID:(NSUUID *)uuid onDeviceNamed:(NSString *)deviceName
{
    WBSCloudTabDevice *device = [self deviceNamed:deviceName];
    if(!device) return NO;

    WBSCloudTab *tab = [device tabWithUUID:uuid];
    if(!tab) return NO;

    return [self closeTab:tab onDevice:device];
}

-(BOOL)closeAllTabsOnDeviceNamed:(NSString *)deviceName
{
    WBSCloudTabDevice *device = [self deviceNamed:deviceName];
    if(!device) return NO;

    return [self closeAllTabsOnDevice:device];
}

@end


@implementation WBSCloudTabDevice (Helpers)

-(NSDictionary *)jsonRepresentation
{
    NSMutableArray *tabDicts = [NSMutableArray arrayWithCapacity:self.tabs.count];

    // Tabs are newest-last, so I'm reversing them here as a personal preference.
    for(WBSCloudTab *tab in self.tabs.reverseObjectEnumerator) {
        [tabDicts addObject:[tab jsonRepresentation]];
    }

    static NSISO8601DateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSISO8601DateFormatter new];
    });

    return @{ @"name": self.name,
              @"lastModified": [dateFormatter stringFromDate:self.lastModified],
              @"supportsCloseRequests": @(self.isCloseRequestSupported),
              @"tabs": tabDicts };
}

-(WBSCloudTab *)tabWithUUID:(NSUUID *)uuid
{
    for(WBSCloudTab *tab in self.tabs) {
        if([tab.uuid isEqual:uuid]) {
            return tab;
        }
    }

    return nil;
}

@end


@implementation WBSCloudTab (Helpers)

-(NSDictionary *)jsonRepresentation
{
    return @{ @"title": self.title,
              @"url": self.url.absoluteString,
              @"uuid": self.uuid.UUIDString };
}

@end
