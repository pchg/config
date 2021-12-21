# coding= utf-8
try:
    import readline 
except ImportError:
    print("Module readline not available.")
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")

def run_clipboard_python_code():
	"Derived from the famous run_clipboard_rebol_code: a utility that automatically runs Rebol^WPython code when placed in the clipboard (or just highlighted text in X systems)."
	#2020_08_24__18_22_11 
	# Moui, faudra que je trouve comment accéder au presse-papier,
	# et comment exécuter du code arbitraire...
	pass

