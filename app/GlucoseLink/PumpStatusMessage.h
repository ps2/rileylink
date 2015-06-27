//
//  GlucoseSensorMessage.h
//  GlucoseLink
//
//  Created by Pete Schwamb on 8/14/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageBase.h"

typedef enum {
		SENSOR_STATUS_MISSING,
		SENSOR_STATUS_METER_BG_NOW,
		SENSOR_STATUS_WEAK_SIGNAL,
		SENSOR_STATUS_WARMUP,
		SENSOR_STATUS_LOST,
		SENSOR_STATUS_HIGH_BG,
		SENSOR_STATUS_OK,
  SENSOR_STATUS_UNKNOWN
} SensorStatus;

typedef enum {
  GLUCOSE_TREND_NONE        = 0b000,
  GLUCOSE_TREND_UP          = 0b001,
  GLUCOSE_TREND_DOUBLE_UP   = 0b010,
  GLUCOSE_TREND_DOWN        = 0b011,
  GLUCOSE_TREND_DOUBLE_DOWN = 0b100,
} GlucoseTrend;


@interface PumpStatusMessage : MessageBase

- (NSInteger) glucose;
- (NSDate*) measurementTime;
- (GlucoseTrend) trend;
- (double) activeInsulin;
- (SensorStatus) sensorStatus;

@end
