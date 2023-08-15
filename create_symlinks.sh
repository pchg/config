#!/bin/bash
config_dir=$(pwd)
echo "Creation of symlinks in \$HOME directory ($HOME), pointing to various configuration files in 'config' current directory (\"$config_dir\")"
cd "$HOME"
shopt -s dotglob nullglob
timestamp=$(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g')
echo "$timestamp"
for f in "$config_dir"/*; do
  case $f in
    ".git" | "README.md" | "create_symlinks.sh" | "tectri.ini" )
                                 # on ne fait que dalle pour ceux-là       # do nothing on these files/directories
      echo "$f ignoré"
      ;;
   ".mc"    )                    # Cas particulier de .mc
      if [[ -a $HOME/.config/mc ]]; then
        mv "$HOME"/.config/mc "$HOME"/.config/mc.old_"$timestamp"
      fi
      ln -s "$config_dir"/.mc ~/.config/mc
      ;;
   *        )                    # les autres, on les traite               # process other ones
      echo "$f"
      if [[ -e "$f" ]]; then     # si f existe                             # if f exists
        mv "$f" "$f".old_"$timestamp"  # on le renomme .old_horodaté             # it is renamed to .old_timestamped
      fi
      ln -s "$config_dir"/"$f" .     # et puis on fait un lien symbolique      # otherwise or not, make a symlink
	  ;;
  esac
done


# remove unwanted symlinks (TODO can be vastly improved)

