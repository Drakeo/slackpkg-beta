/^[a-z].*\/([a-zA-Z0-9_]+)-.*tgz:.* ([Ad]dded|[Ss]plit|[Rr]enamed|[Mm]oved).*/ {
	INPUT=$1
	fs=FS
	FS="/" ; OFS="/"
	$0=INPUT
	FULLPACK=$NF
	FS="-" ; OFS="-"
	$0=FULLPACK
	NF=NF-3
	FS=fs
	CONTINUE=no
	print $0
}

/^[a-z].*\/([a-zA-Z0-9_]+)-.*tgz: *$/ {
	INPUT=$1
	fs=FS
	FS="/" ; OFS="/"
	$0=INPUT
	FULLPACK=$NF
	FS="-" ; OFS="-"
	$0=FULLPACK
	NF=NF-3
	FS=fs
	CONTINUE=yes
	NAME=$0
}

/^ *([Ad]dded|[Ss]plit|[Rr]enamed|[Mm]oved).*/ {
	if ( CONTINUE==yes ) {
		print NAME
	}
	CONTINUE=no
}
