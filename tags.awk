BEGIN {
	print "config system object-tag"
}

$0 ~ /^\s+\S+(;|\s{)$/ {
	out = gensub(/^\s*/, "\tedit \"", "g", $0)
	out = gensub(/(;| {)$/, "\"\n\tnext", "g", out)
}

out { # Si on a un buffer d'affichage on l'écrit
	print gensub(/\t/, "    ", "g", out)
	out = 0 # On clear le buffer un fois affiché
}

END {
	# Pour finir proprement
	print "end"
}
