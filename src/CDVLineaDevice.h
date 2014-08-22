/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
//
//  CDVLineaDevice.h
//
//  Created by Nathan Bruer.
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
