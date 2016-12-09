//
//  ViewController.h
//  QueueElevatorMobile
//
//  Created by Fallingstar on 2016. 12. 9..
//  Copyright © 2016년 Fallingstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, NSStreamDelegate>{
    
    NSArray *floorArr;
    
    NSInputStream *InputStream;
    NSOutputStream *OutputStream;
    NSMutableData *OutputData;
    
}

-(void)ClientInit;
-(IBAction)callButtonClick:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *deptlbl;
@property (strong, nonatomic) IBOutlet UITextField *arrivelbl;
@property (strong, nonatomic) IBOutlet UIPickerView *myPicker;
@property (strong, nonatomic) IBOutlet UIButton *callBtn;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timeSeg;


@end

