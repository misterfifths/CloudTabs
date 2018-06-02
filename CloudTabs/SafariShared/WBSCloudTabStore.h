// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <Foundation/Foundation.h>

@class WBSCloudTabDevice;
@class WBSCloudTab;
@protocol WBSCloudTabStoreDelegate;


NS_ASSUME_NONNULL_BEGIN


@interface WBSCloudTabStore : NSObject

@property (nonatomic, copy, readonly) NSArray<WBSCloudTabDevice *> *syncedCloudTabDevices;
@property (nonatomic, copy, readonly) NSDate *dateOfLastCloudTabDevicesUpdate;

@property (nonatomic, weak) id<WBSCloudTabStoreDelegate> wbsDelegate;


// Calling this refreshes syncedCloudTabDevices. The delegate method
// didUpdateDevicesAndCloseRequestsFromCloudKitForCloudTabStore: is called on completion.
-(void)fetchSyncedCloudTabDevicesAndCloseRequestsFromCloudKit;

-(BOOL)closeTab:(WBSCloudTab *)tab onDevice:(WBSCloudTabDevice *)device;
-(BOOL)closeTabs:(NSArray<WBSCloudTab *> *)tabs onDevice:(WBSCloudTabDevice *)device;
-(BOOL)closeAllTabsOnDevice:(WBSCloudTabDevice *)device;

@end


@protocol WBSCloudTabStoreDelegate <NSObject>

@optional
-(void)didUpdateDevicesAndCloseRequestsFromCloudKitForCloudTabStore:(WBSCloudTabStore *)cloudTabStore;

@end


NS_ASSUME_NONNULL_END
