//
//  ViewController.m
//  Location Test
//
//  Created by Anthony Chen on 5/2/14.
//  Copyright (c) 2014 Anthony Chen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIPickerView *tagCategories;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) IBOutlet UILabel *pickerSelection;
@property (weak, nonatomic) IBOutlet NSString *selectedCategory;
@property (weak, nonatomic) IBOutlet UITextField *note;
@property (weak, nonatomic) IBOutlet NSString *longitude;
@property (weak, nonatomic) IBOutlet NSString *latitude;


@end

@implementation ViewController{
    CLLocationManager *locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];


    [self getLocationAddress];

}

-(void)getLocationAddress
{
    
    self.selectedCategory = @"Fire Hydrant";
    self.categories = [[NSArray alloc] initWithObjects:@"Fire Hydrant",@"Street Camera",@"Knox Box", nil];
    NSString *latitude = @"38.905053";
    NSString *longitude = @"-77.03445";
    
    NSString *url = [NSString stringWithFormat:@"http://nominatim.openstreetmap.org/reverse?format=json&lat=%@&lon=%@&zoom=18&addressdetails=1", latitude, self.longitude];
    
    NSData *jsonDataString = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error: nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonDataString options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
    
    NSString *address = [NSString stringWithFormat:@"%@, %@", [[results objectForKey:@"address"] objectForKey:@"road"], [[results objectForKey:@"address"] objectForKey:@"city"]];
    
    
    self.address.text = [NSString stringWithFormat:@"GPS: %@", address];
}

- (IBAction)postNote:(id)sender {
    

    NSString *url = @"http://vast-atoll-5515.herokuapp.com/createNote";
    
    // Like the post request I showed you before, I'm going to send the deviceId again, because that is generally useful for establishing
    
//    UIDevice *device = [UIDevice currentDevice];
    
//    
//    NSDictionary *form = [NSDictionary dictionaryWithObjectsAndKeys:
//                          @"-77.034994", @"longitude",
//                          @"38.904095", @"latitude",
//                          @"hydrant", self.selectedCategory,
//                          @"note", self.note.text, nil];

    NSString *postString = [NSString stringWithFormat:@"longitude=%@&latitude=%@&type=%@&note=%@",@"-77.034994", @"38.904095", self.selectedCategory, self.note.text];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0f];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];

        if (response != nil && responseData != nil && error == nil) {
            // success
            NSDictionary *jsonReturn = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            if (error != nil) {
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Congrats" message:@"You have successfully created a new note." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
                errorAlert = nil;
                self.note.text =@"";
                return;
            }
            
            // do your shit here
        }
        }];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [self.categories count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.categories objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %d", row);
    switch(row)
    {
        case 0:
            self.pickerSelection.text = @"Fire Hydrant";
            self.selectedCategory = @"Fire Hydrant";
            break;
        case 1:
            self.pickerSelection.text = @"Street Camera";
            self.selectedCategory = @"Street Camera";

            break;
        case 2:
            self.pickerSelection.text = @"Knox Box";
            self.selectedCategory = @"Knox Box";

            break;
      
    }
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_textField isFirstResponder] && [touch view] != _textField) {
        [_textField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (IBAction)getCurrentLocation:(id)sender{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self getLocationAddress];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError; %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"error" message:@"failed to get your location" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [errorAlert show];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if(currentLocation != nil) {
        NSLog([NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
       NSLog([NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
        self.longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.address.text = [NSString stringWithFormat: @"GPS: %@, %@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]];
    }
}
@end
