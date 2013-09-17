//
//  ViewController.m
//  ParkAlarm
//
//  Created by Jose Armando Gonzalez Lopez on 15/09/13.
//  Copyright (c) 2013 Codetlan. All rights reserved.
//

#import "ViewController.h"
#import "Tesseract.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	dateTimePicker.date = [NSDate date];
}

-(IBAction)takePhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    //[picker release];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
    //[tesseract setImage:[UIImage imageNamed:@"numbers.jpg"]];
    
    [tesseract setImage: chosenImage];
    [tesseract recognize];    
    //NSLog(@"%@", [tesseract recognizedText]);
    
    [self showAlert:[tesseract recognizedText]];
    
    [tesseract clear];
    
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void) showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parquímetro" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alert show];
}

-(void) scheduleLocalNotificationWithDate:(NSDate *)fireDate
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = fireDate;
    notification.alertBody = @"!Es hora de recargar el parquímetro!";
    notification.soundName = @"sound.caf";
    notification.repeatInterval = NSMinuteCalendarUnit;
    //notification.applicationIconBadgeNumber = 1;
    UIApplication *app = [UIApplication sharedApplication];
    
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    [notifications addObject:notification];
    app.scheduledLocalNotifications = notifications;
}

- (IBAction)alarmSetButtonTapped:(id)sender
{
    NSDateFormatter *dateFormatter = [[ NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSString *dateTimeString = [dateFormatter stringFromDate: dateTimePicker.date];
    
    //NSLog(@"alarm set : %@", dateTimeString);
    
    [self scheduleLocalNotificationWithDate: dateTimePicker.date];
    
    NSArray *firstSplit = [dateTimeString componentsSeparatedByString:@" "];
    NSString *time = [firstSplit lastObject];
    
    NSString *msj = [NSString stringWithFormat: @"El parquímetro vence a las %@. ¡Te avisaremos diez minutos antes!", time];
    
    [self showAlert:msj];
}

-(IBAction)alarmCancelButtonTapped:(id)sender
{
    NSLog(@"alarm cancel");
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UIImage *image = [UIImage imageNamed: @"bg.jpg"];
    [self.imageView  setImage:image];
    
    [self showAlert:@"¡Recuerda usar el cinturón de seguridad!"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
