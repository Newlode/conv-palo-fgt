BEGIN {
	in_block=0
	print "config firewall address"
}
$0 ~ /{$/ {
	if (in_block) { print "    next" } # on affiche 'next' que lorsque l'on est entre deux blocs
	in_block=1

	out = "\tedit "$1
}

$0 ~ /^\s*ip-netmask / {
	out = "\t\tset subnet "$2
	out = gensub(/;$/, "", "g", out)

	# Si il n'y a pas de '/', on l'ajoute en /32
	if (out !~ "/") { out = out"/32" }

	# Si on sait déterminer la zone à partir de l'IP 
	if (out ~ "192.168.10." || out ~ "192.168.11.") {
		out = out"\n\t\tset associated-interface Orange"
	} else if ( out ~ "192.168.20." ) {
		out = out"\n\t\tset associated-interface Bleu"
	} else if ( out ~ "192.168.[1|2]2[3-8]." ) {
		out = out"\n\t\tset associated-interface Vert"
	}
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
