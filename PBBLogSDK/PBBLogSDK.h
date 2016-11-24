//
//  PBBLogSDK.h
//  PBBLogSDK
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

//! Project version number for PBBLogSDK.
FOUNDATION_EXPORT double PBBLogSDKVersionNumber;

//! Project version string for PBBLogSDK.
FOUNDATION_EXPORT const unsigned char PBBLogSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PBBLogSDK/PublicHeader.h>
#import "PBBLogSDKForiOS-Swift.h"

#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>


//! Project version number for PBBLogSDK.
FOUNDATION_EXPORT double PBBLogSDKVersionNumber;

//! Project version string for PBBLogSDK.
FOUNDATION_EXPORT const unsigned char PBBLogSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PBBLogSDK/PublicHeader.h>
#import "PBBLogSDK-Swift.h"

#endif


