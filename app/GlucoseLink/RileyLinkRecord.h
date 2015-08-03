//
//  RileyLinkRecord.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RileyLinkRecord : NSManagedObject

@property (nonatomic, retain) NSNumber * autoConnect;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * peripheralId;
@property (nonatomic, retain) NSDate * firstSeenAt;

@end
