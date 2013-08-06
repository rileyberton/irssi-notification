#!/usr/bin/env perl -w
#
# This is a simple irssi script to send messages to notification center in mac os x 10.8 and greater
# it will send a notification when your /hilights fire and when you receive private messages.
# Based on the original growl script by Nelson Elhage and Toby Peterson.

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

$VERSION = '0.1';
%IRSSI = (
	authors		=>	'Riley Berton',
	contact		=>	'https://github.com/rileyberton/irssi-notification',
	name		=>	'irssi-notification',
	description	=>	'Sends out notification center messages.  Relies on terminal-notifier.app (https://github.com/alloy/terminal-notifier)',
	license		=>	'BSD',
	url		=>	'https://github.com/rileyberton/irssi-notification'
);

# Notification Settings
Irssi::settings_add_bool($IRSSI{'name'}, 'nc_show_privmsg', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'nc_show_hilight', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'nc_show_notify', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'nc_show_topic', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'nc_reveal_privmsg', 0);

sub cmd_help {
	Irssi::print('irssi-notification can be configured with these settings:');

	Irssi::print('%WNotification Settings%n');
	Irssi::print('  %ync_show_privmsg%n :    Notify about private messages.');
	Irssi::print('  %ync_reveal_privmsg%n :  Include private messages in notification.');
	Irssi::print('  %ync_show_hilight%n :    Notify when your name is hilighted.');
	Irssi::print('  %ync_show_topic%n :      Notify about topic changes.');
	Irssi::print('  %ync_show_notify%n :     Notify when someone on your away list joins or leaves.');
}

sub cmd_nc_net_test {
	nc_notify(
		Title => "Test",
		Message => "This is a test.\n"
	);
} 

sub sig_message_private ($$$$) {
	return unless Irssi::settings_get_bool('nc_show_privmsg');

	my ($server, $data, $nick, $address) = @_;
	
	my $message = "private message";
	$message = "$data" if (Irssi::settings_get_bool('nc_reveal_privmsg'));

	nc_notify(
		Title => "$nick",
		Message => "$message"
	);
}

sub sig_print_text ($$$) {
	return unless Irssi::settings_get_bool('nc_show_hilight');

	my ($dest, $text, $stripped) = @_;
	
	if ($dest->{level} & MSGLEVEL_HILIGHT) {
		
		nc_notify(
			Title => "$dest->{target}",
			Message => "$stripped"
		);
	}
}

sub sig_notify_joined ($$$$$$) {
	return unless Irssi::settings_get_bool('nc_show_notify');
	
	my ($server, $nick, $user, $host, $realname, $away) = @_;
	
	nc_notify(
		Title => "$realname" || "$nick",
		Message => "<$nick!$user\@$host>\nHas joined $server->{chatnet}"
	);
}

sub sig_notify_left ($$$$$$) {
	return unless Irssi::settings_get_bool('nc_show_notify');
	
	my ($server, $nick, $user, $host, $realname, $away) = @_;
	
	nc_notify(
		Title => "$realname" || "$nick",
		Message => "<$nick!$user\@$host>\nHas left $server->{chatnet}"
	);
}

#"message topic", SERVER_REC, char *channel, char *topic, char *nick, char *address
sub sig_message_topic {
	return unless Irssi::settings_get_bool('nc_show_topic');
	my($server, $channel, $topic, $nick, $address) = @_;
	
	nc_notify(
		Title => "$channel",
		Message => "Topic for $channel: $topic"
	);
}

sub nc_notify {
	my (%args) = @_;
	
	my @list; 
	
	foreach my $key (keys %args)
	{
		if ($key eq 'Title') {
			push(@list, "'". $args{$key} . "'");
		}
		if ($key eq 'Message') {
			push(@list, "'" .$args{$key} . "'");
		}	
	}
	system("/Users/rberton/src/irssi-notification/tn.sh", @list);
}

Irssi::command_bind('nc-help',      'cmd_help');
Irssi::command_bind('nc-test',        'cmd_nc_net_test');

Irssi::signal_add_last('message private',   'sig_message_private');
Irssi::signal_add_last('print text',        'sig_print_text');
Irssi::signal_add_last('notifylist joined', 'sig_notify_joined');
Irssi::signal_add_last('notifylist left',   'sig_notify_left');
Irssi::signal_add_last('message topic',     'sig_message_topic');

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded (/nc-help for help. /nc-test to test.)');
