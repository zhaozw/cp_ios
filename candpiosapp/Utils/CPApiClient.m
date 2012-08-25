//
//  CPApiClient.m
//  candpiosapp
//
//  Created by Stephen Birarda on 7/26/12.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//

#import "CPApiClient.h"

@implementation CPApiClient

#pragma mark - Initialization

static AFHTTPClient *sharedClient;

+ (void)initialize
{
    if(!sharedClient) {
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kCandPWebServiceUrl]];
    }
}

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }  
    
    return self;
}

#pragma mark - Common request

+ (void)makeAPIRequestWithAction:(NSString *)action
                      parameters:(NSMutableDictionary *)parameters
                      completion:(void (^)(AFHTTPRequestOperation *, NSDictionary *, NSError *))completion
{
    [parameters setObject:action forKey:@"action"];
    
    [sharedClient postPath:@"api.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(operation, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation, nil, error);
    }];
}

#pragma mark - Helpers

+ (NSString *)stringParameterForCoordinateAngle:(double)coordinateAngle
{
    return [NSString stringWithFormat:@"%.7lf", coordinateAngle];
}

#pragma mark - Check in

+ (void)checkInToVenue:(CPVenue *)venue
                hoursHere:(int)hoursHere
               statusText:(NSString *)statusText
                isVirtual:(BOOL)isVirtual
              isAutomatic:(BOOL)isAutomatic
          completion:(void (^)(AFHTTPRequestOperation *, NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[self stringParameterForCoordinateAngle:venue.coordinate.latitude]
                  forKey:@"lat"];
    [parameters setValue:[self stringParameterForCoordinateAngle:venue.coordinate.longitude]
                  forKey:@"lng"];
    [parameters setValue:venue.name forKey:@"venue_name"];
    [parameters setValue:[NSString stringWithFormat:@"%d", hoursHere] forKey:@"hours_here"];
    [parameters setValue:venue.foursquareID forKey:@"foursquare"];
    [parameters setValue:venue.address forKey:@"address"];
    [parameters setValue:venue.city forKey:@"city"];
    [parameters setValue:venue.state forKey:@"state"];
    [parameters setValue:venue.zip forKey:@"zip"];
    [parameters setValue:venue.phone forKey:@"phone"];
    [parameters setValue:venue.formattedPhone forKey:@"formatted_phone"];
    [parameters setValue:[NSString stringWithFormat:@"%d", isAutomatic] forKey:@"is_automatic"];
    [parameters setValue:statusText forKey:@"status"];
    
    if(isVirtual) {
        [parameters setValue:@"1" forKey:@"is_virtual"];
    } else {
        [parameters setValue:@"0" forKey:@"is_virtual"];
        
    }
    
    [self makeAPIRequestWithAction:@"checkin" parameters:parameters completion:completion];
    
    [FlurryAnalytics logEvent:@"checkedIn"];
}

#pragma mark - Map Marker Data

+ (void)getMarkersForSouthwestCoordinate:(CLLocationCoordinate2D)southwestCoord
                     NortheastCoordinate:(CLLocationCoordinate2D)northeastCoord
                         completion:(void (^)(AFHTTPRequestOperation *, NSDictionary *, NSError *))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // add the Southwest and Northeast coordinates to the params dictionary
    [parameters setValue:[self stringParameterForCoordinateAngle:southwestCoord.latitude] forKey:@"sw_lat"];
    [parameters setValue:[self stringParameterForCoordinateAngle:southwestCoord.longitude] forKey:@"sw_lng"];
    [parameters setValue:[self stringParameterForCoordinateAngle:northeastCoord.latitude] forKey:@"ne_lat"];
    [parameters setValue:[self stringParameterForCoordinateAngle:northeastCoord.longitude] forKey:@"ne_lng"];
    
    // fire off the request using the common request method
    [self makeAPIRequestWithAction:@"getMarkers" parameters:parameters completion:completion];
}

@end
