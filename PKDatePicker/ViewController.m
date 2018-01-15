//
//  ViewController.m
//  PKDatePicker
//
//  Created by Pinkney on 2018/1/15.
//  Copyright © 2018年 Pinkney. All rights reserved.
//

#import "ViewController.h"
#import "PKDatePickerView.h"

@interface ViewController ()
{
    PKDatePickerView *pickerView;
    UILabel *dateLab;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"显示时间" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 100, 100, 50);
    [self.view addSubview:btn];
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"隐藏时间" forState:UIControlStateNormal];
    btn1.tag = 123;
    [btn1 addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    btn1.backgroundColor = [UIColor redColor];
    btn1.frame = CGRectMake(220, 100, 100, 50);
    [self.view addSubview:btn1];
    dateLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 180, 200, 21)];
    dateLab.textColor = [UIColor blackColor];
    dateLab.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:dateLab];
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)testAction:(id)sender
{
    if (!pickerView) {
        pickerView = [[PKDatePickerView alloc] initWithDefualtLimit];
        //        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        //        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        //        NSDate *date = [dateFormatter dateFromString:@"1-1-2002"];
        //        NSDate *mxDate = [dateFormatter dateFromString:@"12-3-2018"];
        //        NSDate *cuDate = [dateFormatter dateFromString:@"1-5-2006"];
        //        pickerView = [[PKPickerView alloc] initWithLimitDate:date max:mxDate];
        //        pickerView.doneBtnColor = [UIColor redColor];
        //        pickerView.separatorColor = [UIColor redColor];
        //        pickerView.topViewColor = [UIColor lightGrayColor];
        //        pickerView.curDate = cuDate;
        [self.view addSubview:pickerView];
        
       __weak typeof(self)weakSelf = self;
        pickerView.finishDoneBlock = ^(id value) {
            if ([value isKindOfClass:[NSString class]]) {
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf->dateLab.text = value;
            }
        };
        
    }
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 123) {
        [pickerView hidePicker];
    }
    else
    {
        [pickerView showPicker];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
