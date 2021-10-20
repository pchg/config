#!/usr/bin/rebol -qs
rebol []
parse read http://www.postgresql.org/ [ thru "pgFrontLatestReleasesWrap" thru "<b>" copy ver to "</b>" thru "&middot;" copy dat to "&middot;" to end]
print rejoin ["PostgreSQL " ver "  est sortie le " dat "!"]
