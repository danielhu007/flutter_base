#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "IOrientationListener.h"
#import "NativeDeviceOrientationPlugin.h"
#import "Orientation.h"
#import "OrientationListener.h"
#import "SensorListener.h"

FOUNDATION_EXPORT double native_device_orientationVersionNumber;
FOUNDATION_EXPORT const unsigned char native_device_orientationVersionString[];

