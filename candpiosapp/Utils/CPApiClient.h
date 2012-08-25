//
//  CPApiClient.h
//  candpiosapp
//
//  Created by Stephen Birarda on 7/26/12.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//

#import "AFHTTPClient.h"

@interface CPApiClient : AFHTTPClient

+ (void)checkInToVenue:(CPVenue *)venue
                hoursHere:(int)hoursHere
               statusText:(NSString *)statusText
                isVirtual:(BOOL)isVirtual
              isAutomatic:(BOOL)isAutomatic
          completionBlock:(void (^)(AFHTTPRequestOperation *, NSDictionary *, NSError *))completion;


@end
