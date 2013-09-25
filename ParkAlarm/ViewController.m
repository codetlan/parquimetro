//
//  ViewController.m
//  ParkAlarm
//
//  Created by Jose Armando Gonzalez Lopez on 15/09/13.
//  Copyright (c) 2013 Codetlan. All rights reserved.
//

#import "ViewController.h"
#import "Tesseract.h"
#import "GPUImage.h"

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
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //Create camera overlay
    CGRect f = picker.view.bounds;
    
    UIGraphicsBeginImageContext(f.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //[[UIColor colorWithRed:255/255.0f green:204/255.0f blue:0/255.0f alpha:1] set];
    [[UIColor colorWithRed:108/255.0f green:256/255.0f blue:0/255.0f alpha:1.0f] set];
    CGRect rectangle = CGRectMake(50, 100, 220, 150);
    CGContextStrokeRect(context, rectangle);
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
    overlayIV.image = overlayImage;
    [picker.cameraOverlayView addSubview:overlayIV];
    //finish overlay
    
   
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    
    //[picker release];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *filteredImage;
    
    filteredImage = chosenImage;
    
    //Gray scale filter
    GPUImageGrayscaleFilter *grayscaleFilter;
    grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    
    //BrightnessFilter
    GPUImageBrightnessFilter *brightnessFilter;
    brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [brightnessFilter setBrightness:0.7];
    
    //ColorInvertFilter
    GPUImageColorInvertFilter *colorInvertFilter;
    colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
    
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.15f, 0.4f, 0.75f, .48f)];
    
    filteredImage = [cropFilter imageByFilteringImage:filteredImage];
    
    filteredImage = [brightnessFilter imageByFilteringImage:filteredImage];
    
    filteredImage = [grayscaleFilter imageByFilteringImage:filteredImage];
    
    filteredImage = [colorInvertFilter imageByFilteringImage:filteredImage];
    
    filteredImage = [grayscaleFilter imageByFilteringImage:filteredImage];
    
    filteredImage = [colorInvertFilter imageByFilteringImage:filteredImage];
    
    
    
    //la ponemos en la vista
    self.imageView.image = filteredImage;
    //self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
   Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    //[tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
    //[tesseract setImage:[UIImage imageNamed:@"numbers.jpg"]];
    
    [tesseract setImage: filteredImage ];
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
