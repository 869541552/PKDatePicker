//
//  PKDatePickerView.m
//  PKDatePicker
//
//  Created by Pinkney on 2018/1/15.
//  Copyright © 2018年 Pinkney. All rights reserved.
//

#import "PKDatePickerView.h"

#define TopBAR_HEIGTH 44.0
#define Picker_HEIGTH 216.0

@interface PKDatePickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *leapDays;
    NSArray *notLeapDays;
    NSInteger minYear;
    NSInteger minMonth;
    NSInteger minDay;
    NSInteger maxYear;
    NSInteger maxMonth;
    NSInteger maxDay;
    
    NSInteger yearSelectIndex;
    NSInteger monthSelectIndex;
    NSInteger daySelectIndex;
}

@property (nonatomic, strong) UIPickerView *datePicker;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *doneBtn;

@property (nonatomic, strong) NSMutableArray<NSString *>  *yearArray;//年份
@property (nonatomic, strong) NSMutableArray<NSString *> *minYearMonthArray;//最小日期的月份
@property (nonatomic, strong) NSMutableArray<NSString *> *maxYearMonthArray;////最大日期的月份
@property (nonatomic, strong) NSMutableArray<NSString *> *minYearDayArray;//最小日期的月天数
@property (nonatomic, strong) NSMutableArray<NSString *> *maxYearDayArray;//最小日期的月天数
@property (nonatomic, strong) NSDate *minimumDate;//最小时间，默认2002.1.1
@property (nonatomic, strong) NSDate *maximumDate;//最大时间，默认当前时间
@end

@implementation PKDatePickerView
inline static CGFloat screenWidth()
{
    return [UIScreen mainScreen].bounds.size.width;
}

inline static CGFloat screenHeight()
{
    return [UIScreen mainScreen].bounds.size.height;
}

-(instancetype)initWithDefualtLimit
{
    self = [super init];
    if (self) {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *date = [dateFormatter dateFromString:@"1-1-2002"];
        self.minimumDate = date;
        self.maximumDate = [NSDate date];
        self.frame = CGRectMake(0, screenHeight() - TopBAR_HEIGTH - Picker_HEIGTH - 1, screenWidth(), Picker_HEIGTH + TopBAR_HEIGTH + 1);
        [self generateDataSource];
        [self setUpViews];
    }
    return self;
}

-(instancetype)initWithLimitDate:(NSDate *)minDate max:(NSDate *)maxDate
{
    self = [super init];
    if (self) {
        self.minimumDate = minDate;
        self.maximumDate = maxDate;
        self.frame = CGRectMake(0, screenHeight() - TopBAR_HEIGTH - Picker_HEIGTH - 1, screenWidth(), Picker_HEIGTH + TopBAR_HEIGTH + 1);
        [self generateDataSource];
        [self setUpViews];
    }
    return self;
}

-(void)setCurDate:(NSDate *)curDate
{
    _curDate = curDate;
    if ([curDate compare:self.minimumDate] == NSOrderedAscending) {
        NSLog(@"早于最小时间");
        _curDate = self.minimumDate;
    }
    else if([curDate compare:self.maximumDate] == NSOrderedDescending)
    {
        NSLog(@"大于最大时间");
        _curDate = self.minimumDate;
    }
    [self updateDatePicker];
}

-(void)updateDatePicker
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    [dateFormatter setDateFormat:@"yyyy"];
    NSInteger year = [[dateFormatter stringFromDate:_curDate] integerValue];
    NSInteger yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%lu",year]];
    [dateFormatter setDateFormat:@"MM"];
    NSInteger month = [[dateFormatter stringFromDate:_curDate] integerValue];
    NSInteger monthIndex = month - 1;
    [dateFormatter setDateFormat:@"dd"];
    NSInteger day = [[dateFormatter stringFromDate:_curDate] integerValue];
    NSInteger dayIndex = day - 1;
    if (year == minYear) {
        monthIndex = [self.minYearMonthArray indexOfObject:[NSString stringWithFormat:@"%lu",month]];
        if(monthIndex == minMonth)
        {
            dayIndex = [_minYearDayArray indexOfObject:[NSString stringWithFormat:@"%lu",day]];
        }
    }
    yearSelectIndex = yearIndex;
    monthSelectIndex = monthIndex;
    daySelectIndex = dayIndex;
    [self.datePicker selectRow:yearIndex inComponent:0 animated:YES];
    [self.datePicker selectRow:monthIndex inComponent:1 animated:YES];
    [self.datePicker selectRow:dayIndex inComponent:2 animated:YES];

//    [self.datePicker reloadAllComponents];
}

-(void)setUpViews
{
    [self.topView addSubview:self.cancelBtn];
    [self.topView addSubview:self.doneBtn];
    [self addSubview:self.topView];
    [self addSubview:self.separatorView];
    //时间选择器
    [self addSubview:self.datePicker];
}

-(UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80.0, TopBAR_HEIGTH)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];    }
    return _cancelBtn;
}

-(UIView *)separatorView
{
    if (!_separatorView) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, TopBAR_HEIGTH, screenWidth(), 1)];
        _separatorView.backgroundColor = [UIColor lightGrayColor];
    }
    return _separatorView;
}

-(UIButton *)doneBtn
{
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth() - 80.0, 0, 80.0, TopBAR_HEIGTH)];
        [_doneBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [_doneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
    }
    return _doneBtn;
}

-(UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth(), TopBAR_HEIGTH)];
        _topView.backgroundColor = [UIColor lightGrayColor];
    }
    return _topView;
}

-(UIPickerView *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, TopBAR_HEIGTH + 1, screenWidth(),Picker_HEIGTH)];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.delegate = self;
    }
    return _datePicker;
}

-(void)setTopViewColor:(UIColor *)topViewColor
{
    self.topView.backgroundColor = topViewColor;
}

-(void)setDoneBtnColor:(UIColor *)doneBtnColor
{
    [self.doneBtn setTitleColor:doneBtnColor forState:UIControlStateNormal];
}

-(void)setCancelBtnColor:(UIColor *)cancelBtnColor
{
    [self.cancelBtn setTitleColor:cancelBtnColor forState:UIControlStateNormal];
}

-(void)setTitleFont:(UIFont *)titleFont
{
    self.doneBtn.titleLabel.font = titleFont;
    self.cancelBtn.titleLabel.font = titleFont;
}

-(void)setPickViewBackgroundColor:(UIColor *)pickViewBackgroundColor
{
    self.datePicker.backgroundColor = pickViewBackgroundColor;
}

-(void)setSeparatorColor:(UIColor *)separatorColor
{
    self.separatorView.backgroundColor = separatorColor;
}

-(IBAction)cancelAction:(id)sender
{
    [self hidePicker];
}

- (BOOL)anySubViewScrolling:(UIView *)view{
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        if (scrollView.dragging || scrollView.decelerating) {
            return YES;
        }
    }
    for (UIView *theSubView in view.subviews) {
        if ([self anySubViewScrolling:theSubView]) {
            return YES;
        }
    }
    return NO;
}

-(IBAction)doneAction:(id)sender
{
    if (![self anySubViewScrolling:self.datePicker]) {
        [self hidePicker];
        NSInteger yearIndex = [self.datePicker selectedRowInComponent:0];
        NSInteger monthIndex = [self.datePicker selectedRowInComponent:1];
        NSInteger dayIndex = [self.datePicker selectedRowInComponent:2];
        NSInteger year = [self.yearArray[yearIndex] integerValue];
        NSInteger month = monthIndex + 1;
        NSInteger day = dayIndex + 1;
        if (minYear == year) {
            month = [_minYearMonthArray[monthIndex] integerValue];
            if (month == minMonth) {
                day = [_minYearDayArray[dayIndex] integerValue];
            }
        }
        else if (maxYear == year)
        {
            month = [_maxYearMonthArray[monthIndex] integerValue];
            if (maxMonth == month) {
                day = [_maxYearDayArray[dayIndex] integerValue];
            }
        }
        NSString *dateStr = [NSString stringWithFormat:@"%lu-%lu-%lu",year,month,day];
        NSLog(@"选择的时间为%@",dateStr);
        if (self.finishDoneBlock) {
            self.finishDoneBlock(dateStr);
        }
    }
}

- (void)generateDataSource
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    self.yearArray = [NSMutableArray array];
    self.minYearDayArray = [NSMutableArray array];
    self.maxYearDayArray = [NSMutableArray array];
    self.minYearMonthArray = [NSMutableArray array];
    self.maxYearMonthArray = [NSMutableArray array];
    leapDays = @[@"31",@"29",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    notLeapDays = @[@"31",@"28",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    [dateFormatter setDateFormat:@"yyyy"];
    minYear = [[dateFormatter stringFromDate:_minimumDate] integerValue];
    maxYear = [[dateFormatter stringFromDate:_maximumDate] integerValue];
    [dateFormatter setDateFormat:@"MM"];
    minMonth = [[dateFormatter stringFromDate:_minimumDate] integerValue];
    maxMonth = [[dateFormatter stringFromDate:_maximumDate] integerValue];
    [dateFormatter setDateFormat:@"dd"];
    minDay = [[dateFormatter stringFromDate:_minimumDate] integerValue];
    maxDay = [[dateFormatter stringFromDate:_maximumDate] integerValue];
    
    for (NSInteger yearNum = minYear; yearNum <= maxYear; yearNum ++) {
        [self.yearArray addObject:[NSString stringWithFormat:@"%ld",yearNum]];//年份
    }
    
    //最小年份剩下的月份数
    for (NSInteger monthNum = minMonth; monthNum <= 12 ; monthNum ++) {
        [self.minYearMonthArray addObject:[NSString stringWithFormat:@"%ld",monthNum]];
    }
    //最大年份已过去的月份数
    for (NSInteger monthNum = 1; monthNum <= maxMonth; monthNum++) {
        [self.maxYearMonthArray addObject:[NSString stringWithFormat:@"%ld",monthNum]];
    }
    
    NSInteger lastDay = [self perMonthDaysFormYear:minYear month:minMonth];
    for (NSInteger dayNum = minDay; dayNum <= lastDay; dayNum ++) {
        [self.minYearDayArray addObject:[NSString stringWithFormat:@"%ld",dayNum]];
    }
    //最大日期过去的天数
    for (NSInteger dayNum = 1; dayNum <= maxDay; dayNum ++) {
        [self.maxYearDayArray addObject:[NSString stringWithFormat:@"%ld",dayNum]];
    }
}

-(NSInteger)monthsFormSelectYear
{
    //    NSInteger index = [self.datePicker selectedRowInComponent:0];
    if (minYear == [self.yearArray[yearSelectIndex] integerValue]) {
        return _minYearMonthArray.count;
    }
    else if(maxYear == [self.yearArray[yearSelectIndex] integerValue])
    {
        return _maxYearMonthArray.count;
    }
    return 12;
}

-(NSInteger)daysFormSelectYearAndMonth
{
    NSInteger selectYear = [self.yearArray[yearSelectIndex] integerValue];
    NSInteger selectMonth = monthSelectIndex + 1;
    if (minYear == selectYear) {
        selectMonth = [self.minYearMonthArray[monthSelectIndex] integerValue];
        if(minMonth == selectMonth)
        {
            return _minYearDayArray.count;
        }
    }
    else if (maxYear == selectYear)
    {
        if (monthSelectIndex < self.maxYearMonthArray.count) {
            selectMonth = [self.maxYearMonthArray[monthSelectIndex] integerValue];
        } else {
            selectMonth = MAX(1, self.maxYearMonthArray.lastObject.integerValue);
        }
        if (maxMonth == selectMonth) {
            return _maxYearDayArray.count;
        }
    }
    return [self perMonthDaysFormYear:selectYear month:selectMonth];
    
}

-(NSInteger)perMonthDaysFormYear:(NSInteger)year month:(NSInteger)month
{
    if ((year % 4 == 0 && year % 100 != 0) || year %400 == 0) {
        return [leapDays[month -1] integerValue];
    }
    else
    {
        return [notLeapDays[month - 1] integerValue];
    }
}

-(void)showPicker
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, screenHeight() - Picker_HEIGTH - TopBAR_HEIGTH - 1, screenWidth(), Picker_HEIGTH + TopBAR_HEIGTH + 1);
    }];
}

-(void)hidePicker
{
    //    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        UIView *popView = self;
        if ([self.superview isKindOfClass:NSClassFromString(@"UIInputSetHostView")]) {
            popView = self.superview;
        }
        popView.frame = CGRectMake(0, screenHeight(), screenWidth(), Picker_HEIGTH + TopBAR_HEIGTH + 1);
    }];
}



#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0)//年
    {
        return _yearArray.count;
    }
    else if (component == 1)//月
    {
        return [self monthsFormSelectYear];
    }
    else//日
    {
        return [self daysFormSelectYearAndMonth];
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0)//年
    {
        return [self.yearArray[row] stringByAppendingString:@"年"];
    }
    else if (component == 1)//月
    {
        NSInteger selectYear = [self.yearArray[yearSelectIndex] integerValue];
        if (minYear == selectYear) {
            return [self.minYearMonthArray[row] stringByAppendingString:@"月"];
        }
        else if(maxMonth == selectYear)
        {
            return [self.maxYearMonthArray[row] stringByAppendingString:@"月"];
        }
        return [NSString stringWithFormat:@"%lu月",row + 1];
    }
    else//日
    {
        NSInteger selectYear = [self.yearArray[yearSelectIndex] integerValue];
        NSInteger selectMonth = monthSelectIndex + 1;
        if (minYear == selectYear) {
            selectMonth = [self.minYearMonthArray[monthSelectIndex] integerValue];
            if (minMonth == selectMonth) {
                return [self.minYearDayArray[row] stringByAppendingString:@"日"];
            }
        }
        else if (maxYear == selectYear)
        {
            if (monthSelectIndex < self.maxYearMonthArray.count) {
                selectMonth = [self.maxYearMonthArray[monthSelectIndex] integerValue];
            } else {
                selectMonth = MAX(1, self.maxYearMonthArray.lastObject.integerValue);
            }
            if (maxMonth == selectMonth) {
                return [self.maxYearDayArray[row] stringByAppendingString:@"日"];
            }
        }
        return [NSString stringWithFormat:@"%lu日",row + 1];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    yearSelectIndex = [self.datePicker selectedRowInComponent:0];
    monthSelectIndex = [self.datePicker selectedRowInComponent:1];
    daySelectIndex = [self.datePicker selectedRowInComponent:2];
    if (component == 0)//年
    {
        [self.datePicker reloadComponent:1];
        [self.datePicker reloadComponent:2];
    }
    else if (component == 1)//月
    {
        [self.datePicker reloadComponent:2];
    }
    else//日
    {
        
    }
}

@end
