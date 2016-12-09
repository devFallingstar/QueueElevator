//
//  ViewController.m
//  QueueElevatorMobile
//
//  Created by Fallingstar on 2016. 12. 9..
//  Copyright © 2016년 Fallingstar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize deptlbl, arrivelbl, myPicker, callBtn, timeSeg;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    floorArr = [[NSArray alloc]initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", nil];
    
    myPicker = [[UIPickerView alloc]init];
    myPicker.dataSource = self;
    myPicker.delegate = self;
    
    self.deptlbl.inputView = myPicker;
    self.arrivelbl.inputView = myPicker;
    
    [self ClientInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [floorArr count];
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        NSInteger dept = [pickerView selectedRowInComponent:0];
        deptlbl.text = [NSString stringWithFormat:@"%d", (int)dept+1];
    }else{
        NSInteger arrive = [pickerView selectedRowInComponent:1];
        arrivelbl.text = [NSString stringWithFormat:@"%d", (int)arrive+1];
    }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [floorArr objectAtIndex:row];
}

-(IBAction)callButtonClick:(id)sender{
    //Send string
    if([deptlbl.text intValue] <= 0 || [deptlbl.text intValue] > 7){
        //Wrong
    }else if([arrivelbl.text intValue] <= 0 || [arrivelbl.text intValue] > 7){
        //Wrong
    }else{
        if(![deptlbl.text isEqualToString:@""] && ![arrivelbl.text isEqualToString:@""]){
            NSString *delay;
            NSString *response;
            switch (timeSeg.selectedSegmentIndex) {
                case 0:
                    delay = @"5";
                    break;
                case 1:
                    delay = @"8";
                    break;
                case 2:
                    delay = @"10";
                    break;
                case 3:
                    delay = @"15";
                    break;
                default:
                    break;
            }
            response = [NSString stringWithFormat:@"%d:%d:%@\n", [deptlbl.text intValue]-1, [arrivelbl.text intValue]-1, delay];
            
            NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
            [OutputStream write:[data bytes] maxLength:[data length]];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.deptlbl resignFirstResponder];
}

-(void)ClientInit{
    NSLog(@"Tcp Client Initialize");
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"127.0.0.1", 9999, &readStream, &writeStream);
    
    InputStream = (__bridge NSInputStream *)readStream;
    OutputStream = (__bridge NSOutputStream *)writeStream;
    
    [InputStream setDelegate:self];
    [OutputStream setDelegate:self];
    
    [InputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [OutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [InputStream open];
    [OutputStream open];
}

-(void)ConnectionEnd{
    [InputStream close];
    [OutputStream close];
    InputStream = nil;
    OutputStream = nil;
    if (OutputData != nil)
    {
        OutputData = nil;
    }
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)StreamEvent
{
    
    switch (StreamEvent)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"TCP Client - Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == InputStream)
            {
                uint8_t buffer[1024];
                int len;
                
                while ([InputStream hasBytesAvailable])
                {
                    len = (int)[InputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output)
                        {
                            NSLog(@"TCP Client - Server sent: %@", output);
                        }

                        int ActualOutputBytes = (int)[OutputStream write:[OutputData bytes] maxLength:[OutputData length]];
                        
                        if (ActualOutputBytes >= 100)
                        {
                            OutputData = nil;
                        }
                        else
                        {
                            [OutputData replaceBytesInRange:NSMakeRange(0, ActualOutputBytes) withBytes:NULL length:0];
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"TCP Client - Can't connect to the host");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"TCP Client - End encountered");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        case NSStreamEventNone:
            NSLog(@"TCP Client - None event");
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"TCP Client - Has space available event");
            if (OutputData != nil)
            {
                int ActualOutputBytes = (int)[OutputStream write:[OutputData bytes] maxLength:[OutputData length]];
                
                if (ActualOutputBytes >= [OutputData length])
                {
                    OutputData = nil;
                }
                else
                {
                    [OutputData replaceBytesInRange:NSMakeRange(0, ActualOutputBytes) withBytes:NULL length:0];
                }
            }
            break;
            
        default:
            NSLog(@"TCP Client - Unknown event");
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self ConnectionEnd];
    
}

@end
