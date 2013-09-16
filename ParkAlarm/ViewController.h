//
//  ViewController.h
//  ParkAlarm
//
//  Created by Jose Armando Gonzalez Lopez on 15/09/13.
//  Copyright (c) 2013 Codetlan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    IBOutlet UIDatePicker *dateTimePicker;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

-(IBAction)takePhoto:(id)sender;

-(void) showAlert: (NSString *) message;
-(void) scheduleLocalNotificationWithDate: (NSDate *) fireDate;
-(IBAction)alarmSetButtonTapped:(id)sender;
-(IBAction)alarmCancelButtonTapped:(id)sender;
@end
