#!/bin/bash
#
# Helper functions for configuration and running logrotate.

# Resetting the default configuration file for
# repeated starts.
function resetConfigurationFile() {
  if [ -f "/usr/bin/logrotate.d/logrotate.conf" ]; then
    rm -f /usr/bin/logrotate.d/logrotate.conf
  else
    touch /usr/bin/logrotate.d/logrotate.conf
  fi

  cat >> /usr/bin/logrotate.d/logrotate.conf <<EOF
# deactivate mail
nomail

# move the log files to another directory?
${logrotate_olddir}
EOF
}

# Logrotate status file handling
readonly logrotate_logstatus=${LOGROTATE_STATUSFILE:-"/logrotate-status/logrotate.status"}

logrotate_olddir=""

function resolveOldDir() {
  if [ -n "${LOGROTATE_OLDDIR}" ]; then
    logrotate_olddir="olddir "${LOGROTATE_OLDDIR}
  fi
}

syslogger_command=""

function resolveSysloggerCommand() {
  local syslogger_tag=""

  if [ -n "${SYSLOGGER_TAG}" ]; then
    syslogger_tag=" -t "${SYSLOGGER_TAG}
  fi

  if [ -n "${SYSLOGGER}" ]; then
    syslogger_command="logger "${syslogger_tag}
  fi
}

logrotate_logfile_compression="nocompress"
logrotate_logfile_compression_delay=""

function resolveLogfileCompression() {
  if [ -n "${LOGROTATE_COMPRESSION}" ]; then
    logrotate_logfile_compression=${LOGROTATE_COMPRESSION}
    if [ ! "${logrotate_logfile_compression}" = "nocompress" ]; then
      logrotate_logfile_compression_delay="delaycompress"
    fi
  fi
}

logrotate_interval=${LOGROTATE_INTERVAL:-""}

logrotate_copies=${LOGROTATE_COPIES:-"5"}

logrotate_size=""

function resolveLogrotateSize() {
  if [ -n "${LOGROTATE_SIZE}" ]; then
    logrotate_size="size "${LOGROTATE_SIZE}
  fi
}

logrotate_autoupdate=true

function resolveLogrotateAutoupdate() {
  if [ -n "${LOGROTATE_AUTOUPDATE}" ]; then
    logrotate_autoupdate="$(echo ${LOGROTATE_AUTOUPDATE,,})"
  fi
}

logrotate_dateformat=${LOGROTATE_DATEFORMAT:-""}

resolveSysloggerCommand
resolveOldDir
resolveLogfileCompression
resolveLogrotateSize
resolveLogrotateAutoupdate
