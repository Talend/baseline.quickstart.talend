Writing System V init scripts for Red Hat Linux
===============================================

All System V init scripts are named /etc/rc.d/init.d/<servicename>
where <servicename> is the name of the service.  There must be no
".init" suffix.

This path will very likely be moved to /etc/init.d in the future.
Once Red Hat Linux 7.0 is installed, you can access scripts as
/etc/init.d/<servicename>, via symlinks.

Sample Script
=============

#!/bin/bash
#
#       /etc/rc.d/init.d/<servicename>
#
#       <description of the *service*>
#       <any general comments about this init script>
#
# <tags -- see below for tag definitions.  *Every line* from the top
#  of the file to the end of the tags section must begin with a #
#  character.  After the tags section, there should be a blank line.
#  This keeps normal comments in the rest of the file from being
#  mistaken for tags, should they happen to fit the pattern.>

# Source function library.
. /etc/init.d/functions

<define any local shell functions used by the code that follows>

start() {
        echo -n "Starting <servicename>: "
        <start daemons, perhaps with the daemon function>
        touch /var/lock/subsys/<servicename>
        return <return code of starting daemon>
}

stop() {
        echo -n "Shutting down <servicename>: "
        <stop daemons, perhaps with the killproc function>
        rm -f /var/lock/subsys/<servicename>
        return <return code of stopping daemon>
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        <report the status of the daemons in free-form format,
        perhaps with the status function>
        ;;
    restart)
        stop
        start
        ;;
    reload)
        <cause the service configuration to be reread, either with
        kill -HUP or by restarting the daemons, in a manner similar
        to restart above>
        ;;
    condrestart)
        <Restarts the servce if it is already running. For example:>
        [ -f /var/lock/subsys/<service> ] && restart || :
    probe)
        <optional.  If it exists, then it should determine whether
        or not the service needs to be restarted or reloaded (or
        whatever) in order to activate any changes in the configuration
        scripts.  It should print out a list of commands to give to
        $0; see the description under the probe tag below.>
        ;;
    *)
        echo "Usage: <servicename> {start|stop|status|reload|restart[|probe]"
        exit 1
        ;;
esac
exit $?

Notes:

- The restart and reload functions may be (and commonly are)
  combined into one test, vis:
    restart|reload)
- You are not prohibited from adding other commands; list all commands
  which you intend to be used interactively to the usage message.
- Notice the change in that stop() and start() are now shell functions.
  This means that restart can be implemented as
     stop
     start
  instead of
     $0 stop
     $0 start
  This saves a few shell invocations.

Functions in /etc/init.d/functions
=======================================

daemon  [ --check <name> ] [ --user <username>]
        [+/-nicelevel] program [arguments] [&]

        Starts a daemon, if it is not already running.  Does
        other useful things like keeping the daemon from dumping
        core if it terminates unexpectedly.

        --check <name>:
           Check that <name> is running, as opposed to simply the
           first argument passed to daemon().
        --user <username>:
           Run command as user <username>

killproc program [signal]

        Sends a signal to the program; by default it sends a SIGTERM,
        and if the process doesn't die, it sends a SIGKILL a few
        seconds later.

        It also tries to remove the pidfile, if it finds one.

pidofproc program

        Tries to find the pid of a program; checking likely pidfiles,
        and using the pidof program.  Used mainly from within other
        functions in this file, but also available to scripts.

status program

        Prints status information.  Assumes that the program name is
        the same as the servicename.


Tags
====

# chkconfig: <startlevellist> <startpriority> <endpriority>

        Required.  <startlevellist> is a list of levels in which
        the service should be started by default.  <startpriority>
        and <endpriority> are priority numbers.  For example:
        # chkconfig: 2345 20 80
        Read 'man chkconfig' for more information.

        Unless there is a VERY GOOD, EXPLICIT reason to the
        contrary, the <endpriority> should be equal to
        100 - <startpriority>

# description: <multi-line description of service>

        Required.  Several lines of description, continued with '\'
        characters.  The initial comment and following whitespace
        on the following lines is ignored.

# description[ln]: <multi-line description of service in the language \
#                  ln, whatever that is>

        Optional.  Should be the description translated into the
        specified language.

# processname:

        Optional, multiple entries allowed.  For each process name
        started by the script, there should be a processname entry.
        For example, the samba service starts two daemons:
        # processname: smdb
        # processname: nmdb

# config:

        Optional, multiple entries allowed.  For each static config
        file used by the daemon, use a single entry.  For example:
        # config: /etc/httpd/conf/httpd.conf
        # config: /etc/httpd/conf/srm.conf

        Optionally, if the server will automatically reload the config
        file if it is changed, you can append the word "autoreload" to
        the line:
        # config: /etc/foobar.conf autoreload

# pidfile:

        Optional, multiple entries allowed.  Use just like the config
        entry, except that it points at pidfiles.  It is assumed that
        the pidfiles are only updated at process creation time, and
        not later.  The first line of this file should be the ASCII
        representation of the PID; a terminating newline is optional.
        Any lines other than the first line are not examined.

# probe: true

        Optional, used IN PLACE of processname, config, and pidfile.
        If it exists, then a proper reload-if-necessary cycle may be
        acheived by running these commands:

        command=$(/etc/rc.d/init.d/SCRIPT probe)
        [ -n "$command" ] && /etc/rc.d/init.d/SCRIPT $command

        where SCRIPT is the name of the service's sysv init script.

        Scripts that need to do complex processing could, as an
        example, return "run /var/tmp/<servicename.probe.$$"
        and implement a "run" command which would execute the
        named script and then remove it.

        Note that the probe command should simply "exit 0" if nothing
        needs to be done to bring the service into sync with its
        configuration files.
