### Aliases ###

alias broken-links='find . -xtype l'
alias checktime='ntpdate -q uk.pool.ntp.org'
alias chmod='chmod -v'
alias chown='chown -v'
alias cp='cp -aiv'
alias dd='dd bs=4M conv=fsync status=progress'
alias df='df --si'
alias du='du --si'
alias firefox='firefox -no-remote'
alias follow-from-current='tail -F -n 0'
alias follow-from-start='tail -F -n +1'
alias g++debug='g++ -Wall -Werror -O0 -ggdb'
alias g++warn='g++ -Wall -Werror'
alias git-branch='git checkout -b "${USER}-$(date +%Y%m%d-%H%M%S)"'
alias git-clone-min='git clone --depth 1 --single-branch'
alias git-commit-reuse='git commit --date="$(date)" -C'
alias git-commit-reuse-head='git commit --date="$(date)" --reuse-message=HEAD'
alias git-log='git log --graph'
alias git-log-diff-from='git log --graph HEAD --not'
alias git-log-diff-to='git log --graph ^HEAD'
alias grep-context='grep -C 5'
alias gunzip='gunzip -v'
alias gzip='gzip -v'
alias hexdump='hexdump -C'
alias less='less -iM'
alias ln='ln -v'
alias ls='ls -la --si --color=auto'
alias mplayer-bg='mplayer -subcp WINDOWS-1251'
alias mv='mv -iv'
alias netstat='netstat -aveep'
alias openssl-view-cert='openssl x509 -noout -text -in'
alias openssl-view-pub-key='openssl rsa -pubin -text -in'
alias openssl-view-private-key='openssl rsa -text -in'
alias orientate='find -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.jpe" -o -iname "*.jif" -o -iname "*.jfif" -o -iname "*.jfi" \) -print0 |
    xargs --null --no-run-if-empty jhead -autorot'
alias play-hum='play -n synth sine 150'
alias play-left-right-test='speaker-test -c 2 -t sine'
alias play-silence='play -n'
alias play-to-end='play --ignore-length'
alias pstree='pstree -paul'
alias qiv='qiv -Rm'
alias radiofip-play-live='play http://direct.fipradio.fr/live/fip-midfi.mp3'
alias radiovarna-play-live='play -t mp3 http://broadcast.masters.bg:8000/live'
alias reboot-to-bios='sudo systemctl reboot --firmware-setup'
alias rm='rm -v'
alias rmdir='rmdir -v'
alias rmdir-and-content='find "$(readlink -f .)" -delete'
alias rmdir-content='find -mindepth 1 -delete'
alias ro-files='find -type f -print0 |
    xargs --null --no-run-if-empty chmod --verbose a-w'
alias rsync-quick='rsync --archive --human-readable --itemize-changes --verbose --progress'
alias rsync-verify='rsync --archive --human-readable --itemize-changes --verbose --progress --checksum'

# Modify window allows for both precision and daylight saving time issues.
# But it's recommend to use checksum and avoid even copying timestamps to completely avoid these issues.
alias rsync-vfat-quick='rsync --recursive --human-readable --itemize-changes --verbose --progress --times --modify-window=3601'
alias rsync-vfat-verify='rsync --recursive --human-readable --itemize-changes --verbose --progress --times --checksum --modify-window=3601'

# jmtpfs is like vfat but doesn't set timestamps and requires --inplace to avoid some errors.
alias rsync-jmtpfs-quick='rsync --recursive --human-readable --itemize-changes --verbose --progress --inplace --omit-dir-times --size-only'
alias rsync-jmtpfs-verify='rsync --recursive --human-readable --itemize-changes --verbose --progress --inplace --omit-dir-times --checksum'

alias slideshow-all-monitor='feh --auto-zoom --hide-pointer --randomize --recursive --slideshow-delay=10 --draw-filename --fullscreen ~/Pictures/.'
alias slideshow-all-tv='feh --auto-zoom --hide-pointer --randomize --recursive --slideshow-delay=10 --draw-filename --borderless --image-bg=black --xinerama-index=1 ~/Pictures/.'
alias slideshow-favorites-monitor='feh --auto-zoom --hide-pointer --randomize --recursive --slideshow-delay=10 --draw-filename --fullscreen ~/Pictures/Favorites/.'
alias slideshow-favorites-tv='feh --auto-zoom --hide-pointer --randomize --recursive --slideshow-delay=10 --draw-filename --borderless --image-bg=black --xinerama-index=1 ~/Pictures/Favorites/.'
alias smbclient-joli='smbclient -U Mark \\\\192.168.0.4\\shared'
alias sox='sox -V --no-clobber'
alias ssh='ssh -Y'
alias umount-iso='sudo umount ~/Mount/.'
alias utf16-cat='iconv -f UTF-16'
alias where='type -a'
alias wodim='wodim -v'
alias zless='zless -iM'

### Shell functions ###

decrypt-file-to-file()
{
    [[ $# -eq 2 ]] || return $?
    [[ -f "${1}" ]] || return $?
    [[ ! -e "${2}" ]] || return $?

    gpg --decrypt --output "${2}" -- "${1}" || return $?
}

decrypt-file-to-file-old()
{
    [[ $# -eq 2 ]] || return $?
    [[ -f "${1}" ]] || return $?
    [[ ! -e "${2}" ]] || return $?

    openssl enc -aes256 -pbkdf2 -d -in "${1}" -out "${2}" || return $?
}

decrypt-file-to-ramdisk()
{
    [[ $# -eq 1 ]] || return $?
    [[ -f "${1}" ]] || return $?

    local ramdisk=~/RamDisk/.
    [[ -d "${ramdisk}" ]] || return $?

    local base="$(basename "${1}" .gpg)"
    [[ -n "${base}" ]] || return $?

    decrypt-file-to-file "${1}" "${ramdisk}/${base}" || return $?
}

decrypt-file-to-stdout()
{
    [[ $# -eq 1 ]] || return $?
    [[ -f "$1" ]] || return $?

    gpg --decrypt -- "${1}" || return $?
}

decrypt-file-to-less()
{
    decrypt-file-to-stdout $@ | less --ignore-case --LONG-PROMPT
}

decrypt-and-untar-file-to-ramdisk()
{
    [[ $# -eq 1 ]] || return $?
    [[ -f "${1}" ]] || return $?

    local ramdisk=~/RamDisk/.
    [[ -d "${ramdisk}" ]] || return $?

    gpg --decrypt -- "${1}" | tar -C "${ramdisk}" -x --verbose || return $?
}

decrypt-file-for()
{
    [[ $# -ge 2 ]] || return $?
    [[ -f "${1}" ]] || return $?
    type -a "${2}" || return $?

    local target_file="${1}"
    shift

    local ramdisk=~/RamDisk/.
    [[ -d "${ramdisk}" ]] || return $?

    local base="$(basename "${target_file}" .gpg)"
    [[ -n "${base}" ]] || return $?

    decrypt-file-to-file "${target_file}" "${ramdisk}/${base}" || return $?

    "${@}" "${ramdisk}/${base}" || return $?

    mv --interactive --verbose -- "${target_file}" "${target_file}.old" || return $?
    encrypt-file-to-file "${ramdisk}/${base}" "${target_file}"  || return $?
    rm --verbose -- "${ramdisk}/${base}" || return $?
}

decrypt-file-for-edit()
{
    decrypt-file-for "${1}" code --wait --new-window || return $?
}

decrypt-file-for-grisbi()
{
    decrypt-file-for "${1}" grisbi || return $?
}

decrypt-file-for-office()
{
    decrypt-file-for "${1}" libreoffice || return $?
}

edit-finances()
{
    decrypt-file-for-grisbi "${HOME}/Documents/Finances.gsb.gpg" || return $?
}

encrypt-file-to-file()
{
    [[ $# -eq 2 ]] || return $?
    [[ -f "${1}" ]] || return $?
    [[ ! -e "${2}" ]] || return $?

    gpg --symmetric --output "${2}" "${1}" || return $?
}

generate-replay-gain-track-tags()
{
    find -type f -print0 | xargs --null -I{} id3convert --v1tag -- {}
    find -type f -print0 | xargs --null -I{} replaygain --no-album -- {}
}

git-worktree-add()
{
    [[ -d '.git' ]] || return $?
    git worktree add -- "../$(basename -- "$(pwd)")-alt" || return $?
}

git-worktree-remove()
{
    [[ -d '.git' ]] || return $?
    git worktree remove -- "../$(basename -- "$(pwd)")-alt" || return $?
}

mount-iso()
{
    [[ $# -eq 1 ]] || return $?
    [[ -f "$1" ]] || return $?

    sudo mount -o loop,ro "$1" ~/Mount/. || return $?
}

openssl-gen-key-pair()
{
    [[ ! -e 'private.pem' ]] || return $?
    [[ ! -e 'public.pem' ]] || return $?
    openssl genrsa -aes256 -out private.pem 2048 || return $?
    openssl rsa -in private.pem -outform PEM -pubout -out public.pem || return $?
}

openssl-sign()
{
    [[ $# -eq 2 ]] || return $?
    [[ -f "$1" ]] || return $?
    [[ -f "$2" ]] || return $?
    [[ ! -e "${1}.sha256" ]] || return $?
    openssl dgst -sha256 -sign "$2" -out "${1}.sha256" "$1" || return $?
}

openssl-verify-signature()
{
    [[ $# -eq 2 ]] || return $?
    [[ -f "$1" ]] || return $?
    [[ -f "$2" ]] || return $?
    [[ -f "${1}.sha256" ]] || return $?
    openssl dgst -sha256 -verify "$2" -signature "${1}.sha256" "$1" || return $?
}

password-generate()
{
    [[ $# -eq 2 ]] || return $?
    (( $1 > 0 )) || return $?
    [[ -n $2 ]] || return $?
    < /dev/urandom tr --delete --complement "$2" | head --bytes="$1"
    echo
}

password-generate-alnum()
{
    [[ $# -eq 1 ]] || return $?
    password-generate "$1" "[:alnum:]"
}

password-generate-alnumsym()
{
    [[ $# -eq 1 ]] || return $?
    password-generate "$1" '[:alnum:]!"$%^&*()-=_+[]{};#:@~,./<>?'
}

password-generate-pin()
{
    password-generate 4 0-9
}

show-secrets()
{
    decrypt-file-to-less "${HOME}/Documents/Secrets.txt.gpg" || return $?
}

split-file()
{
    [[ $# -ge 1 && $# -le 2 ]] || {
        echo >&2 "ERROR: Expected 1-2 argument(s), received $#."
        return 1
    }

    local cmd="split --verbose"
    [[ -z "$2" ]] || cmd="${cmd} -b $2"
    cmd="${cmd} \"$1\" \"$1.\""
    eval ${cmd}
}

unzip-to-ramdisk()
{
    [[ $# -eq 1 ]] || {
        echo >&2 "ERROR: Expected 1 argument(s), received $#."
        return 1
    }
    [[ -f "$1" ]] || {
        echo >&2 "ERROR: '$1' is not a file."
        return 1
    }

    unzip "$1" -d ~/RamDisk/. || {
        echo >&2 "ERROR: Failed to extract ($?)."
        return 1
    }
}

### Non-persistent settings ###

set -P
set -o pipefail
umask 0077

# Choose a colour so that the filename part of grep output is more readable.
export GREP_COLORS="fn=33"

PS1_ORIGINAL="${PS1_ORIGINAL:-${PS1}}"
PS1_ORIGINAL_MINUS_SUFFIX=${PS1_ORIGINAL%\\$ }
PS1="--\n\$(RET=\$?
    [[ \$RET -eq 0 ]] || echo -n \"\[\e[1;31m\]\"
    echo -n \"\$RET\") \t\[\e[0;m\]\n\$(
    [[ \$(id --user) -ne 0 ]] ||
    echo -n \"\[\e[1;31m\]\")${PS1_ORIGINAL_MINUS_SUFFIX}\[\e[0;m\]\n$ "

case ":${PATH:=${HOME}/Backup/bin}:" in
    *":${HOME}/Backup/bin:"*) ;;
    *) PATH="${PATH}:${HOME}/Backup/bin" ;;
esac

# https://github.com/magicmonty/bash-git-prompt
if [[ -e "${HOME}/.bash-git-prompt/gitprompt.sh" ]]
then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_FETCH_REMOTE_STATUS=0
    source "${HOME}/.bash-git-prompt/gitprompt.sh"
fi

# Accept default merge-commit messages.
# Preferable to using an alias for git merge since it maintains command-line auto-completion.
export GIT_MERGE_AUTOEDIT="no"

# Keep full bash command-line history.
export HISTSIZE="-1"
export HISTFILESIZE="-1"

# Media-PC only.
PATH="${PATH}:${HOME}/Linux-main/Scripts"
