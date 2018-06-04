// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <Foundation/Foundation.h>
#import "SafariShared.h"


NS_ASSUME_NONNULL_BEGIN


@interface WBSCloudTabStore (Helpers)

-(NSDictionary *)jsonRepresentation;

-(nullable WBSCloudTabDevice *)deviceNamed:(NSString *)deviceName;

-(BOOL)closeTabWithUUID:(NSUUID *)uuid onDeviceNamed:(NSString *)deviceName;
-(BOOL)closeAllTabsOnDeviceNamed:(NSString *)deviceName;

@end


@interface WBSCloudTabDevice (Helpers)

-(NSDictionary *)jsonRepresentation;

-(nullable WBSCloudTab *)tabWithUUID:(NSUUID *)uuid;

@end


@interface WBSCloudTab (Helpers)

-(NSDictionary *)jsonRepresentation;

@end


NS_ASSUME_NONNULL_END
