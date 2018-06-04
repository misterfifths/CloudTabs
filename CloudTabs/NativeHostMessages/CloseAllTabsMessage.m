//
//  CloseAllTabsMessage.m
//  CloudTabs
//
//  Created by Timothy Clem on 6/3/18.
//  Copyright © 2018 Misterfifths Heavy Industries. All rights reserved.
//

#import "CloseAllTabsMessage.h"
#import "NativeHostMessageProtected.h"



@implementation CloseAllTabsMessage

-(nullable instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self) {
        _deviceName = dictionary[@"deviceName"];
        if(![_deviceName isKindOfClass:[NSString class]]) {
            NSLog(@"Invalid device name: missing or not a string");
            return nil;
        }
    }

    return self;
}

@end
