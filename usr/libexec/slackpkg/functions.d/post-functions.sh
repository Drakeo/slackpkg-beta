showdiff() {
	BASENAME=$(basename $i .new)
	FILEPATH=$(dirname $i)
	FULLNAME="${FILEPATH}/${BASENAME}"

	if [ -e ${FULLNAME} ]; then
	    diff -u ${FULLNAME} ${FULLNAME}.new | $MORECMD
	else
	    echo "file $FULLNAME doesn't exist"
	fi
}

showmenu() {
	echo -e "$1 - \c"
	tput sc
	shift
	while [ $# -gt 0 ]; do
		echo -e "$1"
		tput rc
		shift
	done
}

mergenew() {
	BASENAME=$(basename $i .new)
	FILEPATH=$(dirname $i)
	FULLNAME="${FILEPATH}/${BASENAME}"

	if [ -e ${FULLNAME} ]; then
		GOEX=0
		while [ $GOEX -eq 0 ]; do
			showmenu $i "(V)iew merged file" "(M)erge interactively" "(I)nstall merged file" "(C)ancel"
			read ANSWER
			case $ANSWER in
				V|v)
					if [ -f ${FULLNAME}.smerge ]; then
						$MORECMD ${FULLNAME}.smerge 
					else
						echo -e "Nothing was merged yet..."
					fi
				;;
				M|m)
					rm -f ${FULLNAME}.smerge
					echo "Enter '?' in the prompt (%) to display help."
					cp -p ${FULLNAME}.new ${FULLNAME}.smerge # <- this is so that the installed merged file will have the same permissions as the .new file
					sdiff -s -o ${FULLNAME}.smerge ${FULLNAME} ${FULLNAME}.new
				;;
				C|c)
					rm -f ${FULLNAME}.smerge
					GOEX=1
				;;
				I|i)
					if [ -f ${FULLNAME}.smerge ]; then
						if [ -e ${FULLNAME} ]; then
							mv ${FULLNAME} ${FULLNAME}.orig
						fi
						mv ${FULLNAME}.smerge ${FULLNAME}
						rm -f ${FULLNAME}.new 
						GOEX=1
					else
						echo -e "Nothing was merged yet..."
					fi
				;;
			esac
		done
	else
		echo "file $FULLNAME doesn't exist"
	fi
}

overold() {
	BASENAME=$(basename $i .new)
	FILEPATH=$(dirname $i)
	FULLNAME="${FILEPATH}/${BASENAME}"

	if [ -e ${FULLNAME} ]; then
	    mv ${FULLNAME} ${FULLNAME}.orig
	fi
	mv ${FULLNAME}.new ${FULLNAME}
}

removeold() {
	rm $i
}

looknew() {

	# with ONLY_NEW_DOTNEW set, slackpkg will search only for
	# .new files installed in actual slackpkg's execution
	if [ "$ONLY_NEW_DOTNEW" = "on" ]; then
		ONLY_NEW_DOTNEW="-cnewer $TMPDIR/timestamp"
	else
		ONLY_NEW_DOTNEW=""
	fi

	echo -e "\nSearching for NEW configuration files"
	FILES=$(find /etc -name "*.new" ${ONLY_NEW_DOTNEW} \
		-not -name "rc.inet1.conf.new" \
		-not -name "group.new" \
		-not -name "passwd.new" \
		-not -name "shadow.new" \
		-not -name "gshadow.new" 2>/dev/null)
	if [ "$FILES" != "" ]; then
		echo -e "\n\
Some packages had new configuration files installed.
You have four choices:

	(K)eep the old files and consider .new files later

	(O)verwrite all old files with the new ones. The
	   old files will be stored with the suffix .orig

	(R)emove all .new files

	(P)rompt K, O, R selection for every single file
	
What do you want (K/O/R/P)?"
		answer	
		case $ANSWER in
			K|k)
				break
			;;
			O|o)
				for i in $FILES; do
					overold $i
				done
				break
			;;
			R|r)
				for i in $FILES; do
					removeold $i
				done
				break
			;;
			P|p)
				echo "Select what you want file-by-file"
				for i in $FILES; do
					GOEX=0
					while [ $GOEX -eq 0 ]; do
						echo
						showmenu $i "(K)eep" "(O)verwrite" "(R)emove" "(D)iff" "(M)erge"
						read ANSWER
						case $ANSWER in
							O|o)
								overold $i
								GOEX=1
							;;
							R|r)
								removeold $i
								GOEX=1
							;;
							D|d)
								showdiff $1
							;;
							M|m)
								mergenew $1
							;;
							K|k|*)
								GOEX=1
							;;
						esac
					done
				done
				break
			;;
			*)
				echo "OK! Your choice is nothing! slackpkg will Keep the old files for you to deal with later"
			;;
		esac
	else
		echo -e "\t\tNo .new files found."
	fi
}

lookkernel() {
	NEWKERNELMD5=$(md5sum /boot/vmlinuz 2>/dev/null)
	if [ "$KERNELMD5" != "$NEWKERNELMD5" ]; then
		echo -e "\n
Your kernel image was updated.  We highly recommend you run: lilo
Do you want slackpkg to run lilo now? (Y/n)"
		answer
		if [ "$ANSWER" != "n" ] && [ "$ANSWER" != "N" ]; then
			/sbin/lilo
		fi
	fi
}
