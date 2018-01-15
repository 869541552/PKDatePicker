//
//  PKDatePickerView.h
//  PKDatePicker
//
//  Created by Pinkney on 2018/1/15.
//  Copyright © 2018年 Pinkney. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^FinishDoneBlock)(id value);//完成按钮block

@interface PKDatePickerView : UIView

@property (nonatomic, copy) FinishDoneBlock finishDoneBlock;

@property (nonatomic, strong) NSDate *curDate;
@property (nonatomic, strong) UIColor *topViewColor;//topbar颜色
@property (nonatomic, strong) UIColor *doneBtnColor;//确认按钮颜色
@property (nonatomic, strong) UIColor *cancelBtnColor;//取消按钮颜色
@property (nonatomic, strong) UIColor *separatorColor;//分割线颜色
/** 标题大小 */
@property (nonatomic, strong)UIFont  *titleFont;
/** 选择器背景颜色 */
@property (nonatomic, strong)UIColor *pickViewBackgroundColor;

//初始化日期选择器，默认最大为当前时间，最小为2002-1-1日
-(instancetype)initWithDefualtLimit;

///初始化日期选择器，设置最小和最大时间
-(instancetype)initWithLimitDate:(NSDate *)minDate max:(NSDate *)maxDate;

//显示时间控件
-(void)showPicker;
//隐藏时间控件
-(void)hidePicker;

@end
