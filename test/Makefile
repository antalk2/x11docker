

all:

shellcheck-bash:
	for f in *.bash ; do printf "\n=== %s\n"  "shellcheck $$f"  ;  shellcheck --shell=bash $$f ; done

shellcheck-dash:
	for f in *.dash ; do printf "\n=== %s\n"  "shellcheck $$f"  ;  shellcheck  --norc --shell=dash $$f ; done

shellcheck-sh:
	for f in *.sh ; do printf "\n=== %s\n"  "shellcheck $$f"  ;  shellcheck --norc --shell=sh $$f ; done
