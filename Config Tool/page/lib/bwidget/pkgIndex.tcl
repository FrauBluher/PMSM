
# @@ Meta Begin
# Package BWidget 1.9.5
# Meta activestatetags ActiveTcl Public
# Meta as::author      {Jeff Hobbs} {Damon Courtney}
# Meta as::build::date 2012-02-07
# Meta as::origin      http://sourceforge.net/projects/tcllib
# Meta category        Widget set
# Meta description     The BWidget Toolkit is a high-level widget set for
# Meta description     Tcl/Tk. They feature a professional look and feel
# Meta description     and don't require a compiled extension library.
# Meta license         BSD
# Meta platform        tcl
# Meta recommend       {Tk 8.5a6}
# Meta recommend       {tile 0.6 1}
# Meta require         {Tcl 8.1.1}
# Meta require         {Tk 8.3}
# Meta subject         bwidget widget toolkit Tk megawidget
# Meta summary         A suite of megawidgets for Tk
# @@ Meta End


if {![package vsatisfies [package provide Tcl] 8.1]} return

package ifneeded BWidget 1.9.5 [string map [list @ $dir] {
        # ACTIVESTATE TEAPOT-PKG BEGIN REQUIREMENTS

        package require Tcl 8.1.1
        package require Tk 8.3

        # ACTIVESTATE TEAPOT-PKG END REQUIREMENTS

          set dir {@}
        eval "package require Tk 8.1.1;\
            [list tclPkgSetup $dir BWidget 1.9.5 {
        {arrow.tcl source {ArrowButton ArrowButton::create ArrowButton::use}}
        {labelframe.tcl source {LabelFrame LabelFrame::create LabelFrame::use}}
        {labelentry.tcl source {LabelEntry LabelEntry::create LabelEntry::use}}
        {bitmap.tcl source {Bitmap::get Bitmap::use}}
        {button.tcl source {Button Button::create Button::use}}
        {buttonbox.tcl source {ButtonBox ButtonBox::create ButtonBox::use}}
        {combobox.tcl source {ComboBox ComboBox::create ComboBox::use}}
        {label.tcl source {Label Label::create Label::use}}
        {entry.tcl source {Entry Entry::create Entry::use}}
        {pagesmgr.tcl source {PagesManager PagesManager::create PagesManager::use}}
        {notebook.tcl source {NoteBook NoteBook::create NoteBook::use}}
        {panedw.tcl source {PanedWindow PanedWindow::create PanedWindow::use}}
        {scrollw.tcl source {ScrolledWindow ScrolledWindow::create ScrolledWindow::use}}
        {scrollview.tcl source {ScrollView ScrollView::create ScrollView::use}}
        {scrollframe.tcl source {ScrollableFrame ScrollableFrame::create ScrollableFrame::use}}
        {panelframe.tcl source {PanelFrame PanelFrame::create PanelFrame::use}}
        {progressbar.tcl source {ProgressBar ProgressBar::create ProgressBar::use}}
        {progressdlg.tcl source {ProgressDlg ProgressDlg::create ProgressDlg::use}}
        {passwddlg.tcl source {PasswdDlg PasswdDlg::create PasswdDlg::use}}
        {dragsite.tcl source {DragSite::register DragSite::include DragSite::use}}
        {dropsite.tcl source {DropSite::register DropSite::include DropSite::use}}
        {separator.tcl source {Separator Separator::create Separator::use}}
        {spinbox.tcl source {SpinBox SpinBox::create SpinBox::use}}
        {statusbar.tcl source {StatusBar StatusBar::create StatusBar::use}}
        {titleframe.tcl source {TitleFrame TitleFrame::create TitleFrame::use}}
        {mainframe.tcl source {MainFrame MainFrame::create MainFrame::use}}
        {listbox.tcl source {ListBox ListBox::create ListBox::use}}
        {tree.tcl source {Tree Tree::create Tree::use}}
        {color.tcl source {SelectColor SelectColor::menu SelectColor::dialog SelectColor::setcolor}}
        {dynhelp.tcl source {DynamicHelp::configure DynamicHelp::use DynamicHelp::register DynamicHelp::include DynamicHelp::add DynamicHelp::delete}}
        {dialog.tcl source {Dialog Dialog::create Dialog::use}}
        {messagedlg.tcl source {MessageDlg MessageDlg::create MessageDlg::use}}
        {font.tcl source {SelectFont SelectFont::create SelectFont::use SelectFont::loadfont}}
        {widgetdoc.tcl source {Widget::generate-doc Widget::generate-widget-doc}}
        {wizard.tcl source {Wizard Wizard::create Wizard::use SimpleWizard ClassicWizard}}
        {xpm2image.tcl source {xpm-to-image}}
        }]; \
        	[list namespace eval ::BWIDGET {}]; \
        	[list set ::BWIDGET::LIBRARY $dir]; \
            [list source [file join $dir widget.tcl]]; \
            [list source [file join $dir init.tcl]]; \
            [list source [file join $dir utils.tcl]];"

        # ACTIVESTATE TEAPOT-PKG BEGIN DECLARE

        package provide BWidget 1.9.5

        # ACTIVESTATE TEAPOT-PKG END DECLARE
    }]
