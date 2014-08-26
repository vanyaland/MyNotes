//
//  DetailNoteViewController.m
//  MyNotes
//
//  Created by Ivan Magda on 24.08.14.
//
//

#import "DetailNoteViewController.h"
#import "TextColor.h"
#import "Note.h"

@interface DetailNoteViewController ()

@end

@implementation DetailNoteViewController {
    NSDate *_date;
    Note *_note;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.itemToShow)
    {
        _date = self.itemToShow.date;
        self.textView.text = self.itemToShow.text;
        self.doneButton.enabled = YES;
        
        [self configTextForCurrentDateLabel];
        [self configTextViewHeight:self.textView];
        
        _note = [[Note alloc]init];
        _note.text = self.itemToShow.text;
        _note.date = self.itemToShow.date;
        _note.textSize = self.itemToShow.textSize;
        _note.textColor = [[TextColor alloc]initWithColorsRed:
                                                      self.itemToShow.textColor.redColor
                                                green:self.itemToShow.textColor.greenColor
                                                blue:self.itemToShow.textColor.blueColor
                                                alpha:self.itemToShow.textColor.alphaColor];
    } else {
        _date = [NSDate date];
        
        [self configTextForCurrentDateLabel];
        [self.textView becomeFirstResponder];
        
        _note = [[Note alloc]init];
        _note.date = _date;
    }
    [self updateTextColor];
    [self updateTextSize];
}

- (void)configTextForCurrentDateLabel {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.currentDate.text = [dateFormatter stringFromDate:_date];
    self.currentDate.textColor = self.currentDate.tintColor;
}


- (IBAction)done:(UIBarButtonItem *)sender {
    if (self.itemToShow == nil) {
        [self.delegate detailNoteViewController:self didFinishAddingNote:_note];
    } else {
        self.itemToShow.text = _note.text;
        self.itemToShow.textColor = _note.textColor;
        self.itemToShow.textSize = _note.textSize;
        
        [self.delegate detailNoteViewController:self didFinishShowNote:self.itemToShow];
        if ([self firstTimeExperience]) {
            [[NSUserDefaults standardUserDefaults]setBool:NO
                                                   forKey:@"TextViewBeginEditFirstTime"];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectColor"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CustomizeNoteViewController *controller = (CustomizeNoteViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.noteToShow = _note;
    }
}

#pragma mark - Text View delegate -

- (void)configTextViewHeight:(UITextView *)textView {
    static const NSInteger kCheckTextViewToAdjustHeight = 37;
    
    if ([textView.text length] > kCheckTextViewToAdjustHeight) {
        CGRect frame = self.textView.frame;
        frame.size.height = self.textView.contentSize.height;
        self.textView.frame = frame;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *string = [textView.text stringByReplacingCharactersInRange:range
                                                              withString:text];
    self.doneButton.enabled = ([string length] > 0);
    
    [self configTextViewHeight:textView];
    
    _note.text = string;
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self firstTimeExperience]) {
        textView.text = @"";
        [[NSUserDefaults standardUserDefaults]setBool:NO
                                               forKey:@"TextViewBeginEditFirstTime"];
    }
    return YES;
}

- (BOOL)firstTimeExperience {
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"TextViewBeginEditFirstTime"];
}

#pragma mark - ColorSelectorViewControllerProtocol -

- (void)updateTextColor {
    UIColor *color = [UIColor colorWithRed:_note.textColor.redColor green:_note.textColor.greenColor blue:_note.textColor.blueColor alpha:_note.textColor.alphaColor];
    self.textView.textColor = color;
}

- (void)updateTextSize {
    self.textView.font = [UIFont systemFontOfSize:(CGFloat)_note.textSize];
}

- (void)customizeNoteViewControllerDidCancel:(CustomizeNoteViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)customizeNoteViewController:(CustomizeNoteViewController *)controller didFinishSelectColor:(TextColor *)color andTextSize:(NSInteger)textSize {
    _note.textColor = color;
    _note.textSize = textSize;
    
    [self updateTextColor];
    [self updateTextSize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
