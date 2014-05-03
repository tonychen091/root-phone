//
//  ViewController.h
//  Location Test
//
//  Created by Anthony Chen on 5/2/14.
//  Copyright (c) 2014 Anthony Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;
-(IBAction)textFieldReturn:(id)sender;

@end
