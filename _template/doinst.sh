
## Make it so config files are not overwritten
config() {
  NEW="$1"
  OLD="`dirname $NEW`/`basename $NEW .new`"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

## List of conf files to check
config etc/rc.d/rc.program.new

## Check if group and/or user exists
check_program_env() {
  def_uid=
  def_gid=
  PROGRAM_USER=
  #PROGRAM_HOME=
  # Confirm that the 'program' user and group exist
  grep -q "^$PROGRAM_USER:" /etc/group || groupadd -g $def_gid $PROGRAM_USER || exit 1
  grep -q "^$PROGRAM_USER:" /etc/passwd || useradd -c "program" -d /bin/false -g $PROGRAM_USER -u $def_uid $PROGRAM_USER || exit 1
  #grep -q "^$PROGRAM_USER:" /etc/passwd || useradd -c "program" -d $PROGRAM_HOME -g $PROGRAM_USER -u $def_uid $PROGRAM_USER || exit 1
}

check_program_env

## Update desktop database
if [ -x /usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database -q usr/share/applications
fi

if [ -x /usr/bin/update-mime-database ]; then
  /usr/bin/update-mime-database usr/share/mime > /dev/null 2>&1
fi

if [ -x /usr/bin/gtk-update-icon-cache ]; then
  if [ -e usr/share/icons/gnome/icon-theme.cache ]; then
    /usr/bin/gtk-update-icon-cache -f -q usr/share/icons/gnome > /dev/null 2>&1
  fi
fi

if [ -x /usr/bin/gtk-update-icon-cache ]; then
  if [ -e usr/share/icons/hicolor/icon-theme.cache ]; then
    /usr/bin/gtk-update-icon-cache -f -q usr/share/icons/hicolor > /dev/null 2>&1
  fi
fi

## Update X font indexes and the font cache:
if [ -x ./usr/bin/mkfontdir ]; then
  chroot . /usr/bin/mkfontscale /usr/share/fonts/TTF
  chroot . /usr/bin/mkfontdir /usr/share/fonts/TTF
fi
if [ -x ./usr/bin/fc-cache ]; then
  chroot . /usr/bin/fc-cache -f /usr/share/fonts/TTF
fi

## Make symlinks (generated by makepkg)
