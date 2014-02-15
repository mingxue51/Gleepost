//
//  AnimationDayController.m
//  Gleepost
//
//  Created by Silouanos on 13/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "AnimationDayController.h"
#import "FESSolarCalculator.h"
#import "DateFormatterHelper.h"

@interface AnimationDayController ()

@property (assign, nonatomic) BOOL day;
@property (strong, nonatomic) NSTimer *checkDay;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FESSolarCalculator *solarCalculator;
@property (strong, nonatomic) NSDate *sunset;
@property (strong, nonatomic) NSDate *sunrise;

@end

@implementation AnimationDayController

static AnimationDayController *instance = nil;

+ (AnimationDayController *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AnimationDayController alloc] init];
    });
    
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    
    self.day = NO;
    
    self.checkDay = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(decideDay:) userInfo:nil repeats:YES];
    [self.checkDay fire];
    
    //Initialise Location manager.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    return self;
}




-(void)decideDay:(id)sender
{

    if(sender != nil)
    {
        [self.locationManager startUpdatingLocation];
    }
    
    
    if([[NSDate date] compare:_sunrise] == NSOrderedDescending && [[NSDate date] compare:_sunset] == NSOrderedAscending)
    {
        self.day = YES;
    }
    else
    {
        self.day = NO;
    }
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [self.locationManager stopUpdatingLocation];
    
    _solarCalculator = [[FESSolarCalculator alloc] initWithDate:[NSDate date] location:newLocation];
    
    _sunrise = [_solarCalculator sunrise];
    _sunset = [_solarCalculator sunset];
    
    [self decideDay:nil];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}


#pragma mark - Images' names

-(NSString*)backgroundImage
{
    return self.day ? @"background_day" : @"background_night";
}

-(NSString*)forground
{
    return self.day ? @"hills" : @"hills_night";
}

-(NSString*)sunMoon
{
    return self.day ? @"" : @"sun_night";
}

-(NSString*)cloud1
{
    return self.day ? @"cloud1" : @"cloud1_night";
}

-(NSString*)cloud2
{
    return self.day ? @"cloud2" : @"cloud2_night";
}

-(NSString*)cloud3
{
    return self.day ? @"cloud3" : @"cloud3_night";
}

-(NSString*)pole
{
    return self.day ? @"pole" : @"pole_night";
}

-(NSString*)blades
{
    return self.day ? @"blades_copy" : @"blades_night_copy";
}

-(NSString*)balloon
{
    return self.day ? @"hot_air_balloon" : @"hot_air_balloon_night";
}

-(NSString*)blimp
{
    return self.day ? @"blimp" : @"blimp_night";
}



@end
