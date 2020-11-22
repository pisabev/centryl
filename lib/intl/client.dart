import 'package:intl/intl.dart';

String Tomorrow() => Intl.message('Tomorrow', name: 'Tomorrow');
String Today() => Intl.message('Today', name: 'Today');
String Yesterday() => Intl.message('Yesterday', name: 'Yesterday');
String One_week_back() => Intl.message('One week back', name: 'One_week_back');
String This_week() => Intl.message('This week', name: 'This_week');
String Last_week() => Intl.message('Last week', name: 'Last_week');
String One_month_back() =>
    Intl.message('One month back', name: 'One_month_back');
String This_month() => Intl.message('This month', name: 'This_month');
String Last_month() => Intl.message('Last month', name: 'Last_month');
String One_year_back() => Intl.message('One year back', name: 'One_year_back');
String This_year() => Intl.message('This year', name: 'This_year');
String Last_year() => Intl.message('Last year', name: 'Last_year');
String All() => Intl.message('All', name: 'All');
String Month() => Intl.message('Month', name: 'Month');
String Week() => Intl.message('Week', name: 'Week');
String Day() => Intl.message('Day', name: 'Day');

String Window() => Intl.message('Window', name: 'Window');

String Choose_period() =>
    Intl.message('- Choose period -', name: 'Choose_period');
String Period() => Intl.message('Period', name: 'Period');
String Group_by() => Intl.message('Group by', name: 'Group_by');
String days() => Intl.message('days', name: 'days');
String months() => Intl.message('months', name: 'months');
String years() => Intl.message('years', name: 'years');
String today() => Intl.message('today', name: 'today');
String empty() => Intl.message('empty', name: 'empty');
String done() => Intl.message('done', name: 'done');

String Yes() => Intl.message('Yes', name: 'Yes');
String No() => Intl.message('No', name: 'No');
String Warning() => Intl.message('Warning', name: 'Warning');
String Error() => Intl.message('Error', name: 'Error');
String Exception() => Intl.message('Exception', name: 'Exception');
String Permission() => Intl.message('Permission', name: 'Permission');
String Work_exception() => Intl.message('Work Exception',
    name: 'Work_exception');
String OK() => Intl.message('OK', name: 'OK');

String Total() => Intl.message('Total', name: 'Total');
String Average() => Intl.message('Average', name: 'Average');
String Maximum() => Intl.message('Maximum', name: 'Maximum');
String Minimum() => Intl.message('Minimum', name: 'Minimum');

String File_manager() => Intl.message('File manager', name: 'File_manager');
String New_folder() => Intl.message('New folder', name: 'New_folder');
String Folders() => Intl.message('Folders', name: 'Folders');
String Move_to() => Intl.message('Move to', name: 'Move_to');
String Add_folder() => Intl.message('Add folder', name: 'Add_folder');
String Edit_folder() => Intl.message('Edit folder', name: 'Edit_folder');
String Move_folder() => Intl.message('Move folder', name: 'Move_folder');
String Delete_folder() => Intl.message('Delete folder', name: 'Delete_folder');
String Add_member() => Intl.message('Add member', name: 'Add_member');
String Add_file() => Intl.message('Add file', name: 'Add_file');
String Delete_file() => Intl.message('Delete file', name: 'Delete_file');

String Open() => Intl.message('Open', name: 'Open');
String Notifications() => Intl.message('Notifications', name: 'Notifications');
String See_all() => Intl.message('See all', name: 'See_all');
String Delete() => Intl.message('Delete', name: 'Delete');
String No_new_messages() =>
    Intl.message('No new messages', name: 'No_new_messages');
String Fullscreen() => Intl.message('Fullscreen', name: 'Fullscreen');

String Calendar() => Intl.message('Calendar', name: 'Calendar');
String Messages() => Intl.message('Messages', name: 'Messages');

String more_events(dynamic how_many) =>
    Intl.message('+$how_many more', name: 'more_events', args: [how_many]);
String pages(dynamic from, dynamic to, dynamic total) => Intl.message(
    'current: $from - $to total:'
    ' $total',
    name: 'pages',
    args: [from, to, total]);
String Browser_refresh(int seconds) =>
    Intl.message('The browser will refresh in $seconds seconds!',
        name: 'Browser_refresh', args: [seconds]);

String Search_people() => Intl.message('Search people', name: 'Search_people');

String Call() => Intl.message('Call', name: 'Call');

String Calling() => Intl.message('Calling', name: 'Calling');

String Type_message() =>
    Intl.message('Type a message here', name: 'Type_message');

String Typing_message_single(String name) =>
    Intl.message('$name is typing...',
        name: 'Typing_message_single', args: [name]);

String Typing_message_many(String names) =>
    Intl.message('$names are typing...',
        name: 'Typing_message_many', args: [names]);

String Connection_timeout() =>
    Intl.message('Connection timeout', name: 'Connection_timeout');

String Save_and_close() =>
    Intl.message('Save and close', name: 'Save_and_close');
String Settings() => Intl.message('Settings', name: 'Settings');
String Save() => Intl.message('Save', name: 'Save');
String Continue() => Intl.message('Continue', name: 'Continue');
String Back() => Intl.message('Back', name: 'Back');
String Finish() => Intl.message('Finish', name: 'Finish');
String Deleted() => Intl.message('Deleted', name: 'Deleted');
String Drop() => Intl.message('Drop', name: 'Drop');
String Dropped() => Intl.message('Dropped', name: 'Dropped');
String Remove() => Intl.message('Remove', name: 'Remove');
String Removed() => Intl.message('Removed', name: 'Removed');
String Refresh() => Intl.message('Refresh', name: 'Refresh');
String Delete_warning() => Intl.message(
    'Are you sure? The item(s) will'
        ' be deleted!',
    name: 'Delete_warning');
String Close_warning() => Intl.message(
    'Are you sure? The item'
        ' is not saved!',
    name: 'Close_warning');

String Language() => Intl.message('Language', name: 'Language');
String Print() => Intl.message('Print', name: 'Print');
String Filter() => Intl.message('Filter', name: 'Filter');
String Filters() => Intl.message('Filters', name: 'Filters');
String Clean() => Intl.message('Clean', name: 'Clean');
String Lock() => Intl.message('Lock', name: 'Lock');
String Unlock() => Intl.message('Unlock', name: 'Unlock');
String Generate() => Intl.message('Generate', name: 'Generate');
String Uploaded() => Intl.message('Uploaded', name: 'Uploaded');
String Download() => Intl.message('Download', name: 'Download');
String Export() => Intl.message('Export', name: 'Export');

String Platform_stopped() =>
    Intl.message('The platform has been stopped!', name: 'Platform_stopped');
String Platform_started() =>
    Intl.message('The platform has been started!', name: 'Platform_started');
String Platform_updated() => Intl.message(
    'The platform has been started '
        'and updated!',
    name: 'Platform_updated');
String Platform_updated_refresh() => Intl.message(
    'The platform has been'
        ' started and updated, please hit F5 (Refresh) so the changes could take'
        ' effect!',
    name: 'Platform_updated_refresh');