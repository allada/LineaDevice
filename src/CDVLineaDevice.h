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
- (void) playSound:(CDVInvokedUrlCommand*)command;
- (void) startScan:(CDVInvokedUrlCommand*)command;
- (void) stopScan:(CDVInvokedUrlCommand*)command;
- (void) setScanMode:(CDVInvokedUrlCommand*)command;
- (void) setScanBeep:(CDVInvokedUrlCommand*)command;
- (void) setScanButtonMode:(CDVInvokedUrlCommand*)command;
- (void) setMSCardDataMode:(CDVInvokedUrlCommand*)command;
- (void) setBarcodeTypeMode:(CDVInvokedUrlCommand*)command;
// End JS Callable Functions
@end
