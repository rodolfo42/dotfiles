#!/bin/bash -e

[ -f "/opt/homebrew/bin/brew" ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

export DOTFILES_BENCHMARK=1

if [ "$DOTFILES_BENCHMARK" -ge "1" ]; then
  if ! command -v gdate &> /dev/null; then
    echo "⚠️  DOTFILES_BENCHMARK disabled: gdate not available" >&2
    unset DOTFILES_BENCHMARK
    return
  fi

  # Timing setup - colors and initial checkpoint
  BASHRC_FIRST_CHECKPOINT=$(gdate +%s%3N)
  BASHRC_LAST_CHECKPOINT=$BASHRC_FIRST_CHECKPOINT

  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  PURPLE='\033[0;35m'
  CYAN='\033[0;36m'
  NC='\033[0m' # No Color
fi

# Function to log checkpoint with elapsed time
checkpoint() {
  if [ "$DOTFILES_BENCHMARK" -lt "2" ]; then
    return
  fi
  local current_time=$(gdate +%s%3N)
  local time_unit="ms"
  
  local section_name="$1"
  
  if [ -n "$BASHRC_LAST_CHECKPOINT" ]; then
    local elapsed=$((current_time - BASHRC_LAST_CHECKPOINT))
    
    # Choose color based on elapsed time
    local color
    if [ $elapsed -lt 10 ]; then
      color="$GREEN"
    elif [ $elapsed -lt 50 ]; then
      color="$YELLOW"
    else
      color="$RED"
    fi
    
    # Store elapsed data in arrays for later printing
    BASHRC_CHECKPOINT_NAMES+=("$section_name")
    BASHRC_CHECKPOINT_TIMES+=("$elapsed")
    BASHRC_CHECKPOINT_COLORS+=("$color")
  fi
  
  BASHRC_LAST_CHECKPOINT=$current_time
}

checkpoint "Initialization"

export DOTFILES_DIR=$(dirname $(readlink -n ~/.bashrc))

if [ -d "$DOTFILES_DIR/init.d/" ]; then
  for F in $DOTFILES_DIR/init.d/*; do
    if [ -r "$F" ]; then
      source $F
      checkpoint $F
    fi
  done
fi

# Final timing summary
if [ "$DOTFILES_BENCHMARK" -ge "1" ]; then
  final_time=$(gdate +%s%3N)
  total_elapsed=$((final_time - BASHRC_FIRST_CHECKPOINT))
  
  # Print all stored checkpoint data if benchmark level 2 or higher
  if [ "$DOTFILES_BENCHMARK" -ge "2" ] && [ ${#BASHRC_CHECKPOINT_NAMES[@]} -gt 0 ]; then
    echo -e "${CYAN}🚀 Startup timing: ${BASHRC_CHECKPOINT_NAMES[0]}${NC}" >&2
    for i in $(seq 1 $((${#BASHRC_CHECKPOINT_NAMES[@]} - 1))); do
      echo -e "${BASHRC_CHECKPOINT_COLORS[$i]}⏱️  ${BASHRC_CHECKPOINT_NAMES[$i]}: ${BASHRC_CHECKPOINT_TIMES[$i]}ms${NC}" >&2
    done
  fi
  
  echo -e "🏁 Total startup time: ${GREEN}${total_elapsed}ms${NC}" >&2

  # Clean up timing variables
  unset BASHRC_FIRST_CHECKPOINT BASHRC_LAST_CHECKPOINT BASHRC_CHECKPOINT_NAMES BASHRC_CHECKPOINT_TIMES BASHRC_CHECKPOINT_COLORS RED GREEN YELLOW BLUE PURPLE CYAN NC checkpoint final_time total_elapsed
fi