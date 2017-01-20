BEGIN {
	in_block=0
	print "config firewall addrgrp"
}
$0 ~ /{$/ {
	if (in_block) { print "    next" } # on affiche 'next' que lorsque l'on est entre deux blocs
	in_block=1

	out = "\tedit "$1
}

$0 ~ /^\s*static \[/ {
	out = "\t\tset member"
	# Pour chaque argument Palo (on commence à 3 pour ne pas prendre 'static ['
	for (i = 3; i <= NF ; i++) {
		out = out" \""$i"\""
	}

	gsub("];", "", out) # On nettoie la sortie de ce que le parser awk a laissé passer
}

$0 ~ /^\s*tag \[?/ {
	out = "\t\tset tags"
	# Pour chaque argument Palo (on commence à 3 pour ne pas prendre 'tag ['
	for (i = 2; i <= NF ; i++) {
		if ($i == "[") { continue }
		out = out" \""$i"\""
	}

	out = gensub(/[\[\];]/, "", "g", out) # On nettoie la sortie de ce que le parser awk a laissé passer
}

$0 ~ /^\s*description / {
	out = gensub(/^\s*description/, "\t\tset comment", "g", $0)
}

out { # Si on a un buffer d'affichage on l'écrit
	print gensub(/\t/, "    ", "g", out)
	out = 0 # On clear le buffer un fois affiché
}

END {
	# Pour finir proprement
	print "    next"
	print "end"
}
