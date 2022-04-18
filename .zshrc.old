# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install                                                     
HISTFILE=~/.histfile                                                                          
HISTSIZE=6900                                                                                 
SAVEHIST=6900                                                                                 
bindkey -e                                                                                    
# End of lines configured by zsh-newuser-install                                              
alias ll='ls -al --color'                                                                     
# The following lines were added by compinstall                                               
zstyle :compinstall filename '/home/akira.zshrc '                                             
                                                                                              
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh             
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh                     
                                                                                              
autoload -Uz compinit                                                                         
compinit                                                                                      
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' 
# End of lines added by compinstall                                                           
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
