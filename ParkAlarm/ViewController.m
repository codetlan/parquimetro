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
    
    [[UIColor colorWithRed:108/255.0f green:256/255.0f blue:0/255.0f alpha:1.0f] set];
    CGRect rectangle = CGRectMake(50, 100, 220, 150);
    CGContextStrokeRect(context, rectangle);
    UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
    overlayIV.image = overlayImage;
    picker.cameraOverlayView = overlayIV ;
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
    [brightnessFilter setBrightness:0.6];
    
    //ColorInvertFilter
    GPUImageColorInvertFilter *colorInvertFilter;
    colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
    
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.18f, 0.24f, 0.65f, .48f)];
    
    filteredImage = [cropFilter imageByFilteringImage:filteredImage];
    
    //filteredImage = [brightnessFilter imageByFilteringImage:filteredImage];
    //filteredImage = [grayscaleFilter imageByFilteringImage:filteredImage];
    //filteredImage = [colorInvertFilter imageByFilteringImage:filteredImage];
    //filteredImage = [grayscaleFilter imageByFilteringImage:filteredImage];
    //filteredImage = [colorInvertFilter imageByFilteringImage:filteredImage];
    
    filteredImage = [brightnessFilter imageByFilteringImage:filteredImage];
    filteredImage = [grayscaleFilter imageByFilteringImage:filteredImage];
    
    //le sacamos el texto del la imagen
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    
    [tesseract setImage: filteredImage ];
    [tesseract recognize];
    
    //analizamos la cadena para mejorar el resultado
    NSString *text ;
    NSString *pattern = @"(\\d{2}:\\d{2})";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    text =  [tesseract recognizedText];
    
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if (match != nil) { //si tiene el formato de fecha
        NSString *time = [text substringWithRange:[match rangeAtIndex:1]];
        
        char ch = [time characterAtIndex:0];
        switch (ch){
            case '0':
            case '8':
            case '6':
            case '9':
            case '3':
            case '5':
                time = [time stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"0"];
                break;
            case '2':
            case '7':
                time = [time stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"2"];
            break;
            default:
                time = [time stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"1"];
                break;
        }
        ch = [time characterAtIndex:3];
        switch (ch){
            case '0':
            case '8':
            case '6':
            case '9':
                time = [time stringByReplacingCharactersInRange:NSMakeRange(3, 1) withString:@"0"];
                break;
            case '7':
            case '2':
                time = [time stringByReplacingCharactersInRange:NSMakeRange(3, 1) withString:@"2"];
                break;
            default:break;
        }
        
        //obtenemos la fecha correctamente
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *today = [NSDate date];
        
        NSDateComponents *todayComps = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:today];
        NSDateComponents *comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[dateFormatter dateFromString:time]];
        
        comps.day = todayComps.day;
        comps.month = todayComps.month;
        comps.year = todayComps.year;
        
        NSDate *date = [calendar dateFromComponents:comps];
        dateTimePicker.date = date;
    }
    else{
        [self showAlert:@"Captura el boleto de nuevo." withArg2:@"Error en la captura"];
        UIImage *image = [UIImage imageNamed: @"bg.jpg"];
        [self.imageView  setImage:image];
    }
    
    
    [tesseract clear];
    
    //la ponemos en la vista
    self.imageView.image = chosenImage;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void) showAlert:(NSString *)message withArg2:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alert show];
}

-(void) scheduleLocalNotificationWithDate:(NSDate *)fireDate
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = fireDate;
    notification.alertBody = @"Es hora de recargar el parquímetro";
    notification.soundName = @"sound.caf";
    notification.repeatInterval = NSMinuteCalendarUnit;
    //notification.applicationIconBadgeNumber = 0;
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
    
    //cancelamos todos las notificaciones, por si habia alguna encolada
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //le restamos 10 minutos para que empiece a sonnar la alarma
    NSDate *date = [[NSDate alloc] init];
    date = dateTimePicker.date;
    date = [date dateByAddingTimeInterval:-60*10];
    
    //setemos la alarma o notificiacion
    [self scheduleLocalNotificationWithDate: date];
    
    NSArray *firstSplit = [dateTimeString componentsSeparatedByString:@" "];
    NSString *time = [firstSplit lastObject];
    
    NSString *msj = [NSString stringWithFormat: @"El parquímetro vence a las %@. Te avisaremos diez minutos antes.", time];
    
    [self showAlert:msj withArg2:@"Alarma guardada"];
}

-(IBAction)alarmCancelButtonTapped:(id)sender
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UIImage *image = [UIImage imageNamed: @"bg.jpg"];
    [self.imageView  setImage:image];
    
    [self showAlert:@"Buen viaje, recuerda utilizar el cinturón de seguridad." withArg2:@"Alarma cancelada"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
