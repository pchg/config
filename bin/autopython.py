#!/usr/bin/python3
# A utility that automatically runs Rebol^Wbash^Wpython code when placed in the clipboard (or just highlighted text in X systems).

# run_clipboard_rebol_code:    does      [ 
# ;Un utilitaire pour faire tourner automatiquement le code Rebol^Wbash^python surligné:
from os import popen
from time import sleep
timewait=0.2
changed=False
print(changed)

# wait-duration: :0:2
code_before=""
code=""
err=""
#  write clipboard:// ""
ret = popen('echo "" | xclip -i')

#  c: open/binary/no-wait [scheme: 'console]
#  print "*Autorebol running*, waiting for clipboard contents change..."
print("*Autopython running*, waiting for clipboard contents change...")
#  print "Press Ctrl-C to stop, and any key to suspend automatic execution of code in the clipboard..."
print("Press Ctrl-C to stop, and any key to suspend automatic execution of code in the clipboard...")
enroute=True

#  forever [
while True: #; do
    # Boucle guettant l'appui d'une touche: annulée pour le moment. 
    #   if not none? wait/all [c timewait] [
    #    print "Automatic clipboard code execution suspended.  Doing nothing."
    #    ask "press Enter to resume..."
    #    print "Automatic clipboard code execution resumed."
    #    print "Press Ctrl-C to stop, and any key to suspend automatic execution of code in the clipboard..."
    #    print "*Autorebol running*, waiting for clipboard contents change..."
    #   ]

    # code: copy read clipboard://
    code=popen('xclip -o').read()
    # if code != code_before [
    if (code != code_before):
      code_before=code
      print("#=======================================================")
      print("#========== Code from clipboard: ==========")
      print(code)
      print("#======== Code evaluation output: =========")
      # if error? try [ do load code ] [
      try:
          exec(code)# eval "$code"
          # TODO mettre le retour de l'évaluation dans le presse-papiers (et le notifier)
      except:
          print("#### code not valid ###")
          print("#######################")
      #fi #]
      print("#==========================================\n")
    #fi
    sleep(timewait)
#done

