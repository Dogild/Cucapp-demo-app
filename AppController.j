/*
 * AppController.j
 * Cucapp-demo-app
 *
 * Created by You on July 10, 2014.
 * Copyright 2014, Your Company All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CPResponder+CuCapp.j"

var TableTestDragAndDropTableViewDataType = @"TableTestDragAndDropTableViewDataType";

@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow;
    @outlet CPTableView tableView;
    @outlet CPPopover   popover;
    @outlet CPButton    cancelButton;
    @outlet CPButton    addButton;
    @outlet CPButtonBar buttonBar;
    @outlet CPTextField nameField;

    @outlet CPWindow    externalWindow;
    @outlet CPButton    externalWindowButton;
    @outlet CPTextField externalWindowTextField;

    CPMutableArray      persons;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    persons = [];
    // This is called when the application is done loading.

    [[CPPlatformWindow alloc] initWithWindow:externalWindow];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things.

    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullPlatformWindow:YES];

    var buttonAddObject = [CPButtonBar plusButton];
    [buttonAddObject setButtonType:CPMomentaryChangeButton];
    [buttonAddObject setTarget:self];
    [buttonAddObject setAction:@selector(clickAddButtonBar:)];
    [buttonAddObject setKeyEquivalent:@"a"];
    [buttonAddObject setKeyEquivalentModifierMask:CPCommandKeyMask];
    [buttonAddObject setCucappIdentifier:@"cucappIdentifier-button-bar-add"];

    var buttonDeleteObject = [CPButtonBar minusButton];
    [buttonDeleteObject setButtonType:CPMomentaryChangeButton];
    [buttonDeleteObject setTarget:self];
    [buttonDeleteObject setAction:@selector(clickRemoveButtonBar:)];
    [buttonDeleteObject setCucappIdentifier:@"cucappIdentifier-button-bar-delete"]

    [buttonBar setButtons:[buttonAddObject, buttonDeleteObject]];

    [tableView registerForDraggedTypes:[CPArray arrayWithObjects:TableTestDragAndDropTableViewDataType]];
    [tableView setTarget:self];
    [tableView setDoubleAction:@selector(doubleClick:)];

    [nameField setCucappIdentifier:@"cucappIdentifier-field-name"];
    [cancelButton setCucappIdentifier:@"cucappIdentifier-button-cancel"];
    [addButton setCucappIdentifier:@"cucappIdentifier-button-add"];
    [tableView setCucappIdentifier:@"cucappIdentifier-tableView"];

    [externalWindowButton setCucappIdentifier:@"cucappIdentifier-button-external"];
    [externalWindowTextField setCucappIdentifier:@"cucappIdentifier-field-external"];
    [externalWindow setCucappIdentifier:@"cucappIdentifier-window-external"];

    [theWindow setCucappIdentifier:@"cucappIdentifier-window-main"];
}


#pragma mark -
#pragma mark ButtonBar action

- (void)doubleClick:(id)sender
{
    [popover showRelativeToRect:CGRectMakeZero() ofView:buttonBar preferredEdge:CPMinYEdge];
}

- (void)clickAddButtonBar:(id)sender
{
    [popover showRelativeToRect:CGRectMakeZero() ofView:sender preferredEdge:CPMinYEdge];
}

- (void)clickRemoveButtonBar:(id)sender
{
    if ([tableView selectedRow] == CPNotFound)
        return;

    [persons removeObjectAtIndex:[tableView selectedRow]];
    [tableView reloadData];
}


#pragma mark -
#pragma mark Popover action

- (IBAction)clickSendButtonPopover:(id)sender
{
    [persons addObject:[nameField stringValue]];
    [nameField setStringValue:@""];
    [popover close];

    [tableView reloadData];
}

- (IBAction)clickCancelButtonPopover:(id)sender
{
    [nameField setStringValue:@""];
    [popover close];
}

- (IBAction)openPlatformWindow:(id)sender
{
    [externalWindow makeKeyAndOrderFront:sender];
}

#pragma mark -
#pragma mark TableView Datasource

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
    return persons[aRowIndex];
}

- (CPInteger)numberOfRowsInTableView:(CPTableView)aTableView
{
    return [persons count];
}

// Drag and Drop methods.

- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pasteboard
{
    var encodedData = [CPKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pasteboard declareTypes:[CPArray arrayWithObject:TableTestDragAndDropTableViewDataType] owner:self];
    [pasteboard setData:encodedData forType:TableTestDragAndDropTableViewDataType];

    return YES;
}

- (CPDragOperation)tableView:(CPTableView)aTableView validateDrop:(id)info proposedRow:(CPInteger)row proposedDropOperation:(CPTableViewDropOperation)operation
{
    [aTableView setDropRow:row dropOperation:CPTableViewDropOn];
    return CPDragOperationMove;
}

- (BOOL)tableView:(CPTableView)aTableView acceptDrop:(id)info row:(CPInteger)row dropOperation:(CPTableViewDropOperation)operation
{
    var pasteboard = [info draggingPasteboard],
        encodedData = [pasteboard dataForType:TableTestDragAndDropTableViewDataType],
        sourceIndexes = [CPKeyedUnarchiver unarchiveObjectWithData:encodedData];

    if (row == [sourceIndexes firstIndex])
        return;

    var name = persons[[sourceIndexes firstIndex]];

    persons[row] = persons[row] + name;
    [persons removeObjectAtIndex:[sourceIndexes firstIndex]];

    return YES;
}

- (void)tableView:(CPTableView)aTableView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
    [aView setCucappIdentifier:(@"cucappIdentifier-tableView-cell-" + [aView stringValue])];
}

@end
