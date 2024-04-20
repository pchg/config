#!/bin/bash

DEBUG=0
DEBUG=1
echo_debug() {
  if [[ ${DEBUG} -eq 1 ]]; then
    echo -n "$@"
  fi
}

# echo -e "Paste here text from python error output with traceback:"
echo -e "Select the text from python error output with traceback in the X clipboard, and press Enter..."
read
traceback_txt=$(xclip -o)


echo_debug $traceback_txt


# Example of such a traceback:
# Default value (for the time being):
# if [[ -z ${traceback_txt} ]]; then
# traceback_txt=$(cat <<-'BOF'
# GENE-MnC-LOGM-VM:~ # /usr/local/elan-python-3.10.5/bin/python3 -m eemc_cfg_intg
# Traceback ()
# GENE-MnC-LOGM-VM:~ # /usr/local/elan-python-3.10.5/bin/python3 -m eemc_cfg_intg
# Traceback (most recent call last):
#   File "/usr/local/elan-python-3.10.5/lib/python3.10/runpy.py", line 196, in _run_module_as_main
#     return _run_code(code, main_globals, None,
#   File "/usr/local/elan-python-3.10.5/lib/python3.10/runpy.py", line 86, in _run_code
#     exec(code, run_globals)
#   File "/usr/local/elan-python-3.10.5/lib/python3.10/site-packages/eemc_cfg_intg/__main__.py", line 5, in <module>
#     main()
#   File "/usr/local/elan-python-3.10.5/lib/python3.10/site-packages/eemc_cfg_intg/monitoring.py", line 97, in main
#     logger = EemcLogger("AIDE_Service", FacilityCode.SYSLOG)
#   File "/usr/local/elan-python-3.10.5/lib/python3.10/site-packages/eemc_fwk_cmmn/eemc_logger.py", line 33, in __init__
#     system_configuration = SystemConfiguration()
#   File "/usr/local/elan-python-3.10.5/lib/python3.10/site-packages/eemc_fwk_cmmn/configuration/system_configuration.py", line 30, in __init__
#     os.environ[SystemConfigurationVarEnv.ELAN_MC_ROOT_DIR.value], "logging", "log_level.conf"
#   File "/usr/local/elan-python-3.10.5/lib/python3.10/os.py", line 679, in __getitem__
#     raise KeyError(key) from None
# KeyError: 'ELANMCROOTDIR'
# GENE-MnC-LOGM-VM:~ # 
# BOF
# )
# fi

# echo_debug -e $traceback_txt
# echo_debug "~~~~~~~~~~~~~~~~~~~"
# echo_debug ${traceback_txt} | grep '^ *File "'
# echo_debug "~~~~~~~~~~~~~~~~~~~"


IFS=$'\n'
# echo coucou'
debug_edit="\n\${EDITOR:-vi} -o  "
i=1
regexp="^ *File .*"
for line in ${traceback_txt}; do
  echo_debug line: ${line}
  if [[ ${line} =~ ${regexp} ]]; then
    # echo "match!"
    stack_file=${line#* \"}
    stack_file=${stack_file%\", *}
    stack_line=${line#*\", line }
    stack_line=${stack_line%, *}
    echo_debug stack_file: $stack_file
    echo_debug stack_line: $stack_line
    if (( i == 1 )); then
      debug_edit+="-c 'e  ${stack_file} | ${stack_line}' "
    else
      debug_edit+="-c 'sp ${stack_file} | ${stack_line}' "
    fi
    # read
    i+=1
  fi
  echo_debug -e "\n"
  echo_debug $i
 done
debug_edit+="-c 'windo set nofoldenable' "
debug_edit+="-c 'windo set norelativenumber'"
echo ${debug_edit}

echo -e "\n# To edit all files at call stack lines (with vim syntax):${debug_edit}\n"

