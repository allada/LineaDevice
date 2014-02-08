//
//  CDVLineaDevice.h
//
//  Created by Nathan Bruer.
//  Copyright (c) 2012 Allada Inc. All rights reserved.
//
#ifndef LOG
	#define LOG(s, ...) NSLog(@"<%s : (%d)> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#endif
#import <Cordova/CDVPlugin.h>
#import <Foundation/NSNull.h>
#import "DTDevices.h"
#import <ExternalAccessory/ExternalAccessory.h>
@interface CDVLineaDevice : CDVPlugin <DTDeviceDelegate>{
    DTDevices *linea;
    int lineaConnectionState;
}
@property (retain) NSString* callbackId;

- (void) connectLinea:(NSNotification *)notification;
- (void) disconnectLinea:(NSNotification *)notification;

// Start JS Callable Functions
- (void) playSound:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) startScan:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stopScan:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setScanMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setScanBeep:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setScanButtonMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setMSCardDataMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setBarcodeTypeMode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
// End JS Callable Functions
@end
