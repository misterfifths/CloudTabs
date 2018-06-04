// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "AppDelegate.h"
#import "SynchronousNativeHost.h"
#import "SafariSharedHelpers.h"
#import "NativeHostMessages.h"


@interface AppDelegate () <SynchronousNativeHostDelegate, WBSCloudTabStoreDelegate> {
    dispatch_semaphore_t _updateSemaphore;
}

@property (nonatomic, strong) SynchronousNativeHost *nativeHost;
@property (nonatomic, strong) WBSCloudTabStore *tabStore;

@end


@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _updateSemaphore = dispatch_semaphore_create(0);

    self.tabStore = [WBSCloudTabStore new];
    self.tabStore.wbsDelegate = self;

    // Go ahead and kick off a fetch. It's probably the first thing we'll be asked for anyway.
    [self.tabStore fetchSyncedCloudTabDevicesAndCloseRequestsFromCloudKit];


    self.nativeHost = [[SynchronousNativeHost alloc] initWithDelegate:self];;
    self.nativeHost.messageDeserializer = [NativeHostMessage class];
    [self.nativeHost startReadLoop];
}


#pragma mark - Message handling

-(void)awaitUpdate
{
    [self awaitUpdateWithTimeout:NSUIntegerMax];
}

-(BOOL)awaitUpdateWithTimeout:(NSUInteger)milliseconds
{
    // Is an update waiting for us?
    if(dispatch_semaphore_wait(_updateSemaphore, DISPATCH_TIME_NOW) == 0) return YES;

    [self.tabStore fetchSyncedCloudTabDevicesAndCloseRequestsFromCloudKit];

    dispatch_time_t timeout;
    if(milliseconds == NSUIntegerMax) timeout = DISPATCH_TIME_FOREVER;
    else timeout = dispatch_time(DISPATCH_TIME_NOW, milliseconds * NSEC_PER_MSEC);

    return dispatch_semaphore_wait(_updateSemaphore, timeout) == 0;
}

-(nullable id)handleMessage:(NativeHostMessage *)message
{
    // The "re" field is the id of the message to which this is a response.
    // Useful for debugging, maybe? I originally thought I was going to need to wire up
    // a whole asynchronous reply system on the client, but it turned out otherwise.

    if([message isKindOfClass:[GetTabsMessage class]]) {
        [self awaitUpdate];

        NSMutableDictionary *res = [[self.tabStore jsonRepresentation] mutableCopy];
        res[@"re"] = @(message.messageID);

        return res;
    }
    else if([message isKindOfClass:[CloseTabMessage class]]) {
        CloseTabMessage *closeTabMessage = (CloseTabMessage *)message;
        BOOL success = [self.tabStore closeTabWithUUID:closeTabMessage.tabUUID
                                         onDeviceNamed:closeTabMessage.deviceName];

        return @{ @"re": @(message.messageID),
                  @"success": @(success) };
    }
    else if([message isKindOfClass:[CloseAllTabsMessage class]]) {
        CloseAllTabsMessage *closeAllTabsMessage = (CloseAllTabsMessage *)message;
        BOOL success = [self.tabStore closeAllTabsOnDeviceNamed:closeAllTabsMessage.deviceName];

        return @{ @"re": @(message.messageID),
                  @"success": @(success) };
    }

    NSLog(@"Unsupported message type %@", message.class);
    return nil;
}


#pragma mark - SynchronousNativeHostDelegate and friends

-(id)nativeHost:(SynchronousNativeHost *)host willSendResponseToMessage:(id)message
{
    return [self handleMessage:message];
}

-(void)nativeHostDidExitReadLoop:(SynchronousNativeHost *)host
{
    [NSApp terminate:self];
}


#pragma mark - WBSCloudTabStoreDelegate

-(void)didUpdateDevicesAndCloseRequestsFromCloudKitForCloudTabStore:(WBSCloudTabStore *)cloudTabStore
{
    dispatch_semaphore_signal(_updateSemaphore);
}

@end
