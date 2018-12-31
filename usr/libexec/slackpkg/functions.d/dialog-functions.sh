# Dialog functions
# Original functions from slackpkg modified by Marek Wodzinski (majek@mamy.to)
#

# Show the lists and asks if the user want to proceed with that action
# Return accepted list in $SHOWLIST
#
if [ "$DIALOG" = "on" ] || [ "$DIALOG" = "ON" ]; then
	function showlist() {
		if [ "$ONOFF" != "off" ]; then
			ONOFF=on
		fi
		rm -f $TMPDIR/dialog.tmp
		
		if [ "$2" = "upgrade" ]; then
			ls -1 /var/log/packages > $TMPDIR/tmplist
			for i in $1; do
				BASENAME=`cutpkg $i`
				PKGFOUND=`grep -m1 -e "^${BASENAME}-[^-]\+-\(noarch\|${ARCH}\)" $TMPDIR/tmplist`.tgz
				echo "$i \"\" $ONOFF \"currently installed: $PKGFOUND\"" >>$TMPDIR/dialog.tmp
			done
			HINT="--item-help"
		else
			for i in $1; do
				echo "$i \"\" $ONOFF" >>$TMPDIR/dialog.tmp
			done
			HINT=""
		fi
		if [ `wc -c $TMPDIR/dialog.tmp | cut -f1 -d\ ` -ge 19500 ]; then
			mv $TMPDIR/dialog.tmp $TMPDIR/dialog2.tmp
			awk '{ NF=3 ; print $0 }' $TMPDIR/dialog2.tmp > $TMPDIR/dialog.tmp
			HINT=""
		fi
		dialog --title $2 --backtitle "slackpkg $VERSION" $HINT --checklist "Choose packages to $2:" 19 70 13 --file $TMPDIR/dialog.tmp 2>$TMPDIR/dialog.out
		dialog --clear
		SHOWLIST=`cat $TMPDIR/dialog.out | tr -d \"`
		rm -f $TMPDIR/dialog.*
		if [ -z "$SHOWLIST" ]; then
			echo "No packages selected for $2, exiting."
			cleanup
		fi
	}
fi
